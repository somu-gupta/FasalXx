import 'package:flutter/material.dart';

import '../core/network/api_failure.dart';
import '../services/backend_repositories.dart';
import '../theme/app_theme.dart';
import '../widgets/fasalx_header.dart';

class CropScreen extends StatefulWidget {
  const CropScreen({super.key, this.initialCrop});

  final String? initialCrop;

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  final _fieldsRepository = const FieldRepository();
  final _recommendationRepository = const RecommendationRepository();
  late Future<_CropScreenData> _future;
  String? _targetSeason;
  bool _selecting = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_CropScreenData> _load() async {
    final fields = await _fieldsRepository.listFields();
    Map<String, dynamic>? summary;
    try {
      summary = await _fieldsRepository.summary();
    } catch (_) {
      summary = null;
    }

    Map<String, dynamic>? recommendation;
    final field = _bestField(fields);
    if (field != null) {
      recommendation = await _recommendationRepository.calculate(
        fieldId: field['id']?.toString() ?? '',
        targetSeason: _targetSeason,
      );
    }

    return _CropScreenData(
      fields: fields,
      summary: summary,
      selectedField: field,
      recommendation: recommendation,
    );
  }

  Map<String, dynamic>? _bestField(List<Map<String, dynamic>> fields) {
    if (fields.isEmpty) return null;
    final crop = widget.initialCrop?.toLowerCase();
    if (crop != null && crop.isNotEmpty) {
      for (final field in fields) {
        final selectedCrop = field['selected_crop']?.toString().toLowerCase();
        if (selectedCrop == crop) return field;
      }
    }
    return fields.first;
  }

  void _refresh() {
    setState(() => _future = _load());
  }

  Future<void> _selectCrop({
    required String fieldId,
    required Map<String, dynamic> recommendation,
  }) async {
    final id = recommendation['id']?.toString();
    final cropName = recommendation['crop_name']?.toString();
    if (id == null || id.isEmpty || cropName == null || cropName.isEmpty) {
      return;
    }

    setState(() => _selecting = true);
    try {
      await _recommendationRepository.select(
        fieldId: fieldId,
        recommendationId: id,
        cropName: cropName,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: const Duration(milliseconds: 2500), content: Text('$cropName selected for this field.')),
      );
      _refresh();
    } on ApiFailure catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(duration: const Duration(milliseconds: 2500), content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _selecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Scaffold(
      appBar: const FasalXHeader(),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FutureBuilder<_CropScreenData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final message = snapshot.error is ApiFailure
                ? (snapshot.error as ApiFailure).message
                : 'Could not load crop recommendations.';
            return _StateMessage(
              icon: Icons.cloud_off_outlined,
              title: 'Backend unavailable',
              message: message,
              actionLabel: 'Retry',
              onAction: _refresh,
            );
          }

          final data = snapshot.data!;
          if (data.fields.isEmpty) {
            return const _StateMessage(
              icon: Icons.add_location_alt_outlined,
              title: 'No fields registered',
              message:
                  'Add a field with location and area before calculating crop recommendations.',
            );
          }

          final field = data.selectedField!;
          final fieldId = field['id']?.toString() ?? '';
          final recommendations = data.recommendations;

          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              children: [
                Text(
                  widget.initialCrop == null
                      ? 'Crop Recommendations'
                      : '${widget.initialCrop} Recommendations',
                  style: TextStyle(
                    color: fx.textStrong,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                _FieldSummaryCard(field: field, summary: data.summary),
                const SizedBox(height: 14),
                _SeasonSelector(
                  value: _targetSeason,
                  onChanged: (value) {
                    _targetSeason = value;
                    _refresh();
                  },
                ),
                const SizedBox(height: 16),
                if (recommendations.isEmpty)
                  const _StateMessage(
                    icon: Icons.insights_outlined,
                    title: 'No recommendation returned',
                    message:
                        'The recommendation service responded but did not include crop cards for this field.',
                  )
                else
                  for (final item in recommendations) ...[
                    _RecommendationCard(
                      recommendation: item,
                      selecting: _selecting,
                      onSelect: () => _selectCrop(
                        fieldId: fieldId,
                        recommendation: item,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FieldSummaryCard extends StatelessWidget {
  const _FieldSummaryCard({required this.field, required this.summary});

  final Map<String, dynamic> field;
  final Map<String, dynamic>? summary;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    final area = field['area']?.toString() ?? '-';
    final selectedCrop = field['selected_crop']?.toString();
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field['name']?.toString() ?? 'Registered field',
            style: TextStyle(
              color: fx.textStrong,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          _InfoLine(label: 'Area', value: '$area acres'),
          _InfoLine(
            label: 'Selected crop',
            value: selectedCrop ?? 'Not selected',
          ),
          if (summary != null) ...[
            _InfoLine(
              label: 'Total fields',
              value: summary!['total_fields']?.toString() ?? '-',
            ),
            _InfoLine(
              label: 'Net profit estimate',
              value: _money(summary!['estimated_net_profit']),
            ),
          ],
        ],
      ),
    );
  }

  String _money(Object? value) {
    final amount = value is num ? value.round() : int.tryParse('$value') ?? 0;
    return amount <= 0 ? '-' : 'Rs $amount';
  }
}

class _SeasonSelector extends StatelessWidget {
  const _SeasonSelector({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = value ?? 'Auto';
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'Auto', label: Text('Auto')),
        ButtonSegment(value: 'Kharif', label: Text('Kharif')),
        ButtonSegment(value: 'Rabi', label: Text('Rabi')),
        ButtonSegment(value: 'Zaid', label: Text('Zaid')),
      ],
      selected: {selected},
      onSelectionChanged: (selection) {
        final season = selection.first;
        onChanged(season == 'Auto' ? null : season);
      },
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.recommendation,
    required this.selecting,
    required this.onSelect,
  });

  final Map<String, dynamic> recommendation;
  final bool selecting;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    final cropName = recommendation['crop_name']?.toString() ?? 'Crop';
    final score = recommendation['final_score'];
    final category = recommendation['category']?.toString() ?? 'Recommended';
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: fx.selectedFill,
                child: Icon(
                  Icons.eco_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cropName,
                      style: TextStyle(
                        color: fx.textStrong,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '$category${score == null ? '' : ' - score $score'}',
                      style: TextStyle(
                        color: fx.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            recommendation['why_this_crop']?.toString() ??
                'Backend recommendation for this field.',
            style: TextStyle(
              color: fx.textMuted,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: selecting ? null : onSelect,
            icon: selecting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_circle_outline),
            label: const Text('Select Crop'),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fx.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: fx.border),
      ),
      child: child,
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 54, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: fx.textStrong,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: fx.textMuted, height: 1.35),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class _CropScreenData {
  const _CropScreenData({
    required this.fields,
    required this.summary,
    required this.selectedField,
    required this.recommendation,
  });

  final List<Map<String, dynamic>> fields;
  final Map<String, dynamic>? summary;
  final Map<String, dynamic>? selectedField;
  final Map<String, dynamic>? recommendation;

  List<Map<String, dynamic>> get recommendations {
    final raw = recommendation;
    if (raw == null) return const [];
    return [
      for (final key in ['seasonal', 'horticulture'])
        if (raw[key] is List)
          for (final item in raw[key] as List)
            if (item is Map) Map<String, dynamic>.from(item),
    ];
  }
}
