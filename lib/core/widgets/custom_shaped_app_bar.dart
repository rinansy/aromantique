import 'package:material_ui/material_ui.dart';
import '../theme/app_colors.dart';

/// Custom AppBar with rounded bottom corners and a subtle upward center peak,
/// matching the signature header silhouette on both pages.
class CustomShapedAppBar extends StatelessWidget {
  const CustomShapedAppBar({
    super.key,
    required this.child,
    this.contentHeight = 64,
    this.peakHeight = 11,
    this.cornerRadius = 22,
  });

  final Widget child;
  final double contentHeight;
  final double peakHeight;
  final double cornerRadius;

  static double totalHeight(
    BuildContext context, {
    double contentHeight = 64,
    double peakHeight = 11,
  }) {
    return MediaQuery.paddingOf(context).top + contentHeight + peakHeight;
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final totalHeight = topPadding + contentHeight + peakHeight;

    return SizedBox(
      height: totalHeight,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _AppBarShapePainter(
                peakHeight: peakHeight,
                cornerRadius: cornerRadius,
              ),
            ),
          ),
          ClipPath(
            clipper: _AppBarShapeClipper(
              peakHeight: peakHeight,
              cornerRadius: cornerRadius,
            ),
            child: Container(
              color: AppColors.surface,
              padding: EdgeInsets.only(
                top: topPadding,
                left: 20,
                right: 20,
                bottom: peakHeight,
              ),
              alignment: Alignment.center,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

Path _buildAppBarPath(Size size, double peakHeight, double r) {
  final w = size.width;
  final h = size.height;
  final midX = w * 0.5;
  final bottomY = h - 2;
  final peakY = bottomY - peakHeight;

  return Path()
    ..moveTo(0, 0)
    ..lineTo(0, bottomY - r)
    ..quadraticBezierTo(0, bottomY, r, bottomY)
    ..lineTo(midX - 18, peakY + 2.5)
    ..quadraticBezierTo(midX, peakY - 1.5, midX + 18, peakY + 2.5)
    ..lineTo(w - r, bottomY)
    ..quadraticBezierTo(w, bottomY, w, bottomY - r)
    ..lineTo(w, 0)
    ..close();
}

class _AppBarShapeClipper extends CustomClipper<Path> {
  const _AppBarShapeClipper({
    required this.peakHeight,
    required this.cornerRadius,
  });

  final double peakHeight;
  final double cornerRadius;

  @override
  Path getClip(Size size) => _buildAppBarPath(size, peakHeight, cornerRadius);

  @override
  bool shouldReclip(covariant _AppBarShapeClipper oldClipper) =>
      oldClipper.peakHeight != peakHeight ||
      oldClipper.cornerRadius != cornerRadius;
}

class _AppBarShapePainter extends CustomPainter {
  const _AppBarShapePainter({
    required this.peakHeight,
    required this.cornerRadius,
  });

  final double peakHeight;
  final double cornerRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildAppBarPath(size, peakHeight, cornerRadius);

    // Subtle soft shadow under the shaped edge
    canvas.drawShadow(
      path,
      Colors.black.withValues(alpha: 0.08),
      6,
      false,
    );

    // Crisp hairline border along the bottom contour
    final borderPaint = Paint()
      ..color = AppColors.borderSubtle
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _AppBarShapePainter oldDelegate) =>
      oldDelegate.peakHeight != peakHeight ||
      oldDelegate.cornerRadius != cornerRadius;
}
