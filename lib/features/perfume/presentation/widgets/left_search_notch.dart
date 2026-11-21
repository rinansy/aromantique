import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../../core/theme/app_colors.dart';

/// Left-edge search notch shaped like a sideways perfume bottle:
/// flared base at the screen edge -> narrower neck -> stepped-out rounded collar
/// framing the crisp white rounded-square bottle body.
class LeftSearchNotch extends StatelessWidget {
  const LeftSearchNotch({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  static const double _width = 66;
  static const double _height = 68;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: _width,
        height: _height,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: const _BottleNotchPainter(),
              ),
            ),
            // White rounded-square bottle body sitting inside the stepped-out rim
            Positioned(
              left: 19,
              top: 13,
              right: 5,
              bottom: 13,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  PhosphorIconsRegular.magnifyingGlass,
                  size: 19,
                  color: AppColors.notchSearchAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottleNotchPainter extends CustomPainter {
  const _BottleNotchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    const neckTop = 14.0;
    const neckEndX = 15.0;
    const bodyTop = 8.0;
    const bodyBottom = 8.0;
    const bodyR = 16.0;

    final path = Path()
      // Top flared foot at left edge -> narrows into bottle neck
      ..moveTo(0, 0)
      ..quadraticBezierTo(0, neckTop, 10, neckTop)
      ..lineTo(neckEndX - 3, neckTop)
      // Step outward into rounded bottle body rim
      ..quadraticBezierTo(neckEndX + 1, neckTop, neckEndX + 4, bodyTop + 4)
      ..quadraticBezierTo(neckEndX + 6, bodyTop, neckEndX + 14, bodyTop)
      ..lineTo(w - bodyR, bodyTop)
      ..quadraticBezierTo(w, bodyTop, w, bodyTop + bodyR)
      ..lineTo(w, h - bodyBottom - bodyR)
      ..quadraticBezierTo(w, h - bodyBottom, w - bodyR, h - bodyBottom)
      ..lineTo(neckEndX + 14, h - bodyBottom)
      ..quadraticBezierTo(
          neckEndX + 6, h - bodyBottom, neckEndX + 4, h - bodyBottom - 4)
      // Step back into bottle neck -> bottom flared foot at left edge
      ..quadraticBezierTo(neckEndX + 1, h - neckTop, neckEndX - 3, h - neckTop)
      ..lineTo(10, h - neckTop)
      ..quadraticBezierTo(0, h - neckTop, 0, h)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.notchCollar
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
