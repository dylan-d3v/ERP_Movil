import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panaderia_erp/app.dart';
import 'package:panaderia_erp/data/database/app_database.dart';

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
}
