import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

/// Custom side-drawer container matching the Page 1 sideways-perfume-bottle notch:
/// tallest flare at the screen edge (y=0..h) -> flat horizontal neck ->
/// subtle outward step around the crisp white rounded drawer body.
class FlaredSideDrawerContainer extends StatelessWidget {
  const FlaredSideDrawerContainer({
    super.key,
    required this.fromLeft,
    required this.width,
    required this.maxHeight,
    required this.child,
    this.outerRadius = 26.0,
  });

  final bool fromLeft;
  final double width;
  final double maxHeight;
  final Widget child;
  final double outerRadius;

  static const double _neckEndX = 24.0;
  static const double _bodyInsetY = 12.0;
  static const double _rimPadding = 6.0;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: width,
        minWidth: width,
        maxHeight: maxHeight + ((_bodyInsetY + _rimPadding) * 2),
      ),
      child: CustomPaint(
        painter: _BottleCollarPainter(
          fromLeft: fromLeft,
          neckEndX: _neckEndX,
          bodyInsetY: _bodyInsetY,
          outerRadius: outerRadius,
        ),
        child: Padding(
          padding: EdgeInsets.only(
            top: _bodyInsetY + _rimPadding,
            bottom: _bodyInsetY + _rimPadding,
            left: fromLeft ? _neckEndX + 3 : _rimPadding,
            right: fromLeft ? _rimPadding : _neckEndX + 3,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.borderSubtle.withValues(alpha: 0.7),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: Offset(fromLeft ? 3 : -3, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

Path _buildBottleCollarPath(
  Size size, {
  required bool fromLeft,
  required double neckEndX,
  required double bodyInsetY,
  required double r,
}) {
  final w = size.width;
  final h = size.height;
  final neckY = bodyInsetY + 11.0; // Flat neck sits slightly inside body rim

  if (fromLeft) {
    return Path()
      // Tallest flare at left edge -> curves into flat horizontal neck
      ..moveTo(0, 0)
      ..quadraticBezierTo(0, neckY, 14, neckY)
      ..lineTo(neckEndX - 3, neckY)
      // Steps outward to rounded body rim
      ..quadraticBezierTo(neckEndX + 1, neckY, neckEndX + 4, bodyInsetY + 5)
      ..quadraticBezierTo(neckEndX + 7, bodyInsetY, neckEndX + 16, bodyInsetY)
      ..lineTo(w - r, bodyInsetY)
      ..quadraticBezierTo(w, bodyInsetY, w, bodyInsetY + r)
      ..lineTo(w, h - bodyInsetY - r)
      ..quadraticBezierTo(w, h - bodyInsetY, w - r, h - bodyInsetY)
      ..lineTo(neckEndX + 16, h - bodyInsetY)
      ..quadraticBezierTo(
        neckEndX + 7,
        h - bodyInsetY,
        neckEndX + 4,
        h - bodyInsetY - 5,
      )
      // Steps back into flat neck -> bottom flare at left edge
      ..quadraticBezierTo(neckEndX + 1, h - neckY, neckEndX - 3, h - neckY)
      ..lineTo(14, h - neckY)
      ..quadraticBezierTo(0, h - neckY, 0, h)
      ..close();
  }

  final rightNeckX = w - neckEndX;
  return Path()
    ..moveTo(w, 0)
    ..quadraticBezierTo(w, neckY, w - 14, neckY)
    ..lineTo(rightNeckX + 3, neckY)
    ..quadraticBezierTo(rightNeckX - 1, neckY, rightNeckX - 4, bodyInsetY + 5)
    ..quadraticBezierTo(rightNeckX - 7, bodyInsetY, rightNeckX - 16, bodyInsetY)
    ..lineTo(r, bodyInsetY)
    ..quadraticBezierTo(0, bodyInsetY, 0, bodyInsetY + r)
    ..lineTo(0, h - bodyInsetY - r)
    ..quadraticBezierTo(0, h - bodyInsetY, r, h - bodyInsetY)
    ..lineTo(rightNeckX - 16, h - bodyInsetY)
    ..quadraticBezierTo(
      rightNeckX - 7,
      h - bodyInsetY,
      rightNeckX - 4,
      h - bodyInsetY - 5,
    )
    ..quadraticBezierTo(rightNeckX - 1, h - neckY, rightNeckX + 3, h - neckY)
    ..lineTo(w - 14, h - neckY)
    ..quadraticBezierTo(w, h - neckY, w, h)
    ..close();
}

class _BottleCollarPainter extends CustomPainter {
  const _BottleCollarPainter({
    required this.fromLeft,
    required this.neckEndX,
    required this.bodyInsetY,
    required this.outerRadius,
  });

  final bool fromLeft;
  final double neckEndX;
  final double bodyInsetY;
  final double outerRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildBottleCollarPath(
      size,
      fromLeft: fromLeft,
      neckEndX: neckEndX,
      bodyInsetY: bodyInsetY,
      r: outerRadius,
    );

    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.08), 12, false);

    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.notchCollar
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.borderSubtle
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );
  }

  @override
  bool shouldRepaint(covariant _BottleCollarPainter oldDelegate) =>
      oldDelegate.fromLeft != fromLeft ||
      oldDelegate.neckEndX != neckEndX ||
      oldDelegate.bodyInsetY != bodyInsetY ||
      oldDelegate.outerRadius != outerRadius;
}
