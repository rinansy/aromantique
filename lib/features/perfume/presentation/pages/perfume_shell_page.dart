import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/perfume_providers.dart';
import '../widgets/cart_bottom_sheet.dart';
import '../widgets/perfume_animated_app_bar.dart';
import 'catalog_view.dart';
import 'editorial_home_view.dart';

/// Root vertical slider shell:
/// - Page 0: Editorial Home (swipe up or tap "View all" to replace with Page 2)
/// - Page 1: Catalog View with floating bottom navigation
class PerfumeShellPage extends ConsumerStatefulWidget {
  const PerfumeShellPage({super.key});

  @override
  ConsumerState<PerfumeShellPage> createState() => _PerfumeShellPageState();
}

class _PerfumeShellPageState extends ConsumerState<PerfumeShellPage> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _animateToPage(int page) {
    ref.read(shellPageIndexProvider.notifier).setPage(page);
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  void _showCartSheet() => showCartBottomSheet(context);

  void _backToHome() {
    ref.read(activeNavTabProvider.notifier).select(PerfumeNavTab.home);
    ref.read(favoritesFilterProvider.notifier).set(false);
    _animateToPage(0);
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = ref.watch(shellPageIndexProvider);

    return PopScope(
      canPop: currentPage == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && currentPage == 1) {
          _backToHome();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
        children: [
          Positioned.fill(
            child: PageView(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              physics: currentPage == 0
                  ? const BouncingScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                ref.read(shellPageIndexProvider.notifier).setPage(index);
                if (index == 0) {
                  ref
                      .read(activeNavTabProvider.notifier)
                      .select(PerfumeNavTab.home);
                  ref.read(favoritesFilterProvider.notifier).set(false);
                } else {
                  if (ref.read(activeNavTabProvider) == PerfumeNavTab.home) {
                    ref
                        .read(activeNavTabProvider.notifier)
                        .select(PerfumeNavTab.search);
                  }
                }
              },
              children: [
                EditorialHomeView(
                  onOpenCatalog: () => _animateToPage(1),
                  onOpenCart: _showCartSheet,
                ),
                CatalogView(
                  onBackToHome: () {
                    ref
                        .read(activeNavTabProvider.notifier)
                        .select(PerfumeNavTab.home);
                    ref.read(favoritesFilterProvider.notifier).set(false);
                    _animateToPage(0);
                  },
                  onOpenCart: _showCartSheet,
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _pageController,
              builder: (context, _) {
                final progress = _pageController.hasClients
                    ? (_pageController.page ?? currentPage.toDouble())
                    : currentPage.toDouble();
                return PerfumeAnimatedAppBar(
                  progress: progress,
                  onBackTap: () {
                    ref
                        .read(activeNavTabProvider.notifier)
                        .select(PerfumeNavTab.home);
                    ref.read(favoritesFilterProvider.notifier).set(false);
                    _animateToPage(0);
                  },
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }
}
