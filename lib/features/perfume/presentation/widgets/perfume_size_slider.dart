import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

/// Fully custom ruler-style slider for choosing perfume bottle size from [sizes],
/// featuring continuous finger tracking, magnetic snapping, a left-to-right
/// flowing liquid wave between stops, and synchronized mini-bottle filling.
class PerfumeSizeSlider extends StatefulWidget {
  const PerfumeSizeSlider({
    super.key,
    required this.sizes,
    required this.selectedSizeMl,
    required this.onChanged,
  });

  final List<int> sizes;
  final int selectedSizeMl;
  final ValueChanged<int> onChanged;

  @override
  State<PerfumeSizeSlider> createState() => _PerfumeSizeSliderState();
}

class _PerfumeSizeSliderState extends State<PerfumeSizeSlider>
    with TickerProviderStateMixin {
  late final AnimationController _snapController;
  late final AnimationController _waveController;

  double _snapFrom = 0.0;
  double _snapTo = 0.0;
  bool _isDragging = false;
  double _dragProgress = 0.0;
  double _waveEnergy = 0.0;
  double _phaseBase = 0.0;
  bool _isIncreasing = true;

  double _progressFor(int sizeMl) {
    if (widget.sizes.length <= 1) return 1.0;
    final idx = widget.sizes.indexOf(sizeMl);
    if (idx < 0) return 0.0;
    return idx / (widget.sizes.length - 1);
  }

  double get _currentProgress {
    if (_isDragging) return _dragProgress;
    final t = Curves.easeInOutCubic.transform(_snapController.value);
    return _snapFrom + (_snapTo - _snapFrom) * t;
  }

  @override
  void initState() {
    super.initState();
    _snapTo = _progressFor(widget.selectedSizeMl);
    _snapFrom = _snapTo;
    _dragProgress = _snapTo;

    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 560),
      value: 1.0,
    );
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
      value: 1.0,
    );
  }

  @override
  void didUpdateWidget(covariant PerfumeSizeSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedSizeMl != widget.selectedSizeMl ||
        oldWidget.sizes != widget.sizes) {
      final next = _progressFor(widget.selectedSizeMl);
      if (!_isDragging) {
        final current = _currentProgress;
        _isIncreasing = next >= current;
        _snapFrom = current;
        _snapTo = next;
        _triggerWave(energy: (next - current).abs().clamp(0.65, 1.0));
        _snapController.forward(from: 0.0);
      } else {
        _snapTo = next;
      }
    }
  }

  void _triggerWave({double energy = 0.9}) {
    _phaseBase = (_phaseBase + _waveController.value * math.pi * 6.0) %
        (math.pi * 2);
    _waveEnergy = energy.clamp(0.35, 1.0);
    _waveController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _snapController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  double _ratioForX(double localX, double width) {
    if (width <= 0) return _currentProgress;
    const pad = 16.0;
    final usableW = (width - pad * 2).clamp(1.0, double.infinity);
    return ((localX - pad) / usableW).clamp(0.0, 1.0);
  }

  int _sizeForRatio(double ratio) {
    if (widget.sizes.length <= 1) return widget.selectedSizeMl;
    final idx = (ratio * (widget.sizes.length - 1)).round();
    return widget.sizes[idx];
  }

  void _handleDragStart(double localX, double width) {
    _snapController.stop();
    final ratio = _ratioForX(localX, width);
    final current = _currentProgress;
    setState(() {
      _isDragging = true;
      _snapFrom = current;
      _isIncreasing = ratio >= current;
      _dragProgress = ratio;
    });
    _triggerWave(energy: 0.7);
    final nearest = _sizeForRatio(ratio);
    if (nearest != widget.selectedSizeMl) {
      widget.onChanged(nearest);
    }
  }

  void _handleDragUpdate(double localX, double width, double deltaDx) {
    final ratio = _ratioForX(localX, width);
    final speedBoost = (deltaDx.abs() / 14.0).clamp(0.35, 1.0);
    setState(() {
      _isDragging = true;
      if (deltaDx.abs() > 0.2) _isIncreasing = deltaDx > 0;
      _dragProgress = ratio;
      _phaseBase = (_phaseBase + deltaDx.abs() * 0.12) % (math.pi * 2);
      _waveEnergy = math.max(_waveEnergy * 0.93, speedBoost);
    });
    final nearest = _sizeForRatio(ratio);
    if (nearest != widget.selectedSizeMl) {
      widget.onChanged(nearest);
    }
  }

  void _handleDragEnd() {
    if (!_isDragging) return;
    final targetSize = _sizeForRatio(_dragProgress);
    final targetProgress = _progressFor(targetSize);
    setState(() {
      _isDragging = false;
      _snapFrom = _dragProgress;
      _snapTo = targetProgress;
      _isIncreasing = targetProgress >= _dragProgress;
    });
    _snapController.forward(from: 0.0);
    _triggerWave(energy: math.max(_waveEnergy, 0.65));
    if (targetSize != widget.selectedSizeMl) {
      widget.onChanged(targetSize);
    }
  }

  void _handleTapDown(double localX, double width) {
    final ratio = _ratioForX(localX, width);
    final targetSize = _sizeForRatio(ratio);
    if (targetSize == widget.selectedSizeMl) {
      _triggerWave(energy: 0.55);
      return;
    }
    widget.onChanged(targetSize);
  }

  /// Computes a smooth 0..0.88 liquid fill level for bottle [index] driven
  /// directly by the continuous slider [progress], so each bottle fills up
  /// right as the left-to-right water wave arrives at its tick mark.
  double _bottleFillFor(int index, double progress) {
    final count = widget.sizes.length;
    if (count <= 1 || index == 0) return 0.86;
    final step = 1.0 / (count - 1);
    final stopPos = index * step;
    final startFillPos = (index - 1) * step + (step * 0.22);
    final raw = ((progress - startFillPos) / (stopPos - startFillPos))
        .clamp(0.0, 1.0);
    return Curves.easeInOutCubic.transform(raw) * 0.86;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_snapController, _waveController]),
      builder: (context, _) {
        final progress = _currentProgress;
        final waveT = _waveController.value;
        // Continuous envelope: rises softly from 0 and decays cleanly to 0 (no blink)
        final attack = waveT < 0.06 ? (waveT / 0.06) : 1.0;
        final decay = _isDragging
            ? _waveEnergy
            : _waveEnergy *
                attack *
                (1.0 - Curves.easeOutCubic.transform(waveT));
        final wavePhase = _phaseBase + (waveT * math.pi * 6.0);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Perfume Bottle Size',
              style: TextStyle(
                fontFamily: AppTheme.contentFont,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.inkPrimary,
              ),
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                const barHeight = 36.0;
                const thumbOverflow = 4.0;
                const pad = 16.0;
                final usableW = (width - pad * 2).clamp(1.0, double.infinity);
                final thumbX = pad + (usableW * progress);
                final originX = pad + (usableW * _snapFrom);
                final count = widget.sizes.length;
                final step = count <= 1 ? 1.0 : 1.0 / (count - 1);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mini perfume bottles aligned directly above each ruler stop
                    SizedBox(
                      height: 30,
                      width: width,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: List.generate(count, (i) {
                          final s = widget.sizes[i];
                          final stopPos = count <= 1 ? 0.5 : i * step;
                          final stopX = count <= 1
                              ? width * 0.5
                              : pad + (usableW * stopPos);
                          final bottleH = 14.0 + (stopPos * 11.0);
                          final bottleW = 10.0 + (stopPos * 6.0);
                          final fillLevel = _bottleFillFor(i, progress);
                          final proximity = (1.0 -
                                  ((progress - stopPos).abs() / step)
                                      .clamp(0.0, 1.0));
                          final scale = 1.0 + (0.14 * proximity);
                          final isSelected = s == widget.selectedSizeMl;
                          // Stronger slosh inside bottles currently filling or reached
                          final bottleWaveAmp = fillLevel > 0.02
                              ? decay * (1.8 + 1.4 * proximity)
                              : 0.0;
                          const hitW = 28.0;

                          return Positioned(
                            left: (stopX - hitW / 2)
                                .clamp(0.0, math.max(0.0, width - hitW)),
                            bottom: 0,
                            width: hitW,
                            height: 30,
                            child: GestureDetector(
                              onTap: () => widget.onChanged(s),
                              behavior: HitTestBehavior.opaque,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Transform.scale(
                                  scale: scale,
                                  alignment: Alignment.bottomCenter,
                                  child: CustomPaint(
                                    size: Size(bottleW, bottleH),
                                    painter: _MiniBottleSilhouettePainter(
                                      isSelected: isSelected,
                                      fillLevel: fillLevel,
                                      wavePhase: wavePhase - (i * 0.85),
                                      waveAmplitude: bottleWaveAmp,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Custom ruler track with left-to-right flowing water wave
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (d) =>
                          _handleTapDown(d.localPosition.dx, width),
                      onHorizontalDragStart: (d) =>
                          _handleDragStart(d.localPosition.dx, width),
                      onHorizontalDragUpdate: (d) => _handleDragUpdate(
                        d.localPosition.dx,
                        width,
                        d.delta.dx,
                      ),
                      onHorizontalDragEnd: (_) => _handleDragEnd(),
                      onHorizontalDragCancel: _handleDragEnd,
                      child: SizedBox(
                        height: barHeight + (thumbOverflow * 2),
                        width: width,
                        child: CustomPaint(
                          painter: _RulerSliderPainter(
                            thumbX: thumbX,
                            originX: originX,
                            barHeight: barHeight,
                            thumbOverflow: thumbOverflow,
                            horizontalPad: pad,
                            majorStops: count,
                            wavePhase: wavePhase,
                            waveDamping: decay,
                            isIncreasing: _isIncreasing,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: widget.sizes.map((s) {
                  final isSelected = s == widget.selectedSizeMl;
                  return Flexible(
                    child: GestureDetector(
                      onTap: () => widget.onChanged(s),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${s}ml',
                          style: TextStyle(
                            fontFamily: AppTheme.contentFont,
                            fontSize: 11,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? AppColors.inkPrimary
                                : AppColors.inkSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RulerSliderPainter extends CustomPainter {
  const _RulerSliderPainter({
    required this.thumbX,
    required this.originX,
    required this.barHeight,
    required this.thumbOverflow,
    required this.horizontalPad,
    required this.majorStops,
    required this.wavePhase,
    required this.waveDamping,
    required this.isIncreasing,
  });

  final double thumbX;
  final double originX;
  final double barHeight;
  final double thumbOverflow;
  final double horizontalPad;
  final int majorStops;
  final double wavePhase;
  final double waveDamping;
  final bool isIncreasing;

  /// Builds a liquid fill path from x=0 to [edgeX] with an organic vertical
  /// wave front along the advancing right meniscus.
  Path _buildLiquidFrontPath(
    double edgeX,
    double maxW,
    double amp,
    double phaseOffset,
  ) {
    final top = thumbOverflow;
    final bottom = thumbOverflow + barHeight;
    final path = Path()
      ..moveTo(0, top)
      ..lineTo(edgeX, top);

    const steps = 22;
    for (int i = 0; i <= steps; i++) {
      final frac = i / steps;
      final y = top + (barHeight * frac);
      final edgeTaper = math.sin(frac * math.pi);
      // Minus wavePhase makes crests roll smoothly forward
      final ripple =
          math.sin(frac * math.pi * 2.4 - wavePhase + phaseOffset) *
              amp *
              (0.35 + 0.65 * edgeTaper);
      path.lineTo((edgeX + ripple).clamp(0.0, maxW), y);
    }

    path
      ..lineTo(0, bottom)
      ..close();
    return path;
  }

  /// Builds a horizontal rolling water wave band flowing left → right across
  /// the liquid span `0..spanW`.
  Path _buildFlowingWaterBand({
    required double spanW,
    required double baseY,
    required double amplitude,
    required double freq,
    required double phaseShift,
  }) {
    final top = thumbOverflow;
    final bottom = top + barHeight;
    final path = Path()..moveTo(0, bottom);
    const segments = 28;
    for (int i = 0; i <= segments; i++) {
      final fx = i / segments;
      final x = spanW * fx;
      // Stronger wave swell inside the newly filling zone (originX → thumbX)
      final inZoneBoost = (isIncreasing && x >= originX - 8) ? 1.35 : 0.75;
      // Subtract wavePhase so the wave visibly travels from LEFT to RIGHT
      final y = baseY +
          math.sin((x * freq) - wavePhase + phaseShift) *
              amplitude *
              inZoneBoost;
      path.lineTo(x, y.clamp(top + 2.0, bottom - 2.0));
    }
    path
      ..lineTo(spanW, bottom)
      ..close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final top = thumbOverflow;
    final barRect = Rect.fromLTWH(0, top, w, barHeight);
    final barRRect = RRect.fromRectAndRadius(barRect, const Radius.circular(10));

    // Unfilled right track
    canvas.drawRRect(barRRect, Paint()..color = AppColors.background);

    // Liquid wave fill clipped inside the rounded bar
    canvas.save();
    canvas.clipRRect(barRRect);

    final primaryAmp = waveDamping * 7.5;
    final surgeAmp = waveDamping * 11.0;

    // 1. Leading translucent water surge rushing left → right ahead of thumbX
    final surgeLead = isIncreasing ? (11.0 * waveDamping) : (-4.0 * waveDamping);
    final surgeAlpha = (0.48 * waveDamping).clamp(0.0, 1.0);
    if (surgeAlpha > 0.002) {
      final surgePath = _buildLiquidFrontPath(
        (thumbX + surgeLead).clamp(0.0, w),
        w,
        surgeAmp,
        math.pi * 0.55,
      );
      canvas.drawPath(
        surgePath,
        Paint()..color = AppColors.sageIcon.withValues(alpha: surgeAlpha),
      );
    }

    // 2. Main dark liquid body with smooth curved wave front
    final mainWave = _buildLiquidFrontPath(thumbX, w, primaryAmp, 0.0);
    canvas.drawPath(mainWave, Paint()..color = AppColors.inkPrimary);

    // 3. Two horizontal rolling water waves traveling left → right inside the fill
    if (waveDamping > 0.004 && thumbX > 8) {
      // Back sage-tinted rolling water swell
      final swellAlpha = (0.34 * waveDamping).clamp(0.0, 1.0);
      final swellPath = _buildFlowingWaterBand(
        spanW: thumbX,
        baseY: top + barHeight * 0.46,
        amplitude: 5.5 * waveDamping,
        freq: 0.085,
        phaseShift: 0.0,
      );
      canvas.drawPath(
        swellPath,
        Paint()..color = AppColors.sageIcon.withValues(alpha: swellAlpha),
      );

      // Front bright surface crest traveling left → right
      final crestAlpha = (0.22 * waveDamping).clamp(0.0, 1.0);
      final crestPath = _buildFlowingWaterBand(
        spanW: thumbX,
        baseY: top + barHeight * 0.62,
        amplitude: 4.5 * waveDamping,
        freq: 0.115,
        phaseShift: math.pi * 0.8,
      );
      canvas.drawPath(
        crestPath,
        Paint()..color = AppColors.surface.withValues(alpha: crestAlpha),
      );

      // Streaming micro-bubbles drifting left → right in the active fill wake
      if (isIncreasing && thumbX > originX + 4) {
        final span = (thumbX - originX).clamp(12.0, w);
        final bubblePaint = Paint()
          ..color = AppColors.surface.withValues(alpha: 0.42 * waveDamping);
        for (int b = 0; b < 4; b++) {
          final flow = ((wavePhase * 0.16) + (b * 0.27)) % 1.0;
          final bx = (originX + span * flow).clamp(6.0, thumbX - 4);
          final by = top +
              barHeight * (0.32 + (b % 3) * 0.22) +
              math.sin(wavePhase + b * 1.4) * (2.8 * waveDamping);
          canvas.drawCircle(
            Offset(bx, by),
            1.3 + (b % 2) * 0.7,
            bubblePaint,
          );
        }
      }
    }

    // Ruler tick marks (4 subdivisions per major stop)
    final usableW = (w - horizontalPad * 2).clamp(1.0, double.infinity);
    const subDivs = 4;
    final totalTicks = (majorStops - 1) * subDivs;
    final centerY = top + barHeight / 2;

    if (totalTicks > 0) {
      for (int i = 0; i <= totalTicks; i++) {
        final tx = horizontalPad + (usableW * (i / totalTicks));
        final isMajor = i % subDivs == 0;
        final tickH = isMajor ? 16.0 : 9.0;
        final isFilled = tx <= thumbX;

        canvas.drawLine(
          Offset(tx, centerY - tickH / 2),
          Offset(tx, centerY + tickH / 2),
          Paint()
            ..color = isFilled
                ? AppColors.surface.withValues(alpha: isMajor ? 0.90 : 0.48)
                : AppColors.inkMuted.withValues(alpha: isMajor ? 0.85 : 0.45)
            ..strokeWidth = isMajor ? 1.5 : 1.1
            ..strokeCap = StrokeCap.round,
        );
      }
    } else {
      canvas.drawLine(
        Offset(w * 0.5, centerY - 8.0),
        Offset(w * 0.5, centerY + 8.0),
        Paint()
          ..color = AppColors.surface.withValues(alpha: 0.90)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.restore();

    // Crisp outer border
    canvas.drawRRect(
      barRRect,
      Paint()
        ..color = AppColors.borderSubtle
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Vertical pill thumb protruding slightly above & below the bar
    final thumbRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(thumbX, top + barHeight / 2),
        width: 4.5,
        height: barHeight + (thumbOverflow * 2),
      ),
      const Radius.circular(99),
    );
    canvas.drawRRect(thumbRect, Paint()..color = AppColors.inkPrimary);
    canvas.drawRRect(
      thumbRect,
      Paint()
        ..color = AppColors.surface
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );
  }

  @override
  bool shouldRepaint(covariant _RulerSliderPainter oldDelegate) =>
      oldDelegate.thumbX != thumbX ||
      oldDelegate.originX != originX ||
      oldDelegate.barHeight != barHeight ||
      oldDelegate.majorStops != majorStops ||
      oldDelegate.wavePhase != wavePhase ||
      oldDelegate.waveDamping != waveDamping ||
      oldDelegate.isIncreasing != isIncreasing;
}

/// Unified glass-bottle painter with smooth continuous liquid fill & wave surface
/// (no abrupt solid/liquid branch switching or blink).
class _MiniBottleSilhouettePainter extends CustomPainter {
  const _MiniBottleSilhouettePainter({
    required this.isSelected,
    required this.fillLevel,
    required this.wavePhase,
    required this.waveAmplitude,
  });

  final bool isSelected;
  final double fillLevel;
  final double wavePhase;
  final double waveAmplitude;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final strokeColor = isSelected
        ? AppColors.inkPrimary
        : (fillLevel > 0.1
            ? AppColors.inkPrimary.withValues(alpha: 0.72)
            : AppColors.inkMuted.withValues(alpha: 0.55));

    // Cap
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, h * 0.14),
          width: w * 0.42,
          height: h * 0.22,
        ),
        const Radius.circular(1.5),
      ),
      Paint()..color = strokeColor,
    );

    // Neck
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(cx, h * 0.28),
        width: w * 0.26,
        height: h * 0.09,
      ),
      Paint()..color = strokeColor.withValues(alpha: isSelected ? 0.80 : 0.45),
    );

    // Glass body shell
    final bodyTop = h * 0.33;
    final bodyHeight = h - bodyTop;
    final bodyRRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(0, bodyTop, w, h),
      const Radius.circular(3),
    );
    canvas.drawRRect(bodyRRect, Paint()..color = AppColors.background);

    // Continuous animated liquid fill with gentle wave surface
    if (fillLevel > 0.005) {
      canvas.save();
      canvas.clipRRect(bodyRRect);

      final liquidY = h - (bodyHeight * fillLevel.clamp(0.0, 1.0));
      final wavePath = Path()..moveTo(0, liquidY);
      const segments = 12;
      for (int i = 0; i <= segments; i++) {
        final fx = i / segments;
        final x = w * fx;
        // Minus wavePhase so mini-bottle surface also ripples left → right
        final y = liquidY +
            math.sin(fx * math.pi * 2.0 - wavePhase) * waveAmplitude;
        wavePath.lineTo(x, y);
      }
      wavePath
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close();

      canvas.drawPath(
        wavePath,
        Paint()
          ..color = isSelected
              ? AppColors.inkPrimary
              : AppColors.inkPrimary.withValues(alpha: 0.68),
      );
      canvas.restore();
    }

    // Crisp bottle border
    canvas.drawRRect(
      bodyRRect,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniBottleSilhouettePainter oldDelegate) =>
      oldDelegate.isSelected != isSelected ||
      oldDelegate.fillLevel != fillLevel ||
      oldDelegate.wavePhase != wavePhase ||
      oldDelegate.waveAmplitude != waveAmplitude;
}
