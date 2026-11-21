import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// Extracts dominant and soft pastel tones from a perfume bottle's image asset
/// so each catalog card's description box and bottle shadow harmonize with its bottle.
class BottleToneExtractor {
  BottleToneExtractor._();

  static final Map<String, Color> _dominantCache = {};

  static Future<Color> extractDominantColor(
    String? assetPath, {
    required Color fallbackColor,
  }) async {
    if (assetPath == null) return fallbackColor;
    final cached = _dominantCache[assetPath];
    if (cached != null) return cached;

    try {
      final data = await rootBundle.load(assetPath);
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetWidth: 48,
      );
      final frame = await codec.getNextFrame();
      final byteData = await frame.image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      if (byteData == null) return fallbackColor;

      final w = frame.image.width;
      final h = frame.image.height;

      double sumR = 0;
      double sumG = 0;
      double sumB = 0;
      double weightSum = 0;

      // Focus on bottle body area (skip top cap & bottom shadow)
      final startY = (h * 0.28).floor();
      final endY = (h * 0.85).ceil();

      for (int y = startY; y < endY; y++) {
        for (int x = 0; x < w; x++) {
          final offset = (y * w + x) * 4;
          final r = byteData.getUint8(offset);
          final g = byteData.getUint8(offset + 1);
          final b = byteData.getUint8(offset + 2);
          final a = byteData.getUint8(offset + 3);
          if (a < 180) continue;

          final maxC = r > g ? (r > b ? r : b) : (g > b ? g : b);
          final minC = r < g ? (r < b ? r : b) : (g < b ? g : b);
          final sat = maxC - minC;

          // Ignore pure white background and deep black cap/text
          if (minC > 238 || maxC < 28) continue;

          // Weight chromatic liquid/glass pixels higher than neutral glass
          final weight = sat > 18 ? 1.0 + (sat / 64.0) : 0.25;
          sumR += r * weight;
          sumG += g * weight;
          sumB += b * weight;
          weightSum += weight;
        }
      }

      if (weightSum <= 0) {
        _dominantCache[assetPath] = fallbackColor;
        return fallbackColor;
      }

      final dominant = Color.fromARGB(
        255,
        (sumR / weightSum).round().clamp(0, 255),
        (sumG / weightSum).round().clamp(0, 255),
        (sumB / weightSum).round().clamp(0, 255),
      );
      _dominantCache[assetPath] = dominant;
      return dominant;
    } catch (_) {
      return fallbackColor;
    }
  }

  static Future<Color> extractPastelTint(
    String? assetPath, {
    required Color fallbackColor,
  }) async {
    final dominant = await extractDominantColor(
      assetPath,
      fallbackColor: fallbackColor,
    );
    if (assetPath == null) return fallbackColor;
    return Color.lerp(AppColors.surface, dominant, 0.14)!;
  }
}
