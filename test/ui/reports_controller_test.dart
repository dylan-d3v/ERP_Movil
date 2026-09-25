import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panaderia_erp/data/database/app_database.dart';
import 'package:panaderia_erp/data/repositories/expense_repository.dart';
import 'package:panaderia_erp/data/repositories/product_repository.dart';
import 'package:panaderia_erp/data/repositories/sales_repository.dart';
import 'package:panaderia_erp/services/excel_exporter.dart';
import 'package:panaderia_erp/services/pdf_exporter.dart';
import 'package:panaderia_erp/ui/screens/reports/reports_controller.dart';

import '../helpers/test_locale.dart';

void main() {
  late AppDatabase database;
  late SalesRepository salesRepository;
  late ExpenseRepository expenseRepository;
  late ProductRepository productRepository;
  late ReportsController controller;

  setUp(() async {
    await initializeSpanishLocaleForTests();
    database = AppDatabase.forTesting(NativeDatabase.memory());
    salesRepository = SalesRepository(database);
    expenseRepository = ExpenseRepository(database);
    productRepository = ProductRepository(database);

    controller = ReportsController(
      salesRepository: salesRepository,
      expenseRepository: expenseRepository,
      productRepository: productRepository,
      excelExporter: ExcelExporter(productRepository: productRepository),
      pdfExporter: PdfExporter(),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('loadReport generates chart points for day period', () async {
    controller.setPeriod(ReportPeriod.day);
    await controller.loadReport();

    expect(controller.chartPoints.length, equals(12));
    expect(controller.chartPoints.first.label, equals('00:00'));
  });

  test('loadReport generates chart points for month period', () async {
    controller.setPeriod(ReportPeriod.month);
    await controller.loadReport();

    final now = DateTime.now();
    final expectedDays = DateTime(now.year, now.month + 1, 0).day;
    expect(controller.chartPoints.length, equals(expectedDays));
    expect(controller.chartPoints.first.label, equals('1'));
  });

  test('loadReport generates chart points for year period', () async {
    controller.setPeriod(ReportPeriod.year);
    await controller.loadReport();

    expect(controller.chartPoints.length, equals(12));
    expect(controller.chartPoints.first.label, equals('Ene'));
  });
}

