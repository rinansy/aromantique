import 'package:material_ui/material_ui.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/perfume.dart';

/// Displays the transparent perfume bottle product image if available,
/// falling back to a brand-styled custom-painted bottle.
class PerfumeBottlePlaceholder extends StatelessWidget {
  const PerfumeBottlePlaceholder({
    super.key,
    required this.perfume,
    this.height = 148,
    this.width = 96,
    this.imageScale = 1.0,
  });

  final Perfume perfume;
  final double height;
  final double width;
  final double imageScale;

  @override
  Widget build(BuildContext context) {
    if (perfume.bottleImageAsset != null) {
      return SizedBox(
        width: width,
        height: height,
        child: ClipRect(
          child: Transform.scale(
            scale: imageScale,
            child: Image.asset(
              perfume.bottleImageAsset!,
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _BottlePainter(
          brand: perfume.brand,
          primary: perfume.bottlePrimary,
          secondary: perfume.bottleSecondary,
          label: perfume.name.toUpperCase(),
        ),
      ),
    );
  }
}

class _BottlePainter extends CustomPainter {
  const _BottlePainter({
    required this.brand,
    required this.primary,
    required this.secondary,
    required this.label,
  });

  final String brand;
  final Color primary;
  final Color secondary;
  final String label;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final isCreed = brand.toLowerCase() == 'creed';
    final isLeLabo = brand.toLowerCase() == 'le labo';

    // Soft ground shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, h * 0.94),
        width: w * 0.56,
        height: h * 0.05,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    if (isCreed) {
      // Creed Aventus sculpted flask: clear upper + matte black leather-style lower wrap
      final bodyRect = RRect.fromLTRBAndCorners(
        w * 0.18,
        h * 0.30,
        w * 0.82,
        h * 0.92,
        topLeft: Radius.circular(w * 0.20),
        topRight: Radius.circular(w * 0.20),
        bottomLeft: Radius.circular(w * 0.10),
        bottomRight: Radius.circular(w * 0.10),
      );

      canvas.drawRRect(
        bodyRect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.bottleGlassHighlight,
              secondary,
            ],
          ).createShader(bodyRect.outerRect),
      );

      // Matte black lower wrap
      canvas.drawRRect(
        RRect.fromLTRBAndCorners(
          w * 0.18,
          h * 0.54,
          w * 0.82,
          h * 0.92,
          bottomLeft: Radius.circular(w * 0.10),
          bottomRight: Radius.circular(w * 0.10),
        ),
        Paint()..color = AppColors.bottleGlassCap,
      );

      // Silver collar & sculpted black cap
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(cx, h * 0.26),
          width: w * 0.22,
          height: h * 0.08,
        ),
        Paint()..color = AppColors.bottleSilver,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, h * 0.16),
            width: w * 0.34,
            height: h * 0.14,
          ),
          Radius.circular(w * 0.06),
        ),
        Paint()..color = AppColors.bottleCapDeep,
      );

      // White label text on matte black wrap
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            fontFamily: AppTheme.contentFont,
            fontSize: w * 0.09,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: w * 0.54);
      tp.paint(canvas, Offset(cx - tp.width / 2, h * 0.69));
      return;
    }

    // Cylindrical apothecary bottle (Le Labo / classic)
    final bodyRect = RRect.fromLTRBAndCorners(
      w * 0.20,
      h * 0.28,
      w * 0.80,
      h * 0.92,
      topLeft: Radius.circular(w * 0.14),
      topRight: Radius.circular(w * 0.14),
      bottomLeft: Radius.circular(w * 0.07),
      bottomRight: Radius.circular(w * 0.07),
    );

    canvas.drawRRect(
      bodyRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            secondary.withValues(alpha: 0.90),
            primary.withValues(alpha: 0.92),
          ],
        ).createShader(bodyRect.outerRect),
    );

    // Glass highlight
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.24, h * 0.34, w * 0.06, h * 0.50),
        Radius.circular(w * 0.03),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.38),
    );

    // Cap (brushed silver for Le Labo, dark for others)
    final capColor =
        isLeLabo ? AppColors.bottleSilverMuted : AppColors.bottleGlassCap;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(cx, h * 0.25),
        width: w * 0.22,
        height: h * 0.07,
      ),
      Paint()..color = capColor.withValues(alpha: 0.85),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, h * 0.16),
          width: w * 0.30,
          height: h * 0.13,
        ),
        Radius.circular(w * 0.03),
      ),
      Paint()..color = capColor,
    );

    // Minimalist white paper label for Le Labo
    if (isLeLabo) {
      final labelRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, h * 0.62),
          width: w * 0.52,
          height: h * 0.34,
        ),
        Radius.circular(w * 0.02),
      );
      canvas.drawRRect(labelRect, Paint()..color = AppColors.bottlePaper);
      canvas.drawRRect(
        labelRect,
        Paint()
          ..color = AppColors.bottlePaperBorder
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontFamily: AppTheme.contentFont,
          fontSize: w * 0.08,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: AppColors.inkPrimary.withValues(alpha: 0.85),
        ),
      ),
      maxLines: 1,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: w * 0.48);

    tp.paint(canvas, Offset(cx - tp.width / 2, h * 0.58));
  }

  @override
  bool shouldRepaint(covariant _BottlePainter oldDelegate) =>
      oldDelegate.brand != brand ||
      oldDelegate.primary != primary ||
      oldDelegate.secondary != secondary ||
      oldDelegate.label != label;
}
