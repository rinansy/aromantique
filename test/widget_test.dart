import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:aromantique/main.dart';

void main() {
  testWidgets('Perfume home renders, transitions to catalog, filters & buys',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: AromantiqueApp(),
      ),
    );

    // Animated splash screen renders first, then transitions into homepage
    expect(find.text('Aromantique'), findsOneWidget);
    expect(find.text("L'ART DU SILLAGE"), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pumpAndSettle();

    expect(find.text('Aromantique'), findsOneWidget);
    expect(find.text('Find your\nLuxurious Smell'), findsOneWidget);
    expect(find.text('View all'), findsOneWidget);

    await tester.tap(find.text('View all'));
    await tester.pumpAndSettle();

    expect(find.text('Perfume that\nUnderstand you!'), findsOneWidget);
    expect(find.text('Pacific Chill'), findsOneWidget);

    // Tap Buy on Pacific Chill -> opens detail drawer with Perfume Bottle Size slider
    await tester.tap(find.text('Buy').first);
    await tester.pumpAndSettle();
    expect(find.text('Perfume Bottle Size'), findsOneWidget);

    await tester.tap(find.text('100ml'));
    await tester.pump();
    await tester.tap(find.text('Buy').last);
    await tester.pumpAndSettle();
    expect(find.text('1'), findsWidgets);

    // Tap Pacific Chill tile again and select 300ml -> 2 items in cart
    await tester.tap(find.text('Pacific Chill'));
    await tester.pumpAndSettle();
    expect(find.text('Key Notes'), findsOneWidget);
    expect(find.text('Blackcurrant'), findsOneWidget);

    await tester.tap(find.text('300ml'));
    await tester.pump();
    await tester.tap(find.text('Buy').last);
    await tester.pumpAndSettle();
    expect(find.text('2'), findsWidgets);

    // Open cart bottom sheet, verify size variants, apply AROMA10, pay
    await tester.tap(find.byIcon(PhosphorIconsRegular.shoppingCartSimple));
    await tester.pumpAndSettle();
    expect(find.text('by Louis Vuitton • 100 ml'), findsOneWidget);
    expect(find.text('by Louis Vuitton • 300 ml'), findsOneWidget);
    expect(find.text('Promotion Savings'), findsOneWidget);
    expect(find.text('Pay 256\$'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'AROMA10');
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(find.text('Pay 230\$'), findsOneWidget);

    await tester.tap(find.text('Pay 230\$'));
    await tester.pumpAndSettle();
    expect(find.text('Card Number'), findsOneWidget);

    // Focus Card Number TextField to reveal Visa/Mastercard autocomplete below it
    await tester.tap(find.widgetWithText(TextField, '4916 5820 1194 3072'));
    await tester.pumpAndSettle();
    expect(find.text('Visa •• 6814'), findsOneWidget);

    await tester.tap(find.text('Visa •• 6814'));
    await tester.pumpAndSettle();
    expect(find.text('CVV SECURITY CODE'), findsOneWidget);

    await tester.tap(find.text('Confirm Pay 230\$'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Payment successful'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Open left filter drawer and filter by Byredo
    await tester.tap(find.byIcon(PhosphorIconsRegular.slidersHorizontal));
    await tester.pumpAndSettle();
    expect(find.text('Filter'), findsOneWidget);

    await tester.tap(find.text('Byredo'));
    await tester.pump();
    await tester.tap(find.text('Apply Filters'));
    await tester.pumpAndSettle();

    expect(find.text('Gypsy Water'), findsOneWidget);
    expect(find.text('Pacific Chill'), findsNothing);
  });

  testWidgets('Shows rotate prompt in landscape mode',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(844, 390);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: AromantiqueApp(),
      ),
    );

    expect(find.text('Portrait Mode Recommended'), findsOneWidget);
  });

  testWidgets('Shows foldable alert on wide/unfolded display',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(760, 840);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: AromantiqueApp(),
      ),
    );

    expect(find.text('Foldable Display Detected'), findsOneWidget);
  });
}
