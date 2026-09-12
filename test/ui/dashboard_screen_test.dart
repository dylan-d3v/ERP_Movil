import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panaderia_erp/app.dart';
import 'package:panaderia_erp/data/database/app_database.dart';
import 'package:panaderia_erp/data/repositories/expense_repository.dart';
import 'package:panaderia_erp/data/repositories/product_repository.dart';
import 'package:panaderia_erp/data/repositories/sales_repository.dart';
import 'package:panaderia_erp/data/repositories/stock_repository.dart';

import '../helpers/test_locale.dart';

void main() {
  testWidgets('dashboard shows sales, expenses and low stock summary', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final productRepository = ProductRepository(database);
    final stockRepository = StockRepository(database);
    final salesRepository = SalesRepository(database);
    final expenseRepository = ExpenseRepository(database);

    addTearDown(database.close);
    await initializeSpanishLocaleForTests();

    final productId = await productRepository.createProduct(
      name: 'Pan de casa',
      salePrice: 2.00,
    );

    await stockRepository.registerMovement(
      productId: productId,
      type: StockMovementType.entry,
      quantity: 5,
      reason: StockMovementReason.purchase,
    );

    await salesRepository.createSale(
      items: [
        SaleItemInput(
          productId: productId,
          quantity: 2,
          unitPrice: 2,
        ),
      ],
    );

    await expenseRepository.createExpense(
      category: 'Gas',
      amount: 1.50,
    );

    await tester.pumpWidget(App(database: database));
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Ingresos del dia'), findsOneWidget);
    expect(find.text('\$4.00'), findsWidgets);
    expect(find.text('Egresos del dia'), findsOneWidget);
    expect(find.text('\$1.50'), findsWidgets);
    expect(find.text('Ganancia del dia'), findsOneWidget);
    expect(find.text('\$2.50'), findsWidgets);
    expect(find.textContaining('Ventas de '), findsOneWidget);
    expect(find.textContaining('Egresos de '), findsOneWidget);
    expect(find.textContaining('Ganancia de '), findsOneWidget);
    expect(find.text('Pan de casa'), findsOneWidget);
    expect(find.text('Stock: 3'), findsOneWidget);
  });
}
