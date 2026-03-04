import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';

class TrendLineChartWidget extends ConsumerWidget {
  const TrendLineChartWidget({super.key});

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
                'Trend Mensile',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  _Dot(color: AppTheme.incomeColor, label: 'Entrate'),
                  const SizedBox(width: 14),
                  _Dot(color: AppTheme.expenseColor, label: 'Uscite'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: hasData
                ? LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: _interval(reports),
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: AppTheme.borderDark,
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                Formatters.formatCompact(value),
                                style: const TextStyle(
                                  color: Colors.white30,
                                  fontSize: 10,
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final i = value.toInt();
                              if (i < 0 || i >= reports.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  Formatters.formatShortMonth(
                                    DateTime(reports[i].year, reports[i].month),
                                  ),
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
                        _line(reports.map((r) => r.totalIncome).toList(),
                            AppTheme.incomeColor),
                        _line(reports.map((r) => r.totalExpense).toList(),
                            AppTheme.expenseColor),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => AppTheme.cardDarkAlt,
                          getTooltipItems: (spots) => spots.map((s) {
                            final c = s.barIndex == 0
                                ? AppTheme.incomeColor
                                : AppTheme.expenseColor;
                            return LineTooltipItem(
                              Formatters.formatCurrency(s.y),
                              TextStyle(
                                  color: c,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  )
                : _empty(context),
          ),
        ],
      ),
    );
  }

  LineChartBarData _line(List<double> values, Color color) {
    return LineChartBarData(
      spots: List.generate(
          values.length, (i) => FlSpot(i.toDouble(), values[i])),
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, xPercentage, bar, index) => FlDotCirclePainter(
          radius: 4,
          color: color,
          strokeWidth: 2,
          strokeColor: AppTheme.cardDark,
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        color: color.withValues(alpha: 0.08),
      ),
    );
  }

  double _interval(List reports) {
    double m = 0;
    for (final r in reports) {
      if (r.totalIncome > m) m = r.totalIncome;
      if (r.totalExpense > m) m = r.totalExpense;
    }
    return m == 0 ? 1000 : (m / 4).ceilToDouble();
  }

  Widget _empty(BuildContext context) {
    return Center(
      child: Text(
        'Nessun dato disponibile',
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: AppTheme.textMuted),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final String label;
  const _Dot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration:
              BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(color: AppTheme.textTertiary, fontSize: 11)),
      ],
    );
  }
}

