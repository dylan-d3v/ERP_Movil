import 'dart:io';

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/repositories/product_repository.dart';
import '../data/repositories/sales_repository.dart';

class ReportData {
  final List<SaleWithItems> sales;
  final double totalSales;
  final double totalExpenses;
  final double profit;
  final String periodLabel;

  const ReportData({
    required this.sales,
    required this.totalSales,
    required this.totalExpenses,
    required this.profit,
    required this.periodLabel,
  });
}

class ExcelExporter {
  static const _sheetName = 'Reporte';
  static const _excelMimeType =
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

  final ProductRepository _productRepository;

  ExcelExporter({
    required ProductRepository productRepository,
  }) : _productRepository = productRepository;

  Future<void> export(ReportData report) async {
    final workbook = Excel.createExcel();
    final sheet = workbook[_sheetName];
    workbook.setDefaultSheet(_sheetName);
    workbook.delete('Sheet1');

    _configureColumns(sheet);

    final styles = _ExcelReportStyles();
    var row = 0;

    _writeMergedTitle(
      sheet: sheet,
      row: row,
      text: 'Reporte de Ventas',
      style: styles.title,
    );
    sheet.setRowHeight(row, 30);
    row += 1;

    _writeText(sheet, row, 0, 'Fecha de generacion:', styles.metaLabel);
    _writeText(
      sheet,
      row,
      1,
      DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
      styles.metaValue,
    );
    row += 1;

    _writeText(sheet, row, 0, 'Periodo:', styles.metaLabel);
    _writeText(sheet, row, 1, report.periodLabel, styles.metaValue);
    row += 2;

    _writeHeaderRow(sheet, row, styles.tableHeader);
    row += 1;

    for (final saleWithItems in report.sales) {
      final sale = saleWithItems.sale;
      final items = saleWithItems.items;
      final saleDate = DateFormat('dd/MM/yyyy HH:mm').format(sale.createdAt);

      for (var i = 0; i < items.length; i++) {
        final item = items[i];
        final product = await _productRepository.getProductById(item.productId);
        final productName = product?.name ?? 'Producto #${item.productId}';
        final subtotal = item.quantity * item.unitPrice;

        _writeRow(
          sheet,
          row,
          [
            i == 0 ? sale.id.toString() : '',
            i == 0 ? saleDate : '',
            productName,
            item.quantity.toStringAsFixed(2),
            _formatMoney(item.unitPrice),
            _formatMoney(subtotal),
            '',
          ],
          styles.tableCell,
        );
        row += 1;
      }

      final saleTotal = items.fold<double>(
        0,
        (sum, item) => sum + (item.quantity * item.unitPrice),
      );

      _writeRow(
        sheet,
        row,
        ['', '', '', '', '', 'Total:', _formatMoney(saleTotal)],
        styles.saleTotal,
      );
      row += 2;
    }

    row += 1;
    _writeMergedTitle(
      sheet: sheet,
      row: row,
      text: 'Resumen del Periodo',
      style: styles.summaryTitle,
    );
    sheet.setRowHeight(row, 24);
    row += 1;

    _writeSummaryRow(
      sheet,
      row,
      'Total Ventas:',
      report.totalSales,
      styles.summarySales,
    );
    row += 1;

    _writeSummaryRow(
      sheet,
      row,
      'Total Egresos:',
      report.totalExpenses,
      styles.summaryExpenses,
    );
    row += 1;

    _writeSummaryRow(
      sheet,
      row,
      'Ganancia:',
      report.profit,
      report.profit >= 0 ? styles.summaryProfit : styles.summaryLoss,
    );

    final fileName =
        'reporte_ventas_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
    final fileBytes = workbook.save(fileName: fileName);
    if (fileBytes == null) {
      throw StateError('No se pudo generar el archivo Excel.');
    }

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(fileBytes, flush: true);

    await Share.shareXFiles(
      [
        XFile(
          file.path,
          mimeType: _excelMimeType,
        ),
      ],
      subject: 'Reporte de Ventas - ${report.periodLabel}',
    );
  }

  void _configureColumns(Sheet sheet) {
    const widths = [12.0, 20.0, 30.0, 12.0, 16.0, 16.0, 16.0];

    for (var i = 0; i < widths.length; i++) {
      sheet.setColumnWidth(i, widths[i]);
    }
  }

  void _writeMergedTitle({
    required Sheet sheet,
    required int row,
    required String text,
    required CellStyle style,
  }) {
    final start = _cell(row, 0);
    sheet.merge(
      start,
      _cell(row, 6),
      customValue: TextCellValue(text),
    );
    sheet.setMergedCellStyle(start, style);
  }

  void _writeHeaderRow(Sheet sheet, int row, CellStyle style) {
    _writeRow(
      sheet,
      row,
      [
        'ID Venta',
        'Fecha',
        'Producto',
        'Cantidad',
        'Precio Unitario',
        'Subtotal',
        'Total Venta',
      ],
      style,
    );
  }

  void _writeSummaryRow(
    Sheet sheet,
    int row,
    String label,
    double amount,
    CellStyle style,
  ) {
    _writeText(sheet, row, 0, label, style);
    _writeText(sheet, row, 1, _formatMoney(amount), style);

    for (var column = 2; column <= 6; column++) {
      _writeText(sheet, row, column, '', style);
    }
  }

  void _writeRow(
    Sheet sheet,
    int row,
    List<String> values,
    CellStyle style,
  ) {
    for (var column = 0; column < values.length; column++) {
      _writeText(sheet, row, column, values[column], style);
    }
  }

  void _writeText(
    Sheet sheet,
    int row,
    int column,
    String value,
    CellStyle style,
  ) {
    sheet.updateCell(
      _cell(row, column),
      TextCellValue(value),
      cellStyle: style,
    );
  }

  CellIndex _cell(int row, int column) {
    return CellIndex.indexByColumnRow(
      columnIndex: column,
      rowIndex: row,
    );
  }

  String _formatMoney(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }
}

class _ExcelReportStyles {
  final Border _thinBorder = Border(
    borderStyle: BorderStyle.Thin,
    borderColorHex: ExcelColor.grey400,
  );

  late final CellStyle title = CellStyle(
    bold: true,
    fontSize: 18,
    fontColorHex: ExcelColor.white,
    backgroundColorHex: ExcelColor.blue800,
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
  );

  late final CellStyle metaLabel = CellStyle(
    bold: true,
    backgroundColorHex: ExcelColor.blue50,
    horizontalAlign: HorizontalAlign.Left,
    verticalAlign: VerticalAlign.Center,
  );

  late final CellStyle metaValue = CellStyle(
    backgroundColorHex: ExcelColor.blue50,
    horizontalAlign: HorizontalAlign.Left,
    verticalAlign: VerticalAlign.Center,
  );

  late final CellStyle tableHeader = _borderedStyle(
    bold: true,
    fontColorHex: ExcelColor.white,
    backgroundColorHex: ExcelColor.blueGrey700,
    horizontalAlign: HorizontalAlign.Center,
  );

  late final CellStyle tableCell = _borderedStyle(
    backgroundColorHex: ExcelColor.white,
    horizontalAlign: HorizontalAlign.Left,
  );

  late final CellStyle saleTotal = _borderedStyle(
    bold: true,
    backgroundColorHex: ExcelColor.green50,
    horizontalAlign: HorizontalAlign.Right,
  );

  late final CellStyle summaryTitle = CellStyle(
    bold: true,
    fontSize: 14,
    fontColorHex: ExcelColor.white,
    backgroundColorHex: ExcelColor.orange800,
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
  );

  late final CellStyle summarySales = _borderedStyle(
    bold: true,
    fontColorHex: ExcelColor.green800,
    backgroundColorHex: ExcelColor.green50,
    horizontalAlign: HorizontalAlign.Left,
  );

  late final CellStyle summaryExpenses = _borderedStyle(
    bold: true,
    fontColorHex: ExcelColor.red800,
    backgroundColorHex: ExcelColor.red50,
    horizontalAlign: HorizontalAlign.Left,
  );

  late final CellStyle summaryProfit = _borderedStyle(
    bold: true,
    fontColorHex: ExcelColor.green900,
    backgroundColorHex: ExcelColor.green100,
    horizontalAlign: HorizontalAlign.Left,
  );

  late final CellStyle summaryLoss = _borderedStyle(
    bold: true,
    fontColorHex: ExcelColor.red900,
    backgroundColorHex: ExcelColor.red100,
    horizontalAlign: HorizontalAlign.Left,
  );

  CellStyle _borderedStyle({
    required ExcelColor backgroundColorHex,
    required HorizontalAlign horizontalAlign,
    ExcelColor fontColorHex = ExcelColor.black,
    bool bold = false,
  }) {
    return CellStyle(
      bold: bold,
      fontColorHex: fontColorHex,
      backgroundColorHex: backgroundColorHex,
      horizontalAlign: horizontalAlign,
      verticalAlign: VerticalAlign.Center,
      textWrapping: TextWrapping.WrapText,
      leftBorder: _thinBorder,
      rightBorder: _thinBorder,
      topBorder: _thinBorder,
      bottomBorder: _thinBorder,
    );
  }
}
