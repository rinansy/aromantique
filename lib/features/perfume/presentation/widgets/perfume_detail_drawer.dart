import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/flared_side_drawer_container.dart';
import '../../domain/perfume.dart';
import '../providers/perfume_providers.dart';
import 'perfume_bottle_placeholder.dart';
import 'perfume_size_slider.dart';

/// Opens a rounded half-screen detail drawer from the right when a perfume tile
/// or Buy button is tapped, showing bottle, size slider, notes, description, and Buy button.
Future<void> showPerfumeDetailDrawer(
  BuildContext context, {
  required Perfume perfume,
  required void Function(
    Offset bottleTopLeft,
    Size bottleSize,
    int selectedSizeMl,
    int unitPrice,
  ) onBuyTap,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Perfume Details',
    barrierColor: Colors.black.withValues(alpha: 0.16),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (context, animation, secondaryAnimation) {
      return _PerfumeDetailDrawerBody(
        perfume: perfume,
        onBuyTap: onBuyTap,
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      );
    },
  );
}

class _PerfumeDetailDrawerBody extends ConsumerStatefulWidget {
  const _PerfumeDetailDrawerBody({
    required this.perfume,
    required this.onBuyTap,
  });

  final Perfume perfume;
  final void Function(
    Offset bottleTopLeft,
    Size bottleSize,
    int selectedSizeMl,
    int unitPrice,
  ) onBuyTap;

  @override
  ConsumerState<_PerfumeDetailDrawerBody> createState() =>
      _PerfumeDetailDrawerBodyState();
}

class _PerfumeDetailDrawerBodyState
    extends ConsumerState<_PerfumeDetailDrawerBody> {
  final GlobalKey _drawerBottleKey = GlobalKey();
  late int _selectedSizeMl;

  @override
  void initState() {
    super.initState();
    final sizes = widget.perfume.availableSizesMl;
    _selectedSizeMl = sizes.contains(widget.perfume.volumeMl)
        ? widget.perfume.volumeMl
        : sizes.first;
  }

  void _handleBuy() {
    if (widget.perfume.isOutOfStock) return;
    final box =
        _drawerBottleKey.currentContext?.findRenderObject() as RenderBox?;
    final offset = box != null && box.hasSize
        ? box.localToGlobal(Offset.zero)
        : Offset.zero;
    final size =
        box != null && box.hasSize ? box.size : const Size(110, 150);
    final unitPrice = widget.perfume.priceForSize(_selectedSizeMl);

    Navigator.of(context).pop();
    widget.onBuyTap(offset, size, _selectedSizeMl, unitPrice);
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final favorites = ref.watch(favoritesProvider);
    final isFavorite = favorites.contains(widget.perfume.id);
    final computedPrice = widget.perfume.priceForSize(_selectedSizeMl);

    final drawerWidth = (screen.width * 0.78).clamp(276.0, 350.0);
    final maxDrawerHeight = (screen.height * 0.74).clamp(420.0, 620.0);

    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.transparent,
        child: FlaredSideDrawerContainer(
          fromLeft: false,
          width: drawerWidth,
          maxHeight: maxDrawerHeight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top bar: Optional promo badge + favorite + close
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 14, 4),
                child: Row(
                  children: [
                    if (widget.perfume.isOutOfStock)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: const Text(
                          'OUT OF STOCK',
                          style: TextStyle(
                            fontFamily: AppTheme.contentFont,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.inkSecondary,
                          ),
                        ),
                      )
                    else if (widget.perfume.badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.inkPrimary,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          widget.perfume.badge!,
                          style: const TextStyle(
                            fontFamily: AppTheme.contentFont,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.surface,
                          ),
                        ),
                      ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => ref
                          .read(favoritesProvider.notifier)
                          .toggle(widget.perfume.id),
                      icon: Icon(
                        isFavorite
                            ? PhosphorIconsFill.heart
                            : PhosphorIconsRegular.heart,
                        size: 20,
                        color: isFavorite
                            ? AppColors.notificationDot
                            : AppColors.inkSecondary,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        PhosphorIconsRegular.x,
                        size: 19,
                        color: AppColors.inkSecondary,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
              // Scrollable bottle + size slider + notes + description
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          key: _drawerBottleKey,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            scale: () {
                              final sizes = widget.perfume.availableSizesMl;
                              if (sizes.length <= 1) return 1.0;
                              final idx = sizes.indexOf(_selectedSizeMl).clamp(
                                    0,
                                    sizes.length - 1,
                                  );
                              return 0.90 + (idx / (sizes.length - 1)) * 0.16;
                            }(),
                            child: PerfumeBottlePlaceholder(
                              perfume: widget.perfume,
                              width: 108,
                              height: 144,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.perfume.name,
                                  style: const TextStyle(
                                    fontFamily: AppTheme.brandFont,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.inkPrimary,
                                  ),
                                ),
                                Text(
                                  'by ${widget.perfume.brand} • ${widget.perfume.subtitle}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: AppTheme.contentFont,
                                    fontSize: 12.5,
                                    color: AppColors.inkSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '$computedPrice\$',
                                style: const TextStyle(
                                  fontFamily: AppTheme.contentFont,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.inkPrimary,
                                ),
                              ),
                              Text(
                                '$_selectedSizeMl ml',
                                style: const TextStyle(
                                  fontFamily: AppTheme.contentFont,
                                  fontSize: 12,
                                  color: AppColors.inkSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (widget.perfume.availableSizesMl.length > 1) ...[
                        const SizedBox(height: 14),
                        PerfumeSizeSlider(
                          sizes: widget.perfume.availableSizesMl,
                          selectedSizeMl: _selectedSizeMl,
                          onChanged: (sizeMl) =>
                              setState(() => _selectedSizeMl = sizeMl),
                        ),
                      ],
                      if (widget.perfume.notes.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        const Text(
                          'Key Notes',
                          style: TextStyle(
                            fontFamily: AppTheme.contentFont,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.inkPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: widget.perfume.notes
                              .map(
                                (note) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.borderSubtle,
                                    ),
                                  ),
                                  child: Text(
                                    note,
                                    style: const TextStyle(
                                      fontFamily: AppTheme.contentFont,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.inkPrimary,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                      if (widget.perfume.description.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          widget.perfume.description,
                          style: const TextStyle(
                            fontFamily: AppTheme.contentFont,
                            fontSize: 13,
                            height: 1.42,
                            color: AppColors.inkSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // Bottom Buy button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
                child: SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: FilledButton(
                    onPressed: widget.perfume.isOutOfStock ? null : _handleBuy,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.inkPrimary,
                      disabledBackgroundColor: AppColors.surfaceMuted,
                      foregroundColor: AppColors.surface,
                      disabledForegroundColor: AppColors.inkMuted,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.perfume.isOutOfStock ? 'Out of Stock' : 'Buy',
                      style: const TextStyle(
                        fontFamily: AppTheme.contentFont,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
