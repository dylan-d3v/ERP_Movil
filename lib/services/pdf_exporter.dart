import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data/database/app_database.dart';
import '../data/repositories/sales_repository.dart';
import 'excel_exporter.dart';

class PdfExporter {
  PdfExporter();

  Future<void> export(ReportData report, Map<int, String> productNames) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Reporte de Ventas',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Fecha de generación: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.Text(
              'Período: ${report.periodLabel}',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 16),
            pw.Divider(),
            pw.SizedBox(height: 16),
            pw.Header(level: 1, child: pw.Text('Detalle de Ventas')),
            pw.SizedBox(height: 8),
            ...report.sales.map((saleWithItems) {
              return _buildSaleBlock(saleWithItems, productNames);
            }),
            pw.SizedBox(height: 16),
            pw.Divider(),
            pw.SizedBox(height: 16),
            pw.Header(level: 1, child: pw.Text('Resumen del Período')),
            pw.SizedBox(height: 8),
            _buildSummaryTable(report),
          ];
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'reporte_ventas_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf',
    );
  }

  pw.Widget _buildSaleBlock(SaleWithItems saleWithItems, Map<int, String> productNames) {
    final sale = saleWithItems.sale;
    final items = saleWithItems.items;

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Venta #${sale.id}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                DateFormat('dd/MM/yyyy HH:mm').format(sale.createdAt),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Producto', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Cantidad', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Precio Unit.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Subtotal', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                ],
              ),
              ...items.map((item) {
                return pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(_getProductName(item, productNames)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(item.quantity.toStringAsFixed(2)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('\$${item.unitPrice.toStringAsFixed(2)}'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('\$${(item.quantity * item.unitPrice).toStringAsFixed(2)}'),
                    ),
                  ],
                );
              }),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text(
                'Total: ',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                '\$${_calculateSaleTotal(items).toStringAsFixed(2)}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryTable(ReportData report) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Concepto'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Monto'),
            ),
          ],
        ),
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Total Ventas'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('\$${report.totalSales.toStringAsFixed(2)}'),
            ),
          ],
        ),
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Total Egresos'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('\$${report.totalExpenses.toStringAsFixed(2)}'),
            ),
          ],
        ),
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.green100),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Ganancia', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                '\$${report.profit.toStringAsFixed(2)}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getProductName(SaleItem item, Map<int, String> productNames) {
    return productNames[item.productId] ?? 'Producto #${item.productId}';
  }

  double _calculateSaleTotal(List<SaleItem> items) {
    return items.fold<double>(0, (sum, item) => sum + (item.quantity * item.unitPrice));
  }
}
