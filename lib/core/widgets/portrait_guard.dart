import 'dart:ui' show DisplayFeatureType;
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'aromatique_emblem.dart';

/// Guards the app for Portrait phone experience:
/// - Shows a rotate-to-portrait prompt when in landscape.
/// - Shows a distinct foldable/wide-screen alert when unfolded or on a hinge.
class PortraitGuard extends StatefulWidget {
  const PortraitGuard({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<PortraitGuard> createState() => _PortraitGuardState();
}

class _PortraitGuardState extends State<PortraitGuard> {
  bool _dismissedFoldAlert = false;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;
    final hasFoldFeature = media.displayFeatures.any(
      (f) =>
          f.type == DisplayFeatureType.hinge ||
          f.type == DisplayFeatureType.fold,
    );
    final isUnfoldedOrWide = hasFoldFeature || size.shortestSide >= 600;
    final isLandscape = size.width > size.height;

    if (isUnfoldedOrWide && !_dismissedFoldAlert) {
      return _GuardOverlay(
        icon: PhosphorIconsRegular.devices,
        title: 'Foldable Display Detected',
        message:
            'Aromantique is crafted for a single-hand portrait experience. Please fold your device for the best look.',
        actionLabel: 'Continue anyway',
        onAction: () => setState(() => _dismissedFoldAlert = true),
      );
    }

    if (isLandscape && !isUnfoldedOrWide) {
      return const _GuardOverlay(
        icon: PhosphorIconsRegular.deviceRotate,
        title: 'Portrait Mode Recommended',
        message:
            'For a better experience, please rotate your device back to portrait mode.',
      );
    }

    return widget.child;
  }
}

class _GuardOverlay extends StatelessWidget {
  const _GuardOverlay({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 22,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.borderSubtle),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AromatiqueEmblem(size: 32),
                    const SizedBox(height: 14),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: AppColors.sageHighlight,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        icon,
                        size: 28,
                        color: AppColors.inkPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: AppTheme.brandFont,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: AppTheme.contentFont,
                        fontSize: 14,
                        height: 1.4,
                        color: AppColors.inkSecondary,
                      ),
                    ),
                    if (actionLabel != null && onAction != null) ...[
                      const SizedBox(height: 18),
                      TextButton(
                        onPressed: onAction,
                        child: Text(
                          actionLabel!,
                          style: const TextStyle(
                            fontFamily: AppTheme.contentFont,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.inkPrimary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
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
