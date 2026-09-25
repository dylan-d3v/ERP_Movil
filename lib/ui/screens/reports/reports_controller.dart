import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../../data/database/app_database.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/sales_repository.dart';
import '../../../services/excel_exporter.dart';
import '../../../services/pdf_exporter.dart';

enum ReportPeriod { day, month, year, custom }

class ReportChartPoint {
  final String label;
  final double sales;
  final double expenses;
  final double profit;
  final DateTime timestamp;

  const ReportChartPoint({
    required this.label,
    required this.sales,
    required this.expenses,
    required this.profit,
    required this.timestamp,
  });
}

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
  List<ReportChartPoint> _chartPoints = [];

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
  List<ReportChartPoint> get chartPoints => _chartPoints;

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

    final rawExpenses = await _expenseRepository.getExpensesByDateRange(
      start: start,
      end: end,
    );

    _chartPoints = _buildChartPoints(
      period: _selectedPeriod,
      start: start,
      end: end,
      sales: _sales,
      expenses: rawExpenses,
    );

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

  List<ReportChartPoint> _buildChartPoints({
    required ReportPeriod period,
    required DateTime start,
    required DateTime end,
    required List<SaleWithItems> sales,
    required List<Expense> expenses,
  }) {
    final points = <ReportChartPoint>[];

    if (period == ReportPeriod.day) {
      for (var i = 0; i < 12; i++) {
        final slotStart = DateTime(start.year, start.month, start.day, i * 2);
        final slotEnd = slotStart.add(const Duration(hours: 2));

        final slotSales = sales
            .where((s) =>
                s.sale.createdAt.isAfter(slotStart.subtract(const Duration(microseconds: 1))) &&
                s.sale.createdAt.isBefore(slotEnd))
            .fold<double>(
              0,
              (sum, s) =>
                  sum +
                  s.items.fold<double>(
                    0,
                    (itemSum, item) => itemSum + (item.quantity * item.unitPrice),
                  ),
            );

        final slotExpenses = expenses
            .where((e) =>
                e.createdAt.isAfter(slotStart.subtract(const Duration(microseconds: 1))) &&
                e.createdAt.isBefore(slotEnd))
            .fold<double>(0, (sum, e) => sum + e.amount);

        final label = '${(i * 2).toString().padLeft(2, '0')}:00';
        points.add(
          ReportChartPoint(
            label: label,
            sales: slotSales,
            expenses: slotExpenses,
            profit: slotSales - slotExpenses,
            timestamp: slotStart,
          ),
        );
      }
    } else if (period == ReportPeriod.month) {
      final daysInMonth = DateTime(start.year, start.month + 1, 0).day;
      for (var d = 1; d <= daysInMonth; d++) {
        final dayStart = DateTime(start.year, start.month, d);
        final dayEnd = dayStart.add(const Duration(days: 1));

        final daySales = sales
            .where((s) =>
                s.sale.createdAt.isAfter(dayStart.subtract(const Duration(microseconds: 1))) &&
                s.sale.createdAt.isBefore(dayEnd))
            .fold<double>(
              0,
              (sum, s) =>
                  sum +
                  s.items.fold<double>(
                    0,
                    (itemSum, item) => itemSum + (item.quantity * item.unitPrice),
                  ),
            );

        final dayExpenses = expenses
            .where((e) =>
                e.createdAt.isAfter(dayStart.subtract(const Duration(microseconds: 1))) &&
                e.createdAt.isBefore(dayEnd))
            .fold<double>(0, (sum, e) => sum + e.amount);

        points.add(
          ReportChartPoint(
            label: d.toString(),
            sales: daySales,
            expenses: dayExpenses,
            profit: daySales - dayExpenses,
            timestamp: dayStart,
          ),
        );
      }
    } else if (period == ReportPeriod.year) {
      final monthLabels = [
        'Ene',
        'Feb',
        'Mar',
        'Abr',
        'May',
        'Jun',
        'Jul',
        'Ago',
        'Sep',
        'Oct',
        'Nov',
        'Dic'
      ];
      for (var m = 1; m <= 12; m++) {
        final monthStart = DateTime(start.year, m, 1);
        final monthEnd = DateTime(start.year, m + 1, 1);

        final monthSales = sales
            .where((s) =>
                s.sale.createdAt.isAfter(monthStart.subtract(const Duration(microseconds: 1))) &&
                s.sale.createdAt.isBefore(monthEnd))
            .fold<double>(
              0,
              (sum, s) =>
                  sum +
                  s.items.fold<double>(
                    0,
                    (itemSum, item) => itemSum + (item.quantity * item.unitPrice),
                  ),
            );

        final monthExpenses = expenses
            .where((e) =>
                e.createdAt.isAfter(monthStart.subtract(const Duration(microseconds: 1))) &&
                e.createdAt.isBefore(monthEnd))
            .fold<double>(0, (sum, e) => sum + e.amount);

        points.add(
          ReportChartPoint(
            label: monthLabels[m - 1],
            sales: monthSales,
            expenses: monthExpenses,
            profit: monthSales - monthExpenses,
            timestamp: monthStart,
          ),
        );
      }
    } else {
      final diffDays = end.difference(start).inDays;
      if (diffDays <= 60) {
        var current = DateTime(start.year, start.month, start.day);
        final cutoff = DateTime(end.year, end.month, end.day);
        while (current.isBefore(cutoff)) {
          final next = current.add(const Duration(days: 1));

          final daySales = sales
              .where((s) =>
                  s.sale.createdAt.isAfter(current.subtract(const Duration(microseconds: 1))) &&
                  s.sale.createdAt.isBefore(next))
              .fold<double>(
                0,
                (sum, s) =>
                    sum +
                    s.items.fold<double>(
                      0,
                      (itemSum, item) => itemSum + (item.quantity * item.unitPrice),
                    ),
              );

          final dayExpenses = expenses
              .where((e) =>
                  e.createdAt.isAfter(current.subtract(const Duration(microseconds: 1))) &&
                  e.createdAt.isBefore(next))
              .fold<double>(0, (sum, e) => sum + e.amount);

          points.add(
            ReportChartPoint(
              label: '${current.day}/${current.month}',
              sales: daySales,
              expenses: dayExpenses,
              profit: daySales - dayExpenses,
              timestamp: current,
            ),
          );

          current = next;
        }
      } else {
        var current = DateTime(start.year, start.month, 1);
        final cutoff = DateTime(end.year, end.month, 1);
        while (!current.isAfter(cutoff)) {
          final next = DateTime(current.year, current.month + 1, 1);

          final mSales = sales
              .where((s) =>
                  s.sale.createdAt.isAfter(current.subtract(const Duration(microseconds: 1))) &&
                  s.sale.createdAt.isBefore(next))
              .fold<double>(
                0,
                (sum, s) =>
                    sum +
                    s.items.fold<double>(
                      0,
                      (itemSum, item) => itemSum + (item.quantity * item.unitPrice),
                    ),
              );

          final mExpenses = expenses
              .where((e) =>
                  e.createdAt.isAfter(current.subtract(const Duration(microseconds: 1))) &&
                  e.createdAt.isBefore(next))
              .fold<double>(0, (sum, e) => sum + e.amount);

          points.add(
            ReportChartPoint(
              label: '${current.month}/${current.year.toString().substring(2)}',
              sales: mSales,
              expenses: mExpenses,
              profit: mSales - mExpenses,
              timestamp: current,
            ),
          );

          current = next;
        }
      }
    }

    return points;
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
