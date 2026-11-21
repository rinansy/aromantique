import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/bottle_tone_extractor.dart';
import '../../domain/perfume.dart';
import 'perfume_bottle_placeholder.dart';

/// Asymmetrical stepped-rounded card for Page 2 catalog items.
/// The description container is slightly shorter than the image container,
/// joined by smooth rounded step fillets.
class SteppedPerfumeCard extends StatefulWidget {
  const SteppedPerfumeCard({
    super.key,
    required this.perfume,
    required this.imageOnRight,
    required this.isFavorite,
    required this.onCardTap,
    required this.onToggleFavorite,
    required this.onBuyTap,
  });

  final Perfume perfume;
  final bool imageOnRight;
  final bool isFavorite;
  final VoidCallback onCardTap;
  final void Function(Offset? heartCenter) onToggleFavorite;
  final void Function(Offset bottleTopLeft, Size bottleSize) onBuyTap;

  @override
  State<SteppedPerfumeCard> createState() => _SteppedPerfumeCardState();
}

class _SteppedPerfumeCardState extends State<SteppedPerfumeCard> {
  final GlobalKey _bottleKey = GlobalKey();
  final GlobalKey _heartKey = GlobalKey();
  late Color _bottleShadowTint;

  static const double _cardHeight = 186;
  static const double _stepInset = 17;
  static const double _splitRatio = 0.54;

  @override
  void initState() {
    super.initState();
    _bottleShadowTint = widget.perfume.bottlePrimary;
    _resolveShadowTint();
  }

  @override
  void didUpdateWidget(covariant SteppedPerfumeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.perfume.bottleImageAsset !=
        widget.perfume.bottleImageAsset) {
      _bottleShadowTint = widget.perfume.bottlePrimary;
      _resolveShadowTint();
    }
  }

  Future<void> _resolveShadowTint() async {
    final dominant = await BottleToneExtractor.extractDominantColor(
      widget.perfume.bottleImageAsset,
      fallbackColor: widget.perfume.bottlePrimary,
    );
    if (mounted && dominant != _bottleShadowTint) {
      setState(() => _bottleShadowTint = dominant);
    }
  }

  void _handleToggleFavorite() {
    final box = _heartKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      final center = box.localToGlobal(
        Offset(box.size.width / 2, box.size.height / 2),
      );
      widget.onToggleFavorite(center);
    } else {
      widget.onToggleFavorite(null);
    }
  }

  void _handleBuy() {
    final box = _bottleKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      final offset = box.localToGlobal(Offset.zero);
      widget.onBuyTap(offset, box.size);
    } else {
      widget.onBuyTap(Offset.zero, const Size(96, 150));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardContent = GestureDetector(
      onTap: widget.onCardTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: _cardHeight,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _SteppedCardPainter(
                  imageOnRight: widget.imageOnRight,
                  stepInset: _stepInset,
                  splitRatio: _splitRatio,
                ),
              ),
            ),
            ClipPath(
              clipper: _SteppedCardClipper(
                imageOnRight: widget.imageOnRight,
                stepInset: _stepInset,
                splitRatio: _splitRatio,
              ),
              child: ColoredBox(
                color: AppColors.surface,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final totalW = constraints.maxWidth;
                    final descW = totalW * _splitRatio;
                    final imgW = totalW * (1 - _splitRatio);

                    final descSection = SizedBox(
                      width: descW,
                      height: _cardHeight,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: _stepInset + 6,
                          bottom: _stepInset + 6,
                          left: widget.imageOnRight ? 10 : 6,
                          right: widget.imageOnRight ? 6 : 10,
                        ),
                        child: _DescriptionBox(
                          perfume: widget.perfume,
                          onBuyTap: _handleBuy,
                        ),
                      ),
                    );

                    final imageSection = SizedBox(
                      width: imgW,
                      height: _cardHeight,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _BottleTwoOClockShadowPainter(
                                tint: _bottleShadowTint,
                              ),
                            ),
                          ),
                          _MultiplyBlend(
                            child: Container(
                              key: _bottleKey,
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 6,
                              ),
                              child: PerfumeBottlePlaceholder(
                                perfume: widget.perfume,
                                width: imgW - 12,
                                height: _cardHeight - 16,
                                imageScale: 1.08,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: widget.imageOnRight ? 12 : null,
                            left: widget.imageOnRight ? null : 12,
                            child: GestureDetector(
                              onTap: _handleToggleFavorite,
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                key: _heartKey,
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  widget.isFavorite
                                      ? PhosphorIconsFill.heart
                                      : PhosphorIconsRegular.heart,
                                  size: 18,
                                  color: widget.isFavorite
                                      ? AppColors.notificationDot
                                      : AppColors.inkMuted,
                                ),
                              ),
                            ),
                          ),
                          if (widget.perfume.badge != null &&
                              !widget.perfume.isOutOfStock)
                            Positioned(
                              top: 11,
                              left: widget.imageOnRight ? 10 : null,
                              right: widget.imageOnRight ? null : 10,
                              child: _PromoBadge(label: widget.perfume.badge!),
                            ),
                        ],
                      ),
                    );

                    return Row(
                      children: widget.imageOnRight
                          ? [descSection, imageSection]
                          : [imageSection, descSection],
                    );
                  },
                ),
              ),
            ),
            if (widget.perfume.isOutOfStock)
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: Transform.rotate(
                      angle: -0.20,
                      child: const _OutOfStockStamp(),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (!widget.perfume.isOutOfStock) return cardContent;

    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0, 0, 0, 1, 0,
      ]),
      child: Opacity(
        opacity: 0.68,
        child: cardContent,
      ),
    );
  }
}

class _DescriptionBox extends StatefulWidget {
  const _DescriptionBox({required this.perfume, required this.onBuyTap});

  final Perfume perfume;
  final VoidCallback onBuyTap;

  @override
  State<_DescriptionBox> createState() => _DescriptionBoxState();
}

class _DescriptionBoxState extends State<_DescriptionBox> {
  late Color _boxTint;

  @override
  void initState() {
    super.initState();
    _boxTint = widget.perfume.cardTint;
    _resolveBottleTone();
  }

  @override
  void didUpdateWidget(covariant _DescriptionBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.perfume.bottleImageAsset !=
        widget.perfume.bottleImageAsset) {
      _boxTint = widget.perfume.cardTint;
      _resolveBottleTone();
    }
  }

  Future<void> _resolveBottleTone() async {
    final tint = await BottleToneExtractor.extractPastelTint(
      widget.perfume.bottleImageAsset,
      fallbackColor: widget.perfume.cardTint,
    );
    if (mounted && tint != _boxTint) {
      setState(() => _boxTint = tint);
    }
  }

  @override
  Widget build(BuildContext context) {
    final perfume = widget.perfume;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _boxTint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderSubtle.withValues(alpha: 0.7),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            perfume.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: AppTheme.contentFont,
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: AppColors.inkPrimary,
            ),
          ),
          Text(
            'by ${perfume.brand}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: AppTheme.contentFont,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.inkSecondary,
            ),
          ),
          const SizedBox(height: 4),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${perfume.price}\$',
                        style: const TextStyle(
                          fontFamily: AppTheme.contentFont,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.inkPrimary,
                        ),
                      ),
                      if (perfume.originalPrice != null) ...[
                        const SizedBox(width: 5),
                        Text(
                          '${perfume.originalPrice}\$',
                          style: const TextStyle(
                            fontFamily: AppTheme.contentFont,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.inkMuted,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: AppColors.inkMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                perfume.availableSizesMl.length <= 1
                    ? '${perfume.availableSizesMl.first} ml'
                    : '${perfume.availableSizesMl.length} sizes',
                style: const TextStyle(
                  fontFamily: AppTheme.contentFont,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.inkSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: FilledButton(
              onPressed: perfume.isOutOfStock ? null : widget.onBuyTap,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.inkPrimary,
                disabledBackgroundColor: AppColors.borderSubtle,
                foregroundColor: AppColors.surface,
                disabledForegroundColor: AppColors.inkSecondary,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              child: Text(
                perfume.isOutOfStock ? 'Sold Out' : 'Buy',
                style: const TextStyle(
                  fontFamily: AppTheme.contentFont,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OutOfStockStamp extends StatelessWidget {
  const _OutOfStockStamp();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.inkPrimary,
          width: 2.0,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: AppColors.inkSecondary,
            width: 0.9,
          ),
        ),
        child: const Text(
          'OUT OF STOCK',
          style: TextStyle(
            fontFamily: AppTheme.brandFont,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
            color: AppColors.inkPrimary,
          ),
        ),
      ),
    );
  }
}

class _PromoBadge extends StatelessWidget {
  const _PromoBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final upper = label.toUpperCase();
    final isDiscount = upper.contains('%') || upper.contains('DEAL');
    final isBest = upper.contains('BEST') || upper.contains('TOP');

    final Color bg;
    final Color fg;
    if (isDiscount) {
      bg = AppColors.inkPrimary;
      fg = AppColors.surface;
    } else if (isBest) {
      bg = AppColors.badgeGoldBg;
      fg = AppColors.badgeGoldFg;
    } else {
      bg = AppColors.sageHighlight;
      fg = AppColors.inkPrimary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTheme.contentFont,
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: fg,
        ),
      ),
    );
  }
}

Path _buildSteppedCardPath(
  Size size, {
  required bool imageOnRight,
  required double inset,
  required double splitRatio,
}) {
  final w = size.width;
  final h = size.height;
  const outerR = 18.0;
  const concaveR = 9.0;
  const convexR = 9.0;

  if (imageOnRight) {
    final splitX = w * splitRatio;
    return Path()
      ..moveTo(0, inset + outerR)
      ..quadraticBezierTo(0, inset, outerR, inset)
      ..lineTo(splitX - concaveR, inset)
      ..quadraticBezierTo(splitX, inset, splitX, inset - concaveR)
      ..lineTo(splitX, convexR)
      ..quadraticBezierTo(splitX, 0, splitX + convexR, 0)
      ..lineTo(w - outerR, 0)
      ..quadraticBezierTo(w, 0, w, outerR)
      ..lineTo(w, h - outerR)
      ..quadraticBezierTo(w, h, w - outerR, h)
      ..lineTo(splitX + convexR, h)
      ..quadraticBezierTo(splitX, h, splitX, h - convexR)
      ..lineTo(splitX, h - inset + concaveR)
      ..quadraticBezierTo(splitX, h - inset, splitX - concaveR, h - inset)
      ..lineTo(outerR, h - inset)
      ..quadraticBezierTo(0, h - inset, 0, h - inset - outerR)
      ..close();
  } else {
    final splitX = w * (1 - splitRatio);
    return Path()
      ..moveTo(0, outerR)
      ..quadraticBezierTo(0, 0, outerR, 0)
      ..lineTo(splitX - convexR, 0)
      ..quadraticBezierTo(splitX, 0, splitX, convexR)
      ..lineTo(splitX, inset - concaveR)
      ..quadraticBezierTo(splitX, inset, splitX + concaveR, inset)
      ..lineTo(w - outerR, inset)
      ..quadraticBezierTo(w, inset, w, inset + outerR)
      ..lineTo(w, h - inset - outerR)
      ..quadraticBezierTo(w, h - inset, w - outerR, h - inset)
      ..lineTo(splitX + concaveR, h - inset)
      ..quadraticBezierTo(splitX, h - inset, splitX, h - inset + concaveR)
      ..lineTo(splitX, h - convexR)
      ..quadraticBezierTo(splitX, h, splitX - convexR, h)
      ..lineTo(outerR, h)
      ..quadraticBezierTo(0, h, 0, h - outerR)
      ..close();
  }
}

class _SteppedCardClipper extends CustomClipper<Path> {
  const _SteppedCardClipper({
    required this.imageOnRight,
    required this.stepInset,
    required this.splitRatio,
  });

  final bool imageOnRight;
  final double stepInset;
  final double splitRatio;

  @override
  Path getClip(Size size) => _buildSteppedCardPath(
    size,
    imageOnRight: imageOnRight,
    inset: stepInset,
    splitRatio: splitRatio,
  );

  @override
  bool shouldReclip(covariant _SteppedCardClipper oldClipper) =>
      oldClipper.imageOnRight != imageOnRight ||
      oldClipper.stepInset != stepInset ||
      oldClipper.splitRatio != splitRatio;
}

class _SteppedCardPainter extends CustomPainter {
  const _SteppedCardPainter({
    required this.imageOnRight,
    required this.stepInset,
    required this.splitRatio,
  });

  final bool imageOnRight;
  final double stepInset;
  final double splitRatio;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildSteppedCardPath(
      size,
      imageOnRight: imageOnRight,
      inset: stepInset,
      splitRatio: splitRatio,
    );

    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.06), 8, false);

    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.borderSubtle.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(covariant _SteppedCardPainter oldDelegate) =>
      oldDelegate.imageOnRight != imageOnRight ||
      oldDelegate.stepInset != stepInset ||
      oldDelegate.splitRatio != splitRatio;
}

/// Draws a visible 2-o'clock (upper-right) & base drop shadow tinted to the bottle color.
class _BottleTwoOClockShadowPainter extends CustomPainter {
  const _BottleTwoOClockShadowPainter({required this.tint});

  final Color tint;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final deepTint = Color.lerp(tint, AppColors.inkPrimary, 0.22)!;

    // Angled bottle-tinted shadow cast toward 2 o'clock behind the bottle
    canvas.save();
    canvas.translate(w * 0.63, h * 0.43);
    canvas.rotate(0.32);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 64, height: 118),
      Paint()
        ..color = deepTint.withValues(alpha: 0.42)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
    canvas.restore();

    // Tinted contact shadow beneath the bottle base, shifted toward 2 o'clock
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.58, h * 0.85),
        width: 78,
        height: 16,
      ),
      Paint()
        ..color = deepTint.withValues(alpha: 0.48)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  @override
  bool shouldRepaint(covariant _BottleTwoOClockShadowPainter oldDelegate) =>
      oldDelegate.tint != tint;
}

/// Composites child with BlendMode.multiply so white image backgrounds allow
/// tinted shadows underneath to shine through cleanly.
class _MultiplyBlend extends SingleChildRenderObjectWidget {
  const _MultiplyBlend({required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMultiplyBlend();
}

class _RenderMultiplyBlend extends RenderProxyBox {
  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.saveLayer(
      offset & size,
      Paint()..blendMode = BlendMode.multiply,
    );
    super.paint(context, offset);
    context.canvas.restore();
  }
}
