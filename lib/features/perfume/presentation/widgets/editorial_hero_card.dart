import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/perfume_mock_data.dart';
import '../../domain/perfume.dart';
import '../providers/perfume_providers.dart';
import 'perfume_bottle_placeholder.dart';

class EditorialHeroCard extends ConsumerStatefulWidget {
  const EditorialHeroCard({super.key});

  @override
  ConsumerState<EditorialHeroCard> createState() => _EditorialHeroCardState();
}

class _EditorialHeroCardState extends ConsumerState<EditorialHeroCard> {
  late final PageController _carouselController;

  @override
  void initState() {
    super.initState();
    _carouselController = PageController();
  }

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeIndex = ref.watch(heroCarouselIndexProvider);

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(38),
      ),
      child: Stack(
        children: [
          PageView.builder(
            controller: _carouselController,
            itemCount: featuredPerfumes.length,
            onPageChanged: (index) {
              ref.read(heroCarouselIndexProvider.notifier).setIndex(index);
            },
            itemBuilder: (context, index) {
              return _EditorialSlide(perfume: featuredPerfumes[index]);
            },
          ),
          // Bottom-right pagination indicator dots inside subtle frosted pill
          Positioned(
            right: 20,
            bottom: 22,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  featuredPerfumes.length,
                  (index) {
                    final isSelected = index == activeIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: isSelected ? 14 : 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.surface
                            : AppColors.surface.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditorialSlide extends StatefulWidget {
  const _EditorialSlide({required this.perfume});

  final Perfume perfume;

  @override
  State<_EditorialSlide> createState() => _EditorialSlideState();
}

class _EditorialSlideState extends State<_EditorialSlide> {
  static final Map<String, bool> _darkTopRightCache = {};
  bool _isDarkTopRight = false;

  @override
  void initState() {
    super.initState();
    _detectTopRightLuminance();
  }

  @override
  void didUpdateWidget(covariant _EditorialSlide oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.perfume.heroImageAsset != widget.perfume.heroImageAsset) {
      _detectTopRightLuminance();
    }
  }

  Future<void> _detectTopRightLuminance() async {
    final asset = widget.perfume.heroImageAsset;
    if (asset == null) {
      if (_isDarkTopRight) setState(() => _isDarkTopRight = false);
      return;
    }
    final cached = _darkTopRightCache[asset];
    if (cached != null) {
      if (_isDarkTopRight != cached) setState(() => _isDarkTopRight = cached);
      return;
    }

    try {
      final data = await rootBundle.load(asset);
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetWidth: 64,
      );
      final frame = await codec.getNextFrame();
      final byteData = await frame.image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      if (byteData == null) return;

      final w = frame.image.width;
      final h = frame.image.height;
      final startX = (w * 0.55).floor();
      final endY = (h * 0.28).ceil();

      double totalLuminance = 0;
      int count = 0;
      for (int y = 0; y < endY; y++) {
        for (int x = startX; x < w; x++) {
          final offset = (y * w + x) * 4;
          final r = byteData.getUint8(offset) / 255.0;
          final g = byteData.getUint8(offset + 1) / 255.0;
          final b = byteData.getUint8(offset + 2) / 255.0;
          totalLuminance += (0.2126 * r + 0.7152 * g + 0.0722 * b);
          count++;
        }
      }

      final avgLuminance = count > 0 ? totalLuminance / count : 1.0;
      final isDark = avgLuminance < 0.52;
      _darkTopRightCache[asset] = isDark;
      if (mounted && _isDarkTopRight != isDark) {
        setState(() => _isDarkTopRight = isDark);
      }
    } catch (_) {
      // Keep default light-background styling if asset decoding is unavailable.
    }
  }

  @override
  Widget build(BuildContext context) {
    final perfume = widget.perfume;
    final titleColor = _isDarkTopRight ? AppColors.surface : AppColors.inkPrimary;
    final subtitleColor =
        _isDarkTopRight ? AppColors.surface : AppColors.inkSecondary;
    final pillColor = _isDarkTopRight
        ? Colors.black.withValues(alpha: 0.42)
        : AppColors.heroPillLight.withValues(alpha: 0.85);

    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.25, -0.15),
          radius: 1.15,
          colors: [
            AppColors.surface,
            AppColors.heroBackdropMid,
            AppColors.heroBackdropEdge,
            AppColors.heroBackdropDeep,
          ],
          stops: [0.0, 0.42, 0.74, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (perfume.heroImageAsset != null)
            Image.asset(
              perfume.heroImageAsset!,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            )
          else ...[
            Positioned.fill(
              child: CustomPaint(
                painter: _EditorialSilhouettePainter(
                  accent: perfume.bottlePrimary,
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 32, right: 16),
                child: PerfumeBottlePlaceholder(
                  perfume: perfume,
                  width: 146,
                  height: 218,
                ),
              ),
            ),
          ],
          // Subtle dark bottom gradient so pagination dots stay crisp
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 80,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.25),
                  ],
                ),
              ),
            ),
          ),
          // Top-right brand name & subtitle with adaptive contrast + gradient pill
          Positioned(
            top: 24,
            right: 22,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  perfume.brand.toUpperCase(),
                  style: TextStyle(
                    fontFamily: AppTheme.contentFont,
                    fontSize: 23,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1.8,
                    color: titleColor,
                    shadows: _isDarkTopRight
                        ? [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        pillColor,
                        pillColor.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                  child: Text(
                    perfume.subtitle,
                    style: TextStyle(
                      fontFamily: AppTheme.contentFont,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: subtitleColor,
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

class _EditorialSilhouettePainter extends CustomPainter {
  const _EditorialSilhouettePainter({required this.accent});

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Soft studio glow behind the bottle
    canvas.drawCircle(
      Offset(w * 0.44, h * 0.48),
      w * 0.42,
      Paint()
        ..color = accent.withValues(alpha: 0.14)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 42),
    );

    // Subtle editorial draped shoulder/sleeve geometry at bottom
    final drape = Path()
      ..moveTo(0, h * 0.72)
      ..quadraticBezierTo(w * 0.35, h * 0.64, w * 0.68, h * 0.78)
      ..quadraticBezierTo(w * 0.86, h * 0.85, w, h * 0.80)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawPath(
      drape,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.heroDrapeLight.withValues(alpha: 0.55),
            AppColors.heroDrapeDark.withValues(alpha: 0.45),
          ],
        ).createShader(Rect.fromLTWH(0, h * 0.64, w, h * 0.36)),
    );
  }

  @override
  bool shouldRepaint(covariant _EditorialSilhouettePainter oldDelegate) =>
      oldDelegate.accent != accent;
}
