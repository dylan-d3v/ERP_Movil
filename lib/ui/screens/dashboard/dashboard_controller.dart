import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../../data/database/app_database.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/sales_repository.dart';
import '../../../data/repositories/stock_repository.dart';

class LowStockProductViewData {
  final Product product;
  final double stock;

  const LowStockProductViewData({
    required this.product,
    required this.stock,
  });
}

class DashboardController extends ChangeNotifier {
  static const lowStockThreshold = 5.0;

  final SalesRepository _salesRepository;
  final ExpenseRepository _expenseRepository;
  final ProductRepository _productRepository;
  final StockRepository _stockRepository;

  DashboardController({
    required SalesRepository salesRepository,
    required ExpenseRepository expenseRepository,
    required ProductRepository productRepository,
    required StockRepository stockRepository,
  })  : _salesRepository = salesRepository,
        _expenseRepository = expenseRepository,
        _productRepository = productRepository,
        _stockRepository = stockRepository;

  bool _isLoading = false;
  double _dayIncome = 0;
  double _dayExpenses = 0;
  double _monthSales = 0;
  double _monthExpenses = 0;
  List<LowStockProductViewData> _lowStockProducts = const [];
  String _currentMonthLabel = '';

  bool get isLoading => _isLoading;
  double get dayIncome => _dayIncome;
  double get dayExpenses => _dayExpenses;
  double get monthSales => _monthSales;
  double get monthExpenses => _monthExpenses;
  double get dayProfit => _dayIncome - _dayExpenses;
  double get monthProfit => _monthSales - _monthExpenses;
  List<LowStockProductViewData> get lowStockProducts => _lowStockProducts;
  String get currentMonthLabel => _currentMonthLabel;

  Future<void> loadDashboard() async {
    _isLoading = true;
    notifyListeners();

    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    final monthStart = DateTime(now.year, now.month);
    final monthEnd = DateTime(now.year, now.month + 1);
    _currentMonthLabel = _capitalizeMonth(
      DateFormat.MMMM('es').format(now),
    );

    _dayIncome = await _salesRepository.getSalesTotalByDateRange(
      start: dayStart,
      end: dayEnd,
    );
    _dayExpenses = await _expenseRepository.getExpensesTotalByDateRange(
      start: dayStart,
      end: dayEnd,
    );
    _monthSales = await _salesRepository.getSalesTotalByDateRange(
      start: monthStart,
      end: monthEnd,
    );
    _monthExpenses = await _expenseRepository.getExpensesTotalByDateRange(
      start: monthStart,
      end: monthEnd,
    );

    final products = await _productRepository.getActiveProducts();
    if (products.isEmpty) {
      _lowStockProducts = [];
    } else {
      final productIds = products.map((p) => p.id).toList();
      final stockByProduct = await _stockRepository.getCurrentStocksForProducts(productIds);

      final lowStock = <LowStockProductViewData>[];
      for (final product in products) {
        final stock = stockByProduct[product.id] ?? 0;
        if (stock <= lowStockThreshold) {
          lowStock.add(
            LowStockProductViewData(
              product: product,
              stock: stock,
            ),
          );
        }
      }

      lowStock.sort((a, b) => a.stock.compareTo(b.stock));
      _lowStockProducts = lowStock;
    }
    _isLoading = false;
    notifyListeners();
  }

  String _capitalizeMonth(String month) {
    if (month.isEmpty) {
      return month;
    }

    return '${month[0].toUpperCase()}${month.substring(1)}';
  }
}
