import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panaderia_erp/app.dart';
import 'package:panaderia_erp/data/database/app_database.dart';
import 'package:panaderia_erp/data/repositories/product_repository.dart';
import 'package:panaderia_erp/data/repositories/sales_repository.dart';

import '../helpers/test_locale.dart';

void main() {
  testWidgets('renders reports screen with charts section below sales list', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final productRepo = ProductRepository(database);
    final salesRepo = SalesRepository(database);

    addTearDown(database.close);
    await initializeSpanishLocaleForTests();

    final productId = await productRepo.createProduct(
      name: 'Pan Dulce',
      salePrice: 2.50,
    );

    await salesRepo.createSale(
      items: [
        SaleItemInput(
          productId: productId,
          quantity: 2,
          unitPrice: 2.50,
        ),
      ],
    );

    await tester.pumpWidget(App(database: database));
    await tester.pump();
    await tester.pumpAndSettle();

    // Navigate to Dashboard reports action button
    await tester.tap(find.byIcon(Icons.bar_chart_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Reportes'), findsOneWidget);
    expect(find.text('Registros de Venta'), findsOneWidget);
    expect(find.text('Gráficos del Período'), findsOneWidget);
    expect(
      find.text('Evolución de Ventas, Egresos y Ganancia por período'),
      findsOneWidget,
    );
    expect(find.text('Comparación de Ventas y Egresos'), findsOneWidget);
    expect(
      find.text('Resultado del período: Ventas, Egresos y Ganancia'),
      findsOneWidget,
    );
  });
}

