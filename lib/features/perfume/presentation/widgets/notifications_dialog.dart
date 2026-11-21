import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/aromatique_emblem.dart';
import '../../../../core/widgets/bottle_toast.dart';
import '../../../../core/widgets/custom_shaped_app_bar.dart';
import '../providers/perfume_providers.dart';

/// Displays a minimalist, luxury scrollable notifications panel anchored below
/// the custom AppBar. Uses pure GPU-composited transforms (no per-frame blur)
/// for locked 60/120fps opening and scrolling.
Future<void> showNotificationsDialog(BuildContext context) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Notifications',
    barrierColor: AppColors.inkPrimary.withValues(alpha: 0.30),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const _NotificationsDialog();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutQuart,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.03),
            end: Offset.zero,
          ).animate(curved),
          child: ScaleTransition(
            alignment: Alignment.topRight,
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(curved),
            child: child,
          ),
        ),
      );
    },
  );
}

class _NotificationsDialog extends ConsumerWidget {
  const _NotificationsDialog();

  IconData _iconFor(NotificationKind kind) => switch (kind) {
        NotificationKind.offer => PhosphorIconsRegular.sparkle,
        NotificationKind.arrival => PhosphorIconsRegular.drop,
        NotificationKind.promo => PhosphorIconsRegular.ticket,
        NotificationKind.restock => PhosphorIconsRegular.clock,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final topOffset = CustomShapedAppBar.totalHeight(context) + 8;
    final maxPanelHeight =
        (MediaQuery.sizeOf(context).height - topOffset - 40).clamp(240.0, 480.0);

    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.fromLTRB(18, topOffset, 18, 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 380,
            maxHeight: maxPanelHeight,
          ),
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
                      color: AppColors.inkPrimary.withValues(alpha: 0.13),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      children: [
                        const AromatiqueEmblem(size: 17),
                        const SizedBox(width: 7),
                        const Expanded(
                          child: Text(
                            'NOTIFICATIONS',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppTheme.contentFont,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.7,
                              color: AppColors.sageIcon,
                            ),
                          ),
                        ),
                        if (unreadCount > 0)
                          GestureDetector(
                            onTap: () => ref
                                .read(notificationsProvider.notifier)
                                .markAllRead(),
                            behavior: HitTestBehavior.opaque,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Text(
                                'Mark all read',
                                style: TextStyle(
                                  fontFamily: AppTheme.contentFont,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.inkPrimary,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 28,
                            height: 28,
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
                              size: 13,
                              color: AppColors.inkSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: AppColors.borderSubtle),
                    const SizedBox(height: 10),
                    // Scrollable notification list
                    Flexible(
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(
                          overscroll: false,
                        ),
                        child: ListView.separated(
                          padding: const EdgeInsets.only(bottom: 4),
                          physics: const ClampingScrollPhysics(),
                          itemCount: notifications.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, i) {
                            final item = notifications[i];
                            return GestureDetector(
                              onTap: () {
                                ref
                                    .read(notificationsProvider.notifier)
                                    .markRead(item.id);
                                if (item.promoCode != null) {
                                  Clipboard.setData(
                                    ClipboardData(text: item.promoCode!),
                                  );
                                  showBottleToast(
                                    context,
                                    message: 'Promo Code Copied',
                                    subtitle:
                                        'Use ${item.promoCode} at checkout',
                                  );
                                }
                              },
                              behavior: HitTestBehavior.opaque,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: item.isRead
                                      ? AppColors.surface
                                      : AppColors.background,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: item.isRead
                                        ? AppColors.borderSubtle
                                            .withValues(alpha: 0.65)
                                        : AppColors.sageHighlight,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: item.isRead
                                            ? AppColors.surfaceMuted
                                            : AppColors.sageHighlight
                                                .withValues(alpha: 0.65),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      alignment: Alignment.center,
                                      child: Icon(
                                        _iconFor(item.kind),
                                        size: 16,
                                        color: item.isRead
                                            ? AppColors.inkSecondary
                                            : AppColors.inkPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 11),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item.title,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontFamily:
                                                        AppTheme.contentFont,
                                                    fontSize: 13,
                                                    fontWeight: item.isRead
                                                        ? FontWeight.w600
                                                        : FontWeight.w700,
                                                    color: AppColors.inkPrimary,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                item.timeAgo,
                                                style: const TextStyle(
                                                  fontFamily:
                                                      AppTheme.contentFont,
                                                  fontSize: 10.5,
                                                  color: AppColors.inkMuted,
                                                ),
                                              ),
                                              if (!item.isRead) ...[
                                                const SizedBox(width: 6),
                                                Container(
                                                  width: 6,
                                                  height: 6,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: AppColors
                                                        .notificationDot,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            item.body,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontFamily: AppTheme.contentFont,
                                              fontSize: 11.5,
                                              height: 1.35,
                                              color: AppColors.inkSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
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
