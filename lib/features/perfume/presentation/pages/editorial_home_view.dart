import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/circular_scent_badge.dart';
import '../../../../core/widgets/custom_shaped_app_bar.dart';
import '../../../../core/widgets/perfume_bottle_nav_bg.dart';
import '../providers/perfume_providers.dart';
import '../widgets/editorial_hero_card.dart';
import '../widgets/left_search_notch.dart';

class EditorialHomeView extends ConsumerStatefulWidget {
  const EditorialHomeView({
    super.key,
    required this.onOpenCatalog,
    required this.onOpenCart,
  });

  final VoidCallback onOpenCatalog;
  final VoidCallback onOpenCart;

  @override
  ConsumerState<EditorialHomeView> createState() => _EditorialHomeViewState();
}

class _EditorialHomeViewState extends ConsumerState<EditorialHomeView>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _headlineFade;
  late final Animation<Offset> _headlineSlide;
  late final Animation<double> _badgeFade;
  late final Animation<double> _badgeScale;
  late final Animation<double> _railFade;
  late final Animation<Offset> _railSlide;
  late final Animation<double> _heroFade;
  late final Animation<Offset> _heroSlide;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _headlineFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.05, 0.55, curve: Curves.easeOut),
    );
    _headlineSlide = Tween<Offset>(
      begin: const Offset(0, 0.14),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.05, 0.58, curve: Curves.easeOutCubic),
      ),
    );

    _badgeFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.18, 0.65, curve: Curves.easeOut),
    );
    _badgeScale = Tween<double>(begin: 0.86, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.18, 0.68, curve: Curves.easeOutCubic),
      ),
    );

    _railFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.22, 0.72, curve: Curves.easeOut),
    );
    _railSlide = Tween<Offset>(
      begin: const Offset(-0.18, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.22, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _heroFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.18, 0.82, curve: Curves.easeOut),
    );
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.18, 0.86, curve: Curves.easeOutCubic),
      ),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final activeTab = ref.watch(activeNavTabProvider);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final appBarHeight = CustomShapedAppBar.totalHeight(context);

    return ColoredBox(
      color: AppColors.background,
      child: Column(
        children: [
          // Headline + circular stamp
          Padding(
            padding: EdgeInsets.fromLTRB(22, appBarHeight + 14, 22, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: FadeTransition(
                    opacity: _headlineFade,
                    child: SlideTransition(
                      position: _headlineSlide,
                      child: Text(
                        'Find your\nLuxurious Smell',
                        style:
                            Theme.of(context).textTheme.displaySmall?.copyWith(
                                  fontSize: 33,
                                  fontWeight: FontWeight.w300,
                                ),
                      ),
                    ),
                  ),
                ),
                FadeTransition(
                  opacity: _badgeFade,
                  child: ScaleTransition(
                    scale: _badgeScale,
                    child: const CircularScentBadge(size: 56),
                  ),
                ),
              ],
            ),
          ),
          // Main split: Left rail + Right Hero Showcase Card
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 72,
                  child: FadeTransition(
                    opacity: _railFade,
                    child: SlideTransition(
                      position: _railSlide,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: IntrinsicHeight(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 14),
                                    LeftSearchNotch(
                                      onTap: () {
                                        ref
                                            .read(activeNavTabProvider.notifier)
                                            .select(PerfumeNavTab.search);
                                        widget.onOpenCatalog();
                                      },
                                    ),
                                    const Spacer(flex: 2),
                                    Center(
                                      child: GestureDetector(
                                        onTap: () {
                                          ref
                                              .read(
                                                  activeNavTabProvider.notifier)
                                              .select(PerfumeNavTab.search);
                                          widget.onOpenCatalog();
                                        },
                                        behavior: HitTestBehavior.opaque,
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 10,
                                          ),
                                          child: RotatedBox(
                                            quarterTurns: 3,
                                            child: Text(
                                              'View all',
                                              style: TextStyle(
                                                fontFamily:
                                                    AppTheme.contentFont,
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.inkPrimary,
                                                decoration:
                                                    TextDecoration.underline,
                                                decorationColor:
                                                    AppColors.inkPrimary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Spacer(flex: 3),
                                    Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _RailIcon(
                                            isSelected:
                                                activeTab == PerfumeNavTab.home,
                                            icon:
                                                activeTab == PerfumeNavTab.home
                                                    ? PhosphorIconsFill.house
                                                    : PhosphorIconsRegular
                                                        .house,
                                            onTap: () {
                                              ref
                                                  .read(activeNavTabProvider
                                                      .notifier)
                                                  .select(PerfumeNavTab.home);
                                            },
                                          ),
                                          const SizedBox(height: 6),
                                          _RailIcon(
                                            isSelected: activeTab ==
                                                PerfumeNavTab.search,
                                            icon: activeTab ==
                                                    PerfumeNavTab.search
                                                ? PhosphorIconsFill
                                                    .magnifyingGlass
                                                : PhosphorIconsRegular
                                                    .magnifyingGlass,
                                            onTap: () {
                                              ref
                                                  .read(activeNavTabProvider
                                                      .notifier)
                                                  .select(PerfumeNavTab.search);
                                              widget.onOpenCatalog();
                                            },
                                          ),
                                          const SizedBox(height: 6),
                                          _RailIcon(
                                            isSelected: activeTab ==
                                                PerfumeNavTab.favorite,
                                            icon: activeTab ==
                                                    PerfumeNavTab.favorite
                                                ? PhosphorIconsFill.heart
                                                : PhosphorIconsRegular.heart,
                                            onTap: () {
                                              ref
                                                  .read(activeNavTabProvider
                                                      .notifier)
                                                  .select(
                                                      PerfumeNavTab.favorite);
                                              ref
                                                  .read(favoritesFilterProvider
                                                      .notifier)
                                                  .set(true);
                                              widget.onOpenCatalog();
                                            },
                                          ),
                                          const SizedBox(height: 6),
                                          _RailIcon(
                                            isSelected:
                                                activeTab == PerfumeNavTab.cart,
                                            icon:
                                                activeTab == PerfumeNavTab.cart
                                                    ? PhosphorIconsFill
                                                        .shoppingCartSimple
                                                    : PhosphorIconsRegular
                                                        .shoppingCartSimple,
                                            onTap: widget.onOpenCart,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: bottomInset + 14),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: FadeTransition(
                    opacity: _heroFade,
                    child: SlideTransition(
                      position: _heroSlide,
                      child: const EditorialHeroCard(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RailIcon extends StatelessWidget {
  const _RailIcon({
    required this.isSelected,
    required this.icon,
    required this.onTap,
  });

  final bool isSelected;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: PerfumeBottleNavBg(
        isSelected: isSelected,
        width: 44,
        height: 44,
        child: Icon(
          icon,
          size: 21,
          color: isSelected ? AppColors.inkPrimary : AppColors.inkMuted,
        ),
      ),
    );
  }
}
