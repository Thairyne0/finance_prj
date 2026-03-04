import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';

class MiniChartWidget extends ConsumerWidget {
  const MiniChartWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(lastSixMonthsReportsProvider);

    final hasData = reports.any((r) => r.totalIncome > 0 || r.totalExpense > 0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Andamento',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Row(
                children: [
                  _LegendDot(color: AppTheme.incomeColor, label: 'Entrate'),
                  const SizedBox(width: 16),
                  _LegendDot(color: AppTheme.expenseColor, label: 'Uscite'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: hasData
                ? LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: _calcInterval(reports),
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: AppTheme.borderDark,
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= reports.length) {
                                return const SizedBox.shrink();
                              }
                              final r = reports[index];
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  Formatters.formatShortMonth(
                                      DateTime(r.year, r.month)),
                                  style: const TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        // Income line
                        LineChartBarData(
                          spots: List.generate(
                            reports.length,
                            (i) => FlSpot(i.toDouble(), reports[i].totalIncome),
                          ),
                          isCurved: true,
                          color: AppTheme.incomeColor,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.incomeColor.withValues(alpha: 0.08),
                          ),
                        ),
                        // Expense line
                        LineChartBarData(
                          spots: List.generate(
                            reports.length,
                            (i) =>
                                FlSpot(i.toDouble(), reports[i].totalExpense),
                          ),
                          isCurved: true,
                          color: AppTheme.expenseColor,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color:
                                AppTheme.expenseColor.withValues(alpha: 0.08),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => AppTheme.cardDarkAlt,
                          getTooltipItems: (spots) => spots.map((spot) {
                            final color = spot.barIndex == 0
                                ? AppTheme.incomeColor
                                : AppTheme.expenseColor;
                            return LineTooltipItem(
                              Formatters.formatCompact(spot.y),
                              TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      'Aggiungi transazioni per vedere il grafico',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textMuted,
                          ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  double _calcInterval(List reports) {
    double maxVal = 0;
    for (final r in reports) {
      if (r.totalIncome > maxVal) maxVal = r.totalIncome;
      if (r.totalExpense > maxVal) maxVal = r.totalExpense;
    }
    if (maxVal == 0) return 1000;
    return (maxVal / 4).ceilToDouble();
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textTertiary,
                fontSize: 11,
              ),
        ),
      ],
    );
  }
}

