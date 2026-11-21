import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/aromatique_emblem.dart';
import '../../../../core/widgets/bottle_toast.dart';
import '../../../../core/widgets/empty_perfume_state.dart';
import '../providers/perfume_providers.dart';
import 'payment_card_checkout.dart';
import 'perfume_bottle_placeholder.dart';

/// Opens the Cart bottom sheet styled as an upright perfume bottle:
/// a centered bottle cap & flared collar at the top wrapping the white rounded body.
Future<void> showCartBottomSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    barrierColor: Colors.black.withValues(alpha: 0.20),
    builder: (context) => const _CartBottleSheet(),
  );
}

class _CartBottleSheet extends ConsumerStatefulWidget {
  const _CartBottleSheet();

  @override
  ConsumerState<_CartBottleSheet> createState() => _CartBottleSheetState();
}

class _CartBottleSheetState extends ConsumerState<_CartBottleSheet> {
  static const double _capTotalHeight = 28.0;
  static const double _rimPadding = 7.0;

  bool _isPaymentStep = false;
  final TextEditingController _promoController = TextEditingController();
  String? _appliedPromoCode;
  String? _promoError;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  int _calculatePromoDiscount(int subtotal) {
    switch (_appliedPromoCode) {
      case 'AROMA10':
        return (subtotal * 0.10).round();
      case 'LUXURY20':
        return (subtotal * 0.20).round();
      case 'SCENT15':
        return subtotal >= 15 ? 15 : subtotal;
      default:
        return 0;
    }
  }

  void _applyPromo() {
    final code = _promoController.text.trim().toUpperCase();
    if (code == 'AROMA10' || code == 'LUXURY20' || code == 'SCENT15') {
      setState(() {
        _appliedPromoCode = code;
        _promoError = null;
      });
    } else {
      setState(() {
        _appliedPromoCode = null;
        _promoError = code.isEmpty ? null : 'Try AROMA10 or LUXURY20';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final subtotal = cartItems.fold<int>(
      0,
      (sum, item) => sum + (item.unitPrice * item.quantity),
    );
    final productSavings = cartItems.fold<int>(0, (sum, item) {
      final orig = item.perfume.originalPrice;
      if (orig == null || orig <= item.perfume.price) return sum;
      final origForSize = (orig * (item.unitPrice / item.perfume.price)).round();
      if (origForSize <= item.unitPrice) return sum;
      return sum + ((origForSize - item.unitPrice) * item.quantity);
    });
    final promoDiscount = _calculatePromoDiscount(subtotal);
    final finalTotal = (subtotal - promoDiscount).clamp(0, subtotal);

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final bottomSafe =
        bottomInset > 0 ? 0.0 : MediaQuery.paddingOf(context).bottom;
    final maxSheetHeight = MediaQuery.sizeOf(context).height * 0.86;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxSheetHeight),
        child: CustomPaint(
          painter: const _UprightBottleCollarPainter(
            capHeight: _capTotalHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              top: _capTotalHeight + _rimPadding,
              left: _rimPadding,
              right: _rimPadding,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(26),
                ),
                border: Border(
                  top: BorderSide(
                    color: AppColors.borderSubtle.withValues(alpha: 0.8),
                    width: 0.8,
                  ),
                  left: BorderSide(
                    color: AppColors.borderSubtle.withValues(alpha: 0.8),
                    width: 0.8,
                  ),
                  right: BorderSide(
                    color: AppColors.borderSubtle.withValues(alpha: 0.8),
                    width: 0.8,
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  14,
                  20,
                  _isPaymentStep ? bottomSafe : (18 + bottomSafe),
                ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Aromantique + Logo (and Back arrow when in Payment step)
                      Row(
                        children: [
                          if (_isPaymentStep) ...[
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _isPaymentStep = false),
                              child: Container(
                                width: 34,
                                height: 34,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  PhosphorIconsRegular.arrowLeft,
                                  size: 18,
                                  color: AppColors.inkPrimary,
                                ),
                              ),
                            ),
                          ],
                          const AromatiqueEmblem(size: 24),
                          const SizedBox(width: 8),
                          const Text(
                            'Aromantique',
                            style: TextStyle(
                              fontFamily: AppTheme.brandFont,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              color: AppColors.inkPrimary,
                            ),
                          ),
                          const Spacer(),
                          if (!_isPaymentStep && cartItems.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                ref.read(cartProvider.notifier).clear();
                                setState(() => _appliedPromoCode = null);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.inkSecondary,
                              ),
                              child: const Text(
                                'Clear',
                                style: TextStyle(
                                  fontFamily: AppTheme.contentFont,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (cartItems.isEmpty)
                        const Center(
                          child: AnimatedEmptyCartState(
                            title: 'Your Bag is Empty',
                            subtitle:
                                'Explore our collection and tap Buy on any fragrance you love.',
                          ),
                        )
                      else
                        Flexible(
                          child: AnimatedSize(
                            duration: const Duration(milliseconds: 340),
                            curve: Curves.easeInOutCubic,
                            alignment: Alignment.topCenter,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 280),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              layoutBuilder: (currentChild, previousChildren) {
                                return Stack(
                                  alignment: Alignment.topCenter,
                                  children: [
                                    ...previousChildren,
                                    ?currentChild,
                                  ],
                                );
                              },
                              child: _isPaymentStep
                                ? PaymentCardCheckout(
                                    key: const ValueKey('payment-step'),
                                    finalTotal: finalTotal,
                                    onConfirmPay: () {
                                      final count = cartItems.length;
                                      Navigator.of(context).pop();
                                      ref.read(cartProvider.notifier).clear();
                                      showBottleToast(
                                        context,
                                        message: 'Payment successful',
                                        subtitle:
                                            '$count fragrance(s) • $finalTotal\$',
                                      );
                                    },
                                  )
                                : Column(
                                    key: const ValueKey('cart-step'),
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        child: ListView.separated(
                                          shrinkWrap: true,
                                          itemCount: cartItems.length,
                                          separatorBuilder: (_, _) =>
                                              const SizedBox(height: 8),
                                          itemBuilder: (context, index) {
                                            final item = cartItems[index];
                                            return _SwipeableCartTile(
                                              key: ValueKey(
                                                'cart-${item.cartKey}',
                                              ),
                                              canSwipeToDelete:
                                                  item.quantity > 1,
                                              onDeleteAll: () => ref
                                                  .read(cartProvider.notifier)
                                                  .removeItem(item.cartKey),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.background,
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  border: Border.all(
                                                    color:
                                                        AppColors.borderSubtle,
                                                    width: 0.8,
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 52,
                                                      height: 62,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              3),
                                                      decoration: BoxDecoration(
                                                        color: item
                                                            .perfume.cardTint,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child:
                                                          PerfumeBottlePlaceholder(
                                                        perfume: item.perfume,
                                                        width: 46,
                                                        height: 56,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            item.perfume.name,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                              fontFamily: AppTheme
                                                                  .contentFont,
                                                              fontSize: 14.5,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color: AppColors
                                                                  .inkPrimary,
                                                            ),
                                                          ),
                                                          Text(
                                                            'by ${item.perfume.brand} • ${item.selectedSizeMl} ml',
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                              fontFamily: AppTheme
                                                                  .contentFont,
                                                              fontSize: 12,
                                                              color: AppColors
                                                                  .inkSecondary,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 4),
                                                          Text(
                                                            '${item.unitPrice * item.quantity}\$',
                                                            style:
                                                                const TextStyle(
                                                              fontFamily: AppTheme
                                                                  .contentFont,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 14,
                                                              color: AppColors
                                                                  .inkPrimary,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    // Quantity stepper (- / trash when 1, count, +)
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 4,
                                                        vertical: 4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            AppColors.surface,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        border: Border.all(
                                                          color: AppColors
                                                              .borderSubtle,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () => ref
                                                                .read(cartProvider
                                                                    .notifier)
                                                                .decrementItem(
                                                                    item.cartKey),
                                                            behavior:
                                                                HitTestBehavior
                                                                    .opaque,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(5),
                                                              child: Icon(
                                                                item.quantity <=
                                                                        1
                                                                    ? PhosphorIconsRegular
                                                                        .trash
                                                                    : PhosphorIconsRegular
                                                                        .minus,
                                                                size: 15,
                                                                color: item.quantity <=
                                                                        1
                                                                    ? AppColors
                                                                        .notificationDot
                                                                    : AppColors
                                                                        .inkPrimary,
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        6),
                                                            child: Text(
                                                              '${item.quantity}',
                                                              style:
                                                                  const TextStyle(
                                                                fontFamily: AppTheme
                                                                    .contentFont,
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: AppColors
                                                                    .inkPrimary,
                                                              ),
                                                            ),
                                                          ),
                                                          GestureDetector(
                                                            onTap: () => ref
                                                                .read(cartProvider
                                                                    .notifier)
                                                                .incrementItem(
                                                                    item.cartKey),
                                                            behavior:
                                                                HitTestBehavior
                                                                    .opaque,
                                                            child:
                                                                const Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(5),
                                                              child: Icon(
                                                                PhosphorIconsRegular
                                                                    .plus,
                                                                size: 15,
                                                                color: AppColors
                                                                    .inkPrimary,
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
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      // Bottle-styled Promo Code Input
                                      _BottlePromoTextField(
                                        controller: _promoController,
                                        appliedCode: _appliedPromoCode,
                                        errorText: _promoError,
                                        onApply: _applyPromo,
                                      ),
                                      if (productSavings > 0 ||
                                          promoDiscount > 0) ...[
                                        const SizedBox(height: 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.cardMint,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: AppColors.borderSubtle,
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              if (productSavings > 0)
                                                _SummaryRow(
                                                  label: 'Promotion Savings',
                                                  value: '-$productSavings\$',
                                                  isHighlight: true,
                                                ),
                                              if (promoDiscount > 0)
                                                _SummaryRow(
                                                  label:
                                                      'Promo ($_appliedPromoCode)',
                                                  value: '-$promoDiscount\$',
                                                  isHighlight: true,
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 10),
                                      const Divider(
                                          color: AppColors.borderSubtle),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Total',
                                            style: TextStyle(
                                              fontFamily: AppTheme.contentFont,
                                              fontSize: 15,
                                              color: AppColors.inkSecondary,
                                            ),
                                          ),
                                          Text(
                                            '$finalTotal\$',
                                            style: const TextStyle(
                                              fontFamily: AppTheme.contentFont,
                                              fontSize: 19,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.inkPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 44,
                                        child: FilledButton(
                                          onPressed: () => setState(
                                              () => _isPaymentStep = true),
                                          style: FilledButton.styleFrom(
                                            backgroundColor:
                                                AppColors.inkPrimary,
                                            foregroundColor: AppColors.surface,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                PhosphorIconsRegular.creditCard,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Pay $finalTotal\$',
                                                style: const TextStyle(
                                                  fontFamily:
                                                      AppTheme.contentFont,
                                                  fontSize: 14.5,
                                                  fontWeight: FontWeight.w600,
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

/// Bottle-styled promo code input matching the BottleToast silhouette.
class _BottlePromoTextField extends StatelessWidget {
  const _BottlePromoTextField({
    required this.controller,
    required this.appliedCode,
    required this.errorText,
    required this.onApply,
  });

  final TextEditingController controller;
  final String? appliedCode;
  final String? errorText;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Sideways bottle cap
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: const BoxDecoration(
                color: AppColors.inkPrimary,
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(12),
                  right: Radius.circular(4),
                ),
              ),
              alignment: Alignment.center,
              child: const Icon(
                PhosphorIconsRegular.tag,
                size: 17,
                color: AppColors.surface,
              ),
            ),
            // Bottle neck collar
            Container(
              width: 5,
              height: 26,
              color: AppColors.notchCollar,
            ),
            // Bottle body input container
            Expanded(
              child: Container(
                height: 44,
                padding: const EdgeInsets.only(left: 12, right: 6),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: appliedCode != null
                        ? AppColors.sageIcon
                        : AppColors.borderSubtle,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        textCapitalization: TextCapitalization.characters,
                        style: const TextStyle(
                          fontFamily: AppTheme.contentFont,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.inkPrimary,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Promo code (AROMA10)',
                          hintStyle: TextStyle(
                            fontFamily: AppTheme.contentFont,
                            fontSize: 12.5,
                            color: AppColors.inkMuted,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: onApply,
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.sageHighlight,
                        foregroundColor: AppColors.inkPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      child: Text(
                        appliedCode != null ? 'Applied' : 'Apply',
                        style: const TextStyle(
                          fontFamily: AppTheme.contentFont,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 48, top: 4),
            child: Text(
              errorText!,
              style: const TextStyle(
                fontFamily: AppTheme.contentFont,
                fontSize: 11,
                color: AppColors.notificationDot,
              ),
            ),
          ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  final String label;
  final String value;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: AppTheme.contentFont,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.inkSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppTheme.contentFont,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: isHighlight ? AppColors.sageIcon : AppColors.inkPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _UprightBottleCollarPainter extends CustomPainter {
  const _UprightBottleCollarPainter({required this.capHeight});

  final double capHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    const capWidth = 96.0;
    const shoulderY = 28.0;
    const bodyR = 30.0;
    const capR = 12.0;

    final leftCapX = cx - (capWidth / 2);
    final rightCapX = cx + (capWidth / 2);

    // Unified upright perfume-bottle collar: centered cap -> flared neck -> rounded body
    final path = Path()
      ..moveTo(0, h)
      ..lineTo(0, shoulderY + bodyR)
      ..quadraticBezierTo(0, shoulderY, bodyR, shoulderY)
      ..lineTo(leftCapX - 18, shoulderY)
      ..quadraticBezierTo(leftCapX, shoulderY, leftCapX, shoulderY - 12)
      ..lineTo(leftCapX, capR)
      ..quadraticBezierTo(leftCapX, 0, leftCapX + capR, 0)
      ..lineTo(rightCapX - capR, 0)
      ..quadraticBezierTo(rightCapX, 0, rightCapX, capR)
      ..lineTo(rightCapX, shoulderY - 12)
      ..quadraticBezierTo(rightCapX, shoulderY, rightCapX + 18, shoulderY)
      ..lineTo(w - bodyR, shoulderY)
      ..quadraticBezierTo(w, shoulderY, w, shoulderY + bodyR)
      ..lineTo(w, h)
      ..close();

    canvas.drawShadow(
      path,
      Colors.black.withValues(alpha: 0.10),
      14,
      false,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.notchCollar
        ..style = PaintingStyle.fill,
    );

    final topContour = Path()
      ..moveTo(0, shoulderY + bodyR)
      ..quadraticBezierTo(0, shoulderY, bodyR, shoulderY)
      ..lineTo(leftCapX - 18, shoulderY)
      ..quadraticBezierTo(leftCapX, shoulderY, leftCapX, shoulderY - 12)
      ..lineTo(leftCapX, capR)
      ..quadraticBezierTo(leftCapX, 0, leftCapX + capR, 0)
      ..lineTo(rightCapX - capR, 0)
      ..quadraticBezierTo(rightCapX, 0, rightCapX, capR)
      ..lineTo(rightCapX, shoulderY - 12)
      ..quadraticBezierTo(rightCapX, shoulderY, rightCapX + 18, shoulderY)
      ..lineTo(w - bodyR, shoulderY)
      ..quadraticBezierTo(w, shoulderY, w, shoulderY + bodyR);

    canvas.drawPath(
      topContour,
      Paint()
        ..color = AppColors.borderSubtle
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );

    // Subtle handle pill inside the bottle cap
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, capHeight * 0.5),
          width: 38,
          height: 4,
        ),
        const Radius.circular(99),
      ),
      Paint()..color = AppColors.inkMuted.withValues(alpha: 0.55),
    );
  }

  @override
  bool shouldRepaint(covariant _UprightBottleCollarPainter oldDelegate) =>
      oldDelegate.capHeight != capHeight;
}

/// Custom swipe-to-delete wrapper clipped to the tile's rounded corners so
/// the red delete backdrop sits cleanly underneath without corner seams.
class _SwipeableCartTile extends StatefulWidget {
  const _SwipeableCartTile({
    super.key,
    required this.canSwipeToDelete,
    required this.onDeleteAll,
    required this.child,
  });

  final bool canSwipeToDelete;
  final VoidCallback onDeleteAll;
  final Widget child;

  @override
  State<_SwipeableCartTile> createState() => _SwipeableCartTileState();
}

class _SwipeableCartTileState extends State<_SwipeableCartTile>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0.0;
  late final AnimationController _snapController;
  double _animStart = 0.0;
  double _animEnd = 0.0;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() {
        setState(() {
          _dragOffset = _animStart +
              (_animEnd - _animStart) *
                  Curves.easeOutCubic.transform(_snapController.value);
        });
      });
  }

  @override
  void didUpdateWidget(covariant _SwipeableCartTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.canSwipeToDelete && _dragOffset != 0) {
      _dragOffset = 0;
    }
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  void _animateTo(double target, {VoidCallback? onComplete}) {
    _animStart = _dragOffset;
    _animEnd = target;
    _snapController.forward(from: 0).whenComplete(() {
      if (mounted && onComplete != null) onComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.canSwipeToDelete) return widget.child;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: AppColors.notificationDot.withValues(alpha: 0.14),
              child: const Icon(
                PhosphorIconsRegular.trash,
                size: 20,
                color: AppColors.notificationDot,
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: (details) {
              _snapController.stop();
              setState(() {
                _dragOffset = (_dragOffset + details.delta.dx).clamp(-220.0, 0.0);
              });
            },
            onHorizontalDragEnd: (details) {
              final velocity = details.velocity.pixelsPerSecond.dx;
              if (_dragOffset <= -58 || velocity <= -320) {
                final width = context.size?.width ?? 340;
                _animateTo(-width, onComplete: widget.onDeleteAll);
              } else {
                _animateTo(0);
              }
            },
            child: Transform.translate(
              offset: Offset(_dragOffset, 0),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}
