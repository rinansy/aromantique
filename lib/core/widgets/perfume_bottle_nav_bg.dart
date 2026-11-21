import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

/// Custom perfume-bottle-shaped ("wadah parfum") selected indicator background.
class PerfumeBottleNavBg extends StatelessWidget {
  const PerfumeBottleNavBg({
    super.key,
    required this.isSelected,
    required this.child,
    this.width = 46,
    this.height = 50,
    this.fillColor = AppColors.sageHighlight,
  });

  final bool isSelected;
  final Widget child;
  final double width;
  final double height;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            opacity: isSelected ? 1.0 : 0.0,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              scale: isSelected ? 1.0 : 0.75,
              child: CustomPaint(
                size: Size(width, height),
                painter: _PerfumeBottlePainter(color: fillColor),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: height * 0.14),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _PerfumeBottlePainter extends CustomPainter {
  const _PerfumeBottlePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Bottle cap + neck + rounded squircle body as one unified silhouette
    final capW = w * 0.36;
    final capLeft = (w - capW) / 2;
    final capRight = capLeft + capW;
    final shoulderY = h * 0.22;
    final bodyLeft = w * 0.08;
    final bodyRight = w * 0.92;
    const bodyR = 12.0;

    final path = Path()
      // Cap top
      ..moveTo(capLeft + 4, h * 0.04)
      ..lineTo(capRight - 4, h * 0.04)
      ..quadraticBezierTo(capRight, h * 0.04, capRight, h * 0.09)
      // Neck right down to shoulder
      ..lineTo(capRight, shoulderY - 3)
      ..quadraticBezierTo(capRight, shoulderY, capRight + 4, shoulderY)
      // Right shoulder & body
      ..lineTo(bodyRight - bodyR, shoulderY)
      ..quadraticBezierTo(bodyRight, shoulderY, bodyRight, shoulderY + bodyR)
      ..lineTo(bodyRight, h - bodyR)
      ..quadraticBezierTo(bodyRight, h, bodyRight - bodyR, h)
      // Bottom
      ..lineTo(bodyLeft + bodyR, h)
      ..quadraticBezierTo(bodyLeft, h, bodyLeft, h - bodyR)
      // Left body & shoulder
      ..lineTo(bodyLeft, shoulderY + bodyR)
      ..quadraticBezierTo(bodyLeft, shoulderY, bodyLeft + bodyR, shoulderY)
      ..lineTo(capLeft - 4, shoulderY)
      ..quadraticBezierTo(capLeft, shoulderY, capLeft, shoulderY - 3)
      // Neck left up to cap
      ..lineTo(capLeft, h * 0.09)
      ..quadraticBezierTo(capLeft, h * 0.04, capLeft + 4, h * 0.04)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PerfumeBottlePainter oldDelegate) =>
      oldDelegate.color != color;
}
