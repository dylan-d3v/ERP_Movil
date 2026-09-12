import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panaderia_erp/data/database/app_database.dart';
import 'package:panaderia_erp/data/repositories/expense_repository.dart';

void main() {
  late AppDatabase database;
  late ExpenseRepository expenseRepository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    expenseRepository = ExpenseRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('deleteExpense removes an existing expense and returns true', () async {
    final expenseId = await expenseRepository.createExpense(
      category: 'Transporte',
      amount: 10,
    );

    final deleted = await expenseRepository.deleteExpense(id: expenseId);
    expect(deleted, isTrue);

    final expenses = await expenseRepository.getExpensesByDateRange(
      start: DateTime(2000),
      end: DateTime(2100),
    );
    expect(expenses, isEmpty);
  });

  test('deleteExpense with unknown id returns false', () async {
    final deleted = await expenseRepository.deleteExpense(id: 999999);
    expect(deleted, isFalse);
  });
}
