import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../config/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../data/models/budget_model.dart';
import '../../../data/local/hive_service.dart';
import '../../../widget/tm_widgets.dart';
import '../widgets/budget_progress_card.dart';
import '../widgets/budget_alert_banner.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetStatus = ref.watch(budgetStatusProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final spending = ref.watch(categorySpendingProvider);

    // Categorie senza budget
    final categoriesWithoutBudget = HiveService.expenseCategories
        .where((c) => !budgetStatus.containsKey(c.id))
        .toList();

    // Spese senza budget assegnato
    final unbudgetedSpending = spending.entries
        .where((e) => !budgetStatus.containsKey(e.key))
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.scaffoldDark,
      appBar: AppBar(
        title: const Text('Budget'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          _AddBudgetButton(
            availableCategories: categoriesWithoutBudget,
            selectedDate: selectedDate,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveLayout.modalMaxWidth(context),
            ),
            child: SingleChildScrollView(
              physics: ResponsiveLayout.scrollPhysics(context),
              padding: EdgeInsets.fromLTRB(
                ResponsiveLayout.horizontalPadding(context),
                ResponsiveLayout.topPadding(context),
                ResponsiveLayout.horizontalPadding(context),
                ResponsiveLayout.bottomContentPadding(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildBudgetContent(
                  context, ref, budgetStatus, selectedDate, spending, unbudgetedSpending,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBudgetContent(
    BuildContext context,
    WidgetRef ref,
    Map<String, ({BudgetModel budget, double spent})> budgetStatus,
    DateTime selectedDate,
    Map<String, double> spending,
    List<MapEntry<String, double>> unbudgetedSpending,
  ) {
    final widgets = <Widget>[];

    widgets.add(
      Text(
        Formatters.formatMonthYear(selectedDate),
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Colors.white54),
      ),
    );

    widgets.add(const SizedBox(height: 24));

    // Alert budget (>=80% o superati)
    widgets.add(BudgetAlertBanner());

    // Riepilogo totale budget
    if (budgetStatus.isNotEmpty) {
      widgets.add(_TotalBudgetSummary(budgetStatus: budgetStatus));
      widgets.add(const SizedBox(height: 20));
    }

    // Budget cards
    if (budgetStatus.isEmpty) {
      widgets.add(
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: const TmEmptyState(
            icon: Icons.pie_chart_outline_rounded,
            title: 'Nessun budget impostato',
            subtitle: 'Imposta limiti di spesa per categoria',
          ),
        ),
      );
    } else {
      for (final entry in budgetStatus.entries) {
        final cat = HiveService.getCategoryById(entry.key);
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: BudgetProgressCard(
              categoryName: cat.name,
              iconCodePoint: cat.iconCodePoint,
              colorValue: cat.colorValue,
              budgetLimit: entry.value.budget.limit,
              spent: entry.value.spent,
              onDelete: () {
                ref
                    .read(allBudgetsProvider.notifier)
                    .delete(entry.value.budget.id);
              },
            ),
          ),
        );
      }
    }

    // Spese senza budget
    if (unbudgetedSpending.isNotEmpty) {
      widgets.add(const SizedBox(height: 24));
      widgets.add(
        Text(
          'SPESE SENZA BUDGET',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white38,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
        ),
      );
      widgets.add(const SizedBox(height: 12));

      for (final entry in unbudgetedSpending) {
        final cat = HiveService.getCategoryById(entry.key);
        widgets.add(
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderDark),
            ),
            child: Row(
              children: [
                Icon(
                  IconData(cat.iconCodePoint, fontFamily: 'MaterialIcons'),
                  color: Color(cat.colorValue),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(cat.name,
                    style: Theme.of(context).textTheme.bodyMedium),
                const Spacer(),
                Text(
                  Formatters.formatCurrency(entry.value),
                  style: const TextStyle(
                    color: AppTheme.expenseColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return widgets;
  }
}

class _TotalBudgetSummary extends StatelessWidget {
  final Map<String, ({BudgetModel budget, double spent})> budgetStatus;

  const _TotalBudgetSummary({required this.budgetStatus});

  @override
  Widget build(BuildContext context) {
    double totalBudget = 0;
    double totalSpent = 0;
    int overCount = 0;

    for (final entry in budgetStatus.values) {
      totalBudget += entry.budget.limit;
      totalSpent += entry.spent;
      if (entry.spent > entry.budget.limit) overCount++;
    }

    final percent = totalBudget > 0 ? (totalSpent / totalBudget) : 0.0;
    final isOver = totalSpent > totalBudget;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOver
              ? AppTheme.expenseColor.withValues(alpha: 0.4)
              : AppTheme.borderDark,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Totale Budget',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              if (overCount > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.expenseColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$overCount superati',
                    style: const TextStyle(
                      color: AppTheme.expenseColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TmProgressBar(
            value: percent,
            color: isOver ? AppTheme.expenseColor : AppTheme.incomeColor,
            height: 10,
            borderRadius: 8,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Speso: ${Formatters.formatCurrency(totalSpent)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                'Budget: ${Formatters.formatCurrency(totalBudget)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddBudgetButton extends ConsumerWidget {
  final List availableCategories;
  final DateTime selectedDate;

  const _AddBudgetButton({
    required this.availableCategories,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: IconButton(
        onPressed: availableCategories.isEmpty
            ? null
            : () => _showAddBudgetDialog(context, ref),
        icon: const Icon(Icons.add_rounded, color: AppTheme.primaryColor),
      ),
    );
  }

  void _showAddBudgetDialog(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    String? selectedCatId =
        availableCategories.isNotEmpty ? availableCategories.first.id : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                  20, 24, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TmBottomSheetHandle(),
                  const SizedBox(height: 20),
                  Text('Nuovo Budget',
                      style: Theme.of(ctx).textTheme.titleLarge),
                  const SizedBox(height: 20),
                  // Categoria
                  DropdownButtonFormField<String>(
                    initialValue: selectedCatId,
                    dropdownColor: AppTheme.cardDarkAlt,
                    decoration: const InputDecoration(labelText: 'Categoria'),
                    items: availableCategories.map<DropdownMenuItem<String>>((c) {
                      return DropdownMenuItem(
                        value: c.id,
                        child: Row(
                          children: [
                            Icon(
                              IconData(c.iconCodePoint,
                                  fontFamily: 'MaterialIcons'),
                              color: Color(c.colorValue),
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Text(c.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (v) => setSheetState(() => selectedCatId = v),
                  ),
                  const SizedBox(height: 16),
                  // Importo
                  TextFormField(
                    controller: amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+[.,]?\d{0,2}')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Limite mensile',
                      prefixText: '€ ',
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        final amount = double.tryParse(
                            amountController.text.replaceAll(',', '.'));
                        if (amount == null ||
                            amount <= 0 ||
                            selectedCatId == null) {
                          return;
                        }

                        ref.read(allBudgetsProvider.notifier).add(BudgetModel(
                              id: const Uuid().v4(),
                              categoryId: selectedCatId!,
                              limit: amount,
                              month: selectedDate.month,
                              year: selectedDate.year,
                            ));
                        Navigator.pop(ctx);
                      },
                      child: const Text('Crea Budget'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}




