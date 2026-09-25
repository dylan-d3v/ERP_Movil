import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../reports_controller.dart';

class ReportChartsSection extends StatelessWidget {
  final ReportsController controller;

  const ReportChartsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final points = controller.chartPoints;

    return Column(
      children: [
        EvolucionVentasEgresosGananciaChart(points: points),
        const SizedBox(height: 16),
        ComparacionVentasEgresosChart(points: points),
        const SizedBox(height: 16),
        ResultadoPeriodoChart(
          totalSales: controller.totalSales,
          totalExpenses: controller.totalExpenses,
          profit: controller.profit,
        ),
        const SizedBox(height: 16),
        EvolucionGananciaChart(points: points),
        const SizedBox(height: 16),
        VentasYGananciaChart(points: points),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget legend;
  final Widget chart;

  const _ChartCard({
    required this.title,
    required this.legend,
    required this.chart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            legend,
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: chart,
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

// 1. Evolución de Ventas, Egresos y Ganancia por período (Líneas)
class EvolucionVentasEgresosGananciaChart extends StatelessWidget {
  final List<ReportChartPoint> points;

  const EvolucionVentasEgresosGananciaChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    final maxY = _calculateMaxY([
      ...points.map((p) => p.sales),
      ...points.map((p) => p.expenses),
      ...points.map((p) => p.profit),
    ]);

    final minY = _calculateMinY(points.map((p) => p.profit));

    return _ChartCard(
      title: 'Evolución de Ventas, Egresos y Ganancia por período',
      legend: const Wrap(
        spacing: 16,
        children: [
          _LegendBadge(label: 'Ventas', color: Colors.green),
          _LegendBadge(label: 'Egresos', color: Colors.red),
          _LegendBadge(label: 'Ganancia', color: Colors.blue),
        ],
      ),
      chart: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          titlesData: _buildTitlesData(points),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: points
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value.sales))
                  .toList(),
              isCurved: true,
              color: Colors.green.shade700,
              barWidth: 3,
              dotData: const FlDotData(show: false),
            ),
            LineChartBarData(
              spots: points
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value.expenses))
                  .toList(),
              isCurved: true,
              color: Colors.red.shade700,
              barWidth: 3,
              dotData: const FlDotData(show: false),
            ),
            LineChartBarData(
              spots: points
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value.profit))
                  .toList(),
              isCurved: true,
              color: Colors.blue.shade700,
              barWidth: 3,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}

// 2. Comparación de Ventas y Egresos (Barras lado a lado)
class ComparacionVentasEgresosChart extends StatelessWidget {
  final List<ReportChartPoint> points;

  const ComparacionVentasEgresosChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    final maxY = _calculateMaxY([
      ...points.map((p) => p.sales),
      ...points.map((p) => p.expenses),
    ]);

    return _ChartCard(
      title: 'Comparación de Ventas y Egresos',
      legend: const Wrap(
        spacing: 16,
        children: [
          _LegendBadge(label: 'Ventas', color: Colors.green),
          _LegendBadge(label: 'Egresos', color: Colors.red),
        ],
      ),
      chart: BarChart(
        BarChartData(
          maxY: maxY,
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          titlesData: _buildTitlesData(points),
          borderData: FlBorderData(show: false),
          barGroups: points.asMap().entries.map((e) {
            final idx = e.key;
            final p = e.value;
            return BarChartGroupData(
              x: idx,
              barRods: [
                BarChartRodData(
                  toY: p.sales,
                  color: Colors.green.shade700,
                  width: 6,
                  borderRadius: BorderRadius.circular(2),
                ),
                BarChartRodData(
                  toY: p.expenses,
                  color: Colors.red.shade700,
                  width: 6,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// 3. Resultado del período: Ventas, Egresos y Ganancia (Barras resumen)
class ResultadoPeriodoChart extends StatelessWidget {
  final double totalSales;
  final double totalExpenses;
  final double profit;

  const ResultadoPeriodoChart({
    super.key,
    required this.totalSales,
    required this.totalExpenses,
    required this.profit,
  });

  @override
  Widget build(BuildContext context) {
    final maxY = _calculateMaxY([totalSales, totalExpenses, profit.abs()]);

    return _ChartCard(
      title: 'Resultado del período: Ventas, Egresos y Ganancia',
      legend: const Wrap(
        spacing: 16,
        children: [
          _LegendBadge(label: 'Ventas Total', color: Colors.green),
          _LegendBadge(label: 'Egresos Total', color: Colors.red),
          _LegendBadge(label: 'Ganancia Neta', color: Colors.blue),
        ],
      ),
      chart: BarChart(
        BarChartData(
          maxY: maxY,
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  switch (idx) {
                    case 0:
                      return const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text('Ventas', style: TextStyle(fontSize: 11)),
                      );
                    case 1:
                      return const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text('Egresos', style: TextStyle(fontSize: 11)),
                      );
                    case 2:
                      return const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text('Ganancia', style: TextStyle(fontSize: 11)),
                      );
                    default:
                      return const Text('');
                  }
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: totalSales,
                  color: Colors.green.shade700,
                  width: 24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: totalExpenses,
                  color: Colors.red.shade700,
                  width: 24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: profit,
                  color: profit >= 0 ? Colors.blue.shade700 : Colors.red.shade900,
                  width: 24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 4. Evolución de la Ganancia (Línea)
class EvolucionGananciaChart extends StatelessWidget {
  final List<ReportChartPoint> points;

  const EvolucionGananciaChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    final maxY = _calculateMaxY(points.map((p) => p.profit));
    final minY = _calculateMinY(points.map((p) => p.profit));

    return _ChartCard(
      title: 'Evolución de la Ganancia',
      legend: const Wrap(
        spacing: 16,
        children: [
          _LegendBadge(label: 'Ganancia Neta', color: Colors.blue),
        ],
      ),
      chart: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          titlesData: _buildTitlesData(points),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: points
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value.profit))
                  .toList(),
              isCurved: true,
              color: Colors.blue.shade700,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.shade700.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 5. Ventas y Ganancia por período (Líneas comparativas Ventas vs Ganancia)
class VentasYGananciaChart extends StatelessWidget {
  final List<ReportChartPoint> points;

  const VentasYGananciaChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    final maxY = _calculateMaxY([
      ...points.map((p) => p.sales),
      ...points.map((p) => p.profit),
    ]);

    final minY = _calculateMinY(points.map((p) => p.profit));

    return _ChartCard(
      title: 'Ventas y Ganancia por período',
      legend: const Wrap(
        spacing: 16,
        children: [
          _LegendBadge(label: 'Ventas', color: Colors.green),
          _LegendBadge(label: 'Ganancia', color: Colors.blue),
        ],
      ),
      chart: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          titlesData: _buildTitlesData(points),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: points
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value.sales))
                  .toList(),
              isCurved: true,
              color: Colors.green.shade700,
              barWidth: 3,
              dotData: const FlDotData(show: false),
            ),
            LineChartBarData(
              spots: points
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value.profit))
                  .toList(),
              isCurved: true,
              color: Colors.blue.shade700,
              barWidth: 3,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}

// Helpers para escalas e intervalos de ejes
double _calculateMaxY(Iterable<double> values) {
  if (values.isEmpty) return 100;
  final maxVal = values.reduce((a, b) => a > b ? a : b);
  if (maxVal <= 0) return 10;
  return maxVal * 1.2;
}

double _calculateMinY(Iterable<double> values) {
  if (values.isEmpty) return 0;
  final minVal = values.reduce((a, b) => a < b ? a : b);
  if (minVal >= 0) return 0;
  return minVal * 1.2;
}

FlTitlesData _buildTitlesData(List<ReportChartPoint> points) {
  final interval = (points.length / 5).ceil().clamp(1, points.length);

  return FlTitlesData(
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        interval: interval.toDouble(),
        getTitlesWidget: (value, meta) {
          final idx = value.toInt();
          if (idx >= 0 && idx < points.length) {
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                points[idx].label,
                style: const TextStyle(fontSize: 10),
              ),
            );
          }
          return const Text('');
        },
      ),
    ),
  );
}

