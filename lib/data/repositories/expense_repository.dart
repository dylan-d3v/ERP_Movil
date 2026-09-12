import 'package:drift/drift.dart';

import '../database/app_database.dart';

class ExpenseRepository {
  final AppDatabase _database;

  ExpenseRepository(this._database);

  Future<int> createExpense({
    required String category,
    required double amount,
    String? notes,
    DateTime? createdAt,
  }) {
    return _database.into(_database.expenses).insert(
          ExpensesCompanion.insert(
            category: category,
            amount: amount,
            notes: Value(notes),
            createdAt: Value(createdAt ?? DateTime.now()),
          ),
        );
  }

  Future<bool> updateExpense({
    required int id,
    required String category,
    required double amount,
    String? notes,
    DateTime? createdAt,
  }) async {
    final rowsAffected = await (_database.update(_database.expenses)
          ..where((table) => table.id.equals(id)))
        .write(
          ExpensesCompanion(
            category: Value(category),
            amount: Value(amount),
            notes: Value(notes),
            createdAt: Value(createdAt ?? DateTime.now()),
          ),
        );

    return rowsAffected > 0;
  }

  Future<bool> deleteExpense({required int id}) async {
    final rowsAffected = await (_database.delete(_database.expenses)
          ..where((table) => table.id.equals(id)))
        .go();
    return rowsAffected > 0;
  }

  Future<List<Expense>> getExpensesByDateRange({
    required DateTime start,
    required DateTime end,
  }) {
    return (_database.select(_database.expenses)
          ..where(
            (table) => table.createdAt.isBetweenValues(start, end),
          )
          ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]))
        .get();
  }

  Future<double> getExpensesTotalByDateRange({
    required DateTime start,
    required DateTime end,
  }) async {
    final expenses = await getExpensesByDateRange(start: start, end: end);
    return expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
  }
}
