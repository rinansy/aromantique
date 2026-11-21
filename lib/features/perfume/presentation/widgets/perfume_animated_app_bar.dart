import 'dart:math' as math;
import 'dart:ui' show lerpDouble;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/aromatique_emblem.dart';
import '../../../../core/widgets/custom_shaped_app_bar.dart';
import '../providers/perfume_providers.dart';
import 'member_profile_dialog.dart';
import 'notifications_dialog.dart';

/// Shared AppBar across Page 1 and Page 2 that smoothly animates ("Hero"-style)
/// the "Aromantique" brand title from the left (Page 1) to the center (Page 2)
/// while cross-fading the left and right action slots.
class PerfumeAnimatedAppBar extends ConsumerStatefulWidget {
  const PerfumeAnimatedAppBar({
    super.key,
    required this.progress,
    required this.onBackTap,
  });

  /// 0.0 = Editorial Home (Page 1), 1.0 = Catalog (Page 2).
  final double progress;
  final VoidCallback onBackTap;

  @override
  ConsumerState<PerfumeAnimatedAppBar> createState() =>
      _PerfumeAnimatedAppBarState();
}

class _PerfumeAnimatedAppBarState extends ConsumerState<PerfumeAnimatedAppBar>
    with TickerProviderStateMixin {
  final GlobalKey _rightEmblemKey = GlobalKey();
  final List<AnimationController> _sprayControllers = [];
  late final AnimationController _squeezeController;

  @override
  void initState() {
    super.initState();
    _squeezeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
  }

  @override
  void dispose() {
    for (final c in _sprayControllers) {
      c.dispose();
    }
    _squeezeController.dispose();
    super.dispose();
  }

  void _triggerSprayMist() {
    _squeezeController.forward(from: 0);

    final box =
        _rightEmblemKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final nozzle = box.localToGlobal(
      Offset(box.size.width * 0.22, box.size.height * 0.16),
    );
    final overlay = Overlay.of(context, rootOverlay: true);

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 680),
    );
    _sprayControllers.add(controller);

    final rng = math.Random();
    final particles = List.generate(34, (i) {
      // Fine mist cone aimed closer to the top-right edge/corner
      final angle = math.pi * 0.76 + (rng.nextDouble() - 0.5) * 0.70;
      final speed = 26.0 + rng.nextDouble() * 58.0;
      final radius = 0.8 + rng.nextDouble() * 1.6;
      final color = i % 3 == 0
          ? AppColors.notchSearchAccent
          : (i % 3 == 1 ? AppColors.sageIcon : AppColors.badgeGoldFg);
      return _SprayParticle(
        angle: angle,
        distance: speed,
        baseRadius: radius,
        color: color,
        isSparkle: i % 5 == 0,
      );
    });

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return IgnorePointer(
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              return CustomPaint(
                size: MediaQuery.sizeOf(context),
                painter: _SprayMistPainter(
                  origin: nozzle,
                  progress: Curves.easeOutCubic.transform(controller.value),
                  fadeProgress: controller.value,
                  particles: particles,
                ),
              );
            },
          ),
        );
      },
    );

    overlay.insert(entry);
    controller.forward().whenComplete(() {
      if (entry.mounted) entry.remove();
      _sprayControllers.remove(controller);
      controller.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasUnreadNotifs = ref.watch(unreadNotificationsCountProvider) > 0;
    final t = widget.progress.clamp(0.0, 1.0);
    final leftPadding = lerpDouble(36.0, 0.0, t)!;
    final titleAlignment = Alignment.lerp(
      Alignment.centerLeft,
      Alignment.center,
      t,
    )!;
    final fontSize = lerpDouble(22.0, 20.0, t)!;

    return CustomShapedAppBar(
      child: SizedBox(
        height: 42,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Left slot: Emblem on Page 1 -> Back button on Page 2
            Align(
              alignment: Alignment.centerLeft,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  IgnorePointer(
                    ignoring: t > 0.5,
                    child: Opacity(
                      opacity: (1.0 - t * 1.4).clamp(0.0, 1.0),
                      child: const Hero(
                        tag: 'aromatique-emblem',
                        child: AromatiqueEmblem(size: 28),
                      ),
                    ),
                  ),
                  IgnorePointer(
                    ignoring: t <= 0.5,
                    child: Opacity(
                      opacity: ((t - 0.3) / 0.7).clamp(0.0, 1.0),
                      child: GestureDetector(
                        onTap: widget.onBackTap,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            PhosphorIconsRegular.arrowLeft,
                            size: 20,
                            color: AppColors.inkSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Gliding brand title: left-aligned next to emblem -> centered on Page 2
            Align(
              alignment: titleAlignment,
              child: Padding(
                padding: EdgeInsets.only(left: leftPadding),
                child: Hero(
                  tag: 'aromatique-title',
                  child: Material(
                    type: MaterialType.transparency,
                    child: Text(
                      'Aromantique',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTheme.brandFont,
                        fontSize: fontSize,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                        color: AppColors.inkPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Right slot: Avatar + Bell on Page 1 -> Interactive Spray Emblem on Page 2
            Align(
              alignment: Alignment.centerRight,
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  IgnorePointer(
                    ignoring: t > 0.5,
                    child: Opacity(
                      opacity: (1.0 - t * 1.4).clamp(0.0, 1.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => showMemberProfileDialog(context),
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.borderSubtle,
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: Image.asset(
                                  'assets/images/user_avatar.jpg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => showNotificationsDialog(context),
                            behavior: HitTestBehavior.opaque,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.borderSubtle,
                                      width: 1,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    PhosphorIconsFill.bell,
                                    size: 19,
                                    color: hasUnreadNotifs
                                        ? AppColors.inkPrimary
                                        : AppColors.inkMuted,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 9,
                                  child: AnimatedScale(
                                    duration: const Duration(milliseconds: 220),
                                    curve: Curves.easeOutBack,
                                    scale: hasUnreadNotifs ? 1.0 : 0.0,
                                    child: Container(
                                      width: 7,
                                      height: 7,
                                      decoration: const BoxDecoration(
                                        color: AppColors.notificationDot,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IgnorePointer(
                    ignoring: t <= 0.5,
                    child: Opacity(
                      opacity: ((t - 0.3) / 0.7).clamp(0.0, 1.0),
                      child: GestureDetector(
                        onTap: _triggerSprayMist,
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedBuilder(
                          animation: _squeezeController,
                          builder: (context, child) {
                            final s = _squeezeController.value;
                            final scale =
                                1.0 - math.sin(s * math.pi) * 0.16;
                            return Transform.scale(scale: scale, child: child);
                          },
                          child: Padding(
                            key: _rightEmblemKey,
                            padding: const EdgeInsets.all(4),
                            child: const AromatiqueEmblem(size: 30),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SprayParticle {
  const _SprayParticle({
    required this.angle,
    required this.distance,
    required this.baseRadius,
    required this.color,
    required this.isSparkle,
  });

  final double angle;
  final double distance;
  final double baseRadius;
  final Color color;
  final bool isSparkle;
}

class _SprayMistPainter extends CustomPainter {
  const _SprayMistPainter({
    required this.origin,
    required this.progress,
    required this.fadeProgress,
    required this.particles,
  });

  final Offset origin;
  final double progress;
  final double fadeProgress;
  final List<_SprayParticle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    final alpha = (1.0 - fadeProgress).clamp(0.0, 1.0);
    if (alpha <= 0) return;

    // Soft fine mist puff cloud near the nozzle
    canvas.drawCircle(
      origin + Offset(-10 * progress, 6 * progress),
      5 + 14 * progress,
      Paint()
        ..color = AppColors.sageHighlight.withValues(alpha: alpha * 0.34)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
    );

    for (final p in particles) {
      final dx = math.cos(p.angle) * p.distance * progress;
      final dy = math.sin(p.angle) * p.distance * progress +
          (8 * fadeProgress * fadeProgress);
      final pos = origin + Offset(dx, dy);
      final r = p.baseRadius * (0.7 + 0.4 * progress);

      final paint = Paint()
        ..color = p.color.withValues(alpha: alpha * 0.72)
        ..style = PaintingStyle.fill;

      if (p.isSparkle) {
        final star = Path()
          ..moveTo(pos.dx, pos.dy - r * 1.6)
          ..lineTo(pos.dx + r * 0.5, pos.dy - r * 0.5)
          ..lineTo(pos.dx + r * 1.6, pos.dy)
          ..lineTo(pos.dx + r * 0.5, pos.dy + r * 0.5)
          ..lineTo(pos.dx, pos.dy + r * 1.6)
          ..lineTo(pos.dx - r * 0.5, pos.dy + r * 0.5)
          ..lineTo(pos.dx - r * 1.6, pos.dy)
          ..lineTo(pos.dx - r * 0.5, pos.dy - r * 0.5)
          ..close();
        canvas.drawPath(star, paint);
      } else {
        canvas.drawCircle(pos, r, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SprayMistPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.fadeProgress != fadeProgress;
}
