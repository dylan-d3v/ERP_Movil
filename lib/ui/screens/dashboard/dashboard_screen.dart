import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../reports/reports_screen.dart';
import 'dashboard_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardController>(
      builder: (context, controller, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Dashboard'),
            actions: [
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReportsScreen()),
                ),
                icon: const Icon(Icons.bar_chart_outlined),
                tooltip: 'Reportes',
              ),
            ],
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: controller.loadDashboard,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _MetricsGrid(controller: controller),
                      const SizedBox(height: 24),
                      Text(
                        'Productos con stock bajo',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      if (controller.lowStockProducts.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'No hay productos con stock bajo.',
                            ),
                          ),
                        )
                      else
                        ...controller.lowStockProducts.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Card(
                              child: ListTile(
                                title: Text(item.product.name),
                                subtitle: Text(
                                  'Precio: \$${item.product.salePrice.toStringAsFixed(2)}',
                                ),
                                trailing: Text(
                                  'Stock: ${formatStock(item.stock)}',
                                  style: TextStyle(
                                    color: item.stock == 0
                                        ? Colors.red.shade800
                                        : null,
                                    fontWeight: item.stock == 0
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                                tileColor: item.stock == 0
                                    ? Colors.red.shade50
                                    : null,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  static const double _spacing = 12;
  static const double _minCardWidth = 150;
  static const double _maxCardWidth = 190;

  final DashboardController controller;

  const _MetricsGrid({required this.controller});

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _MetricCardData(
        title: 'Ingresos del dia',
        value: '\$${controller.dayIncome.toStringAsFixed(2)}',
        valueColor: Colors.green.shade800,
      ),
      _MetricCardData(
        title: 'Egresos del dia',
        value: '\$${controller.dayExpenses.toStringAsFixed(2)}',
        valueColor: Colors.red.shade800,
      ),
      _MetricCardData(
        title: 'Ganancia del dia',
        value: '\$${controller.dayProfit.toStringAsFixed(2)}',
        valueColor: controller.dayProfit >= 0
            ? Colors.green.shade800
            : Colors.red.shade800,
      ),
      _MetricCardData(
        title: 'Ventas de ${controller.currentMonthLabel}',
        value: '\$${controller.monthSales.toStringAsFixed(2)}',
        valueColor: Colors.green.shade800,
      ),
      _MetricCardData(
        title: 'Egresos de ${controller.currentMonthLabel}',
        value: '\$${controller.monthExpenses.toStringAsFixed(2)}',
        valueColor: Colors.red.shade800,
      ),
      _MetricCardData(
        title: 'Ganancia de ${controller.currentMonthLabel}',
        value: '\$${controller.monthProfit.toStringAsFixed(2)}',
        valueColor: controller.monthProfit >= 0
            ? Colors.green.shade800
            : Colors.red.shade800,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final columns = _columnCountForWidth(availableWidth);
        final totalSpacing = _spacing * (columns - 1);
        final rawCardWidth = (availableWidth - totalSpacing) / columns;
        final cardWidth = rawCardWidth.clamp(_minCardWidth, _maxCardWidth);
        final gridWidth = (cardWidth * columns) + totalSpacing;

        return Center(
          child: SizedBox(
            width: gridWidth,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: _spacing,
              runSpacing: _spacing,
              children: metrics
                  .map(
                    (metric) => _MetricCard(
                      title: metric.title,
                      value: metric.value,
                      valueColor: metric.valueColor,
                      width: cardWidth,
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  int _columnCountForWidth(double width) {
    if (width >= (_minCardWidth * 3) + (_spacing * 2)) {
      return 3;
    }

    if (width >= (_minCardWidth * 2) + _spacing) {
      return 2;
    }

    return 1;
  }
}

class _MetricCardData {
  final String title;
  final String value;
  final Color valueColor;

  const _MetricCardData({
    required this.title,
    required this.value,
    required this.valueColor,
  });
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;
  final double width;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.width,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        margin: EdgeInsets.zero,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 118),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  value,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: valueColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String formatStock(double stock) {
  return stock.toInt().toString();
}
