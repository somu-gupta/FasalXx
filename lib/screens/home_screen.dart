import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/fasalx_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FasalXHeader(),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 204),
        children: const [
          _AnimatedDashboardCard(delay: 0, child: _GreetingCard()),
          SizedBox(height: 14),
          _AnimatedDashboardCard(delay: 80, child: _PestAlertCard()),
          SizedBox(height: 22),
          _AnimatedDashboardCard(delay: 140, child: _CropTimelineSection()),
          SizedBox(height: 18),
          _AnimatedDashboardCard(delay: 200, child: _SensorDataCard()),
          SizedBox(height: 18),
          _AnimatedDashboardCard(delay: 260, child: _MandiFinanceSection()),
        ],
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard();

  @override
  Widget build(BuildContext context) {
    return _TapCard(
      color: const Color(0xFFEAF7FF),
      borderRadius: 20,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 360) {
              return const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _GreetingText(),
                  SizedBox(height: 14),
                  _WeatherPill(),
                ],
              );
            }

            return const Row(
              children: [
                Expanded(child: _GreetingText()),
                SizedBox(width: 14),
                _WeatherPill(),
              ],
            );
          },
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Greetings, Kisan!',
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

class _WeatherPill extends StatelessWidget {
  const _WeatherPill();

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: fx.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wb_sunny_rounded, color: fx.warning, size: 28),
          const SizedBox(width: 8),
          Text(
            '39°C',
            style: TextStyle(
              color: fx.textStrong,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 2),
          Icon(Icons.keyboard_arrow_down_rounded, color: fx.textMuted),
        ],
      ),
    );
  }
}

class _PestAlertCard extends StatelessWidget {
  const _PestAlertCard();

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
                    'Pest Alert: Locust Swarm',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: fx.danger,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Nearby fields reported pest movement. Inspect leaves and spray only if damage is visible.',
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
              onPressed: () {},
              icon: Icon(Icons.close_rounded, color: fx.danger),
            ),
          ],
        ),
      ),
    );
  }
}

class _CropTimelineSection extends StatelessWidget {
  const _CropTimelineSection();

  static const _stages = [
    _TimelineData('Sowing', Icons.spa_outlined, false),
    _TimelineData('Sprout', Icons.eco_outlined, false),
    _TimelineData('Growth', Icons.grass_rounded, true),
    _TimelineData('Flowering', Icons.local_florist_outlined, false),
    _TimelineData('Harvest', Icons.agriculture_outlined, false),
  ];

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
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
            const _CropDropdownChip(),
          ],
        ),
        const SizedBox(height: 12),
        _TapCard(
          color: fx.surface,
          borderRadius: 20,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: Row(
              children: [
                for (var i = 0; i < _stages.length; i++) ...[
                  SizedBox(width: 64, child: _TimelineStep(data: _stages[i])),
                  if (i != _stages.length - 1)
                    Container(
                      width: 28,
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 22),
                      color: i < 2
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
  const _TimelineData(this.label, this.icon, this.isActive);

  final String label;
  final IconData icon;
  final bool isActive;
}

class _CropDropdownChip extends StatelessWidget {
  const _CropDropdownChip();

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Material(
      color: fx.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () {},
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
                'Wheat (Field A)',
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
  const _TimelineStep({required this.data});

  final _TimelineData data;

  @override
  Widget build(BuildContext context) {
    final color = data.isActive
        ? const Color(0xFF16823A)
        : const Color(0xFF8A968A);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          width: data.isActive ? 48 : 42,
          height: data.isActive ? 48 : 42,
          decoration: BoxDecoration(
            color: data.isActive
                ? const Color(0xFFEAF7E8)
                : const Color(0xFFF4F7F2),
            shape: BoxShape.circle,
            border: Border.all(
              color: data.isActive
                  ? const Color(0xFF16823A)
                  : const Color(0xFFE0E8DD),
              width: data.isActive ? 2 : 1,
            ),
          ),
          child: Icon(data.icon, color: color, size: data.isActive ? 25 : 22),
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
              fontWeight: data.isActive ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _SensorDataCard extends StatelessWidget {
  const _SensorDataCard();

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return _TapCard(
      color: fx.surface,
      borderRadius: 22,
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
  const _MandiFinanceSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 520) {
          return const Column(
            children: [_MandiPriceCard(), SizedBox(height: 14), _FinanceCard()],
          );
        }

        return const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _MandiPriceCard()),
            SizedBox(width: 14),
            Expanded(child: _FinanceCard()),
          ],
        );
      },
    );
  }
}

class _MandiPriceCard extends StatelessWidget {
  const _MandiPriceCard();

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return _TapCard(
      color: fx.warningContainer,
      borderRadius: 20,
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
                  'Bhopal Mandi',
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
  const _FinanceCard();

  @override
  Widget build(BuildContext context) {
    return _TapCard(
      color: Colors.transparent,
      borderRadius: 20,
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
  });

  final Widget child;
  final Color color;
  final double borderRadius;
  final Color? borderColor;

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
        onTap: () {},
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
