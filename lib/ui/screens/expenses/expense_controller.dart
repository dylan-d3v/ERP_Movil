import 'package:flutter/foundation.dart';

import '../../../data/database/app_database.dart';
import '../../../data/repositories/expense_repository.dart';

class ExpenseFilter {
  final DateTime start;
  final DateTime end;

  const ExpenseFilter({
    required this.start,
    required this.end,
  });
}

class ExpenseController extends ChangeNotifier {
  final ExpenseRepository _expenseRepository;

  ExpenseController({
    required ExpenseRepository expenseRepository,
  }) : _expenseRepository = expenseRepository;

  bool _isLoading = false;
  List<Expense> _expenses = const [];
  String? _message;
  ExpenseFilter? _activeFilter;

  bool get isLoading => _isLoading;
  List<Expense> get expenses => _expenses;
  String? get message => _message;
  ExpenseFilter? get activeFilter => _activeFilter;

  Future<void> loadExpenses() async {
    _isLoading = true;
    notifyListeners();

    final now = DateTime.now();
    final end = _activeFilter?.end ?? now;
    final start = _activeFilter?.start ??
        DateTime(now.year, now.month, now.day).subtract(const Duration(days: 30));

    _expenses = await _expenseRepository.getExpensesByDateRange(
      start: start,
      end: end,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createExpense({
    required String category,
    required double amount,
    String? notes,
    required DateTime date,
  }) async {
    await _expenseRepository.createExpense(
      category: category,
      amount: amount,
      notes: notes,
      createdAt: date,
    );

    _message = 'Egreso registrado correctamente';
    await loadExpenses();
  }

  Future<void> updateExpense({
    required int id,
    required String category,
    required double amount,
    String? notes,
    required DateTime date,
  }) async {
    await _expenseRepository.updateExpense(
      id: id,
      category: category,
      amount: amount,
      notes: notes,
      createdAt: date,
    );

    _message = 'Egreso actualizado correctamente';
    await loadExpenses();
  }

  Future<void> deleteExpense({required int id}) async {
    final deleted = await _expenseRepository.deleteExpense(id: id);
    _message = deleted
        ? 'Egreso eliminado correctamente'
        : 'No se pudo eliminar el egreso';
    await loadExpenses();
  }

  Future<void> applyFilter({
    required DateTime start,
    required DateTime end,
  }) async {
    _activeFilter = ExpenseFilter(start: start, end: end);
    _message = null;
    await loadExpenses();
  }

  Future<void> clearFilter() async {
    _activeFilter = null;
    _message = null;
    await loadExpenses();
  }

  void clearMessage() {
    _message = null;
    notifyListeners();
  }
}
