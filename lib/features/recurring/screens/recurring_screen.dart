import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../config/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/recurring_transaction_model.dart';
import '../../../data/local/hive_service.dart';
import '../../../widget/tm_widgets.dart';

class RecurringScreen extends ConsumerWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recurring = ref.watch(allRecurringProvider);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldDark,
      appBar: AppBar(
        title: const Text('Transazioni Ricorrenti'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: recurring.isEmpty
                ? const TmEmptyState(
                    icon: Icons.repeat_rounded,
                    title: 'Nessuna transazione ricorrente',
                    subtitle: 'Aggiungi bollette, abbonamenti, stipendio...',
                  )
            : ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                itemCount: recurring.length,
                itemBuilder: (context, index) {
                  final item = recurring[index];
                  final cat = HiveService.getCategoryById(item.categoryId);
                  final isExpense = item.type == 1;

                  return Dismissible(
                    key: Key(item.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) {
                      ref.read(allRecurringProvider.notifier).delete(item.id);
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      decoration: BoxDecoration(
                        color: AppTheme.expenseColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.delete_outline,
                          color: AppTheme.expenseColor),
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: item.isActive
                              ? AppTheme.borderDark
                              : AppTheme.borderDark.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Color(cat.colorValue)
                                  .withValues(alpha: item.isActive ? 0.15 : 0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              IconData(cat.iconCodePoint,
                                  fontFamily: 'MaterialIcons'),
                              color: Color(cat.colorValue).withValues(
                                  alpha: item.isActive ? 1.0 : 0.3),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.description.isEmpty
                                      ? cat.name
                                      : item.description,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: item.isActive
                                            ? Colors.white
                                            : Colors.white38,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Ogni ${item.dayOfMonth} del mese',
                                  style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${isExpense ? '-' : '+'}${Formatters.formatCurrency(item.amount)}',
                                style: TextStyle(
                                  color: isExpense
                                      ? AppTheme.expenseColor
                                      : AppTheme.incomeColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap: () {
                                  ref
                                      .read(allRecurringProvider.notifier)
                                      .toggleActive(item.id);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: item.isActive
                                        ? AppTheme.incomeColor
                                            .withValues(alpha: 0.15)
                                        : Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item.isActive ? 'Attivo' : 'Pausa',
                                    style: TextStyle(
                                      color: item.isActive
                                          ? AppTheme.incomeColor
                                          : Colors.white30,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRecurring(context, ref),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _showAddRecurring(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    final descController = TextEditingController();
    int type = 1; // expense default
    String catId = HiveService.expenseCategories.first.id;
    int day = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final categories =
              type == 1 ? HiveService.expenseCategories : HiveService.incomeCategories;
          if (!categories.any((c) => c.id == catId)) {
            catId = categories.first.id;
          }

          return Padding(
            padding: EdgeInsets.fromLTRB(
                20, 24, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TmBottomSheetHandle(),
                  const SizedBox(height: 20),
                  Text('Nuova Ricorrente',
                      style: Theme.of(ctx).textTheme.titleLarge),
                  const SizedBox(height: 20),
                  // Tipo
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 1, label: Text('Spesa')),
                        ButtonSegment(value: 0, label: Text('Entrata')),
                      ],
                      selected: {type},
                      onSelectionChanged: (s) =>
                          setSheetState(() => type = s.first),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+[.,]?\d{0,2}')),
                    ],
                    decoration: const InputDecoration(
                        labelText: 'Importo', prefixText: '€ '),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration:
                        const InputDecoration(labelText: 'Descrizione'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: catId,
                    dropdownColor: AppTheme.cardDarkAlt,
                    decoration: const InputDecoration(labelText: 'Categoria'),
                    items: categories.map((c) {
                      return DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      );
                    }).toList(),
                    onChanged: (v) => setSheetState(() => catId = v ?? catId),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: day,
                    dropdownColor: AppTheme.cardDarkAlt,
                    decoration:
                        const InputDecoration(labelText: 'Giorno del mese'),
                    items: List.generate(28, (i) => i + 1)
                        .map((d) =>
                            DropdownMenuItem(value: d, child: Text('$d')))
                        .toList(),
                    onChanged: (v) => setSheetState(() => day = v ?? 1),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        final amount = double.tryParse(
                            amountController.text.replaceAll(',', '.'));
                        if (amount == null || amount <= 0) return;

                        ref.read(allRecurringProvider.notifier).add(
                              RecurringTransactionModel(
                                id: const Uuid().v4(),
                                amount: amount,
                                type: type,
                                categoryId: catId,
                                description: descController.text.trim(),
                                dayOfMonth: day,
                              ),
                            );
                        Navigator.pop(ctx);
                      },
                      child: const Text('Aggiungi'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}





