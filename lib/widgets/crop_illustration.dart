import 'package:flutter/material.dart';

class CropIllustration extends StatelessWidget {
  const CropIllustration({
    super.key,
    required this.crop,
    this.selected = false,
    this.compact = false,
  });

  final String crop;
  final bool selected;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = _CropPalette.forCrop(crop);
    final radius = compact ? 999.0 : 16.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: selected
              ? [palette.light, palette.mid.withAlpha(210)]
              : [palette.light.withAlpha(220), palette.light.withAlpha(120)],
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: selected
              ? palette.dark.withAlpha(160)
              : palette.mid.withAlpha(80),
          width: selected ? 1.4 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        painter: _CropPainter(
          crop: crop,
          palette: palette,
          selected: selected,
          compact: compact,
        ),
      ),
    );
  }
}

class _CropPalette {
  const _CropPalette({
    required this.light,
    required this.mid,
    required this.dark,
    required this.accent,
  });

  final Color light;
  final Color mid;
  final Color dark;
  final Color accent;

  static _CropPalette forCrop(String crop) {
    switch (crop.toLowerCase()) {
      case 'wheat':
      case 'bajra':
        return const _CropPalette(
          light: Color(0xFFFFF4C7),
          mid: Color(0xFFE8B949),
          dark: Color(0xFF8A5A13),
          accent: Color(0xFFFFD66B),
        );
      case 'rice':
        return const _CropPalette(
          light: Color(0xFFE8F7D6),
          mid: Color(0xFF87B64B),
          dark: Color(0xFF2F6D28),
          accent: Color(0xFFFFF6D0),
        );
      case 'tomato':
        return const _CropPalette(
          light: Color(0xFFFFE2D9),
          mid: Color(0xFFE94B35),
          dark: Color(0xFF8F1D15),
          accent: Color(0xFFFF7A5C),
        );
      case 'cotton':
        return const _CropPalette(
          light: Color(0xFFF4F7FF),
          mid: Color(0xFFAFC0E8),
          dark: Color(0xFF46577F),
          accent: Color(0xFFFFFFFF),
        );
      case 'maize':
      case 'corn':
        return const _CropPalette(
          light: Color(0xFFFFF0C2),
          mid: Color(0xFFF0B935),
          dark: Color(0xFF3F7B32),
          accent: Color(0xFFFFD54F),
        );
      case 'sugarcane':
        return const _CropPalette(
          light: Color(0xFFE5F6D6),
          mid: Color(0xFF75B843),
          dark: Color(0xFF246B2D),
          accent: Color(0xFFB8D45A),
        );
      case 'potato':
      case 'groundnut':
        return const _CropPalette(
          light: Color(0xFFFFEDD7),
          mid: Color(0xFFC98243),
          dark: Color(0xFF7A431B),
          accent: Color(0xFFD9A15F),
        );
      case 'onion':
        return const _CropPalette(
          light: Color(0xFFFFE6F0),
          mid: Color(0xFFC55B8A),
          dark: Color(0xFF7A2856),
          accent: Color(0xFFF1A7C7),
        );
      case 'mustard':
        return const _CropPalette(
          light: Color(0xFFFFF7C9),
          mid: Color(0xFFE3C72D),
          dark: Color(0xFF5C751F),
          accent: Color(0xFFFFE45C),
        );
      case 'soybean':
        return const _CropPalette(
          light: Color(0xFFE8F4DD),
          mid: Color(0xFF79A85C),
          dark: Color(0xFF3E6B35),
          accent: Color(0xFFB7D284),
        );
      default:
        return const _CropPalette(
          light: Color(0xFFE8F5E9),
          mid: Color(0xFF81C784),
          dark: Color(0xFF2E7D32),
          accent: Color(0xFFA5D6A7),
        );
    }
  }
}

class _CropPainter extends CustomPainter {
  const _CropPainter({
    required this.crop,
    required this.palette,
    required this.selected,
    required this.compact,
  });

  final String crop;
  final _CropPalette palette;
  final bool selected;
  final bool compact;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;

    final soil = Paint()
      ..color = palette.dark.withAlpha(compact ? 45 : 58)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.82),
        width: w * 0.68,
        height: h * 0.14,
      ),
      soil,
    );

    switch (crop.toLowerCase()) {
      case 'wheat':
      case 'bajra':
        _drawGrain(canvas, size);
        break;
      case 'rice':
        _drawRice(canvas, size);
        break;
      case 'tomato':
        _drawTomato(canvas, size);
        break;
      case 'cotton':
        _drawCotton(canvas, size);
        break;
      case 'maize':
      case 'corn':
        _drawMaize(canvas, size);
        break;
      case 'sugarcane':
        _drawSugarcane(canvas, size);
        break;
      case 'potato':
      case 'groundnut':
        _drawTuber(canvas, size);
        break;
      case 'onion':
        _drawOnion(canvas, size);
        break;
      case 'mustard':
        _drawMustard(canvas, size);
        break;
      case 'soybean':
        _drawSoybean(canvas, size);
        break;
      default:
        _drawGeneric(canvas, size);
    }

    if (selected) {
      final badge = Paint()..color = Colors.white.withAlpha(230);
      final check = Paint()
        ..color = palette.dark
        ..style = PaintingStyle.stroke
        ..strokeWidth = compact ? 1.7 : 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final r = compact ? w * 0.14 : w * 0.12;
      final center = Offset(w - r * 1.45, r * 1.45);
      canvas.drawCircle(center, r, badge);
      final path = Path()
        ..moveTo(center.dx - r * 0.45, center.dy)
        ..lineTo(center.dx - r * 0.12, center.dy + r * 0.34)
        ..lineTo(center.dx + r * 0.52, center.dy - r * 0.38);
      canvas.drawPath(path, check);
    }
  }

  void _drawStem(Canvas canvas, Size size, {double x = 0.5, double top = 0.26}) {
    final paint = Paint()
      ..color = palette.dark
      ..strokeWidth = size.width * (compact ? 0.045 : 0.035)
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * x, size.height * 0.78),
      Offset(size.width * x, size.height * top),
      paint,
    );
  }

  void _drawLeaf(
    Canvas canvas,
    Size size,
    Offset center,
    double width,
    double height,
    double angle,
  ) {
    final rect = Rect.fromCenter(center: center, width: width, height: height);
    final path = Path()
      ..moveTo(rect.left, center.dy)
      ..quadraticBezierTo(center.dx, rect.top, rect.right, center.dy)
      ..quadraticBezierTo(center.dx, rect.bottom, rect.left, center.dy);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawPath(path, Paint()..color = palette.mid);
    canvas.restore();
  }

  void _drawGeneric(Canvas canvas, Size size) {
    _drawStem(canvas, size);
    _drawLeaf(
      canvas,
      size,
      Offset(size.width * 0.38, size.height * 0.56),
      size.width * 0.34,
      size.height * 0.17,
      -0.45,
    );
    _drawLeaf(
      canvas,
      size,
      Offset(size.width * 0.62, size.height * 0.46),
      size.width * 0.32,
      size.height * 0.16,
      0.45,
    );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.3),
      size.width * 0.1,
      Paint()..color = palette.accent,
    );
  }

  void _drawGrain(Canvas canvas, Size size) {
    for (final x in [0.38, 0.5, 0.62]) {
      _drawStem(canvas, size, x: x, top: 0.2);
      for (var i = 0; i < 4; i++) {
        final y = size.height * (0.24 + i * 0.08);
        _drawLeaf(canvas, size, Offset(size.width * (x - 0.035), y), size.width * 0.15, size.height * 0.055, -0.7);
        _drawLeaf(canvas, size, Offset(size.width * (x + 0.035), y), size.width * 0.15, size.height * 0.055, 0.7);
      }
    }
  }

  void _drawRice(Canvas canvas, Size size) {
    for (final x in [0.34, 0.45, 0.56, 0.67]) {
      _drawStem(canvas, size, x: x, top: 0.27);
      _drawLeaf(
        canvas,
        size,
        Offset(size.width * (x - 0.04), size.height * 0.48),
        size.width * 0.18,
        size.height * 0.08,
        -0.95,
      );
    }
  }

  void _drawTomato(Canvas canvas, Size size) {
    _drawStem(canvas, size, top: 0.24);
    _drawLeaf(
      canvas,
      size,
      Offset(size.width * 0.38, size.height * 0.5),
      size.width * 0.32,
      size.height * 0.13,
      -0.45,
    );
    _drawLeaf(
      canvas,
      size,
      Offset(size.width * 0.62, size.height * 0.43),
      size.width * 0.3,
      size.height * 0.13,
      0.45,
    );
    final fruit = Paint()..color = palette.mid;
    for (final offset in [Offset(0.43, 0.34), Offset(0.57, 0.38), Offset(0.5, 0.49)]) {
      canvas.drawCircle(
        Offset(size.width * offset.dx, size.height * offset.dy),
        size.width * 0.09,
        fruit,
      );
    }
  }

  void _drawCotton(Canvas canvas, Size size) {
    _drawStem(canvas, size, top: 0.28);
    _drawLeaf(
      canvas,
      size,
      Offset(size.width * 0.38, size.height * 0.55),
      size.width * 0.26,
      size.height * 0.12,
      -0.45,
    );
    _drawLeaf(
      canvas,
      size,
      Offset(size.width * 0.62, size.height * 0.53),
      size.width * 0.26,
      size.height * 0.12,
      0.45,
    );
    final pod = Paint()..color = palette.accent;
    for (final center in [Offset(0.45, 0.33), Offset(0.55, 0.33), Offset(0.5, 0.26)]) {
      canvas.drawCircle(
        Offset(size.width * center.dx, size.height * center.dy),
        size.width * 0.085,
        pod,
      );
    }
  }

  void _drawMaize(Canvas canvas, Size size) {
    _drawStem(canvas, size, top: 0.2);
    _drawLeaf(
      canvas,
      size,
      Offset(size.width * 0.36, size.height * 0.52),
      size.width * 0.36,
      size.height * 0.16,
      -0.8,
    );
    _drawLeaf(
      canvas,
      size,
      Offset(size.width * 0.64, size.height * 0.5),
      size.width * 0.36,
      size.height * 0.16,
      0.8,
    );
    final cobRect = Rect.fromCenter(
      center: Offset(size.width * 0.52, size.height * 0.42),
      width: size.width * 0.16,
      height: size.height * 0.28,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(cobRect, Radius.circular(size.width * 0.09)),
      Paint()..color = palette.accent,
    );
  }

  void _drawSugarcane(Canvas canvas, Size size) {
    final cane = Paint()
      ..color = palette.mid
      ..strokeWidth = size.width * 0.065
      ..strokeCap = StrokeCap.round;
    for (final x in [0.42, 0.52, 0.62]) {
      canvas.drawLine(
        Offset(size.width * x, size.height * 0.78),
        Offset(size.width * (x - 0.05), size.height * 0.18),
        cane,
      );
    }
    _drawLeaf(
      canvas,
      size,
      Offset(size.width * 0.42, size.height * 0.28),
      size.width * 0.34,
      size.height * 0.13,
      -0.65,
    );
    _drawLeaf(
      canvas,
      size,
      Offset(size.width * 0.63, size.height * 0.26),
      size.width * 0.34,
      size.height * 0.13,
      0.65,
    );
  }

  void _drawTuber(Canvas canvas, Size size) {
    final tuber = Paint()..color = palette.mid;
    for (final item in [Offset(0.38, 0.62), Offset(0.55, 0.58), Offset(0.66, 0.68)]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * item.dx, size.height * item.dy),
          width: size.width * 0.22,
          height: size.height * 0.14,
        ),
        tuber,
      );
    }
    _drawStem(canvas, size, top: 0.38);
    _drawLeaf(
      canvas,
      size,
      Offset(size.width * 0.42, size.height * 0.42),
      size.width * 0.28,
      size.height * 0.12,
      -0.45,
    );
    _drawLeaf(
      canvas,
      size,
      Offset(size.width * 0.6, size.height * 0.38),
      size.width * 0.26,
      size.height * 0.12,
      0.45,
    );
  }

  void _drawOnion(Canvas canvas, Size size) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.62),
        width: size.width * 0.32,
        height: size.height * 0.27,
      ),
      Paint()..color = palette.mid,
    );
    for (final x in [0.42, 0.5, 0.58]) {
      _drawStem(canvas, size, x: x, top: 0.18);
    }
  }

  void _drawMustard(Canvas canvas, Size size) {
    _drawStem(canvas, size, top: 0.24);
    _drawLeaf(canvas, size, Offset(size.width * 0.39, size.height * 0.54), size.width * 0.3, size.height * 0.13, -0.5);
    _drawLeaf(canvas, size, Offset(size.width * 0.61, size.height * 0.48), size.width * 0.28, size.height * 0.12, 0.5);
    final flower = Paint()..color = palette.accent;
    for (final center in [Offset(0.43, 0.31), Offset(0.54, 0.28), Offset(0.6, 0.38)]) {
      canvas.drawCircle(
        Offset(size.width * center.dx, size.height * center.dy),
        size.width * 0.045,
        flower,
      );
    }
  }

  void _drawSoybean(Canvas canvas, Size size) {
    _drawStem(canvas, size, top: 0.25);
    for (final center in [Offset(0.38, 0.48), Offset(0.5, 0.34), Offset(0.62, 0.48)]) {
      _drawLeaf(
        canvas,
        size,
        Offset(size.width * center.dx, size.height * center.dy),
        size.width * 0.25,
        size.height * 0.13,
        center.dx < 0.5 ? -0.45 : 0.45,
      );
    }
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.57),
        width: size.width * 0.2,
        height: size.height * 0.09,
      ),
      Paint()..color = palette.accent,
    );
  }

  @override
  bool shouldRepaint(covariant _CropPainter oldDelegate) {
    return oldDelegate.crop != crop ||
        oldDelegate.selected != selected ||
        oldDelegate.compact != compact;
  }
}
