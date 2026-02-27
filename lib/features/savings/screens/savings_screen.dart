import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../config/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/savings_goal_model.dart';

class SavingsScreen extends ConsumerWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(allSavingsProvider);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldDark,
      appBar: AppBar(
        title: const Text('Obiettivi di Risparmio'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: goals.isEmpty
            ? _EmptyState()
            : ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  final goal = goals[index];
                  return _GoalCard(goal: goal);
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoal(context, ref),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _showAddGoal(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    DateTime deadline = DateTime.now().add(const Duration(days: 90));
    int selectedIcon = Icons.savings_rounded.codePoint;
    int selectedColor = AppTheme.primaryColor.toARGB32();

    final iconOptions = [
      Icons.savings_rounded,
      Icons.flight_rounded,
      Icons.home_rounded,
      Icons.directions_car_rounded,
      Icons.phone_iphone_rounded,
      Icons.laptop_mac_rounded,
      Icons.school_rounded,
      Icons.medical_services_rounded,
      Icons.celebration_rounded,
      Icons.diamond_rounded,
    ];

    final colorOptions = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.incomeColor,
      Colors.orange,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
      Colors.cyan,
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
                20, 24, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Nuovo Obiettivo',
                      style: Theme.of(ctx).textTheme.titleLarge),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: nameController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration:
                        const InputDecoration(labelText: 'Nome obiettivo'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: targetController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+[.,]?\d{0,2}')),
                    ],
                    decoration: const InputDecoration(
                        labelText: 'Importo target', prefixText: '€ '),
                  ),
                  const SizedBox(height: 16),
                  // Scadenza
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: deadline,
                        firstDate: DateTime.now(),
                        lastDate:
                            DateTime.now().add(const Duration(days: 3650)),
                        builder: (c, child) => Theme(
                          data: Theme.of(c).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: AppTheme.primaryColor,
                              surface: AppTheme.cardDark,
                              onSurface: Colors.white,
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        setSheetState(() => deadline = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration:
                          const InputDecoration(labelText: 'Scadenza'),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              size: 18, color: AppTheme.primaryColor),
                          const SizedBox(width: 10),
                          Text(Formatters.formatDate(deadline)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Icona
                  Text('Icona', style: Theme.of(ctx).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: iconOptions.map((icon) {
                      final isSelected = icon.codePoint == selectedIcon;
                      return GestureDetector(
                        onTap: () =>
                            setSheetState(() => selectedIcon = icon.codePoint),
                        child: Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryColor.withValues(alpha: 0.2)
                                : AppTheme.surfaceDark,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : AppTheme.borderDark,
                            ),
                          ),
                          child: Icon(icon,
                              size: 20,
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : Colors.white54),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  // Colore
                  Text('Colore', style: Theme.of(ctx).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: colorOptions.map((color) {
                      final isSelected = color.toARGB32() == selectedColor;
                      return GestureDetector(
                        onTap: () =>
                            setSheetState(() => selectedColor = color.toARGB32()),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(10),
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 2.5)
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        final target = double.tryParse(
                            targetController.text.replaceAll(',', '.'));
                        if (target == null ||
                            target <= 0 ||
                            nameController.text.trim().isEmpty) return;

                        ref.read(allSavingsProvider.notifier).add(
                              SavingsGoalModel(
                                id: const Uuid().v4(),
                                name: nameController.text.trim(),
                                targetAmount: target,
                                currentAmount: 0,
                                deadline: deadline,
                                iconCodePoint: selectedIcon,
                                colorValue: selectedColor,
                                createdAt: DateTime.now(),
                              ),
                            );
                        Navigator.pop(ctx);
                      },
                      child: const Text('Crea Obiettivo'),
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

class _GoalCard extends ConsumerWidget {
  final SavingsGoalModel goal;
  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Color(goal.colorValue);

    return Dismissible(
      key: Key(goal.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => ref.read(allSavingsProvider.notifier).delete(goal.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppTheme.expenseColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline, color: AppTheme.expenseColor),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: goal.isCompleted
                ? AppTheme.incomeColor.withValues(alpha: 0.4)
                : AppTheme.borderDark,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    IconData(goal.iconCodePoint, fontFamily: 'MaterialIcons'),
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(goal.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600)),
                          ),
                          if (goal.isCompleted)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.incomeColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('✓ Raggiunto',
                                  style: TextStyle(
                                      color: AppTheme.incomeColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        goal.isCompleted
                            ? 'Obiettivo completato!'
                            : '${goal.daysLeft} giorni rimanenti • ${Formatters.formatCurrency(goal.dailySavingsNeeded)}/giorno',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.white38),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: goal.progress,
                minHeight: 8,
                backgroundColor: AppTheme.borderDark,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${Formatters.formatCurrency(goal.currentAmount)} / ${Formatters.formatCurrency(goal.targetAmount)}',
                  style:
                      const TextStyle(color: Colors.white54, fontSize: 13),
                ),
                Text(
                  '${(goal.progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 14),
                ),
              ],
            ),
            if (!goal.isCompleted) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: OutlinedButton.icon(
                  onPressed: () => _showAddAmountDialog(context, ref),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: color.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: Icon(Icons.add_rounded, size: 18, color: color),
                  label: Text('Aggiungi importo',
                      style: TextStyle(color: color, fontSize: 13)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddAmountDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Aggiungi al risparmio'),
        content: TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+[.,]?\d{0,2}')),
          ],
          decoration:
              const InputDecoration(hintText: 'Importo', prefixText: '€ '),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annulla',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              final amount =
                  double.tryParse(controller.text.replaceAll(',', '.'));
              if (amount != null && amount > 0) {
                ref
                    .read(allSavingsProvider.notifier)
                    .addAmount(goal.id, amount);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Aggiungi',
                style: TextStyle(color: AppTheme.primaryColor)),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.savings_outlined,
              size: 56, color: Colors.white.withValues(alpha: 0.12)),
          const SizedBox(height: 16),
          Text('Nessun obiettivo di risparmio',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white38)),
          const SizedBox(height: 8),
          Text('Crea un obiettivo per iniziare a risparmiare',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white24)),
        ],
      ),
    );
  }
}



