import 'package:material_ui/material_ui.dart';

enum PerfumeGender {
  men('Men'),
  women('Women'),
  unisex('Unisex');

  const PerfumeGender(this.label);
  final String label;
}

class Perfume {
  const Perfume({
    required this.id,
    required this.name,
    required this.brand,
    required this.subtitle,
    required this.price,
    required this.volumeMl,
    required this.cardTint,
    required this.bottlePrimary,
    required this.bottleSecondary,
    this.gender = PerfumeGender.unisex,
    this.availableSizesMl = const [100],
    this.description = '',
    this.notes = const [],
    this.badge,
    this.originalPrice,
    this.isFeatured = false,
    this.isOutOfStock = false,
    this.heroImageAsset,
    this.bottleImageAsset,
  });

  final String id;
  final String name;
  final String brand;
  final String subtitle;
  final int price;
  final int volumeMl;
  final Color cardTint;
  final Color bottlePrimary;
  final Color bottleSecondary;
  final PerfumeGender gender;
  final List<int> availableSizesMl;
  final String description;
  final List<String> notes;
  final String? badge;
  final int? originalPrice;
  final bool isFeatured;
  final bool isOutOfStock;
  final String? heroImageAsset;
  final String? bottleImageAsset;

  /// Computes unit price for a selected bottle size (100..500 ml).
  int priceForSize(int sizeMl) {
    final ratio = sizeMl / volumeMl;
    // Slight volume discount curve so larger bottles feel realistic
    final factor = 0.65 + (0.35 * ratio);
    return (price * factor).round().clamp(35, 999);
  }
}

class CartItem {
  const CartItem({
    required this.perfume,
    required this.selectedSizeMl,
    required this.unitPrice,
    required this.quantity,
  });

  final Perfume perfume;
  final int selectedSizeMl;
  final int unitPrice;
  final int quantity;

  String get cartKey => '${perfume.id}_$selectedSizeMl';

  CartItem copyWith({int? quantity}) {
    return CartItem(
      perfume: perfume,
      selectedSizeMl: selectedSizeMl,
      unitPrice: unitPrice,
      quantity: quantity ?? this.quantity,
    );
  }
}
