import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panaderia_erp/app.dart';
import 'package:panaderia_erp/data/database/app_database.dart';
import 'package:panaderia_erp/data/repositories/product_repository.dart';
import 'package:panaderia_erp/data/repositories/stock_repository.dart';

import '../helpers/test_locale.dart';

void main() {
  testWidgets('allows registering a sale and updates product stock', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final productRepository = ProductRepository(database);
    final stockRepository = StockRepository(database);

    addTearDown(database.close);
    await initializeSpanishLocaleForTests();

    final productId = await productRepository.createProduct(
      name: 'Pan de queso',
      salePrice: 1.50,
    );

    await stockRepository.registerMovement(
      productId: productId,
      type: StockMovementType.entry,
      quantity: 10,
      reason: StockMovementReason.purchase,
    );

    await tester.pumpWidget(App(database: database));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Ventas'));
    await tester.pumpAndSettle();

    expect(find.text('Confirmar venta'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<int>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pan de queso').last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Cantidad').first,
      '2',
    );
    await tester.pumpAndSettle();

    expect(find.text('Subtotal: \$3.00'), findsOneWidget);
    expect(find.text('Total: \$3.00'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Confirmar venta'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Venta registrada correctamente'), findsOneWidget);

    await tester.tap(find.text('Productos'));
    await tester.pumpAndSettle();

    expect(find.text('Stock actual: 8'), findsOneWidget);
  });
}
