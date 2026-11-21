import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/bottle_toast.dart';
import '../../../../core/widgets/circular_scent_badge.dart';
import '../../../../core/widgets/custom_shaped_app_bar.dart';
import '../../../../core/widgets/empty_perfume_state.dart';
import '../../domain/perfume.dart';
import '../providers/perfume_providers.dart';
import '../widgets/catalog_promo_banner.dart';
import '../widgets/floating_bottom_nav.dart';
import '../widgets/grid_perfume_card.dart';
import '../widgets/perfume_bottle_placeholder.dart';
import '../widgets/perfume_detail_drawer.dart';
import '../widgets/perfume_filter_drawer.dart';
import '../widgets/stepped_perfume_card.dart';

class CatalogView extends ConsumerStatefulWidget {
  const CatalogView({
    super.key,
    required this.onBackToHome,
    required this.onOpenCart,
  });

  final VoidCallback onBackToHome;
  final VoidCallback onOpenCart;

  @override
  ConsumerState<CatalogView> createState() => _CatalogViewState();
}

class _CatalogViewState extends ConsumerState<CatalogView>
    with TickerProviderStateMixin {
  late final TextEditingController _searchController;
  late final AnimationController _entranceController;
  final GlobalKey _cartIconKey = GlobalKey();
  final GlobalKey _favoriteIconKey = GlobalKey();
  final List<AnimationController> _activeFlyControllers = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    if (ref.read(shellPageIndexProvider) == 1) {
      _entranceController.forward();
    }
  }

  @override
  void dispose() {
    for (final c in _activeFlyControllers) {
      c.dispose();
    }
    _entranceController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _staggeredReveal({
    required double start,
    required double end,
    required Widget child,
    Offset beginOffset = const Offset(0, 0.08),
  }) {
    final fade = CurvedAnimation(
      parent: _entranceController,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
    final slide = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }

  void _launchBottleJump({
    required Perfume perfume,
    required Offset startTopLeft,
    required Size bottleSize,
    required int selectedSizeMl,
    required int unitPrice,
  }) {
    final cartBox =
        _cartIconKey.currentContext?.findRenderObject() as RenderBox?;
    if (cartBox == null || !cartBox.hasSize || startTopLeft == Offset.zero) {
      ref.read(cartProvider.notifier).addItem(
            perfume,
            sizeMl: selectedSizeMl,
            unitPrice: unitPrice,
          );
      ref.read(cartBounceTickProvider.notifier).trigger();
      return;
    }

    final overlay = Overlay.of(context, rootOverlay: true);
    final cartCenter = cartBox.localToGlobal(
      Offset(cartBox.size.width / 2, cartBox.size.height / 2),
    );
    final startCenter = Offset(
      startTopLeft.dx + bottleSize.width / 2,
      startTopLeft.dy + bottleSize.height / 2,
    );

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    );
    _activeFlyControllers.add(controller);

    final curved = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    );

    // Basketball-shot quadratic Bezier arc: shoots UP high first, then drops into cart
    final controlPoint = Offset(
      (startCenter.dx + cartCenter.dx) / 2,
      math.min(startCenter.dy, cartCenter.dy) - 210,
    );

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return AnimatedBuilder(
          animation: curved,
          builder: (context, child) {
            final t = curved.value;
            final inv = 1.0 - t;
            final x = inv * inv * startCenter.dx +
                2 * inv * t * controlPoint.dx +
                t * t * cartCenter.dx;
            final y = inv * inv * startCenter.dy +
                2 * inv * t * controlPoint.dy +
                t * t * cartCenter.dy;

            // Slight pop-up on launch, then shrinks smoothly into the cart
            final scale = t < 0.25
                ? 1.0 + (t / 0.25) * 0.14
                : 1.14 - ((t - 0.25) / 0.75) * 0.86;
            final rotation = math.sin(t * math.pi) * 0.35;

            return Positioned(
              left: x - (bottleSize.width / 2),
              top: y - (bottleSize.height / 2),
              child: IgnorePointer(
                child: Transform.rotate(
                  angle: rotation,
                  child: Transform.scale(
                    scale: scale,
                    child: child,
                  ),
                ),
              ),
            );
          },
          child: Opacity(
            opacity: 0.95,
            child: PerfumeBottlePlaceholder(
              perfume: perfume,
              width: bottleSize.width,
              height: bottleSize.height,
            ),
          ),
        );
      },
    );

    overlay.insert(entry);
    controller.forward().whenComplete(() {
      entry.remove();
      _activeFlyControllers.remove(controller);
      controller.dispose();
      if (!mounted) return;
      ref.read(cartProvider.notifier).addItem(
            perfume,
            sizeMl: selectedSizeMl,
            unitPrice: unitPrice,
          );
      ref.read(cartBounceTickProvider.notifier).trigger();
    });
  }

  void _launchHeartJump({
    required Perfume perfume,
    required Offset? startCenter,
  }) {
    final favBox =
        _favoriteIconKey.currentContext?.findRenderObject() as RenderBox?;
    if (favBox == null || !favBox.hasSize || startCenter == null) {
      ref.read(favoritesProvider.notifier).toggle(perfume.id);
      ref.read(favoriteBounceTickProvider.notifier).trigger();
      return;
    }

    final overlay = Overlay.of(context, rootOverlay: true);
    final favCenter = favBox.localToGlobal(
      Offset(favBox.size.width / 2, favBox.size.height / 2),
    );

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 560),
    );
    _activeFlyControllers.add(controller);

    final curved = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    );

    final controlPoint = Offset(
      (startCenter.dx + favCenter.dx) / 2,
      math.min(startCenter.dy, favCenter.dy) - 160,
    );

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return AnimatedBuilder(
          animation: curved,
          builder: (context, child) {
            final t = curved.value;
            final inv = 1.0 - t;
            final x = inv * inv * startCenter.dx +
                2 * inv * t * controlPoint.dx +
                t * t * favCenter.dx;
            final y = inv * inv * startCenter.dy +
                2 * inv * t * controlPoint.dy +
                t * t * favCenter.dy;

            final scale = t < 0.25
                ? 1.0 + (t / 0.25) * 0.40
                : 1.40 - ((t - 0.25) / 0.75) * 0.65;

            return Positioned(
              left: x - 14,
              top: y - 14,
              child: IgnorePointer(
                child: Transform.scale(scale: scale, child: child),
              ),
            );
          },
          child: const Icon(
            PhosphorIconsFill.heart,
            size: 28,
            color: AppColors.notificationDot,
          ),
        );
      },
    );

    overlay.insert(entry);
    controller.forward().whenComplete(() {
      entry.remove();
      _activeFlyControllers.remove(controller);
      controller.dispose();
      if (!mounted) return;
      ref.read(favoritesProvider.notifier).toggle(perfume.id);
      ref.read(favoriteBounceTickProvider.notifier).trigger();
    });
  }

  void _openPerfumeDetail(Perfume perfume) {
    showPerfumeDetailDrawer(
      context,
      perfume: perfume,
      onBuyTap: (startOffset, bottleSize, selectedSizeMl, unitPrice) =>
          _launchBottleJump(
        perfume: perfume,
        startTopLeft: startOffset,
        bottleSize: bottleSize,
        selectedSizeMl: selectedSizeMl,
        unitPrice: unitPrice,
      ),
    );
  }

  void _handlePerfumeFavorite(Perfume perfume, Offset? heartCenter) {
    final isFav = ref.read(favoritesProvider).contains(perfume.id);
    if (isFav) {
      ref.read(favoritesProvider.notifier).toggle(perfume.id);
    } else {
      _launchHeartJump(perfume: perfume, startCenter: heartCenter);
    }
  }

  void _handlePerfumeBuy(
    Perfume perfume,
    Offset startOffset,
    Size bottleSize,
  ) {
    if (perfume.availableSizesMl.length <= 1) {
      final sizeMl = perfume.availableSizesMl.first;
      _launchBottleJump(
        perfume: perfume,
        startTopLeft: startOffset,
        bottleSize: bottleSize,
        selectedSizeMl: sizeMl,
        unitPrice: perfume.priceForSize(sizeMl),
      );
    } else {
      _openPerfumeDetail(perfume);
    }
  }

  Widget _buildSteppedTile(
    Perfume perfume, {
    required bool imageOnRight,
    required Set<String> favorites,
    int? revealIndex,
  }) {
    final card = Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: SteppedPerfumeCard(
        perfume: perfume,
        imageOnRight: imageOnRight,
        isFavorite: favorites.contains(perfume.id),
        onCardTap: () => _openPerfumeDetail(perfume),
        onToggleFavorite: (c) => _handlePerfumeFavorite(perfume, c),
        onBuyTap: (o, s) => _handlePerfumeBuy(perfume, o, s),
      ),
    );
    if (revealIndex != null && revealIndex < 4) {
      final start = 0.22 + (revealIndex * 0.08);
      final end = (start + 0.42).clamp(0.0, 1.0);
      return _staggeredReveal(start: start, end: end, child: card);
    }
    return card;
  }

  Widget _buildGridChunk(List<Perfume> items, Set<String> favorites) {
    final rows = <Widget>[];
    for (int i = 0; i < items.length; i += 2) {
      final left = items[i];
      final right = i + 1 < items.length ? items[i + 1] : null;
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GridPerfumeCard(
                  perfume: left,
                  isFavorite: favorites.contains(left.id),
                  onCardTap: () => _openPerfumeDetail(left),
                  onToggleFavorite: (c) => _handlePerfumeFavorite(left, c),
                  onBuyTap: (o, s) => _handlePerfumeBuy(left, o, s),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: right != null
                    ? GridPerfumeCard(
                        perfume: right,
                        isFavorite: favorites.contains(right.id),
                        onCardTap: () => _openPerfumeDetail(right),
                        onToggleFavorite: (c) =>
                            _handlePerfumeFavorite(right, c),
                        onBuyTap: (o, s) => _handlePerfumeBuy(right, o, s),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
    }
    return Column(mainAxisSize: MainAxisSize.min, children: rows);
  }

  Widget _buildSectionHeader(String title, String tag) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: AppTheme.brandFont,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.inkPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            tag,
            style: const TextStyle(
              fontFamily: AppTheme.contentFont,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: AppColors.sageIcon,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCatalogSections({
    required List<Perfume> perfumes,
    required Set<String> favorites,
    required bool isFilteredMode,
  }) {
    // Filtered / Search / Favorites: keep clean without promotional banners
    if (isFilteredMode || perfumes.length < 6) {
      if (perfumes.length <= 3) {
        return List.generate(
          perfumes.length,
          (i) => _buildSteppedTile(
            perfumes[i],
            imageOnRight: i.isEven,
            favorites: favorites,
            revealIndex: i,
          ),
        );
      }
      return [
        _buildSteppedTile(
          perfumes[0],
          imageOnRight: true,
          favorites: favorites,
          revealIndex: 0,
        ),
        _buildSteppedTile(
          perfumes[1],
          imageOnRight: false,
          favorites: favorites,
          revealIndex: 1,
        ),
        const SizedBox(height: 8),
        _buildGridChunk(perfumes.sublist(2), favorites),
      ];
    }

    // Full editorial catalog: stepped cards -> light promo banner -> 2-col grid
    // -> stepped cards -> dark atelier banner -> 2-col grid -> remaining stepped
    final widgets = <Widget>[];

    // 1. Opening signature stepped cards (0..1)
    for (int i = 0; i < 2; i++) {
      widgets.add(
        _buildSteppedTile(
          perfumes[i],
          imageOnRight: i.isEven,
          favorites: favorites,
          revealIndex: i,
        ),
      );
    }

    // 2. Promotional Banner 1 (Seasonal Archive — light mist-sage editorial)
    final featuredOffer = perfumes.firstWhere(
      (p) => (p.badge ?? '').contains('45%'),
      orElse: () => perfumes.first,
    );
    widgets.add(
      _staggeredReveal(
        start: 0.34,
        end: 0.76,
        child: Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 4),
          child: CatalogPromoBanner(
            imageAsset: 'assets/images/banners/promo_summer_scent.jpg',
            eyebrow: 'SEASONAL ARCHIVE',
            title: 'Up to 45% Off',
            subtitle: 'Coastal citrus & rare woods',
            ctaLabel: 'Explore Offer',
            isDark: false,
            onTap: () => _openPerfumeDetail(featuredOffer),
          ),
        ),
      ),
    );

    // 3. Curated 2-Column Grid (2..5)
    final firstGridEnd = math.min(6, perfumes.length);
    widgets.add(_buildSectionHeader('Curated Collection', '4 fragrances'));
    widgets.add(
      _buildGridChunk(perfumes.sublist(2, firstGridEnd), favorites),
    );

    if (perfumes.length <= firstGridEnd) return widgets;

    // 4. Mid-feed signature stepped cards (6..7)
    final midSteppedEnd = math.min(8, perfumes.length);
    widgets.add(_buildSectionHeader("Editor's Picks", 'Signature line'));
    for (int i = firstGridEnd; i < midSteppedEnd; i++) {
      widgets.add(
        _buildSteppedTile(
          perfumes[i],
          imageOnRight: i.isEven,
          favorites: favorites,
        ),
      );
    }

    if (perfumes.length <= midSteppedEnd) return widgets;

    // 5. Promotional Banner 2 (Atelier Reserve — dark obsidian-sage editorial)
    widgets.add(
      Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 4),
        child: CatalogPromoBanner(
          imageAsset: 'assets/images/banners/promo_atelier_reserve.jpg',
          eyebrow: 'ATELIER RESERVE',
          title: 'Extra 10% Off',
          subtitle: 'Use code AROMA10 at checkout',
          ctaLabel: 'Copy AROMA10',
          isDark: true,
          onTap: () {
            Clipboard.setData(const ClipboardData(text: 'AROMA10'));
            showBottleToast(
              context,
              message: 'Promo Code Copied',
              subtitle: 'Apply AROMA10 at checkout for 10% off',
            );
          },
        ),
      ),
    );

    // 6. Second 2-Column Grid (8..11)
    final secondGridEnd = math.min(12, perfumes.length);
    widgets.add(_buildSectionHeader('Maison Icons', 'Explore more'));
    widgets.add(
      _buildGridChunk(
        perfumes.sublist(midSteppedEnd, secondGridEnd),
        favorites,
      ),
    );

    // 7. Remaining items (e.g. Out-of-Stock archive item at bottom)
    if (perfumes.length > secondGridEnd) {
      widgets.add(_buildSectionHeader('Archive Vault', 'Restocking soon'));
      for (int i = secondGridEnd; i < perfumes.length; i++) {
        widgets.add(
          _buildSteppedTile(
            perfumes[i],
            imageOnRight: i.isEven,
            favorites: favorites,
          ),
        );
      }
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(shellPageIndexProvider, (prev, next) {
      if (next == 1 && prev != 1) {
        _entranceController.forward(from: 0);
      }
    });

    final perfumes = ref.watch(filteredCatalogPerfumesProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final onlyFavorites = ref.watch(favoritesFilterProvider);
    final favorites = ref.watch(favoritesProvider);
    final hasActiveFilters = ref.watch(hasActiveFiltersProvider);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final appBarHeight = CustomShapedAppBar.totalHeight(context);

    return ColoredBox(
      color: AppColors.background,
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: NotificationListener<OverscrollNotification>(
                  onNotification: (notification) {
                    if (notification.overscroll < -24) {
                      widget.onBackToHome();
                    }
                    return false;
                  },
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      appBarHeight + 12,
                      20,
                      bottomPadding + 104,
                    ),
                    children: [
                      // Search input + circular filter drawer button
                      _staggeredReveal(
                        start: 0.04,
                        end: 0.45,
                        child: Row(
                          children: [
                          Expanded(
                            child: Container(
                              height: 46,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(99),
                                border: Border.all(
                                  color: AppColors.borderSubtle,
                                  width: 1,
                                ),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 18),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      onChanged: (val) => ref
                                          .read(searchQueryProvider.notifier)
                                          .update(val),
                                      style: const TextStyle(
                                        fontFamily: AppTheme.contentFont,
                                        fontSize: 14,
                                        color: AppColors.inkPrimary,
                                      ),
                                      decoration: const InputDecoration(
                                        hintText: 'Search luxury Fragrance',
                                        hintStyle: TextStyle(
                                          fontFamily: AppTheme.contentFont,
                                          fontSize: 14,
                                          color: AppColors.inkSecondary,
                                        ),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: searchQuery.isNotEmpty
                                        ? () {
                                            _searchController.clear();
                                            ref
                                                .read(searchQueryProvider
                                                    .notifier)
                                                .update('');
                                          }
                                        : null,
                                    behavior: HitTestBehavior.opaque,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 220),
                                        transitionBuilder: (child, anim) {
                                          return RotationTransition(
                                            turns: Tween<double>(
                                              begin: 0.75,
                                              end: 1.0,
                                            ).animate(anim),
                                            child: ScaleTransition(
                                              scale: anim,
                                              child: FadeTransition(
                                                opacity: anim,
                                                child: child,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Icon(
                                          searchQuery.isNotEmpty
                                              ? PhosphorIconsRegular.x
                                              : PhosphorIconsRegular
                                                  .magnifyingGlass,
                                          key: ValueKey<bool>(
                                            searchQuery.isNotEmpty,
                                          ),
                                          size: 20,
                                          color: AppColors.inkPrimary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => showPerfumeFilterDrawer(context),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: hasActiveFilters
                                    ? AppColors.inkPrimary
                                    : AppColors.sageHighlight,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                PhosphorIconsRegular.slidersHorizontal,
                                size: 20,
                                color: hasActiveFilters
                                    ? AppColors.surface
                                    : AppColors.inkPrimary,
                              ),
                            ),
                          ),
                        ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Heading + circular scent badge
                      _staggeredReveal(
                        start: 0.14,
                        end: 0.56,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 240),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                layoutBuilder: (current, previous) => Stack(
                                  alignment: Alignment.centerLeft,
                                  children: [...previous, ?current],
                                ),
                                child: Text(
                                  onlyFavorites
                                      ? 'Your Signature\nFavorites!'
                                      : 'Perfume that\nUnderstand you!',
                                  key: ValueKey<bool>(onlyFavorites),
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(
                                        fontSize: 31,
                                        fontWeight: FontWeight.w300,
                                      ),
                                ),
                              ),
                            ),
                            const CircularScentBadge(size: 54),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (perfumes.isEmpty)
                        const EmptyPerfumeState(
                          title: 'No Scents Found',
                          subtitle:
                              'Try adjusting your search or filter to discover another fragrance.',
                        )
                      else
                        ..._buildCatalogSections(
                          perfumes: perfumes,
                          favorites: favorites,
                          isFilteredMode: hasActiveFilters ||
                              searchQuery.isNotEmpty ||
                              onlyFavorites,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Floating bottom navigation bar on Page 2
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomPadding + 14,
            child: Center(
              child: _staggeredReveal(
                start: 0.28,
                end: 0.72,
                beginOffset: const Offset(0, 0.30),
                child: FloatingBottomNav(
                  cartIconKey: _cartIconKey,
                  favoriteIconKey: _favoriteIconKey,
                  onGoHome: widget.onBackToHome,
                  onOpenCart: widget.onOpenCart,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
