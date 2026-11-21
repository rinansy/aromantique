import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import '../../data/perfume_mock_data.dart';
import '../../domain/perfume.dart';

/// Tracks active vertical page: 0 = Editorial Home (Page 1), 1 = Catalog (Page 2).
class ShellPageIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setPage(int index) {
    state = index.clamp(0, 1);
  }
}

final shellPageIndexProvider =
    NotifierProvider<ShellPageIndexNotifier, int>(ShellPageIndexNotifier.new);

/// Tracks active carousel index on Page 1.
class HeroCarouselIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) => state = index;
}

final heroCarouselIndexProvider =
    NotifierProvider<HeroCarouselIndexNotifier, int>(
  HeroCarouselIndexNotifier.new,
);

/// Tracks active navigation item on Page 1 left rail & Page 2 floating nav.
enum PerfumeNavTab { home, search, favorite, cart }

class ActiveNavTabNotifier extends Notifier<PerfumeNavTab> {
  @override
  PerfumeNavTab build() => PerfumeNavTab.home;

  void select(PerfumeNavTab tab) => state = tab;
}

final activeNavTabProvider =
    NotifierProvider<ActiveNavTabNotifier, PerfumeNavTab>(
  ActiveNavTabNotifier.new,
);

/// Search query on Page 2.
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
}

final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

/// Toggle favorites-only filter on Page 2.
class FavoritesFilterNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void set(bool value) => state = value;
}

final favoritesFilterProvider =
    NotifierProvider<FavoritesFilterNotifier, bool>(
  FavoritesFilterNotifier.new,
);

/// Selected brand filters (empty = all brands).
class SelectedBrandsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void toggleBrand(String brand) {
    if (state.contains(brand)) {
      state = {...state}..remove(brand);
    } else {
      state = {...state, brand};
    }
  }

  void setBrands(Set<String> brands) => state = brands;
  void clear() => state = {};
}

final selectedBrandsProvider =
    NotifierProvider<SelectedBrandsNotifier, Set<String>>(
  SelectedBrandsNotifier.new,
);

/// Selected gender filters (empty = all genders).
class SelectedGendersNotifier extends Notifier<Set<PerfumeGender>> {
  @override
  Set<PerfumeGender> build() => {};

  void toggleGender(PerfumeGender gender) {
    if (state.contains(gender)) {
      state = {...state}..remove(gender);
    } else {
      state = {...state, gender};
    }
  }

  void clear() => state = {};
}

final selectedGendersProvider =
    NotifierProvider<SelectedGendersNotifier, Set<PerfumeGender>>(
  SelectedGendersNotifier.new,
);

/// Min/Max price filter range.
const double kMinPerfumePrice = 50;
const double kMaxPerfumePrice = 400;

class PriceRangeNotifier extends Notifier<RangeValues> {
  @override
  RangeValues build() => const RangeValues(kMinPerfumePrice, kMaxPerfumePrice);

  void update(RangeValues values) => state = values;
  void reset() => state = const RangeValues(kMinPerfumePrice, kMaxPerfumePrice);
}

final priceRangeProvider =
    NotifierProvider<PriceRangeNotifier, RangeValues>(PriceRangeNotifier.new);

/// Whether any catalog drawer filter is currently active.
final hasActiveFiltersProvider = Provider<bool>((ref) {
  final brands = ref.watch(selectedBrandsProvider);
  final genders = ref.watch(selectedGendersProvider);
  final priceRange = ref.watch(priceRangeProvider);
  return brands.isNotEmpty ||
      genders.isNotEmpty ||
      priceRange.start > kMinPerfumePrice ||
      priceRange.end < kMaxPerfumePrice;
});

/// Favorite perfume IDs.
class FavoritesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {'pacific-chill'};

  void toggle(String perfumeId) {
    if (state.contains(perfumeId)) {
      state = {...state}..remove(perfumeId);
    } else {
      state = {...state, perfumeId};
    }
  }
}

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, Set<String>>(FavoritesNotifier.new);

/// Shopping cart items keyed by `(perfume.id, selectedSizeMl)`.
class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  void addItem(Perfume perfume, {int? sizeMl, int? unitPrice}) {
    final chosenSize = sizeMl ?? perfume.volumeMl;
    final chosenPrice = unitPrice ?? perfume.priceForSize(chosenSize);
    final key = '${perfume.id}_$chosenSize';
    final existingIndex = state.indexWhere((item) => item.cartKey == key);
    if (existingIndex == -1) {
      state = [
        ...state,
        CartItem(
          perfume: perfume,
          selectedSizeMl: chosenSize,
          unitPrice: chosenPrice,
          quantity: 1,
        ),
      ];
    } else {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == existingIndex)
            state[i].copyWith(quantity: state[i].quantity + 1)
          else
            state[i],
      ];
    }
  }

  void incrementItem(String cartKey) {
    state = [
      for (final item in state)
        if (item.cartKey == cartKey)
          item.copyWith(quantity: item.quantity + 1)
        else
          item,
    ];
  }

  void decrementItem(String cartKey) {
    final target = state.where((i) => i.cartKey == cartKey).firstOrNull;
    if (target == null) return;
    if (target.quantity <= 1) {
      removeItem(cartKey);
    } else {
      state = [
        for (final item in state)
          if (item.cartKey == cartKey)
            item.copyWith(quantity: item.quantity - 1)
          else
            item,
      ];
    }
  }

  void removeItem(String cartKey) {
    state = state.where((item) => item.cartKey != cartKey).toList();
  }

  void clear() => state = [];
}

final cartProvider =
    NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

/// Incremented each time a flying bottle lands in the cart to trigger cart bounce.
class CartBounceTickNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void trigger() => state = state + 1;
}

final cartBounceTickProvider =
    NotifierProvider<CartBounceTickNotifier, int>(CartBounceTickNotifier.new);

/// Incremented each time a flying heart lands in the Favorite nav icon.
class FavoriteBounceTickNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void trigger() => state = state + 1;
}

final favoriteBounceTickProvider =
    NotifierProvider<FavoriteBounceTickNotifier, int>(
  FavoriteBounceTickNotifier.new,
);

final cartCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0, (sum, item) => sum + item.quantity);
});

/// Dummy luxury atelier notification model.
enum NotificationKind { offer, arrival, promo, restock }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timeAgo,
    required this.kind,
    this.isRead = false,
    this.promoCode,
  });

  final String id;
  final String title;
  final String body;
  final String timeAgo;
  final NotificationKind kind;
  final bool isRead;
  final String? promoCode;

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        title: title,
        body: body,
        timeAgo: timeAgo,
        kind: kind,
        isRead: isRead ?? this.isRead,
        promoCode: promoCode,
      );
}

class NotificationsNotifier extends Notifier<List<AppNotification>> {
  @override
  List<AppNotification> build() => const [
        AppNotification(
          id: 'notif-1',
          title: 'Private Archive • 45% Off',
          body: 'Tam Dao Eau de Parfum is now curated at an exclusive seasonal rate.',
          timeAgo: '2m ago',
          kind: NotificationKind.offer,
          isRead: false,
        ),
        AppNotification(
          id: 'notif-2',
          title: 'New Arrival: Afternoon Swim',
          body: 'Louis Vuitton Mediterranean citrus cologne is now available in 4 sizes.',
          timeAgo: '1h ago',
          kind: NotificationKind.arrival,
          isRead: false,
        ),
        AppNotification(
          id: 'notif-3',
          title: 'Atelier Privilege Active',
          body: 'Enjoy an extra 10% off your next order with code AROMA10.',
          timeAgo: '3h ago',
          kind: NotificationKind.promo,
          isRead: false,
          promoCode: 'AROMA10',
        ),
        AppNotification(
          id: 'notif-4',
          title: 'Complimentary Discovery Vial',
          body: 'Orders above 200\$ include a hand-poured 5ml Santal 33 travel vial.',
          timeAgo: 'Yesterday',
          kind: NotificationKind.offer,
          isRead: true,
        ),
        AppNotification(
          id: 'notif-5',
          title: 'Vault Watch: Oud Wood',
          body: 'We will notify you the moment Tom Ford Oud Wood returns to stock.',
          timeAgo: '2d ago',
          kind: NotificationKind.restock,
          isRead: true,
        ),
        AppNotification(
          id: 'notif-6',
          title: 'Limited Batch: Imagination',
          body: 'Final 50ml flacons of Louis Vuitton Imagination remain in the boutique.',
          timeAgo: '3d ago',
          kind: NotificationKind.arrival,
          isRead: true,
        ),
        AppNotification(
          id: 'notif-7',
          title: 'Seasonal Curation: Pacific Chill',
          body: 'Save 20% on our signature California citrus & blackcurrant cologne.',
          timeAgo: '4d ago',
          kind: NotificationKind.offer,
          isRead: true,
        ),
        AppNotification(
          id: 'notif-8',
          title: 'Bespoke Gift Wrapping',
          body: 'Wax-sealed linen boxes and handwritten notes are complimentary this week.',
          timeAgo: '5d ago',
          kind: NotificationKind.promo,
          isRead: true,
        ),
        AppNotification(
          id: 'notif-9',
          title: 'Maison Spotlight: Byredo',
          body: 'Explore Gypsy Water & Blanche — clean Scandinavian minimalism in glass.',
          timeAgo: '1w ago',
          kind: NotificationKind.arrival,
          isRead: true,
        ),
        AppNotification(
          id: 'notif-10',
          title: 'Welcome to Aromantique',
          body: 'Your Atelier Member pass (21552011052) is verified and ready.',
          timeAgo: '2w ago',
          kind: NotificationKind.promo,
          isRead: true,
        ),
      ];

  void markRead(String id) {
    state = [
      for (final n in state)
        if (n.id == id && !n.isRead) n.copyWith(isRead: true) else n,
    ];
  }

  void markAllRead() {
    state = [for (final n in state) n.copyWith(isRead: true)];
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsNotifier, List<AppNotification>>(
  NotificationsNotifier.new,
);

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final items = ref.watch(notificationsProvider);
  return items.where((n) => !n.isRead).length;
});

final filteredCatalogPerfumesProvider = Provider<List<Perfume>>((ref) {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final onlyFavorites = ref.watch(favoritesFilterProvider);
  final favorites = ref.watch(favoritesProvider);
  final selectedBrands = ref.watch(selectedBrandsProvider);
  final selectedGenders = ref.watch(selectedGendersProvider);
  final priceRange = ref.watch(priceRangeProvider);

  return catalogPerfumes.where((perfume) {
    if (onlyFavorites && !favorites.contains(perfume.id)) {
      return false;
    }
    if (selectedBrands.isNotEmpty && !selectedBrands.contains(perfume.brand)) {
      return false;
    }
    if (selectedGenders.isNotEmpty &&
        !selectedGenders.contains(perfume.gender)) {
      return false;
    }
    if (perfume.price < priceRange.start || perfume.price > priceRange.end) {
      return false;
    }
    if (query.isEmpty) return true;
    return perfume.name.toLowerCase().contains(query) ||
        perfume.brand.toLowerCase().contains(query) ||
        perfume.subtitle.toLowerCase().contains(query);
  }).toList();
});
