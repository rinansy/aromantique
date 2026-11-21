import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/perfume_bottle_nav_bg.dart';
import '../providers/perfume_providers.dart';

class FloatingBottomNav extends ConsumerStatefulWidget {
  const FloatingBottomNav({
    super.key,
    required this.onGoHome,
    required this.onOpenCart,
    this.cartIconKey,
    this.favoriteIconKey,
  });

  final VoidCallback onGoHome;
  final VoidCallback onOpenCart;
  final GlobalKey? cartIconKey;
  final GlobalKey? favoriteIconKey;

  @override
  ConsumerState<FloatingBottomNav> createState() => _FloatingBottomNavState();
}

class _FloatingBottomNavState extends ConsumerState<FloatingBottomNav>
    with TickerProviderStateMixin {
  late final AnimationController _cartBounceController;
  late final AnimationController _favoriteBounceController;

  @override
  void initState() {
    super.initState();
    _cartBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _favoriteBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
  }

  @override
  void dispose() {
    _cartBounceController.dispose();
    _favoriteBounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(cartBounceTickProvider, (prev, next) {
      if (prev != null && next > prev) {
        _cartBounceController.forward(from: 0);
      }
    });
    ref.listen<int>(favoriteBounceTickProvider, (prev, next) {
      if (prev != null && next > prev) {
        _favoriteBounceController.forward(from: 0);
      }
    });

    final activeTab = ref.watch(activeNavTabProvider);
    final onlyFavorites = ref.watch(favoritesFilterProvider);
    final favoriteCount = ref.watch(favoritesProvider).length;
    final cartCount = ref.watch(cartCountProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _NavButton(
            isSelected: activeTab == PerfumeNavTab.home,
            onTap: () {
              ref.read(activeNavTabProvider.notifier).select(PerfumeNavTab.home);
              ref.read(favoritesFilterProvider.notifier).set(false);
              widget.onGoHome();
            },
            icon: activeTab == PerfumeNavTab.home
                ? PhosphorIconsFill.house
                : PhosphorIconsRegular.house,
          ),
          const SizedBox(width: 8),
          _NavButton(
            isSelected: activeTab == PerfumeNavTab.search && !onlyFavorites,
            onTap: () {
              ref
                  .read(activeNavTabProvider.notifier)
                  .select(PerfumeNavTab.search);
              ref.read(favoritesFilterProvider.notifier).set(false);
            },
            icon: activeTab == PerfumeNavTab.search && !onlyFavorites
                ? PhosphorIconsFill.magnifyingGlass
                : PhosphorIconsRegular.magnifyingGlass,
          ),
          const SizedBox(width: 8),
          AnimatedBuilder(
            animation: _favoriteBounceController,
            builder: (context, child) {
              final t = _favoriteBounceController.value;
              final scale = t == 0 ? 1.0 : 1.0 + math.sin(t * math.pi) * 0.28;
              final angle =
                  t == 0 ? 0.0 : math.sin(t * math.pi * 3) * 0.16 * (1 - t);
              return Transform.rotate(
                angle: angle,
                child: Transform.scale(scale: scale, child: child),
              );
            },
            child: Container(
              key: widget.favoriteIconKey,
              child: _NavButton(
                isSelected: onlyFavorites || activeTab == PerfumeNavTab.favorite,
                badgeCount: favoriteCount,
                onTap: () {
                  ref
                      .read(activeNavTabProvider.notifier)
                      .select(PerfumeNavTab.favorite);
                  ref.read(favoritesFilterProvider.notifier).toggle();
                },
                icon: (onlyFavorites || activeTab == PerfumeNavTab.favorite)
                    ? PhosphorIconsFill.heart
                    : PhosphorIconsRegular.heart,
                activeIconColor: AppColors.notificationDot,
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedBuilder(
            animation: _cartBounceController,
            builder: (context, child) {
              final t = _cartBounceController.value;
              // Snappy bounce + wiggle when bottle lands in cart
              final scale = t == 0
                  ? 1.0
                  : 1.0 + math.sin(t * math.pi) * 0.28;
              final angle = t == 0
                  ? 0.0
                  : math.sin(t * math.pi * 3) * 0.16 * (1 - t);
              return Transform.rotate(
                angle: angle,
                child: Transform.scale(
                  scale: scale,
                  child: child,
                ),
              );
            },
            child: Container(
              key: widget.cartIconKey,
              child: _NavButton(
                isSelected: activeTab == PerfumeNavTab.cart,
                badgeCount: cartCount,
                onTap: widget.onOpenCart,
                icon: activeTab == PerfumeNavTab.cart
                    ? PhosphorIconsFill.shoppingCartSimple
                    : PhosphorIconsRegular.shoppingCartSimple,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.isSelected,
    required this.onTap,
    required this.icon,
    this.badgeCount = 0,
    this.activeIconColor,
  });

  final bool isSelected;
  final VoidCallback onTap;
  final IconData icon;
  final int badgeCount;
  final Color? activeIconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          PerfumeBottleNavBg(
            isSelected: isSelected,
            width: 44,
            height: 46,
            child: Icon(
              icon,
              size: 21,
              color: isSelected
                  ? (activeIconColor ?? AppColors.inkPrimary)
                  : AppColors.inkSecondary,
            ),
          ),
          if (badgeCount > 0)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.inkPrimary,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    fontFamily: AppTheme.contentFont,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.surface,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
