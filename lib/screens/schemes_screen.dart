import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';
import '../widgets/fasalx_header.dart';

enum SchemeType { central, state }

enum SchemeFilter { all, central, state }

class SchemesScreen extends StatefulWidget {
  const SchemesScreen({super.key});

  @override
  State<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen> {
  SchemeFilter _selectedFilter = SchemeFilter.all;
  final List<SchemeInfo> _schemes = SchemeInfo.demoSchemes;

  List<SchemeInfo> get _filteredSchemes {
    // Filter from the full scheme list without mutating the source data.
    return _schemes.where((scheme) {
      switch (_selectedFilter) {
        case SchemeFilter.all:
          return true;
        case SchemeFilter.central:
          return scheme.type == SchemeType.central;
        case SchemeFilter.state:
          return scheme.type == SchemeType.state;
      }
    }).toList();
  }

  void _openSchemeDetails(SchemeInfo scheme) {
    // Read More uses a reusable 80%-height modal sheet, not a full page route.
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SchemeDetailBottomSheet(
        scheme: scheme,
        onVisitPortal: () => _visitOfficialPortal(scheme),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final schemes = _filteredSchemes;
    final fx = context.fx;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const FasalXHeader(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Government Schemes',
                        style: TextStyle(
                          color: fx.textStrong,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Find benefits, eligibility, and official actions in one place.',
                  style: TextStyle(
                    color: fx.textMuted,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                _SchemeFilters(
                  selectedFilter: _selectedFilter,
                  onSelected: (filter) {
                    setState(() => _selectedFilter = filter);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 176),
              itemCount: schemes.length,
              itemBuilder: (context, index) {
                final scheme = schemes[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: SchemeCard(
                    scheme: scheme,
                    onReadMore: () => _openSchemeDetails(scheme),
                    onVisitPortal: () => _visitOfficialPortal(scheme),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _visitOfficialPortal(SchemeInfo scheme) async {
    final uri = Uri.parse(scheme.portalUrl);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted || opened) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not open ${scheme.portalHost}.')),
    );
  }
}

class _SchemeFilters extends StatelessWidget {
  const _SchemeFilters({
    required this.selectedFilter,
    required this.onSelected,
  });

  final SchemeFilter selectedFilter;
  final ValueChanged<SchemeFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    const filters = [
      SchemeFilter.all,
      SchemeFilter.central,
      SchemeFilter.state,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in filters) ...[
            ChoiceChip(
              label: Text(filter.label),
              selected: selectedFilter == filter,
              onSelected: (_) => onSelected(filter),
              selectedColor: fx.selectedFill,
              checkmarkColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: selectedFilter == filter
                    ? Theme.of(context).colorScheme.primary
                    : fx.textMuted,
                fontWeight: FontWeight.w900,
              ),
              side: BorderSide(
                color: selectedFilter == filter
                    ? Theme.of(context).colorScheme.primary
                    : fx.border,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class SchemeCard extends StatelessWidget {
  const SchemeCard({
    super.key,
    required this.scheme,
    required this.onReadMore,
    required this.onVisitPortal,
  });

  final SchemeInfo scheme;
  final VoidCallback onReadMore;
  final VoidCallback onVisitPortal;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    final typeColor = scheme.type == SchemeType.central ? fx.warning : fx.info;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fx.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: scheme.isEnrolled
              ? Theme.of(context).colorScheme.primary.withAlpha(130)
              : fx.border,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SoftIcon(icon: scheme.icon, color: typeColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Pill(label: scheme.tag, color: typeColor),
                        _StatusBadge(scheme: scheme),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      scheme.title,
                      style: TextStyle(
                        color: fx.textStrong,
                        fontSize: 18.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            scheme.shortDescription,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: fx.textMuted,
              height: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          _BenefitHighlight(benefit: scheme.benefits),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onReadMore,
              icon: const Icon(Icons.article_outlined, size: 18),
              label: const Text('Read More'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                textStyle: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onVisitPortal,
              icon: const Icon(Icons.open_in_new_rounded, size: 19),
              label: Text('Visit Official Portal (${scheme.portalHost})'),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SchemeDetailBottomSheet extends StatelessWidget {
  const SchemeDetailBottomSheet({
    super.key,
    required this.scheme,
    required this.onVisitPortal,
  });

  final SchemeInfo scheme;
  final VoidCallback onVisitPortal;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return FractionallySizedBox(
      heightFactor: 0.82,
      child: Container(
        decoration: BoxDecoration(
          color: fx.surfaceAlt,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD8E2D4),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        IconButton.filledTonal(
                          tooltip: 'Back to schemes',
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Back to Schemes',
                            style: TextStyle(
                              color: fx.textStrong,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close',
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _SchemeDetailCard(scheme: scheme),
                    const SizedBox(height: 18),
                    const _SectionTitle('About the Scheme'),
                    const SizedBox(height: 8),
                    Text(
                      scheme.description,
                      style: TextStyle(
                        color: fx.textMuted,
                        height: 1.48,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const _SectionTitle('General Eligibility Criteria'),
                    const SizedBox(height: 10),
                    for (final item in scheme.eligibility)
                      _CheckLine(text: item),
                    const SizedBox(height: 18),
                    const _SectionTitle('Required Documents'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final document in scheme.documents)
                          _DocumentChip(label: document),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _BottomSheetActions(scheme: scheme, onVisitPortal: onVisitPortal),
          ],
        ),
      ),
    );
  }
}

class _SchemeDetailCard extends StatelessWidget {
  const _SchemeDetailCard({required this.scheme});

  final SchemeInfo scheme;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fx.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: fx.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Pill(
            label: scheme.tag,
            color: scheme.type == SchemeType.central ? fx.warning : fx.info,
          ),
          const SizedBox(height: 12),
          Text(
            scheme.title,
            style: TextStyle(
              color: fx.textStrong,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            scheme.shortDescription,
            style: TextStyle(
              color: fx.textMuted,
              height: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          _BenefitHighlight(benefit: scheme.benefits),
        ],
      ),
    );
  }
}

class _BottomSheetActions extends StatelessWidget {
  const _BottomSheetActions({
    required this.scheme,
    required this.onVisitPortal,
  });

  final SchemeInfo scheme;
  final VoidCallback onVisitPortal;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: fx.surface,
        border: Border(top: BorderSide(color: fx.border)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: FilledButton.icon(
          onPressed: onVisitPortal,
          icon: const Icon(Icons.open_in_new_rounded),
          label: Text('Visit Official Portal (${scheme.portalHost})'),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}

class _BenefitHighlight extends StatelessWidget {
  const _BenefitHighlight({required this.benefit});

  final String benefit;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: fx.selectedFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: fx.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.volunteer_activism_outlined,
            color: Theme.of(context).colorScheme.primary,
            size: 21,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              benefit,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                height: 1.3,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.scheme});

  final SchemeInfo scheme;

  @override
  Widget build(BuildContext context) {
    final isEnrolled = scheme.isEnrolled;
    return _Pill(
      label: isEnrolled ? 'Enrolled Active' : 'Last Date: ${scheme.lastDate}',
      color: isEnrolled
          ? Theme.of(context).colorScheme.primary
          : context.fx.textMuted,
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withAlpha(
          Theme.of(context).brightness == Brightness.dark ? 46 : 24,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SoftIcon extends StatelessWidget {
  const _SoftIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final alpha = Theme.of(context).brightness == Brightness.dark ? 46 : 24;
    return CircleAvatar(
      radius: 27,
      backgroundColor: color.withAlpha(alpha),
      child: Icon(icon, color: color, size: 28),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Text(
      title,
      style: TextStyle(
        color: fx.textStrong,
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _CheckLine extends StatelessWidget {
  const _CheckLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 21,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: fx.textMuted,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentChip extends StatelessWidget {
  const _DocumentChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Chip(
      avatar: Icon(
        Icons.description_outlined,
        size: 17,
        color: Theme.of(context).colorScheme.primary,
      ),
      label: Text(label),
      backgroundColor: fx.surface,
      side: BorderSide(color: fx.border),
      labelStyle: TextStyle(color: fx.textStrong, fontWeight: FontWeight.w800),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    );
  }
}

class SchemeInfo {
  const SchemeInfo({
    required this.id,
    required this.type,
    required this.title,
    required this.shortDescription,
    required this.description,
    required this.benefits,
    required this.eligibility,
    required this.documents,
    required this.lastDate,
    required this.portalUrl,
    required this.icon,
    required this.isEnrolled,
  });

  final int id;
  final SchemeType type;
  final String title;
  final String shortDescription;
  final String description;
  final String benefits;
  final List<String> eligibility;
  final List<String> documents;
  final String lastDate;
  final String portalUrl;
  final IconData icon;
  final bool isEnrolled;

  String get tag => type == SchemeType.central ? 'Central Govt' : 'State Govt';

  String get portalHost => Uri.parse(portalUrl).host.replaceFirst('www.', '');

  // Demo data can later be replaced by an API response without changing the UI.
  static const demoSchemes = [
    SchemeInfo(
      id: 1,
      type: SchemeType.central,
      title: 'PM-KISAN Samman Nidhi',
      shortDescription:
          'Direct income support for eligible farmer families through verified bank transfer.',
      description:
          'PM-KISAN provides structured income support to eligible farmer families. The scheme helps farmers manage seasonal expenses, crop inputs, and household farming needs through direct benefit transfer.',
      benefits: 'Rs 6,000 per year in three direct installments',
      eligibility: [
        'Resident farmer or eligible farming family',
        'Aadhaar linked bank account',
        'Valid land ownership proof',
      ],
      documents: [
        'Aadhaar Card',
        'Bank Passbook',
        'Land Records (Khasra)',
        'Passport Photo',
      ],
      lastDate: 'Open all year',
      portalUrl: 'https://pmkisan.gov.in/',
      icon: Icons.account_balance_rounded,
      isEnrolled: true,
    ),
    SchemeInfo(
      id: 2,
      type: SchemeType.central,
      title: 'Pradhan Mantri Fasal Bima Yojana',
      shortDescription:
          'Crop insurance support against weather, pest, disease, and yield loss risks.',
      description:
          'PMFBY is designed to reduce farmer risk by offering crop insurance for notified crops and areas. It supports farmers when crop losses happen due to natural calamities, pests, diseases, or adverse weather.',
      benefits: 'Affordable crop insurance and claim support',
      eligibility: [
        'Resident farmer or tenant cultivator in notified area',
        'Aadhaar linked bank account',
        'Crop sowing or land ownership proof',
      ],
      documents: [
        'Aadhaar Card',
        'Bank Passbook',
        'Land Records (Khasra)',
        'Crop Sowing Proof',
      ],
      lastDate: 'Before season cutoff',
      portalUrl: 'https://pmfby.gov.in/',
      icon: Icons.health_and_safety_outlined,
      isEnrolled: false,
    ),
    SchemeInfo(
      id: 3,
      type: SchemeType.state,
      title: 'Mukhyamantri Kisan Kalyan Yojana',
      shortDescription:
          'Additional state income support for registered Madhya Pradesh farmers.',
      description:
          'This state scheme gives additional financial assistance to eligible farmers in Madhya Pradesh. It works alongside central farmer support programs and helps farmers cover recurring agriculture costs.',
      benefits: 'State-level income support for registered farmers',
      eligibility: [
        'Resident farmer or citizen of Madhya Pradesh',
        'Aadhaar linked bank account',
        'Land ownership proof and PM-KISAN registration',
      ],
      documents: [
        'Aadhaar Card',
        'Bank Passbook',
        'Land Records (Khasra)',
        'Samagra ID',
      ],
      lastDate: 'Open as notified',
      portalUrl: 'https://pmkisan.gov.in/',
      icon: Icons.savings_outlined,
      isEnrolled: true,
    ),
    SchemeInfo(
      id: 4,
      type: SchemeType.state,
      title: 'Subsidy on Farm Equipment',
      shortDescription:
          'Subsidy assistance for selected agriculture machinery and useful farm tools.',
      description:
          'Farm equipment subsidy programs help farmers access machinery at reduced cost. Eligible farmers can apply for support on approved tools, equipment, and mechanization assets.',
      benefits: 'Subsidy support on approved farm equipment',
      eligibility: [
        'Resident farmer or registered cultivator',
        'Aadhaar linked bank account',
        'Land ownership proof and equipment quotation',
      ],
      documents: [
        'Aadhaar Card',
        'Bank Passbook',
        'Land Records (Khasra)',
        'Quotation',
      ],
      lastDate: '31 May 2026',
      portalUrl: 'https://dbt.mpdage.org/',
      icon: Icons.agriculture_outlined,
      isEnrolled: false,
    ),
  ];
}

extension on SchemeFilter {
  String get label {
    switch (this) {
      case SchemeFilter.all:
        return 'All';
      case SchemeFilter.central:
        return 'Central';
      case SchemeFilter.state:
        return 'State';
    }
  }
}
