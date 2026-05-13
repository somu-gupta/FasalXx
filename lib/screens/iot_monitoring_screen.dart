import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/backend_repositories.dart';
import '../theme/app_theme.dart';
import 'health_screen.dart';

class IotMonitoringScreen extends StatefulWidget {
  const IotMonitoringScreen({super.key, this.onBack, this.onOpenCropDoctor});

  final VoidCallback? onBack;
  final VoidCallback? onOpenCropDoctor;

  @override
  State<IotMonitoringScreen> createState() => _IotMonitoringScreenState();
}

class _IotMonitoringScreenState extends State<IotMonitoringScreen> {
  final _backend = DemoIotBackend.instance;
  bool _refreshing = false;
  bool _irrigationActive = false;

  Future<void> _refresh() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    await _backend.refresh();
    if (!mounted) return;
    setState(() => _refreshing = false);
    _showSnack('Sensor data refreshed.');
  }

  void _goBack() {
    final onBack = widget.onBack;
    if (onBack != null) {
      onBack();
      return;
    }
    Navigator.of(context).maybePop();
  }

  void _startIrrigation() {
    setState(() => _irrigationActive = true);
    _showSnack('Irrigation started. Pump relay is active.');
  }

  void _stopIrrigation() {
    setState(() => _irrigationActive = false);
    _showSnack('Irrigation stopped. Pump relay is inactive.');
  }

  void _generateReport() {
    _showSnack('Farm sensor report generated for the latest readings.');
  }

  void _openCropDoctor() {
    final callback = widget.onOpenCropDoctor;
    if (callback != null) {
      callback();
      return;
    }
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const HealthScreen()));
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AnimatedBuilder(
        animation: _backend,
        builder: (context, _) {
          final data = _backend.snapshot;
          return SafeArea(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
                    sliver: SliverList.list(
                      children: [
                        _IotHeader(
                          activeCount: data.activeSensorCount,
                          refreshing: _refreshing,
                          onBack: _goBack,
                          onRefresh: _refresh,
                        ),
                        const SizedBox(height: 16),
                        _WeatherSummaryRow(weather: data.weather),
                        const SizedBox(height: 22),
                        Text(
                          'Live Sensors',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: fx.textStrong,
                                fontWeight: FontWeight.w900,
                                fontSize: 22,
                              ),
                        ),
                        const SizedBox(height: 12),
                        _SensorGrid(sensors: data.sensors),
                        const SizedBox(height: 18),
                        _AiRecommendationCard(
                          recommendation: data.recommendation,
                        ),
                        const SizedBox(height: 18),
                        _MoistureTrendCard(trend: data.moistureTrend),
                        const SizedBox(height: 22),
                        Text(
                          'Quick Actions',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: fx.textStrong,
                                fontWeight: FontWeight.w900,
                                fontSize: 22,
                              ),
                        ),
                        const SizedBox(height: 12),
                        _QuickActionsGrid(
                          irrigationActive: _irrigationActive,
                          onStartIrrigation: _startIrrigation,
                          onStopIrrigation: _stopIrrigation,
                          onGenerateReport: _generateReport,
                          onCropDoctor: _openCropDoctor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _IotHeader extends StatelessWidget {
  const _IotHeader({
    required this.activeCount,
    required this.refreshing,
    required this.onBack,
    required this.onRefresh,
  });

  final int activeCount;
  final bool refreshing;
  final VoidCallback onBack;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _HeaderIconButton(
          tooltip: 'Back',
          icon: Icons.arrow_back_rounded,
          onTap: onBack,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'IoT Monitoring',
                style: TextStyle(
                  color: fx.textStrong,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.wifi_tethering_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 17,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$activeCount Sensors Active',
                    style: TextStyle(
                      color: fx.textMuted,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _HeaderIconButton(
          tooltip: 'Refresh',
          icon: Icons.refresh_rounded,
          spinning: refreshing,
          onTap: onRefresh,
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.spinning = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  final bool spinning;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    final child = Icon(icon, color: fx.textStrong);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: fx.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: spinning
                  ? TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 700),
                      builder: (context, value, child) {
                        return Transform.rotate(
                          angle: math.pi * 2 * value,
                          child: child,
                        );
                      },
                      child: child,
                    )
                  : child,
            ),
          ),
        ),
      ),
    );
  }
}

class _WeatherSummaryRow extends StatelessWidget {
  const _WeatherSummaryRow({required this.weather});

  final IotWeather weather;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _WeatherChip(
            icon: Icons.wb_sunny_rounded,
            label: 'Temperature',
            value: '${weather.temperature}°C',
            color: context.fx.warning,
          ),
          const SizedBox(width: 10),
          _WeatherChip(
            icon: Icons.water_drop_outlined,
            label: 'Humidity',
            value: '${weather.humidity}%',
            color: context.fx.info,
          ),
          const SizedBox(width: 10),
          _WeatherChip(
            icon: Icons.air_rounded,
            label: 'Wind',
            value: '${weather.windSpeed} km/h',
            color: context.fx.success,
          ),
        ],
      ),
    );
  }
}

class _WeatherChip extends StatelessWidget {
  const _WeatherChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Container(
      width: 148,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: fx.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fx.border),
        boxShadow: _softShadow(context),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withAlpha(28),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: fx.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: fx.textStrong,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SensorGrid extends StatelessWidget {
  const _SensorGrid({required this.sensors});

  final List<IotSensorReading> sensors;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = constraints.maxWidth >= 720 ? 16.0 : 12.0;
        final ratio = constraints.maxWidth >= 720 ? 1.9 : 1.18;
        return GridView.builder(
          itemCount: sensors.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: gap,
            mainAxisSpacing: gap,
            childAspectRatio: ratio,
          ),
          itemBuilder: (context, index) => _SensorCard(sensor: sensors[index]),
        );
      },
    );
  }
}

class _SensorCard extends StatelessWidget {
  const _SensorCard({required this.sensor});

  final IotSensorReading sensor;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Material(
      color: fx.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          showModalBottomSheet<void>(
            context: context,
            showDragHandle: true,
            backgroundColor: fx.surface,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (context) => _SensorDetailSheet(sensor: sensor),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: fx.border),
            boxShadow: _softShadow(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 21,
                    backgroundColor: sensor.color.withAlpha(28),
                    child: Icon(sensor.icon, color: sensor.color, size: 22),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 15,
                    color: fx.textMuted,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                sensor.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: fx.textMuted,
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                sensor.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: fx.textStrong,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sensor.status,
                style: TextStyle(
                  color: sensor.color,
                  fontWeight: FontWeight.w900,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: sensor.progress,
                  minHeight: 7,
                  backgroundColor: fx.fieldFill,
                  valueColor: AlwaysStoppedAnimation<Color>(sensor.color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SensorDetailSheet extends StatelessWidget {
  const _SensorDetailSheet({required this.sensor});

  final IotSensorReading sensor;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        6,
        20,
        24 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: sensor.color.withAlpha(28),
            child: Icon(sensor.icon, color: sensor.color),
          ),
          const SizedBox(height: 14),
          Text(
            sensor.name,
            style: TextStyle(
              color: fx.textStrong,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${sensor.value} - ${sensor.status}',
            style: TextStyle(color: fx.textMuted, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Text(
            'Demo sensor feed is online. This card will connect to the device telemetry endpoint when the hardware backend is available.',
            style: TextStyle(color: fx.textMuted, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _AiRecommendationCard extends StatefulWidget {
  const _AiRecommendationCard({required this.recommendation});

  final String recommendation;

  @override
  State<_AiRecommendationCard> createState() => _AiRecommendationCardState();
}

class _AiRecommendationCardState extends State<_AiRecommendationCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: fx.selectedFill,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withAlpha(38),
        ),
        boxShadow: _softShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: fx.surface,
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'AI Recommendation',
                  style: TextStyle(
                    color: fx.textStrong,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                tooltip: _expanded ? 'Hide details' : 'Show details',
                onPressed: () => setState(() => _expanded = !_expanded),
                icon: AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: fx.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.recommendation,
            style: TextStyle(
              color: fx.textStrong,
              height: 1.4,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: 10),
            Text(
              'Reason: Moisture readings are trending downward while temperature remains warm. Start irrigation soon to avoid crop stress.',
              style: TextStyle(
                color: fx.textMuted,
                height: 1.4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => setState(() => _expanded = true),
            icon: const Icon(Icons.insights_rounded),
            label: const Text('View Details'),
          ),
        ],
      ),
    );
  }
}

class _MoistureTrendCard extends StatelessWidget {
  const _MoistureTrendCard({required this.trend});

  final List<MoisturePoint> trend;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: fx.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: fx.border),
        boxShadow: _softShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Moisture Trend',
                      style: TextStyle(
                        color: fx.textStrong,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Last 7 readings',
                      style: TextStyle(
                        color: fx.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.show_chart_rounded, color: fx.success),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 240,
            width: double.infinity,
            child: CustomPaint(
              painter: _MoistureTrendPainter(
                trend: trend,
                lineColor: Theme.of(context).colorScheme.primary,
                gridColor: fx.border,
                textColor: fx.textMuted,
                strongTextColor: fx.textStrong,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoistureTrendPainter extends CustomPainter {
  const _MoistureTrendPainter({
    required this.trend,
    required this.lineColor,
    required this.gridColor,
    required this.textColor,
    required this.strongTextColor,
  });

  final List<MoisturePoint> trend;
  final Color lineColor;
  final Color gridColor;
  final Color textColor;
  final Color strongTextColor;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 34.0;
    const right = 12.0;
    const top = 26.0;
    const bottom = 34.0;
    final chart = Rect.fromLTWH(
      left,
      top,
      size.width - left - right,
      size.height - top - bottom,
    );

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (var i = 0; i <= 4; i++) {
      final y = chart.top + chart.height * i / 4;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), gridPaint);
    }

    final points = <Offset>[];
    for (var i = 0; i < trend.length; i++) {
      final x = chart.left + chart.width * i / (trend.length - 1);
      final normalized = (trend[i].value - 35) / 35;
      final y = chart.bottom - chart.height * normalized.clamp(0.0, 1.0);
      points.add(Offset(x, y));
    }

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final control = Offset((current.dx + next.dx) / 2, current.dy);
      linePath.quadraticBezierTo(control.dx, control.dy, next.dx, next.dy);
    }

    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, chart.bottom)
      ..lineTo(points.first.dx, chart.bottom)
      ..close();
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [lineColor.withAlpha(62), lineColor.withAlpha(0)],
      ).createShader(chart);
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);

    final pointPaint = Paint()..color = lineColor;
    final pointStroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      canvas.drawCircle(point, 5, pointPaint);
      canvas.drawCircle(point, 5, pointStroke);
      _drawText(
        canvas,
        '${trend[i].value}%',
        Offset(point.dx, point.dy - 20),
        strongTextColor,
        11,
        FontWeight.w900,
        center: true,
      );
      _drawText(
        canvas,
        trend[i].label,
        Offset(point.dx, chart.bottom + 18),
        textColor,
        10,
        FontWeight.w700,
        center: true,
      );
    }

    for (final label in [40, 55, 70]) {
      final normalized = (label - 35) / 35;
      final y = chart.bottom - chart.height * normalized.clamp(0.0, 1.0);
      _drawText(
        canvas,
        '$label%',
        Offset(0, y - 7),
        textColor,
        10,
        FontWeight.w700,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    Color color,
    double fontSize,
    FontWeight weight, {
    bool center = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize, fontWeight: weight),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      center ? offset - Offset(painter.width / 2, 0) : offset,
    );
  }

  @override
  bool shouldRepaint(covariant _MoistureTrendPainter oldDelegate) {
    return oldDelegate.trend != trend ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor;
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid({
    required this.irrigationActive,
    required this.onStartIrrigation,
    required this.onStopIrrigation,
    required this.onGenerateReport,
    required this.onCropDoctor,
  });

  final bool irrigationActive;
  final VoidCallback onStartIrrigation;
  final VoidCallback onStopIrrigation;
  final VoidCallback onGenerateReport;
  final VoidCallback onCropDoctor;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = constraints.maxWidth >= 720 ? 16.0 : 12.0;
        final ratio = constraints.maxWidth >= 720 ? 2.4 : 1.55;
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: gap,
          mainAxisSpacing: gap,
          childAspectRatio: ratio,
          children: [
            _QuickActionCard(
              icon: Icons.water_drop_rounded,
              title: 'Start Irrigation',
              color: fx.success,
              background: fx.successContainer,
              active: irrigationActive,
              onTap: onStartIrrigation,
            ),
            _QuickActionCard(
              icon: Icons.stop_circle_outlined,
              title: 'Stop Irrigation',
              color: fx.danger,
              background: fx.dangerContainer,
              active: !irrigationActive,
              onTap: onStopIrrigation,
            ),
            _QuickActionCard(
              icon: Icons.description_outlined,
              title: 'Generate Report',
              color: fx.info,
              background: fx.infoContainer,
              onTap: onGenerateReport,
            ),
            _QuickActionCard(
              icon: Icons.health_and_safety_outlined,
              title: 'Crop Doctor',
              color: fx.warning,
              background: fx.warningContainer,
              onTap: onCropDoctor,
            ),
          ],
        );
      },
    );
  }
}

class _QuickActionCard extends StatefulWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.background,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String title;
  final Color color;
  final Color background;
  final VoidCallback onTap;
  final bool active;

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      scale: _pressed ? 0.97 : 1,
      child: Material(
        color: fx.surface,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: widget.active ? widget.color.withAlpha(140) : fx.border,
                width: widget.active ? 1.5 : 1,
              ),
              boxShadow: [
                ..._softShadow(context),
                if (widget.active)
                  BoxShadow(
                    color: widget.color.withAlpha(44),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: widget.background,
                  child: Icon(widget.icon, color: widget.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      color: fx.textStrong,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DemoIotBackend extends ChangeNotifier {
  DemoIotBackend._();

  static final DemoIotBackend instance = DemoIotBackend._();

  int _refreshTick = 0;
  final _agronomyRepository = const AgronomyRepository();
  final _telemetryRepository = const TelemetryRepository();
  IotWeather? _liveWeather;

  IotSnapshot get snapshot {
    final moisture = (42 + (_refreshTick % 3)).clamp(0, 100);
    return IotSnapshot(
      activeSensorCount: 8,
      weather:
          _liveWeather ??
          const IotWeather(temperature: 27, humidity: 68, windSpeed: 12),
      recommendation:
          'Soil moisture is getting low. Irrigation recommended in 2 hours.',
      moistureTrend: const [
        MoisturePoint('8 AM', 68),
        MoisturePoint('10 AM', 62),
        MoisturePoint('12 PM', 57),
        MoisturePoint('2 PM', 51),
        MoisturePoint('4 PM', 47),
        MoisturePoint('6 PM', 44),
        MoisturePoint('8 PM', 42),
      ],
      sensors: [
        IotSensorReading(
          name: 'Soil Moisture',
          value: '$moisture%',
          status: 'Normal',
          progress: moisture / 100,
          icon: Icons.water_drop_outlined,
          color: const Color(0xFF3B82F6),
        ),
        IotSensorReading(
          name: 'Temperature',
          value: '31°C',
          status: 'Warm',
          progress: 0.68,
          icon: Icons.thermostat_rounded,
          color: const Color(0xFFF97316),
        ),
        IotSensorReading(
          name: 'Humidity',
          value: '68%',
          status: 'Good',
          progress: 0.68,
          icon: Icons.opacity_rounded,
          color: const Color(0xFF10B981),
        ),
        IotSensorReading(
          name: 'Rain Sensor',
          value: 'No Rain',
          status: 'Dry',
          progress: 0.22,
          icon: Icons.cloud_outlined,
          color: const Color(0xFF6B7280),
        ),
        IotSensorReading(
          name: 'Water Level',
          value: '72%',
          status: 'Enough',
          progress: 0.72,
          icon: Icons.waves_rounded,
          color: const Color(0xFF10B981),
        ),
        IotSensorReading(
          name: 'Light Intensity',
          value: '820 lx',
          status: 'Bright',
          progress: 0.82,
          icon: Icons.wb_sunny_outlined,
          color: const Color(0xFFF97316),
        ),
        IotSensorReading(
          name: 'Water Tank',
          value: '64%',
          status: 'Ready',
          progress: 0.64,
          icon: Icons.water_rounded,
          color: const Color(0xFF3B82F6),
        ),
        IotSensorReading(
          name: 'Soil pH',
          value: '6.8',
          status: 'Balanced',
          progress: 0.68,
          icon: Icons.science_outlined,
          color: const Color(0xFF10B981),
        ),
      ],
    );
  }

  Future<void> refresh() async {
    try {
      final weather = await _agronomyRepository.weather();
      _liveWeather = IotWeather(
        temperature: _asInt(weather['temperature'], fallback: 27),
        humidity: _asInt(weather['humidity'], fallback: 68),
        windSpeed: _asInt(weather['wind_speed'], fallback: 12),
      );
    } catch (_) {
      // Keep demo weather when the backend is offline.
    }

    try {
      final moisture = (42 + (_refreshTick % 3)).toDouble();
      await _telemetryRepository.ingest({
        'device_id': 'fasalx-demo-soil-node',
        'moisture': moisture,
        'temperature': 31.0,
        'ph': 6.8,
        'nitrogen': 120.0,
        'phosphorus': 35.0,
        'potassium': 80.0,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (_) {
      // Telemetry submit is best-effort from this demo screen.
    }

    await Future<void>.delayed(const Duration(milliseconds: 650));
    _refreshTick++;
    notifyListeners();
  }

  int _asInt(Object? value, {required int fallback}) {
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}

class IotSnapshot {
  const IotSnapshot({
    required this.activeSensorCount,
    required this.weather,
    required this.sensors,
    required this.recommendation,
    required this.moistureTrend,
  });

  final int activeSensorCount;
  final IotWeather weather;
  final List<IotSensorReading> sensors;
  final String recommendation;
  final List<MoisturePoint> moistureTrend;
}

class IotWeather {
  const IotWeather({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
  });

  final int temperature;
  final int humidity;
  final int windSpeed;
}

class IotSensorReading {
  const IotSensorReading({
    required this.name,
    required this.value,
    required this.status,
    required this.progress,
    required this.icon,
    required this.color,
  });

  final String name;
  final String value;
  final String status;
  final double progress;
  final IconData icon;
  final Color color;
}

class MoisturePoint {
  const MoisturePoint(this.label, this.value);

  final String label;
  final int value;
}

List<BoxShadow> _softShadow(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return [
    BoxShadow(
      color: Colors.black.withAlpha(isDark ? 70 : 18),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];
}
