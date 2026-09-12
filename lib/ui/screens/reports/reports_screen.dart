import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/expense_repository.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/sales_repository.dart';
import '../../../services/excel_exporter.dart';
import '../../../services/pdf_exporter.dart';
import 'reports_controller.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final controller = _buildController(context);
        Future.microtask(() => controller.loadReport());
        return controller;
      },
      child: Consumer<ReportsController>(
        builder: (context, controller, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Reportes'),
            ),
            body: Column(
              children: [
                _PeriodSelector(controller: controller),
                const Divider(height: 1),
                Expanded(
                  child: controller.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : controller.sales.isEmpty
                          ? const _EmptyState()
                          : _ReportContent(controller: controller),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  ReportsController _buildController(BuildContext context) {
    final salesRepo = Provider.of<SalesRepository>(context, listen: false);
    final expenseRepo = Provider.of<ExpenseRepository>(context, listen: false);
    final productRepo = Provider.of<ProductRepository>(context, listen: false);

    final excelExporter = ExcelExporter(
      productRepository: productRepo,
    );

    final pdfExporter = PdfExporter();

    return ReportsController(
      salesRepository: salesRepo,
      expenseRepository: expenseRepo,
      productRepository: productRepo,
      excelExporter: excelExporter,
      pdfExporter: pdfExporter,
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final ReportsController controller;

  const _PeriodSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<ReportPeriod>(
            segments: const [
              ButtonSegment(value: ReportPeriod.day, label: Text('Día')),
              ButtonSegment(value: ReportPeriod.month, label: Text('Mes')),
              ButtonSegment(value: ReportPeriod.year, label: Text('Año')),
              ButtonSegment(value: ReportPeriod.custom, label: Text('Rango')),
            ],
            selected: {controller.selectedPeriod},
            onSelectionChanged: (selection) {
              controller.setPeriod(selection.first);
              if (selection.first == ReportPeriod.custom) {
                _showDateRangePicker(context);
              } else {
                controller.loadReport();
              }
            },
          ),
          if (controller.selectedPeriod == ReportPeriod.custom) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDateRangePicker(context),
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text(
                      '${controller.customStartDate.day.toString().padLeft(2, '0')}/${controller.customStartDate.month.toString().padLeft(2, '0')}/${controller.customStartDate.year}',
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('—'),
                ),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDateRangePicker(context),
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text(
                      '${controller.customEndDate.day.toString().padLeft(2, '0')}/${controller.customEndDate.month.toString().padLeft(2, '0')}/${controller.customEndDate.year}',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: controller.loadReport,
                child: const Text('Generar reporte'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(
        start: controller.customStartDate,
        end: controller.customEndDate,
      ),
    );

    if (picked != null) {
      controller.setCustomDateRange(picked.start, picked.end);
      controller.loadReport();
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 72, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay ventas en este período',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Registra una venta para generar un reporte.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportContent extends StatelessWidget {
  final ReportsController controller;

  const _ReportContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SummaryCards(controller: controller),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.sales.length,
            itemBuilder: (context, index) {
              final saleWithItems = controller.sales[index];
              return _SaleCard(
                saleWithItems: saleWithItems,
                productNames: controller.productNames,
              );
            },
          ),
        ),
        _ExportButtons(controller: controller),
      ],
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final ReportsController controller;

  const _SummaryCards({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _SummaryChip(
            label: 'Ventas',
            value: '\$${controller.totalSales.toStringAsFixed(2)}',
            color: Colors.green.shade800,
          ),
          _SummaryChip(
            label: 'Egresos',
            value: '\$${controller.totalExpenses.toStringAsFixed(2)}',
            color: Colors.red.shade800,
          ),
          _SummaryChip(
            label: 'Ganancia',
            value: '\$${controller.profit.toStringAsFixed(2)}',
            color: controller.profit >= 0 ? Colors.green.shade800 : Colors.red.shade800,
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: color)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SaleCard extends StatelessWidget {
  final SaleWithItems saleWithItems;
  final Map<int, String> productNames;

  const _SaleCard({
    required this.saleWithItems,
    required this.productNames,
  });

  @override
  Widget build(BuildContext context) {
    final sale = saleWithItems.sale;
    final items = saleWithItems.items;
    final total = items.fold<double>(
      0,
      (sum, item) => sum + (item.quantity * item.unitPrice),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text('Venta #${sale.id}'),
        subtitle: Text(
          '${sale.createdAt.day.toString().padLeft(2, '0')}/${sale.createdAt.month.toString().padLeft(2, '0')}/${sale.createdAt.year} ${sale.createdAt.hour.toString().padLeft(2, '0')}:${sale.createdAt.minute.toString().padLeft(2, '0')}',
        ),
        trailing: Text(
          '\$${total.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        children: items.map((item) {
          final productName = productNames[item.productId] ?? 'Producto #${item.productId}';
          return ListTile(
            dense: true,
            title: Text(productName),
            subtitle: Text(
              'Cant: ${item.quantity.toStringAsFixed(2)} × \$${item.unitPrice.toStringAsFixed(2)}',
            ),
            trailing: Text(
              '\$${(item.quantity * item.unitPrice).toStringAsFixed(2)}',
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ExportButtons extends StatelessWidget {
  final ReportsController controller;

  const _ExportButtons({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: controller.exportToExcel,
              icon: const Icon(Icons.table_chart_outlined),
              label: const Text('Exportar Excel'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: controller.exportToPdf,
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('Exportar PDF'),
            ),
          ),
        ],
      ),
    );
  }
}
