import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panaderia_erp/data/database/app_database.dart';
import 'package:panaderia_erp/data/repositories/expense_repository.dart';
import 'package:panaderia_erp/data/repositories/product_repository.dart';
import 'package:panaderia_erp/data/repositories/sales_repository.dart';
import 'package:panaderia_erp/data/repositories/stock_repository.dart';
import 'package:panaderia_erp/ui/screens/dashboard/dashboard_controller.dart';
import 'package:panaderia_erp/ui/screens/expenses/expense_controller.dart';

import '../helpers/test_locale.dart';

void main() {
  late AppDatabase database;
  late ExpenseRepository expenseRepository;
  late ExpenseController controller;

  setUp(() async {
    await initializeSpanishLocaleForTests();
    database = AppDatabase.forTesting(NativeDatabase.memory());
    expenseRepository = ExpenseRepository(database);
    controller = ExpenseController(expenseRepository: expenseRepository);
  });

  tearDown(() async {
    await database.close();
  });

  test('deleteExpense refreshes list and sets success message', () async {
    final now = DateTime.now();
    final id = await expenseRepository.createExpense(
      category: 'Internet',
      amount: 40,
      createdAt: now,
    );

    await controller.applyFilter(
      start: now.subtract(const Duration(days: 1)),
      end: now.add(const Duration(days: 1)),
    );
    expect(controller.expenses, hasLength(1));

    await controller.deleteExpense(id: id);

    expect(controller.message, 'Egreso eliminado correctamente');
    expect(controller.expenses, isEmpty);
    expect(controller.activeFilter, isNotNull);
  });

  test('deleteExpense with unknown id sets controlled error message', () async {
    await controller.deleteExpense(id: -1);

    expect(controller.message, 'No se pudo eliminar el egreso');
  });

  test('createExpense and deleteExpense reload DashboardController metrics', () async {
    final productRepository = ProductRepository(database);
    final stockRepository = StockRepository(database);
    final salesRepository = SalesRepository(database);
    final dashboardController = DashboardController(
      salesRepository: salesRepository,
      expenseRepository: expenseRepository,
      productRepository: productRepository,
      stockRepository: stockRepository,
    );

    final controllerWithDashboard = ExpenseController(
      expenseRepository: expenseRepository,
      dashboardController: dashboardController,
    );

    final now = DateTime.now();
    await controllerWithDashboard.createExpense(
      category: 'Insumos',
      amount: 50.0,
      date: now,
    );

    expect(dashboardController.dayExpenses, 50.0);

    final id = controllerWithDashboard.expenses.first.id;
    await controllerWithDashboard.deleteExpense(id: id);

    expect(dashboardController.dayExpenses, 0.0);
  });
}
