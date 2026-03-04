import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../widget/tm_widgets.dart';
import '../widgets/line_chart_widget.dart';
import '../widgets/pie_chart_widget.dart';
import '../widgets/bar_chart_widget.dart';
import '../widgets/patrimonio_chart_widget.dart';

class ChartsScreen extends ConsumerWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final report = ref.watch(monthlyReportProvider);
    final screenType = ResponsiveLayout.getScreenType(context);
    final hPadding = ResponsiveLayout.horizontalPadding(context);
    final vSpacing = ResponsiveLayout.sectionSpacing(context);
    final colGap = ResponsiveLayout.columnGap(context);
    final topPad = ResponsiveLayout.topPadding(context);

    return SafeArea(
      bottom: false,
      child: ResponsiveContent(
          child: TmFadeScroll(
          topFadeHeight: 24,
          bottomFadeHeight: screenType == ScreenType.mobile ? 80 : 40,
          child: SingleChildScrollView(
            physics: ResponsiveLayout.scrollPhysics(context),
            padding: EdgeInsets.fromLTRB(hPadding, topPad, hPadding, ResponsiveLayout.bottomContentPadding(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Grafici',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: screenType == ScreenType.desktop ? 30 : null,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.formatMonthYear(selectedDate),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppTheme.textTertiary),
                ),
                SizedBox(height: vSpacing),

                // Savings Rate indicator
                _SavingsIndicator(report: report),
                SizedBox(height: vSpacing),

                // ── Desktop/Tablet: Charts in griglia ──
                if (screenType != ScreenType.mobile) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(child: TrendLineChartWidget()),
                      SizedBox(width: colGap),
                      const Expanded(child: IncomeExpenseBarChart()),
                    ],
                  ),
                  SizedBox(height: vSpacing),
                  const CategoryPieChartWidget(),
                  SizedBox(height: vSpacing),
                  const PatrimonioChartWidget(),
                ] else ...[
                  // ── Mobile: layout verticale ──
                  const TrendLineChartWidget(),
                  SizedBox(height: vSpacing),
                  const IncomeExpenseBarChart(),
                  SizedBox(height: vSpacing),
                  const CategoryPieChartWidget(),
                  SizedBox(height: vSpacing),
                  const PatrimonioChartWidget(),
                ],
              ],
            ),
          ),
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
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isPositive
              ? AppTheme.incomeColor.withValues(alpha: 0.3)
              : AppTheme.expenseColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          TmIconBadge(
            icon: isPositive
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            color: isPositive ? AppTheme.incomeColor : AppTheme.expenseColor,
            size: 56,
            iconSize: 28,
            borderRadius: 16,
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
                        color: AppTheme.textTertiary,
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


