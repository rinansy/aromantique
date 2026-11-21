import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/flared_side_drawer_container.dart';
import '../../data/perfume_mock_data.dart';
import '../../domain/perfume.dart';
import '../providers/perfume_providers.dart';

/// Opens a half-width, vertically-centered rounded filter drawer from the left
/// with a light translucent backdrop so the catalog remains visible behind it.
Future<void> showPerfumeFilterDrawer(BuildContext context) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Filter',
    barrierColor: Colors.black.withValues(alpha: 0.16),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const _PerfumeFilterDrawerBody();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-1, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      );
    },
  );
}

class _PerfumeFilterDrawerBody extends ConsumerWidget {
  const _PerfumeFilterDrawerBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screen = MediaQuery.sizeOf(context);
    final selectedBrands = ref.watch(selectedBrandsProvider);
    final selectedGenders = ref.watch(selectedGendersProvider);
    final priceRange = ref.watch(priceRangeProvider);

    final drawerWidth = (screen.width * 0.70).clamp(260.0, 320.0);
    final maxDrawerHeight = (screen.height * 0.56).clamp(320.0, 480.0);

    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.transparent,
        child: FlaredSideDrawerContainer(
          fromLeft: true,
          width: drawerWidth,
          maxHeight: maxDrawerHeight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 14, 10),
                  child: Row(
                    children: [
                      const Icon(
                        PhosphorIconsRegular.slidersHorizontal,
                        size: 18,
                        color: AppColors.inkPrimary,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Filter',
                        style: TextStyle(
                          fontFamily: AppTheme.brandFont,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.inkPrimary,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          ref.read(selectedBrandsProvider.notifier).clear();
                          ref.read(selectedGendersProvider.notifier).clear();
                          ref.read(priceRangeProvider.notifier).reset();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.inkSecondary,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Reset',
                          style: TextStyle(
                            fontFamily: AppTheme.contentFont,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.borderSubtle),
                // Scrollable filter options
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 14, 18, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gender',
                          style: TextStyle(
                            fontFamily: AppTheme.contentFont,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.inkPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: PerfumeGender.values.map((gender) {
                            final isSelected = selectedGenders.contains(gender);
                            return GestureDetector(
                              onTap: () => ref
                                  .read(selectedGendersProvider.notifier)
                                  .toggleGender(gender),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 160),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.inkPrimary
                                      : AppColors.background,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.inkPrimary
                                        : AppColors.borderSubtle,
                                  ),
                                ),
                                child: Text(
                                  gender.label,
                                  style: TextStyle(
                                    fontFamily: AppTheme.contentFont,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.surface
                                        : AppColors.inkPrimary,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Brand',
                          style: TextStyle(
                            fontFamily: AppTheme.contentFont,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.inkPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: availableBrands.map((brand) {
                            final isSelected = selectedBrands.contains(brand);
                            return GestureDetector(
                              onTap: () => ref
                                  .read(selectedBrandsProvider.notifier)
                                  .toggleBrand(brand),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 160),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.inkPrimary
                                      : AppColors.background,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.inkPrimary
                                        : AppColors.borderSubtle,
                                  ),
                                ),
                                child: Text(
                                  brand,
                                  style: TextStyle(
                                    fontFamily: AppTheme.contentFont,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.surface
                                        : AppColors.inkPrimary,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                'Price Range',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: AppTheme.contentFont,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.inkPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.sageHighlight
                                    .withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${priceRange.start.round()}\$ – ${priceRange.end.round()}\$',
                                style: const TextStyle(
                                  fontFamily: AppTheme.contentFont,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.inkPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColors.inkPrimary,
                            inactiveTrackColor: AppColors.borderSubtle,
                            thumbColor: AppColors.inkPrimary,
                            overlayColor:
                                AppColors.inkPrimary.withValues(alpha: 0.12),
                            trackHeight: 3,
                          ),
                          child: RangeSlider(
                            values: priceRange,
                            min: kMinPerfumePrice,
                            max: kMaxPerfumePrice,
                            divisions: 35,
                            onChanged: (values) => ref
                                .read(priceRangeProvider.notifier)
                                .update(values),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Apply button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 18, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.inkPrimary,
                        foregroundColor: AppColors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          fontFamily: AppTheme.contentFont,
                          fontSize: 13,
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
