import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Editorial empty-state illustration for Search/Filter featuring 3 neutral
/// minimalist perfume bottle silhouettes with one gently tilted/leaning.
class EmptyPerfumeState extends StatelessWidget {
  const EmptyPerfumeState({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 146,
            height: 92,
            child: CustomPaint(
              painter: const _EmptyBottlesPainter(),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTheme.brandFont,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.inkPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTheme.contentFont,
              fontSize: 13,
              height: 1.38,
              color: AppColors.inkSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated sad-bottle empty-state illustration specifically for an empty Cart.
class AnimatedEmptyCartState extends StatefulWidget {
  const AnimatedEmptyCartState({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  State<AnimatedEmptyCartState> createState() => _AnimatedEmptyCartStateState();
}

class _AnimatedEmptyCartStateState extends State<AnimatedEmptyCartState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = Curves.easeInOut.transform(_controller.value);
              final dy = math.sin(t * math.pi) * -4.0;
              final tilt = math.sin(t * math.pi * 2) * 0.07;
              return Transform.translate(
                offset: Offset(0, dy),
                child: Transform.rotate(
                  angle: tilt,
                  child: child,
                ),
              );
            },
            child: SizedBox(
              width: 68,
              height: 86,
              child: CustomPaint(
                painter: const _SingleSadBottlePainter(),
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 18),
                    child: Icon(
                      PhosphorIconsRegular.smileySad,
                      size: 26,
                      color: AppColors.inkSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTheme.brandFont,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.inkPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTheme.contentFont,
              fontSize: 13,
              height: 1.38,
              color: AppColors.inkSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBottlesPainter extends CustomPainter {
  const _EmptyBottlesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Soft ground shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.50, h * 0.90),
        width: w * 0.78,
        height: 10,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // 1. Left bottle: neutral frosted white/gray (upright)
    _drawBottle(
      canvas,
      center: Offset(w * 0.28, h * 0.56),
      bodyW: 26,
      bodyH: 46,
      capW: 11,
      capH: 10,
      bodyColor: AppColors.surface,
      capColor: AppColors.inkMuted,
      angle: -0.03,
    );

    // 2. Center bottle: neutral light-gray (upright)
    _drawBottle(
      canvas,
      center: Offset(w * 0.48, h * 0.50),
      bodyW: 34,
      bodyH: 54,
      capW: 15,
      capH: 13,
      bodyColor: AppColors.notchCollar,
      capColor: AppColors.inkPrimary.withValues(alpha: 0.80),
      angle: 0.0,
    );

    // 3. Right bottle: neutral off-white tilted / leaning gently
    _drawBottle(
      canvas,
      center: Offset(w * 0.72, h * 0.57),
      bodyW: 28,
      bodyH: 44,
      capW: 12,
      capH: 10,
      bodyColor: AppColors.surfaceMuted,
      capColor: AppColors.inkSecondary.withValues(alpha: 0.75),
      angle: 0.26,
    );

    // Subtle neutral sparkles
    _drawSparkle(canvas, Offset(w * 0.16, h * 0.26), 4.0, AppColors.inkMuted);
    _drawSparkle(
      canvas,
      Offset(w * 0.84, h * 0.24),
      5.0,
      AppColors.inkSecondary,
    );
  }

  void _drawBottle(
    Canvas canvas, {
    required Offset center,
    required double bodyW,
    required double bodyH,
    required double capW,
    required double capH,
    required Color bodyColor,
    required Color capColor,
    required double angle,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(0, capH * 0.5),
        width: bodyW,
        height: bodyH,
      ),
      const Radius.circular(8),
    );

    canvas.drawRRect(bodyRect, Paint()..color = bodyColor);
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..color = AppColors.borderSubtle
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );

    // Neck
    final neckRect = Rect.fromCenter(
      center: Offset(0, -bodyH * 0.5 + capH * 0.25),
      width: capW * 0.65,
      height: 6,
    );
    canvas.drawRect(neckRect, Paint()..color = AppColors.notchCollar);

    // Cap
    final capRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(0, -bodyH * 0.5 - capH * 0.25),
        width: capW,
        height: capH,
      ),
      const Radius.circular(3.5),
    );
    canvas.drawRRect(capRect, Paint()..color = capColor);

    canvas.restore();
  }

  void _drawSparkle(Canvas canvas, Offset c, double r, Color color) {
    final path = Path()
      ..moveTo(c.dx, c.dy - r)
      ..lineTo(c.dx + r * 0.3, c.dy - r * 0.3)
      ..lineTo(c.dx + r, c.dy)
      ..lineTo(c.dx + r * 0.3, c.dy + r * 0.3)
      ..lineTo(c.dx, c.dy + r)
      ..lineTo(c.dx - r * 0.3, c.dy + r * 0.3)
      ..lineTo(c.dx - r, c.dy)
      ..lineTo(c.dx - r * 0.3, c.dy - r * 0.3)
      ..close();
    canvas.drawPath(
      path,
      Paint()..color = color.withValues(alpha: 0.45),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SingleSadBottlePainter extends CustomPainter {
  const _SingleSadBottlePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;

    // Bottle cap
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, h * 0.11),
          width: w * 0.34,
          height: h * 0.14,
        ),
        const Radius.circular(5),
      ),
      Paint()..color = AppColors.inkPrimary.withValues(alpha: 0.85),
    );

    // Bottle neck
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(cx, h * 0.21),
        width: w * 0.22,
        height: h * 0.08,
      ),
      Paint()..color = AppColors.notchCollar,
    );

    // Bottle body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.12, h * 0.25, w * 0.88, h * 0.94),
      const Radius.circular(16),
    );
    canvas.drawRRect(bodyRect, Paint()..color = AppColors.background);
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..color = AppColors.borderSubtle
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
