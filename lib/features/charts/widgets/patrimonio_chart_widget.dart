import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';

/// Grafico a linea che mostra il patrimonio cumulativo nel tempo
class PatrimonioChartWidget extends ConsumerWidget {
  const PatrimonioChartWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(patrimonioOverTimeProvider);
    if (data.length < 2) return const SizedBox.shrink();

    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.balance))
        .toList();

    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final range = (maxY - minY).abs();
    final padding = range > 0 ? range * 0.15 : 100.0;

    final isPositive = data.last.balance >= 0;
    final lineColor = isPositive ? AppTheme.incomeColor : AppTheme.expenseColor;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Patrimonio nel Tempo',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: lineColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  Formatters.formatCurrency(data.last.balance),
                  style: TextStyle(
                    color: lineColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: minY - padding,
                maxY: maxY + padding,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: range > 0 ? (range / 4).ceilToDouble().clamp(50, double.infinity) : 100,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: AppTheme.border(context), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 55,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          Formatters.formatCompact(value),
                          style: TextStyle(
                              color: AppTheme.textMutedC(context), fontSize: 10),
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
                      reservedSize: 28,
                      interval: data.length > 12
                          ? (data.length / 6).ceilToDouble()
                          : 1,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= data.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            Formatters.formatShortMonth(data[idx].month),
                            style: TextStyle(
                                color: AppTheme.textMutedC(context), fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: lineColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, a, b, c) => FlDotCirclePainter(
                        radius: spot.x == spots.last.x ? 4 : 0,
                        color: lineColor,
                        strokeWidth: 2,
                        strokeColor: AppTheme.card(context),
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          lineColor.withValues(alpha: 0.2),
                          lineColor.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                  // Linea zero
                  if (minY < 0 && maxY > 0)
                    LineChartBarData(
                      spots: [
                        FlSpot(0, 0),
                        FlSpot(spots.last.x, 0),
                      ],
                      isCurved: false,
                      color: Colors.white12,
                      barWidth: 1,
                      dotData: const FlDotData(show: false),
                      dashArray: [4, 4],
                    ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppTheme.cardAlt(context),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((s) {
                        final idx = s.x.toInt();
                        final month = idx >= 0 && idx < data.length
                            ? Formatters.formatMonthYear(data[idx].month)
                            : '';
                        return LineTooltipItem(
                          '$month\n${Formatters.formatCurrency(s.y)}',
                          TextStyle(
                            color: lineColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


