import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../widgets/line_chart_widget.dart';
import '../widgets/pie_chart_widget.dart';
import '../widgets/bar_chart_widget.dart';

class ChartsScreen extends ConsumerWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final report = ref.watch(monthlyReportProvider);

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Grafici',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              Formatters.formatMonthYear(selectedDate),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white54),
            ),
            const SizedBox(height: 24),

            // Savings Rate indicator
            _SavingsIndicator(report: report),
            const SizedBox(height: 24),

            // Line Chart - Trend ultimi 6 mesi
            const TrendLineChartWidget(),
            const SizedBox(height: 24),

            // Bar Chart - Income vs Expense
            const IncomeExpenseBarChart(),
            const SizedBox(height: 24),

            // Pie Chart - Ripartizione categorie
            const CategoryPieChartWidget(),
          ],
        ),
      ),
    );
  }
}

class _SavingsIndicator extends StatelessWidget {
  final dynamic report;

  const _SavingsIndicator({required this.report});

  @override
  Widget build(BuildContext context) {
    final balance = report.totalIncome - report.totalExpense;
    final isPositive = balance >= 0;
    final savingsRate = report.totalIncome > 0
        ? (balance / report.totalIncome * 100).clamp(-100.0, 100.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPositive
              ? [
                  AppTheme.incomeColor.withValues(alpha: 0.15),
                  AppTheme.cardDark,
                ]
              : [
                  AppTheme.expenseColor.withValues(alpha: 0.15),
                  AppTheme.cardDark,
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPositive
              ? AppTheme.incomeColor.withValues(alpha: 0.3)
              : AppTheme.expenseColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: (isPositive ? AppTheme.incomeColor : AppTheme.expenseColor)
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isPositive
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              color:
                  isPositive ? AppTheme.incomeColor : AppTheme.expenseColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPositive ? 'Stai risparmiando!' : 'Attenzione',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  isPositive
                      ? 'Risparmio del ${savingsRate.toStringAsFixed(1)}% questo mese'
                      : 'Le spese superano le entrate',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white54,
                      ),
                ),
              ],
            ),
          ),
          Text(
            Formatters.formatCompact(balance.abs()),
            style: TextStyle(
              color:
                  isPositive ? AppTheme.incomeColor : AppTheme.expenseColor,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}


