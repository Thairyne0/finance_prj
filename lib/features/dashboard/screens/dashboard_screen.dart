import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/balance_card.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/widgets/transaction_tile.dart';
import '../../../data/local/hive_service.dart';
import '../../../widget/tm_widgets.dart';
import '../widgets/mini_chart_widget.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(monthlyReportProvider);
    final recentTransactions = ref.watch(recentTransactionsProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final patrimonio = ref.watch(totalPatrimonioProvider);
    final totalIncomeAll = ref.watch(totalIncomeAllTimeProvider);
    final totalExpenseAll = ref.watch(totalExpenseAllTimeProvider);
    final screenType = ResponsiveLayout.getScreenType(context);
    final hPadding = ResponsiveLayout.horizontalPadding(context);
    final vSpacing = ResponsiveLayout.sectionSpacing(context);
    final colGap = ResponsiveLayout.columnGap(context);
    final topPad = ResponsiveLayout.topPadding(context);

    return SafeArea(
      child: ResponsiveContent(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(hPadding, topPad, hPadding, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bentornato 👋',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white54,
                                    fontSize: screenType == ScreenType.desktop ? 16 : null,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Le tue Finanze',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontSize: screenType == ScreenType.desktop ? 30 : null,
                                  ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.cardDark,
                            borderRadius: BorderRadius.circular(14),
                            border:
                                Border.all(color: AppTheme.borderDark, width: 1),
                          ),
                          child: IconButton(
                            onPressed: () => context.push('/add-transaction'),
                            icon: const Icon(Icons.add_rounded,
                                color: AppTheme.primaryColor),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ── Desktop/Tablet: Layout a griglia ──
                    if (screenType != ScreenType.mobile) ...[
                      // Top row: Patrimonio + Balance side by side
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _PatrimonioCard(
                              patrimonio: patrimonio,
                              totalIncome: totalIncomeAll,
                              totalExpense: totalExpenseAll,
                            ),
                          ),
                          SizedBox(width: colGap),
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                TmMonthSelector(
                                  selectedDate: selectedDate,
                                  onPrevious: () {
                                    ref.read(selectedDateProvider.notifier).state =
                                        DateTime(selectedDate.year, selectedDate.month - 1);
                                  },
                                  onNext: () {
                                    ref.read(selectedDateProvider.notifier).state =
                                        DateTime(selectedDate.year, selectedDate.month + 1);
                                  },
                                ),
                                const SizedBox(height: 20),
                                BalanceCard(
                                  totalIncome: report.totalIncome,
                                  totalExpense: report.totalExpense,
                                  period: Formatters.formatMonthYear(selectedDate),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: vSpacing),

                      // Second row: Chart + Budget/Savings
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(
                            flex: 3,
                            child: MiniChartWidget(),
                          ),
                          SizedBox(width: colGap),
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                _BudgetAlerts(),
                                _SavingsGoalsMini(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // ── Mobile: layout verticale originale ──
                      _PatrimonioCard(
                        patrimonio: patrimonio,
                        totalIncome: totalIncomeAll,
                        totalExpense: totalExpenseAll,
                      ),
                      const SizedBox(height: 20),
                      TmMonthSelector(
                        selectedDate: selectedDate,
                        onPrevious: () {
                          ref.read(selectedDateProvider.notifier).state =
                              DateTime(selectedDate.year, selectedDate.month - 1);
                        },
                        onNext: () {
                          ref.read(selectedDateProvider.notifier).state =
                              DateTime(selectedDate.year, selectedDate.month + 1);
                        },
                      ),
                      const SizedBox(height: 20),
                      BalanceCard(
                        totalIncome: report.totalIncome,
                        totalExpense: report.totalExpense,
                        period: Formatters.formatMonthYear(selectedDate),
                      ),
                      const SizedBox(height: 24),
                      const MiniChartWidget(),
                      const SizedBox(height: 24),
                      _BudgetAlerts(),
                      _SavingsGoalsMini(),
                    ],

                    SizedBox(height: vSpacing),

                    // Recent Transactions Header
                    TmSectionHeader(
                      title: 'Ultimi Movimenti',
                      actionLabel: 'Vedi tutti',
                      onAction: () => context.go('/transactions'),
                    ),
                  ],
                ),
              ),
            ),

            // Recent Transactions List
            if (recentTransactions.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: hPadding, vertical: 40),
                  child: const TmEmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'Nessun movimento ancora',
                    subtitle: 'Tocca + per aggiungere il primo',
                    iconSize: 64,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: hPadding),
                sliver: screenType != ScreenType.mobile
                    ? SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: ResponsiveLayout.gridColumns(context),
                          mainAxisSpacing: 10,
                          crossAxisSpacing: colGap,
                          mainAxisExtent: 86,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => TransactionTile(
                            transaction: recentTransactions[index],
                          ),
                          childCount: recentTransactions.length,
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return TransactionTile(
                              transaction: recentTransactions[index],
                            );
                          },
                          childCount: recentTransactions.length,
                        ),
                      ),
              ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
    );
  }
}

class _BudgetAlerts extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetStatus = ref.watch(budgetStatusProvider);
    if (budgetStatus.isEmpty) return const SizedBox.shrink();

    final alerts = budgetStatus.entries.where((e) {
      final percent = e.value.budget.limit > 0
          ? e.value.spent / e.value.budget.limit
          : 0.0;
      return percent > 0.8;
    }).toList();

    if (alerts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TmSectionHeader(
          title: '⚠️ Budget',
          actionLabel: 'Vedi tutti',
          onAction: () => context.push('/budget'),
        ),
        const SizedBox(height: 8),
        ...alerts.take(3).map((entry) {
          final cat = HiveService.getCategoryById(entry.key);
          final percent = entry.value.spent / entry.value.budget.limit;
          final isOver = percent > 1.0;
          final color = isOver ? AppTheme.expenseColor : AppTheme.warningColor;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Icon(
                  IconData(cat.iconCodePoint, fontFamily: 'MaterialIcons'),
                  color: Color(cat.colorValue),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cat.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 4),
                      TmProgressBar(
                        value: percent,
                        color: color,
                        height: 6,
                        borderRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(percent * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SavingsGoalsMini extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(allSavingsProvider);
    if (goals.isEmpty) return const SizedBox.shrink();

    final activeGoals = goals.where((g) => !g.isCompleted).take(2).toList();
    if (activeGoals.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TmSectionHeader(
          title: '🎯 Obiettivi',
          actionLabel: 'Vedi tutti',
          onAction: () => context.push('/savings'),
        ),
        const SizedBox(height: 8),
        ...activeGoals.map((goal) {
          final color = Color(goal.colorValue);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderDark),
            ),
            child: Row(
              children: [
                TmIconBadge.fromCodePoint(
                  iconCodePoint: goal.iconCodePoint,
                  colorValue: goal.colorValue,
                  size: 38,
                  iconSize: 18,
                  borderRadius: 11,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(goal.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 6),
                      TmProgressBar(
                        value: goal.progress,
                        color: color,
                        height: 6,
                        borderRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(goal.progress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontSize: 15),
                    ),
                    Text(
                      '${goal.daysLeft}gg',
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _PatrimonioCard extends StatelessWidget {
  final double patrimonio;
  final double totalIncome;
  final double totalExpense;

  const _PatrimonioCard({
    required this.patrimonio,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = patrimonio >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPositive
              ? [
                  AppTheme.incomeColor.withValues(alpha: 0.25),
                  AppTheme.cardDark,
                  AppTheme.cardDarkAlt,
                ]
              : [
                  AppTheme.expenseColor.withValues(alpha: 0.25),
                  AppTheme.cardDark,
                  AppTheme.cardDarkAlt,
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPositive
              ? AppTheme.incomeColor.withValues(alpha: 0.3)
              : AppTheme.expenseColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isPositive ? AppTheme.incomeColor : AppTheme.expenseColor)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: isPositive ? AppTheme.incomeColor : AppTheme.expenseColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Patrimonio Totale',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            Formatters.formatCurrency(patrimonio),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 30,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _PatrimonioDetail(
                  label: 'Tot. Entrate',
                  amount: totalIncome,
                  icon: Icons.trending_up_rounded,
                  color: AppTheme.incomeColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PatrimonioDetail(
                  label: 'Tot. Uscite',
                  amount: totalExpense,
                  icon: Icons.trending_down_rounded,
                  color: AppTheme.expenseColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PatrimonioDetail extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  const _PatrimonioDetail({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white38,
                        fontSize: 10,
                      ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    Formatters.formatCurrency(amount),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

