import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

enum CardNetwork { visa, mastercard, amex, unknown }

class SavedCardMock {
  const SavedCardMock({
    required this.network,
    required this.label,
    required this.number,
    required this.holderName,
    required this.expiry,
  });

  final CardNetwork network;
  final String label;
  final String number;
  final String holderName;
  final String expiry;
}

const List<SavedCardMock> mockSavedCards = [
  SavedCardMock(
    network: CardNetwork.visa,
    label: 'Visa •• 6814',
    number: '4532 8910 3472 6814',
    holderName: 'Rifky Abdul Hanan',
    expiry: '08/28',
  ),
  SavedCardMock(
    network: CardNetwork.mastercard,
    label: 'Mastercard •• 9903',
    number: '5425 2334 3010 9903',
    holderName: 'Rifky Abdul Hanan',
    expiry: '11/27',
  ),
];

CardNetwork detectCardNetwork(String rawNumber) {
  final digits = rawNumber.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return CardNetwork.unknown;
  if (digits.startsWith('4')) return CardNetwork.visa;
  if (digits.startsWith('5') || digits.startsWith('2')) {
    return CardNetwork.mastercard;
  }
  if (digits.startsWith('34') || digits.startsWith('37')) {
    return CardNetwork.amex;
  }
  return CardNetwork.unknown;
}

/// Interactive card payment view rendered inside the Cart Bottom Sheet.
class PaymentCardCheckout extends StatefulWidget {
  const PaymentCardCheckout({
    super.key,
    required this.finalTotal,
    required this.onConfirmPay,
  });

  final int finalTotal;
  final VoidCallback onConfirmPay;

  @override
  State<PaymentCardCheckout> createState() => _PaymentCardCheckoutState();
}

class _PaymentCardCheckoutState extends State<PaymentCardCheckout>
    with SingleTickerProviderStateMixin {
  final _numberController = TextEditingController();
  final _nameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  final _numberFocusNode = FocusNode();
  final _cvvFocusNode = FocusNode();
  late final AnimationController _flipController;
  bool _showAutocomplete = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _numberFocusNode.addListener(_onNumberFocusChanged);
    _cvvFocusNode.addListener(_onCvvFocusChanged);
    _numberController.addListener(_refresh);
    _nameController.addListener(_refresh);
    _expiryController.addListener(_refresh);
    _cvvController.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  void _onNumberFocusChanged() {
    setState(() {
      _showAutocomplete = _numberFocusNode.hasFocus;
    });
  }

  void _onCvvFocusChanged() {
    if (_cvvFocusNode.hasFocus) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
  }

  @override
  void dispose() {
    _numberFocusNode.removeListener(_onNumberFocusChanged);
    _numberFocusNode.dispose();
    _cvvFocusNode.removeListener(_onCvvFocusChanged);
    _cvvFocusNode.dispose();
    _flipController.dispose();
    _numberController.dispose();
    _nameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _selectSavedCard(SavedCardMock card) {
    _numberController.text = card.number;
    _nameController.text = card.holderName;
    _expiryController.text = card.expiry;
    _cvvController.clear();
    _showAutocomplete = false;
    _cvvFocusNode.requestFocus();
  }

  List<SavedCardMock> get _filteredSavedCards {
    final digits = _numberController.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return mockSavedCards;
    return mockSavedCards
        .where((c) => c.number.replaceAll(' ', '').startsWith(digits))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final network = detectCardNetwork(_numberController.text);

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 3D Flipping Interactive Card Mockup
          AnimatedBuilder(
            animation: _flipController,
            builder: (context, _) {
              final angle = _flipController.value * math.pi;
              final showBack = angle > (math.pi / 2);
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0012)
                  ..rotateY(angle),
                child: showBack
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(math.pi),
                        child: _CardBackMockup(
                          network: network,
                          cvv: _cvvController.text,
                        ),
                      )
                    : _CardFrontMockup(
                        network: network,
                        cardNumber: _numberController.text,
                        holderName: _nameController.text,
                        expiry: _expiryController.text,
                      ),
              );
            },
          ),
          const SizedBox(height: 14),
          _CardInputField(
            controller: _numberController,
            focusNode: _numberFocusNode,
            label: 'Card Number',
            hint: '4916 5820 1194 3072',
            keyboardType: TextInputType.number,
          ),
          // Autocomplete dropdown directly below Card Number field
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            child: _showAutocomplete && _filteredSavedCards.isNotEmpty
                ? Container(
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderSubtle),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int i = 0; i < _filteredSavedCards.length; i++) ...[
                          if (i > 0)
                            const Divider(
                              height: 1,
                              color: AppColors.borderSubtle,
                            ),
                          InkWell(
                            onTap: () =>
                                _selectSavedCard(_filteredSavedCards[i]),
                            borderRadius: BorderRadius.circular(14),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    _filteredSavedCards[i].network ==
                                            CardNetwork.visa
                                        ? 'assets/images/payments/visa.webp'
                                        : 'assets/images/payments/mastercard.webp',
                                    height: 16,
                                    width: 28,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _filteredSavedCards[i].label,
                                          style: const TextStyle(
                                            fontFamily: AppTheme.contentFont,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.inkPrimary,
                                          ),
                                        ),
                                        Text(
                                          '${_filteredSavedCards[i].holderName} • ${_filteredSavedCards[i].expiry}',
                                          style: const TextStyle(
                                            fontFamily: AppTheme.contentFont,
                                            fontSize: 11,
                                            color: AppColors.inkSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    PhosphorIconsRegular.arrowBendDownLeft,
                                    size: 15,
                                    color: AppColors.inkMuted,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 10),
          _CardInputField(
            controller: _nameController,
            label: 'Cardholder Name',
            hint: 'John Doe',
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _CardInputField(
                  controller: _expiryController,
                  label: 'Exp Date',
                  hint: 'MM/YY',
                  keyboardType: TextInputType.datetime,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CardInputField(
                  controller: _cvvController,
                  focusNode: _cvvFocusNode,
                  label: 'CVV',
                  hint: '•••',
                  keyboardType: TextInputType.number,
                  maxLength: 3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: FilledButton(
              onPressed: widget.onConfirmPay,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.inkPrimary,
                foregroundColor: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(PhosphorIconsRegular.lockSimple, size: 17),
                  const SizedBox(width: 8),
                  Text(
                    'Confirm Pay ${widget.finalTotal}\$',
                    style: const TextStyle(
                      fontFamily: AppTheme.contentFont,
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
    );
  }
}

class _CardInputField extends StatelessWidget {
  const _CardInputField({
    required this.controller,
    required this.label,
    required this.hint,
    this.focusNode,
    this.keyboardType,
    this.maxLength,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: AppTheme.contentFont,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: AppColors.inkSecondary,
            ),
          ),
          const SizedBox(height: 2),
          TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            maxLength: maxLength,
            style: const TextStyle(
              fontFamily: AppTheme.contentFont,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.inkPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontFamily: AppTheme.contentFont,
                fontSize: 13.5,
                color: AppColors.inkMuted,
              ),
              counterText: '',
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

bool _isLightCard(CardNetwork network) => network == CardNetwork.visa;

List<Color> _cardGradient(CardNetwork network) {
  switch (network) {
    case CardNetwork.visa:
      return const [AppColors.cardVisaLightStart, AppColors.cardVisaLightEnd];
    case CardNetwork.mastercard:
      return const [
        AppColors.cardMasterDarkStart,
        AppColors.cardMasterDarkEnd,
      ];
    case CardNetwork.amex:
    case CardNetwork.unknown:
      return const [AppColors.inkPrimary, AppColors.bottleGlassCap];
  }
}

class _CardFrontMockup extends StatelessWidget {
  const _CardFrontMockup({
    required this.network,
    required this.cardNumber,
    required this.holderName,
    required this.expiry,
  });

  final CardNetwork network;
  final String cardNumber;
  final String holderName;
  final String expiry;

  @override
  Widget build(BuildContext context) {
    final isLight = _isLightCard(network);
    final fg = isLight ? AppColors.inkPrimary : AppColors.surface;
    final fgMuted = isLight
        ? AppColors.inkSecondary
        : AppColors.surface.withValues(alpha: 0.68);

    final displayNumber =
        cardNumber.trim().isEmpty ? '••••  ••••  ••••  ••••' : cardNumber;
    final displayName =
        holderName.trim().isEmpty ? 'JOHN DOE' : holderName.toUpperCase();
    final displayExpiry = expiry.trim().isEmpty ? 'MM/YY' : expiry;

    return Container(
      height: 162,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _cardGradient(network),
        ),
        border: isLight ? Border.all(color: AppColors.borderSubtle) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.08 : 0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _CardPatternPainter(network: network),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const _EmvChip(),
                      const SizedBox(width: 10),
                      Icon(
                        PhosphorIconsRegular.wifiHigh,
                        size: 16,
                        color: fgMuted,
                      ),
                      const Spacer(),
                      _NetworkBadge(network: network, isLight: isLight),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    displayNumber,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTheme.contentFont,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.6,
                      color: fg,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CARD HOLDER',
                              style: TextStyle(
                                fontFamily: AppTheme.contentFont,
                                fontSize: 9,
                                letterSpacing: 0.8,
                                color: fgMuted,
                              ),
                            ),
                            Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: AppTheme.contentFont,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: fg,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'EXPIRES',
                            style: TextStyle(
                              fontFamily: AppTheme.contentFont,
                              fontSize: 9,
                              letterSpacing: 0.8,
                              color: fgMuted,
                            ),
                          ),
                          Text(
                            displayExpiry,
                            style: TextStyle(
                              fontFamily: AppTheme.contentFont,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: fg,
                            ),
                          ),
                        ],
                      ),
                    ],
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

class _CardBackMockup extends StatelessWidget {
  const _CardBackMockup({
    required this.network,
    required this.cvv,
  });

  final CardNetwork network;
  final String cvv;

  @override
  Widget build(BuildContext context) {
    final isLight = _isLightCard(network);
    final fgMuted = isLight
        ? AppColors.inkSecondary
        : AppColors.surface.withValues(alpha: 0.72);
    final displayCvv = cvv.trim().isEmpty ? '•••' : cvv;

    return Container(
      height: 162,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _cardGradient(network),
        ),
        border: isLight ? Border.all(color: AppColors.borderSubtle) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.08 : 0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _CardPatternPainter(network: network),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Container(
                  height: 32,
                  width: double.infinity,
                  color: isLight
                      ? AppColors.inkPrimary.withValues(alpha: 0.85)
                      : AppColors.bottleCapDeep,
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.90),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: const Text(
                            'AUTHORIZED SIGNATURE',
                            style: TextStyle(
                              fontFamily: AppTheme.contentFont,
                              fontSize: 9,
                              letterSpacing: 1.0,
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 64,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(6),
                          border: isLight
                              ? Border.all(color: AppColors.borderSubtle)
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          displayCvv,
                          style: const TextStyle(
                            fontFamily: AppTheme.contentFont,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.6,
                            color: AppColors.inkPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CVV SECURITY CODE',
                        style: TextStyle(
                          fontFamily: AppTheme.contentFont,
                          fontSize: 9.5,
                          letterSpacing: 0.7,
                          color: fgMuted,
                        ),
                      ),
                      _NetworkBadge(network: network, isLight: isLight),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// EMV metallic gold chip with realistic contact circuit lines.
class _EmvChip extends StatelessWidget {
  const _EmvChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 25,
      decoration: BoxDecoration(
        color: AppColors.cardChipGold,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: AppColors.cardChipLine.withValues(alpha: 0.6),
          width: 0.8,
        ),
      ),
      child: CustomPaint(
        painter: const _EmvChipPainter(),
      ),
    );
  }
}

class _EmvChipPainter extends CustomPainter {
  const _EmvChipPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = AppColors.cardChipLine.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    // Horizontal contact lines
    canvas.drawLine(Offset(0, h * 0.34), Offset(w * 0.36, h * 0.34), paint);
    canvas.drawLine(Offset(0, h * 0.66), Offset(w * 0.36, h * 0.66), paint);
    canvas.drawLine(Offset(w * 0.64, h * 0.34), Offset(w, h * 0.34), paint);
    canvas.drawLine(Offset(w * 0.64, h * 0.66), Offset(w, h * 0.66), paint);

    // Center contact module
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(w * 0.34, h * 0.22, w * 0.66, h * 0.78),
        const Radius.circular(3),
      ),
      paint,
    );
    canvas.drawLine(Offset(w * 0.50, 0), Offset(w * 0.50, h * 0.22), paint);
    canvas.drawLine(Offset(w * 0.50, h * 0.78), Offset(w * 0.50, h), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Subtle geometric hex grid + connected constellation particle network.
class _CardPatternPainter extends CustomPainter {
  const _CardPatternPainter({required this.network});

  final CardNetwork network;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final isLight = _isLightCard(network);

    final accentColor = network == CardNetwork.visa
        ? AppColors.cardVisaAccent
        : AppColors.cardMasterAccent;

    // 1. Subtle hexagon pattern on the right side
    final hexPaint = Paint()
      ..color = (isLight ? AppColors.cardVisaAccent : AppColors.surface)
          .withValues(alpha: isLight ? 0.08 : 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const hexR = 22.0;
    final centers = [
      Offset(w * 0.78, h * 0.18),
      Offset(w * 0.90, h * 0.36),
      Offset(w * 0.76, h * 0.54),
      Offset(w * 0.90, h * 0.72),
      Offset(w * 0.78, h * 0.90),
    ];
    for (final c in centers) {
      final hex = Path();
      for (int i = 0; i < 6; i++) {
        final angle = (math.pi / 3) * i;
        final pt = Offset(
          c.dx + hexR * math.cos(angle),
          c.dy + hexR * math.sin(angle),
        );
        if (i == 0) {
          hex.moveTo(pt.dx, pt.dy);
        } else {
          hex.lineTo(pt.dx, pt.dy);
        }
      }
      hex.close();
      canvas.drawPath(hex, hexPaint);
    }

    // 2. Connected constellation particle nodes & lines
    final nodes = [
      Offset(w * 0.36, h * 0.24),
      Offset(w * 0.55, h * 0.42),
      Offset(w * 0.64, h * 0.30),
      Offset(w * 0.80, h * 0.38),
      Offset(w * 0.74, h * 0.64),
      Offset(w * 0.46, h * 0.68),
      Offset(w * 0.66, h * 0.88),
      Offset(w * 0.94, h * 0.56),
    ];

    const edges = [
      [0, 1],
      [1, 2],
      [2, 3],
      [1, 4],
      [3, 4],
      [3, 7],
      [4, 6],
      [5, 6],
      [0, 5],
      [1, 5],
    ];

    final linePaint = Paint()
      ..color = accentColor.withValues(alpha: isLight ? 0.16 : 0.28)
      ..strokeWidth = 1.1;
    for (final e in edges) {
      canvas.drawLine(nodes[e[0]], nodes[e[1]], linePaint);
    }

    for (int i = 0; i < nodes.length; i++) {
      final pt = nodes[i];
      if (i == 2 || i == 4) {
        canvas.drawCircle(
          pt,
          12,
          Paint()..color = accentColor.withValues(alpha: isLight ? 0.10 : 0.16),
        );
      }
      canvas.drawCircle(
        pt,
        i.isEven ? 4.0 : 2.8,
        Paint()..color = accentColor.withValues(alpha: isLight ? 0.32 : 0.65),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CardPatternPainter oldDelegate) =>
      oldDelegate.network != network;
}

class _NetworkBadge extends StatelessWidget {
  const _NetworkBadge({
    required this.network,
    required this.isLight,
  });

  final CardNetwork network;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    switch (network) {
      case CardNetwork.visa:
        return Image.asset(
          'assets/images/payments/visa.webp',
          height: 22,
          fit: BoxFit.contain,
        );
      case CardNetwork.mastercard:
        return Image.asset(
          'assets/images/payments/mastercard.webp',
          height: 24,
          fit: BoxFit.contain,
        );
      case CardNetwork.amex:
      case CardNetwork.unknown:
        return Icon(
          PhosphorIconsRegular.creditCard,
          size: 20,
          color: isLight ? AppColors.inkPrimary : AppColors.surface,
        );
    }
  }
}
