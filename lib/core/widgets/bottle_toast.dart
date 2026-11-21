import 'dart:async';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'aromatique_emblem.dart';
import 'custom_shaped_app_bar.dart';

/// Displays a left-anchored, bottle-themed toast notification below the AppBar
/// that expands smoothly outward from the left edge toward the center.
void showBottleToast(
  BuildContext context, {
  required String message,
  String? subtitle,
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _BottleToastOverlay(
      message: message,
      subtitle: subtitle,
      onDismissed: () {
        if (entry.mounted) {
          entry.remove();
        }
      },
    ),
  );
  overlay.insert(entry);
}

class _BottleToastOverlay extends StatefulWidget {
  const _BottleToastOverlay({
    required this.message,
    required this.onDismissed,
    this.subtitle,
  });

  final String message;
  final String? subtitle;
  final VoidCallback onDismissed;

  @override
  State<_BottleToastOverlay> createState() => _BottleToastOverlayState();
}

class _BottleToastOverlayState extends State<_BottleToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandFactor;
  late final Animation<double> _fade;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _expandFactor = curved;
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
    );

    _controller.forward();
    _dismissTimer = Timer(const Duration(milliseconds: 2200), () async {
      if (!mounted) return;
      await _controller.reverse();
      if (mounted) widget.onDismissed();
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBarBottom = CustomShapedAppBar.totalHeight(context);

    return Positioned(
      top: appBarBottom + 10,
      left: 28,
      right: 0,
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.centerRight,
          child: FadeTransition(
            opacity: _fade,
            child: SizeTransition(
              sizeFactor: _expandFactor,
              axis: Axis.horizontal,
              alignment: Alignment.centerRight,
              child: Material(
                color: Colors.transparent,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Leading bottle cap at the left tip as it expands right-to-left
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.inkPrimary,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(14),
                          right: Radius.circular(4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 14,
                            offset: const Offset(-2, 6),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const AromatiqueEmblem(
                        size: 20,
                        color: AppColors.surface,
                      ),
                    ),
                    // Bottle collar neck connector
                    Container(
                      width: 6,
                      height: 30,
                      color: AppColors.notchCollar,
                    ),
                    // Right-anchored bottle body toast card
                    Flexible(
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 48),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(16),
                          ),
                          border: Border.all(color: AppColors.borderSubtle),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.10),
                              blurRadius: 18,
                              offset: const Offset(-2, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.message,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: AppTheme.contentFont,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.inkPrimary,
                                    ),
                                  ),
                                  if (widget.subtitle != null)
                                    Text(
                                      widget.subtitle!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: AppTheme.contentFont,
                                        fontSize: 11.5,
                                        color: AppColors.inkSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              PhosphorIconsFill.checkCircle,
                              size: 17,
                              color: AppColors.sageIcon,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
