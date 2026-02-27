import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/balance_card.dart';
import '../../../core/widgets/transaction_tile.dart';
import '../../../data/local/hive_service.dart';
import '../widgets/mini_chart_widget.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(monthlyReportProvider);
    final recentTransactions = ref.watch(recentTransactionsProvider);
    final selectedDate = ref.watch(selectedDateProvider);

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
                                ?.copyWith(color: Colors.white54),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Le tue Finanze',
                            style: Theme.of(context).textTheme.headlineMedium,
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

                  const SizedBox(height: 24),

                  // Month Selector
                  _MonthSelector(
                    selectedDate: selectedDate,
                    onPrevious: () {
                      ref.read(selectedDateProvider.notifier).state = DateTime(
                        selectedDate.year,
                        selectedDate.month - 1,
                      );
                    },
                    onNext: () {
                      ref.read(selectedDateProvider.notifier).state = DateTime(
                        selectedDate.year,
                        selectedDate.month + 1,
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Balance Card
                  BalanceCard(
                    totalIncome: report.totalIncome,
                    totalExpense: report.totalExpense,
                    period: Formatters.formatMonthYear(selectedDate),
                  ),

                  const SizedBox(height: 24),

                  // Mini Chart
                  const MiniChartWidget(),

                  const SizedBox(height: 24),

                  // Budget Alerts
                  _BudgetAlerts(),

                  // Savings Goals Mini
                  _SavingsGoalsMini(),

                  // Recent Transactions Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ultimi Movimenti',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () => context.go('/transactions'),
                        child: Text(
                          'Vedi tutti',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppTheme.primaryColor),
                        ),
                      ),
                    ],
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
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 64, color: Colors.white.withValues(alpha: 0.15)),
                      const SizedBox(height: 16),
                      Text(
                        'Nessun movimento ancora',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white38,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tocca + per aggiungere il primo',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white24,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
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
    );
  }
}

class _MonthSelector extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _MonthSelector({
    required this.selectedDate,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left_rounded,
                color: Colors.white70),
            iconSize: 24,
          ),
          Text(
            Formatters.formatMonthYear(selectedDate),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right_rounded,
                color: Colors.white70),
            iconSize: 24,
          ),
        ],
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('⚠️ Budget', style: Theme.of(context).textTheme.titleLarge),
            TextButton(
              onPressed: () => context.go('/budget'),
              child: Text('Vedi tutti',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppTheme.primaryColor)),
            ),
          ],
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percent.clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: AppTheme.borderDark,
                          valueColor: AlwaysStoppedAnimation(color),
                        ),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('🎯 Obiettivi', style: Theme.of(context).textTheme.titleLarge),
            TextButton(
              onPressed: () => context.push('/savings'),
              child: Text('Vedi tutti',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppTheme.primaryColor)),
            ),
          ],
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
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    IconData(goal.iconCodePoint, fontFamily: 'MaterialIcons'),
                    color: color,
                    size: 18,
                  ),
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: goal.progress,
                          minHeight: 6,
                          backgroundColor: AppTheme.borderDark,
                          valueColor: AlwaysStoppedAnimation(color),
                        ),
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
