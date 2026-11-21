import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

/// Editorial promotional banner displayed between catalog sections to break
/// monotony while maintaining Aromantique's mist-sage & obsidian palette.
class CatalogPromoBanner extends StatelessWidget {
  const CatalogPromoBanner({
    super.key,
    required this.imageAsset,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.isDark,
    required this.onTap,
  });

  final String imageAsset;
  final String eyebrow;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final titleColor = isDark ? AppColors.surface : AppColors.inkPrimary;
    final subColor = isDark
        ? AppColors.sageHighlight.withValues(alpha: 0.90)
        : AppColors.inkSecondary;
    final eyebrowBg = isDark
        ? AppColors.sageHighlight.withValues(alpha: 0.16)
        : AppColors.surface.withValues(alpha: 0.85);
    final eyebrowFg = isDark ? AppColors.sageHighlight : AppColors.sageIcon;
    final ctaBg = isDark ? AppColors.surface : AppColors.inkPrimary;
    final ctaFg = isDark ? AppColors.inkPrimary : AppColors.surface;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 152,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? AppColors.inkPrimary.withValues(alpha: 0.20)
                : AppColors.borderSubtle,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.05),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Editorial background photography
              Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
                errorBuilder: (_, _, _) => ColoredBox(
                  color: isDark
                      ? AppColors.inkPrimary
                      : AppColors.sageHighlight,
                ),
              ),
              // Directional legibility veil on the left side
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: const [0.0, 0.52, 0.86, 1.0],
                    colors: isDark
                        ? [
                            AppColors.inkPrimary.withValues(alpha: 0.94),
                            AppColors.inkPrimary.withValues(alpha: 0.78),
                            AppColors.inkPrimary.withValues(alpha: 0.18),
                            Colors.transparent,
                          ]
                        : [
                            AppColors.background.withValues(alpha: 0.95),
                            AppColors.background.withValues(alpha: 0.80),
                            AppColors.background.withValues(alpha: 0.16),
                            Colors.transparent,
                          ],
                  ),
                ),
              ),
              // Editorial copy & pill CTA
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.66,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: eyebrowBg,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          eyebrow,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppTheme.contentFont,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: eyebrowFg,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppTheme.brandFont,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              height: 1.1,
                              color: titleColor,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppTheme.contentFont,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w400,
                              color: subColor,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: ctaBg,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                ctaLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: AppTheme.contentFont,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: ctaFg,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Icon(
                              PhosphorIconsRegular.arrowRight,
                              size: 12,
                              color: ctaFg,
                            ),
                          ],
                        ),
                      ),
                    ],
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
