import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../../data/repositories/expense_repository.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/sales_repository.dart';
import '../../../services/excel_exporter.dart';
import '../../../services/pdf_exporter.dart';

enum ReportPeriod { day, month, year, custom }

class ReportsController extends ChangeNotifier {
  final SalesRepository _salesRepository;
  final ExpenseRepository _expenseRepository;
  final ProductRepository _productRepository;
  final ExcelExporter _excelExporter;
  final PdfExporter _pdfExporter;

  ReportsController({
    required SalesRepository salesRepository,
    required ExpenseRepository expenseRepository,
    required ProductRepository productRepository,
    required ExcelExporter excelExporter,
    required PdfExporter pdfExporter,
  })  : _salesRepository = salesRepository,
        _expenseRepository = expenseRepository,
        _productRepository = productRepository,
        _excelExporter = excelExporter,
        _pdfExporter = pdfExporter;

  bool _isLoading = false;
  bool _hasExported = false;
  ReportPeriod _selectedPeriod = ReportPeriod.day;
  DateTime _customStartDate = DateTime.now();
  DateTime _customEndDate = DateTime.now();
  List<SaleWithItems> _sales = [];
  double _totalSales = 0;
  double _totalExpenses = 0;
  double _profit = 0;
  String _periodLabel = '';
  Map<int, String> _productNames = {};

  bool get isLoading => _isLoading;
  bool get hasExported => _hasExported;
  ReportPeriod get selectedPeriod => _selectedPeriod;
  DateTime get customStartDate => _customStartDate;
  DateTime get customEndDate => _customEndDate;
  List<SaleWithItems> get sales => _sales;
  double get totalSales => _totalSales;
  double get totalExpenses => _totalExpenses;
  double get profit => _profit;
  String get periodLabel => _periodLabel;
  Map<int, String> get productNames => _productNames;

  Future<void> loadReport() async {
    _isLoading = true;
    _hasExported = false;
    notifyListeners();

    final now = DateTime.now();
    DateTime start;
    DateTime end;
    String label;

    switch (_selectedPeriod) {
      case ReportPeriod.day:
        start = DateTime(now.year, now.month, now.day);
        end = start.add(const Duration(days: 1));
        label = DateFormat('dd/MMMM/yyyy', 'es').format(now);
        break;
      case ReportPeriod.month:
        start = DateTime(now.year, now.month);
        end = DateTime(now.year, now.month + 1);
        label = DateFormat('MMMM yyyy', 'es').format(now);
        break;
      case ReportPeriod.year:
        start = DateTime(now.year);
        end = DateTime(now.year + 1);
        label = now.year.toString();
        break;
      case ReportPeriod.custom:
        start = DateTime(_customStartDate.year, _customStartDate.month, _customStartDate.day);
        end = DateTime(_customEndDate.year, _customEndDate.month, _customEndDate.day).add(const Duration(days: 1));
        label = '${DateFormat('dd/MM/yyyy', 'es').format(_customStartDate)} - ${DateFormat('dd/MM/yyyy', 'es').format(_customEndDate)}';
        break;
    }

    _periodLabel = label;

    _sales = await _salesRepository.getSalesWithItemsByDateRange(
      start: start,
      end: end,
    );

    _totalSales = await _salesRepository.getSalesTotalByDateRange(
      start: start,
      end: end,
    );

    _totalExpenses = await _expenseRepository.getExpensesTotalByDateRange(
      start: start,
      end: end,
    );

    _profit = _totalSales - _totalExpenses;

    final productIds = <int>{};
    for (final saleWithItems in _sales) {
      for (final item in saleWithItems.items) {
        productIds.add(item.productId);
      }
    }

    _productNames = {};
    for (final id in productIds) {
      final product = await _productRepository.getProductById(id);
      if (product != null) {
        _productNames[id] = product.name;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  void setPeriod(ReportPeriod period) {
    _selectedPeriod = period;
    notifyListeners();
  }

  void setCustomDateRange(DateTime start, DateTime end) {
    _customStartDate = start;
    _customEndDate = end;
    notifyListeners();
  }

  Future<void> exportToExcel() async {
    final report = ReportData(
      sales: _sales,
      totalSales: _totalSales,
      totalExpenses: _totalExpenses,
      profit: _profit,
      periodLabel: _periodLabel,
    );
    await _excelExporter.export(report);
    _hasExported = true;
    notifyListeners();
  }

  Future<void> exportToPdf() async {
    final report = ReportData(
      sales: _sales,
      totalSales: _totalSales,
      totalExpenses: _totalExpenses,
      profit: _profit,
      periodLabel: _periodLabel,
    );
    await _pdfExporter.export(report, _productNames);
    _hasExported = true;
    notifyListeners();
  }
}
