import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/aromatique_emblem.dart';
import '../../../../core/widgets/bottle_toast.dart';

/// Displays a minimalist, luxury animated member identity card when tapping
/// the home profile avatar. Uses pure GPU-composited transforms (no per-frame
/// backdrop blur re-rasterization) for silky 60/120fps transitions.
Future<void> showMemberProfileDialog(BuildContext context) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Member Profile',
    barrierColor: AppColors.inkPrimary.withValues(alpha: 0.34),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const _MemberProfileDialog();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutQuart,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.93, end: 1.0).animate(curved),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        ),
      );
    },
  );
}

class _MemberProfileDialog extends StatelessWidget {
  const _MemberProfileDialog();

  static const String _memberName = 'Rifky Abdul Hanan';
  static const String _memberId = '21552011052';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 312),
          child: RepaintBoundary(
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.borderSubtle,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.inkPrimary.withValues(alpha: 0.14),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Minimal header row: Atelier mark + Close button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AromatiqueEmblem(size: 18),
                            SizedBox(width: 7),
                            Text(
                              'ATELIER MEMBER',
                              style: TextStyle(
                                fontFamily: AppTheme.contentFont,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.8,
                                color: AppColors.sageIcon,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.borderSubtle,
                                width: 0.8,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              PhosphorIconsRegular.x,
                              size: 14,
                              color: AppColors.inkSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Framed editorial portrait
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.sageHighlight,
                          width: 1.5,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/user_avatar.jpg',
                          width: 76,
                          height: 76,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Member Name
                    const Text(
                      _memberName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTheme.brandFont,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                        color: AppColors.inkPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Subtle hairline divider
                    Container(
                      height: 1,
                      width: 44,
                      color: AppColors.sageHighlight,
                    ),
                    const SizedBox(height: 14),
                    // NIM / ID pill with copy action
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(
                          const ClipboardData(text: _memberId),
                        );
                        showBottleToast(
                          context,
                          message: 'Member ID Copied',
                          subtitle: _memberId,
                        );
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.borderSubtle,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'ID',
                              style: TextStyle(
                                fontFamily: AppTheme.contentFont,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                                color: AppColors.sageIcon,
                              ),
                            ),
                            Container(
                              height: 12,
                              width: 1,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              color: AppColors.borderSubtle,
                            ),
                            const Text(
                              _memberId,
                              style: TextStyle(
                                fontFamily: AppTheme.contentFont,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.4,
                                color: AppColors.inkPrimary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              PhosphorIconsRegular.copy,
                              size: 14,
                              color: AppColors.inkSecondary,
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
