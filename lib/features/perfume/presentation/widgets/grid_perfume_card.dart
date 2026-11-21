import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/bottle_tone_extractor.dart';
import '../../domain/perfume.dart';
import 'perfume_bottle_placeholder.dart';

/// Compact 2-column editorial grid card for breaking up the vertical rhythm
/// of the perfume catalog while preserving tinted bottle shadows and animations.
class GridPerfumeCard extends StatefulWidget {
  const GridPerfumeCard({
    super.key,
    required this.perfume,
    required this.isFavorite,
    required this.onCardTap,
    required this.onToggleFavorite,
    required this.onBuyTap,
  });

  final Perfume perfume;
  final bool isFavorite;
  final VoidCallback onCardTap;
  final void Function(Offset? heartCenter) onToggleFavorite;
  final void Function(Offset bottleTopLeft, Size bottleSize) onBuyTap;

  @override
  State<GridPerfumeCard> createState() => _GridPerfumeCardState();
}

class _GridPerfumeCardState extends State<GridPerfumeCard> {
  final GlobalKey _bottleKey = GlobalKey();
  final GlobalKey _heartKey = GlobalKey();
  late Color _stageTint;
  late Color _shadowTint;

  @override
  void initState() {
    super.initState();
    _stageTint = widget.perfume.cardTint;
    _shadowTint = widget.perfume.bottlePrimary;
    _resolveTones();
  }

  @override
  void didUpdateWidget(covariant GridPerfumeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.perfume.bottleImageAsset !=
        widget.perfume.bottleImageAsset) {
      _stageTint = widget.perfume.cardTint;
      _shadowTint = widget.perfume.bottlePrimary;
      _resolveTones();
    }
  }

  Future<void> _resolveTones() async {
    final results = await Future.wait([
      BottleToneExtractor.extractPastelTint(
        widget.perfume.bottleImageAsset,
        fallbackColor: widget.perfume.cardTint,
      ),
      BottleToneExtractor.extractDominantColor(
        widget.perfume.bottleImageAsset,
        fallbackColor: widget.perfume.bottlePrimary,
      ),
    ]);
    if (!mounted) return;
    if (results[0] != _stageTint || results[1] != _shadowTint) {
      setState(() {
        _stageTint = results[0];
        _shadowTint = results[1];
      });
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
      widget.onBuyTap(box.localToGlobal(Offset.zero), box.size);
    } else {
      widget.onBuyTap(Offset.zero, const Size(86, 120));
    }
  }

  @override
  Widget build(BuildContext context) {
    final perfume = widget.perfume;

    final card = GestureDetector(
      onTap: widget.onCardTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.borderSubtle.withValues(alpha: 0.85),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pastel bottle showcase stage
                AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  height: 132,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _stageTint,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _GridBottleShadowPainter(tint: _shadowTint),
                        ),
                      ),
                      _GridMultiplyBlend(
                        child: Padding(
                          key: _bottleKey,
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 10,
                          ),
                          child: PerfumeBottlePlaceholder(
                            perfume: perfume,
                            width: 90,
                            height: 114,
                            imageScale: 1.06,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: _handleToggleFavorite,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            key: _heartKey,
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.surface.withValues(alpha: 0.85),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              widget.isFavorite
                                  ? PhosphorIconsFill.heart
                                  : PhosphorIconsRegular.heart,
                              size: 15,
                              color: widget.isFavorite
                                  ? AppColors.notificationDot
                                  : AppColors.inkSecondary,
                            ),
                          ),
                        ),
                      ),
                      if (perfume.badge != null && !perfume.isOutOfStock)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: _GridPromoBadge(label: perfume.badge!),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 9),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        perfume.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppTheme.contentFont,
                          fontSize: 14,
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
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                          color: AppColors.inkSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
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
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.inkPrimary,
                                    ),
                                  ),
                                  if (perfume.originalPrice != null) ...[
                                    const SizedBox(width: 4),
                                    Text(
                                      '${perfume.originalPrice}\$',
                                      style: const TextStyle(
                                        fontFamily: AppTheme.contentFont,
                                        fontSize: 10.5,
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
                          const SizedBox(width: 4),
                          Text(
                            perfume.availableSizesMl.length <= 1
                                ? '${perfume.availableSizesMl.first} ml'
                                : '${perfume.availableSizesMl.length} sizes',
                            style: const TextStyle(
                              fontFamily: AppTheme.contentFont,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.inkSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 30,
                        child: FilledButton(
                          onPressed: perfume.isOutOfStock ? null : _handleBuy,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.inkPrimary,
                            disabledBackgroundColor: AppColors.borderSubtle,
                            foregroundColor: AppColors.surface,
                            disabledForegroundColor: AppColors.inkSecondary,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            perfume.isOutOfStock ? 'Sold Out' : 'Buy',
                            style: const TextStyle(
                              fontFamily: AppTheme.contentFont,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (perfume.isOutOfStock)
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: Transform.rotate(
                      angle: -0.22,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.inkPrimary,
                            width: 1.8,
                          ),
                        ),
                        child: const Text(
                          'OUT OF STOCK',
                          style: TextStyle(
                            fontFamily: AppTheme.brandFont,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: AppColors.inkPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (!perfume.isOutOfStock) return card;

    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0, 0, 0, 1, 0,
      ]),
      child: Opacity(opacity: 0.68, child: card),
    );
  }
}

class _GridPromoBadge extends StatelessWidget {
  const _GridPromoBadge({required this.label});

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
      bg = AppColors.surface.withValues(alpha: 0.92);
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
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: fg,
        ),
      ),
    );
  }
}

class _GridBottleShadowPainter extends CustomPainter {
  const _GridBottleShadowPainter({required this.tint});

  final Color tint;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final deepTint = Color.lerp(tint, AppColors.inkPrimary, 0.22)!;

    canvas.save();
    canvas.translate(w * 0.60, h * 0.44);
    canvas.rotate(0.30);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 46, height: 84),
      Paint()
        ..color = deepTint.withValues(alpha: 0.36)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 11),
    );
    canvas.restore();

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.56, h * 0.85),
        width: 58,
        height: 12,
      ),
      Paint()
        ..color = deepTint.withValues(alpha: 0.42)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  @override
  bool shouldRepaint(covariant _GridBottleShadowPainter oldDelegate) =>
      oldDelegate.tint != tint;
}

class _GridMultiplyBlend extends SingleChildRenderObjectWidget {
  const _GridMultiplyBlend({required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderGridMultiplyBlend();
}

class _RenderGridMultiplyBlend extends RenderProxyBox {
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
