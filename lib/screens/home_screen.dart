import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/auth_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/fasalx_header.dart';
import 'crop_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.onOpenIot,
    this.onOpenCropDetails,
    this.onOpenCropTimeline,
    this.onOpenMandiPrice,
    this.onOpenFinanceAnalytics,
  });

  final VoidCallback? onOpenIot;
  final ValueChanged<String>? onOpenCropDetails;
  final VoidCallback? onOpenCropTimeline;
  final VoidCallback? onOpenMandiPrice;
  final VoidCallback? onOpenFinanceAnalytics;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isAlertDismissed = false;
  int _cropChangeCounter = 0;

  void _openDashboardDetail(String title, IconData icon, String message) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            _DashboardDetailScreen(title: title, icon: icon, message: message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final alert = _dashboardAlerts.firstWhere((item) => item.isHighPriority);

    return Scaffold(
      appBar: const FasalXHeader(),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 204),
        children: [
          const _AnimatedDashboardCard(delay: 0, child: _GreetingCard()),
          if (!_isAlertDismissed) ...[
            const SizedBox(height: 14),
            _AnimatedDashboardCard(
              delay: 80,
              child: _PestAlertCard(
                alert: alert,
                onDismiss: () => setState(() => _isAlertDismissed = true),
              ),
            ),
          ],
          const SizedBox(height: 22),
          _AnimatedDashboardCard(
            delay: 100,
            child: _MyCropsSection(
              onCropsChanged: () => setState(() => _cropChangeCounter++),
              onOpenCropDetails: widget.onOpenCropDetails,
            ),
          ),
          const SizedBox(height: 18),
          _AnimatedDashboardCard(
            delay: 140,
            child: _CropTimelineSection(
              key: ValueKey(_cropChangeCounter),
              onTap:
                  widget.onOpenCropTimeline ??
                  () => _openDashboardDetail(
                    'Crop Timeline',
                    Icons.timeline_rounded,
                    'Crop stage planning and farm tasks are ready from your dashboard.',
                  ),
            ),
          ),
          const SizedBox(height: 18),
          _AnimatedDashboardCard(
            delay: 180,
            child: _SensorDataCard(
              onTap:
                  widget.onOpenIot ??
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const _DashboardDetailScreen(
                        title: 'IoT Monitoring',
                        icon: Icons.sensors_rounded,
                        message:
                            'Live soil moisture, NPK, humidity, and field sensor readings.',
                      ),
                    ),
                  ),
            ),
          ),
          const SizedBox(height: 18),
          _AnimatedDashboardCard(
            delay: 220,
            child: _MandiFinanceSection(
              onOpenMandiPrice:
                  widget.onOpenMandiPrice ??
                  () => _openDashboardDetail(
                    'Mandi Prices',
                    Icons.storefront_rounded,
                    'Nearby mandi prices and crop trend tracking.',
                  ),
              onOpenFinanceAnalytics:
                  widget.onOpenFinanceAnalytics ??
                  () => _openDashboardDetail(
                    'Finance Analytics',
                    Icons.calculate_outlined,
                    'Estimated expenses, yield, and profit for your active farm.',
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardAlert {
  const _DashboardAlert({
    required this.title,
    required this.message,
    required this.isHighPriority,
  });

  final String title;
  final String message;
  final bool isHighPriority;
}

const _dashboardAlerts = [
  _DashboardAlert(
    title: 'Pest Alert: Locust Swarm',
    message:
        'Nearby fields reported pest movement. Inspect leaves and spray only if damage is visible.',
    isHighPriority: true,
  ),
  _DashboardAlert(
    title: 'Irrigation Reminder',
    message:
        'Wheat field moisture is slightly low. Plan irrigation in the next 2 days.',
    isHighPriority: false,
  ),
];

class _DashboardData {
  const _DashboardData._();

  static AppUser? get _user => AuthController.instance.currentUser;
  static FarmProfile get _farm => _user?.farm ?? const FarmProfile.empty();

  static String get firstName {
    final name = _user?.name.trim() ?? '';
    final parts = name.split(RegExp(r'\s+'));
    return parts.isEmpty || parts.first.isEmpty ? 'Kisan' : parts.first;
  }

  static List<String> get crops {
    final selected = _farm.crops
        .map((crop) => canonicalCrop(crop))
        .where((crop) => crop.isNotEmpty)
        .toSet()
        .toList();
    return selected.isEmpty
        ? const ['Wheat', 'Rice', 'Soybean', 'Tomato', 'Cotton', 'Maize']
        : selected;
  }

  static String canonicalCrop(String crop) {
    final normalized = crop.trim().toLowerCase();
    switch (normalized) {
      case 'soyabean':
      case 'soybean':
        return 'Soybean';
      case 'rice':
        return 'Rice';
      case 'wheat':
        return 'Wheat';
      case 'tomato':
        return 'Tomato';
      case 'cotton':
        return 'Cotton';
      case 'maize':
        return 'Maize';
      default:
        return crop.trim();
    }
  }

  static int stageIndexFor(String crop) {
    switch (canonicalCrop(crop)) {
      case 'Rice':
      case 'Maize':
        return 3;
      case 'Soybean':
        return 1;
      case 'Tomato':
        return 4;
      default:
        return 2;
    }
  }
}

class _GreetingCard extends StatefulWidget {
  const _GreetingCard();

  @override
  State<_GreetingCard> createState() => _GreetingCardState();
}

class _GreetingCardState extends State<_GreetingCard> {
  bool _isWeatherExpanded = false;
  final _forecastController = ScrollController();

  @override
  void dispose() {
    _forecastController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return _TapCard(
      color: const Color(0xFFEAF7FF),
      borderRadius: 20,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 360;
              final header = isNarrow
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _GreetingText(),
                        const SizedBox(height: 10),
                        _WeatherSummary(
                          isExpanded: _isWeatherExpanded,
                          onTap: () => setState(
                            () => _isWeatherExpanded = !_isWeatherExpanded,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        const Expanded(child: _GreetingText()),
                        const SizedBox(width: 10),
                        _WeatherSummary(
                          isExpanded: _isWeatherExpanded,
                          onTap: () => setState(
                            () => _isWeatherExpanded = !_isWeatherExpanded,
                          ),
                        ),
                      ],
                    );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  header,
                  if (_isWeatherExpanded) ...[
                    const SizedBox(height: 12),
                    Container(height: 1, color: fx.border),
                    const SizedBox(height: 8),
                    _ForecastStrip(controller: _forecastController),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ForecastDay {
  const _ForecastDay(
    this.day,
    this.date,
    this.icon,
    this.temperature, {
    this.isToday = false,
  });

  final String day;
  final String date;
  final IconData icon;
  final String temperature;
  final bool isToday;
}

class _ForecastStrip extends StatelessWidget {
  const _ForecastStrip({required this.controller});

  final ScrollController controller;

  static const _forecast = [
    _ForecastDay('MON', '12 Aug', Icons.cloud_outlined, '36°'),
    _ForecastDay('TUE', '13 Aug', Icons.water_drop_outlined, '35°'),
    _ForecastDay('WED', '14 Aug', Icons.wb_cloudy_outlined, '37°'),
    _ForecastDay(
      'TODAY',
      '15 Aug',
      Icons.wb_sunny_rounded,
      '39°',
      isToday: true,
    ),
    _ForecastDay('FRI', '16 Aug', Icons.cloud_outlined, '37°'),
    _ForecastDay('SAT', '17 Aug', Icons.thunderstorm_outlined, '34°'),
    _ForecastDay('SUN', '18 Aug', Icons.water_drop_outlined, '33°'),
  ];

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        controller: controller,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [for (final day in _forecast) _ForecastItem(day: day)],
        ),
      ),
    );
  }
}

class _ForecastItem extends StatelessWidget {
  const _ForecastItem({required this.day});

  final _ForecastDay day;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    final content = SizedBox(
      width: day.isToday ? 62 : 50,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            day.day,
            style: TextStyle(
              color: day.isToday ? fx.textStrong : fx.textMuted,
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            day.date,
            style: TextStyle(
              color: fx.textMuted,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Icon(day.icon, color: fx.warning, size: 20),
          const SizedBox(height: 3),
          Text(
            day.temperature,
            style: TextStyle(
              color: fx.textStrong,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );

    if (!day.isToday) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: content,
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: fx.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: content,
    );
  }
}

class _WeatherSummary extends StatelessWidget {
  const _WeatherSummary({required this.isExpanded, required this.onTap});

  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Material(
      color: fx.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wb_sunny_rounded, color: fx.warning, size: 25),
              const SizedBox(width: 6),
              Text(
                '39°C',
                style: TextStyle(
                  color: fx.textStrong,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 1),
              AnimatedRotation(
                turns: isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: fx.textMuted,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GreetingText extends StatelessWidget {
  const _GreetingText();

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
        ? 'Good Afternoon'
        : 'Good Evening';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting, ${_DashboardData.firstName}',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: fx.textStrong,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Here is your farm update today.',
          style: TextStyle(
            color: fx.textMuted,
            fontSize: 15.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _MyCropsSection extends StatefulWidget {
  const _MyCropsSection({required this.onCropsChanged, this.onOpenCropDetails});

  final VoidCallback onCropsChanged;
  final ValueChanged<String>? onOpenCropDetails;

  @override
  State<_MyCropsSection> createState() => _MyCropsSectionState();
}

class _MyCropsSectionState extends State<_MyCropsSection> {
  String? _selectedCrop;
  final Set<String> _localCrops = {..._DashboardData.crops};

  void _showCropManagementModal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CropManagementModal(
        initialCrops: _localCrops,
        onSaved: (crops) {
          setState(
            () => _localCrops
              ..clear()
              ..addAll(crops),
          );
          widget.onCropsChanged();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    final crops = _localCrops.isEmpty
        ? _DashboardData.crops
        : _localCrops.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'My Crops',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: fx.textStrong,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Manage crops',
              onPressed: _showCropManagementModal,
              icon: const Icon(Icons.add_circle_outline, size: 24),
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: crops.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final crop = crops[index];
              return _CropTab(
                crop: crop,
                isSelected: _selectedCrop == crop,
                onTap: () {
                  setState(() => _selectedCrop = crop);
                  final openDetails = widget.onOpenCropDetails;
                  if (openDetails != null) {
                    openDetails(crop);
                    return;
                  }
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CropScreen(initialCrop: crop),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CropTab extends StatelessWidget {
  const _CropTab({required this.crop, this.isSelected = false, this.onTap});

  final String crop;
  final bool isSelected;
  final VoidCallback? onTap;

  String get _cropIcon {
    switch (crop.toLowerCase()) {
      case 'wheat':
        return 'W';
      case 'rice':
        return 'R';
      case 'soybean':
        return 'S';
      case 'tomato':
        return 'T';
      case 'cotton':
        return 'C';
      case 'maize':
        return 'M';
      default:
        return crop.isEmpty ? '?' : crop.characters.first.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    final active = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(36),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: isSelected ? fx.selectedFill : fx.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? active : fx.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _cropIcon,
              style: TextStyle(
                color: isSelected ? active : fx.textStrong,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              crop,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? active : fx.textStrong,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CropManagementModal extends StatefulWidget {
  const _CropManagementModal({
    required this.initialCrops,
    required this.onSaved,
  });

  final Set<String> initialCrops;
  final ValueChanged<Set<String>> onSaved;

  @override
  State<_CropManagementModal> createState() => _CropManagementModalState();
}

class _CropManagementModalState extends State<_CropManagementModal> {
  final _customCropController = TextEditingController();
  late final Set<String> _selectedCrops = {...widget.initialCrops};

  static const _availableCrops = [
    'Wheat',
    'Rice',
    'Soybean',
    'Tomato',
    'Cotton',
    'Maize',
    'Sugarcane',
    'Potato',
    'Onion',
    'Mustard',
    'Bajra',
    'Groundnut',
  ];

  @override
  void dispose() {
    _customCropController.dispose();
    super.dispose();
  }

  void _addCustomCrop() {
    final crop = _customCropController.text.trim();
    if (crop.isEmpty) return;
    setState(() {
      _selectedCrops.add(crop);
      _customCropController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: fx.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Manage Crops',
                    style: TextStyle(
                      color: fx.textStrong,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              children: [
                TextField(
                  controller: _customCropController,
                  decoration: const InputDecoration(
                    hintText: 'Add custom crop',
                    prefixIcon: Icon(Icons.add_rounded),
                  ),
                  onSubmitted: (_) => _addCustomCrop(),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final crop in _availableCrops)
                      FilterChip(
                        label: Text(crop),
                        selected: _selectedCrops.contains(crop),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedCrops.add(crop);
                            } else {
                              _selectedCrops.remove(crop);
                            }
                          });
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              20 + MediaQuery.of(context).padding.bottom,
            ),
            child: FilledButton(
              onPressed: () {
                widget.onSaved(_selectedCrops);
                Navigator.of(context).pop();
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PestAlertCard extends StatelessWidget {
  const _PestAlertCard({required this.alert, required this.onDismiss});

  final _DashboardAlert alert;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return _TapCard(
      color: fx.dangerContainer,
      borderColor: fx.danger.withAlpha(90),
      borderRadius: 18,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE0E4),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFE53935),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: fx.danger,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    alert.message,
                    style: TextStyle(
                      color: fx.textStrong,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Dismiss',
              onPressed: onDismiss,
              icon: Icon(Icons.close_rounded, color: fx.danger),
            ),
          ],
        ),
      ),
    );
  }
}

class _CropTimelineSection extends StatefulWidget {
  const _CropTimelineSection({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  State<_CropTimelineSection> createState() => _CropTimelineSectionState();
}

class _CropTimelineSectionState extends State<_CropTimelineSection> {
  late final List<String> _cropOptions;
  late String _selectedCrop;

  static const _stages = [
    _TimelineData('Sowing', Icons.spa_outlined),
    _TimelineData('Sprout', Icons.eco_outlined),
    _TimelineData('Growth', Icons.grass_rounded),
    _TimelineData('Flowering', Icons.local_florist_outlined),
    _TimelineData('Harvest', Icons.agriculture_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _cropOptions = _DashboardData.crops;
    _selectedCrop = _cropOptions.first;
  }

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    final activeStageIndex = _DashboardData.stageIndexFor(_selectedCrop);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Crop Timeline',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: fx.textStrong,
              ),
            ),
            _CropDropdownChip(
              selectedCrop: _selectedCrop,
              options: _cropOptions,
              onSelected: (crop) => setState(() => _selectedCrop = crop),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _TapCard(
          color: fx.surface,
          borderRadius: 20,
          onTap: widget.onTap,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: Row(
              children: [
                for (var i = 0; i < _stages.length; i++) ...[
                  SizedBox(
                    width: 64,
                    child: _TimelineStep(
                      data: _stages[i],
                      isActive: i == activeStageIndex,
                    ),
                  ),
                  if (i != _stages.length - 1)
                    Container(
                      width: 28,
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 22),
                      color: i < activeStageIndex
                          ? Theme.of(context).colorScheme.primary
                          : fx.border,
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelineData {
  const _TimelineData(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _CropDropdownChip extends StatelessWidget {
  const _CropDropdownChip({
    required this.selectedCrop,
    required this.options,
    required this.onSelected,
  });

  final String selectedCrop;
  final List<String> options;
  final ValueChanged<String> onSelected;

  Future<void> _showCropMenu(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final topLeft = box.localToGlobal(Offset.zero, ancestor: overlay);
    final position = RelativeRect.fromRect(
      Rect.fromLTWH(
        topLeft.dx,
        topLeft.dy + box.size.height + 4,
        box.size.width,
        0,
      ),
      Offset.zero & overlay.size,
    );

    final selected = await showMenu<String>(
      context: context,
      position: position,
      constraints: BoxConstraints.tightFor(width: box.size.width),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      items: [
        for (final crop in options)
          PopupMenuItem<String>(
            value: crop,
            height: 42,
            child: Text(
              crop,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
      ],
    );
    if (selected != null) onSelected(selected);
  }

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Material(
      color: fx.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => _showCropMenu(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: fx.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$selectedCrop (Field A)',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: fx.textStrong,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: fx.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({required this.data, required this.isActive});

  final _TimelineData data;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF16823A) : const Color(0xFF8A968A);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          width: isActive ? 48 : 42,
          height: isActive ? 48 : 42,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFEAF7E8) : const Color(0xFFF4F7F2),
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive
                  ? const Color(0xFF16823A)
                  : const Color(0xFFE0E8DD),
              width: isActive ? 2 : 1,
            ),
          ),
          child: Icon(data.icon, color: color, size: isActive ? 25 : 22),
        ),
        const SizedBox(height: 7),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            data.label,
            maxLines: 1,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _SensorDataCard extends StatelessWidget {
  const _SensorDataCard({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return _TapCard(
      color: fx.surface,
      borderRadius: 22,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'IoT Sensor Data',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: fx.textStrong,
                    ),
                  ),
                ),
                const _LiveSyncBadge(),
              ],
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 430) {
                  return const Column(
                    children: [
                      _NpkChart(),
                      SizedBox(height: 18),
                      _SensorMetrics(),
                    ],
                  );
                }

                return const Row(
                  children: [
                    SizedBox(width: 150, child: _NpkChart()),
                    SizedBox(width: 18),
                    Expanded(child: _SensorMetrics()),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveSyncBadge extends StatelessWidget {
  const _LiveSyncBadge();

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: fx.selectedFill,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.sync_rounded,
            size: 15,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 5),
          Text(
            'Live sync',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _NpkChart extends StatelessWidget {
  const _NpkChart();

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Column(
      children: [
        SizedBox(
          width: 132,
          height: 132,
          child: CustomPaint(
            painter: _NpkPainter(),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'NPK',
                    style: TextStyle(
                      color: fx.textStrong,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Good',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: [
            _LegendDot(label: 'N', color: Color(0xFF16823A)),
            _LegendDot(label: 'P', color: Color(0xFFF59E0B)),
            _LegendDot(label: 'K', color: Color(0xFF3B82F6)),
          ],
        ),
      ],
    );
  }
}

class _NpkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    final values = [
      const _ChartSegment(0.42, Color(0xFF16823A)),
      const _ChartSegment(0.30, Color(0xFFF59E0B)),
      const _ChartSegment(0.22, Color(0xFF3B82F6)),
    ];

    var start = -math.pi / 2;
    for (final item in values) {
      stroke.color = item.color;
      final sweep = math.pi * 2 * item.value;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        stroke,
      );
      start += sweep + 0.14;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ChartSegment {
  const _ChartSegment(this.value, this.color);

  final double value;
  final Color color;
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _SensorMetrics extends StatelessWidget {
  const _SensorMetrics();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _MetricBar(
          label: 'Soil Moisture',
          value: '64%',
          progress: 0.64,
          color: Color(0xFF3B82F6),
        ),
        SizedBox(height: 14),
        _MetricBar(
          label: 'Soil Temperature',
          value: '31°C',
          progress: 0.58,
          color: Color(0xFFF59E0B),
        ),
        SizedBox(height: 14),
        _MetricBar(
          label: 'Humidity',
          value: '72%',
          progress: 0.72,
          color: Color(0xFF16823A),
        ),
      ],
    );
  }
}

class _MetricBar extends StatelessWidget {
  const _MetricBar({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
  });

  final String label;
  final String value;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: fx.textMuted,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                color: fx.textStrong,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: fx.fieldFill,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _MandiFinanceSection extends StatelessWidget {
  const _MandiFinanceSection({
    this.onOpenMandiPrice,
    this.onOpenFinanceAnalytics,
  });

  final VoidCallback? onOpenMandiPrice;
  final VoidCallback? onOpenFinanceAnalytics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 520) {
          return Column(
            children: [
              _MandiPriceCard(onTap: onOpenMandiPrice),
              const SizedBox(height: 14),
              _FinanceCard(onTap: onOpenFinanceAnalytics),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _MandiPriceCard(onTap: onOpenMandiPrice)),
            const SizedBox(width: 14),
            Expanded(child: _FinanceCard(onTap: onOpenFinanceAnalytics)),
          ],
        );
      },
    );
  }
}

class _MandiPriceCard extends StatelessWidget {
  const _MandiPriceCard({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return _TapCard(
      color: fx.warningContainer,
      borderRadius: 20,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Mandi Prices',
                  style: TextStyle(
                    color: fx.textStrong,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _PriceRow(crop: 'Wheat', price: '₹2,300 / Quintal'),
            const SizedBox(height: 12),
            _PriceRow(crop: 'Soyabean', price: '₹4,500 / Quintal'),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.crop, required this.price});

  final String crop;
  final String price;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Row(
      children: [
        Text(
          crop,
          style: TextStyle(color: fx.textMuted, fontWeight: FontWeight.w800),
        ),
        const Spacer(),
        Text(
          price,
          style: TextStyle(color: fx.textStrong, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class _FinanceCard extends StatelessWidget {
  const _FinanceCard({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _TapCard(
      color: Colors.transparent,
      borderRadius: 20,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF14532D), Color(0xFF1F8A45)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Row(
              children: [
                Text(
                  'Finances (Est)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Spacer(),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0x29FFFFFF),
                  child: Icon(
                    Icons.calculate_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
            SizedBox(height: 14),
            _FinanceRow(label: 'Exp.', value: '₹12,400'),
            SizedBox(height: 10),
            _FinanceRow(label: 'Est. Yield', value: '18 Q'),
            SizedBox(height: 10),
            _FinanceRow(label: 'Est. Profit', value: '₹29,000'),
          ],
        ),
      ),
    );
  }
}

class _FinanceRow extends StatelessWidget {
  const _FinanceRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xD9FFFFFF),
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _TapCard extends StatelessWidget {
  const _TapCard({
    required this.child,
    required this.color,
    required this.borderRadius,
    this.borderColor,
    this.onTap,
  });

  final Widget child;
  final Color color;
  final double borderRadius;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    final effectiveColor = Theme.of(context).brightness == Brightness.dark
        ? (color == Colors.transparent ? Colors.transparent : fx.surface)
        : color;
    final effectiveBorder = Theme.of(context).brightness == Brightness.dark
        ? borderColor ?? fx.border
        : borderColor;
    return Material(
      color: effectiveColor,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: effectiveColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: effectiveBorder == null
                ? null
                : Border.all(color: effectiveBorder),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 22,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _AnimatedDashboardCard extends StatelessWidget {
  const _AnimatedDashboardCard({required this.child, required this.delay});

  final Widget child;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _DashboardDetailScreen extends StatelessWidget {
  const _DashboardDetailScreen({
    required this.title,
    required this.icon,
    required this.message,
  });

  final String title;
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: fx.selectedFill,
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 38,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: fx.textStrong,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: fx.textMuted,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
