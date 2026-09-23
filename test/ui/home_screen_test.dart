import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panaderia_erp/app.dart';
import 'package:panaderia_erp/data/database/app_database.dart';
import 'package:panaderia_erp/data/repositories/product_repository.dart';

import '../helpers/test_locale.dart';

void main() {
  testWidgets('allows creating a product from the main screen', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());

    addTearDown(database.close);
    await initializeSpanishLocaleForTests();

    await tester.pumpWidget(App(database: database));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Productos'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FloatingActionButton, 'Nuevo producto'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Nombre'), 'Pan integral');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Precio de venta'),
      '1.25',
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Crear'));
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Pan integral'), findsOneWidget);
    expect(find.text('Precio: \$1.25'), findsOneWidget);
    expect(find.text('Stock actual: 0'), findsOneWidget);
  });

  testWidgets('filters products in real time ignoring case', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final productRepository = ProductRepository(database);

    addTearDown(database.close);
    await initializeSpanishLocaleForTests();

    await productRepository.createProduct(name: 'Pan Frances', salePrice: 0.50);
    await productRepository.createProduct(name: 'Pastel de Chocolate', salePrice: 15.00);
    await productRepository.createProduct(name: 'Pan de Molde', salePrice: 2.00);

    await tester.pumpWidget(App(database: database));
    await tester.pump();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Productos'));
    await tester.pumpAndSettle();

    expect(find.text('Pan Frances'), findsOneWidget);
    expect(find.text('Pastel de Chocolate'), findsOneWidget);
    expect(find.text('Pan de Molde'), findsOneWidget);

    // Type search query "pan" in lower case
    await tester.enterText(find.byType(TextField).first, 'pan');
    await tester.pumpAndSettle();

    expect(find.text('Pan Frances'), findsOneWidget);
    expect(find.text('Pan de Molde'), findsOneWidget);
    expect(find.text('Pastel de Chocolate'), findsNothing);

    // Type search query with no matches
    await tester.enterText(find.byType(TextField).first, 'galleta');
    await tester.pumpAndSettle();

    expect(find.text('No se encontraron productos'), findsOneWidget);
    expect(find.text('Pan Frances'), findsNothing);

    // Clear search query
    await tester.enterText(find.byType(TextField).first, '');
    await tester.pumpAndSettle();

    expect(find.text('Pan Frances'), findsOneWidget);
    expect(find.text('Pastel de Chocolate'), findsOneWidget);
    expect(find.text('Pan de Molde'), findsOneWidget);
  });
}
