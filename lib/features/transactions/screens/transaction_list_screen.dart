import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/widgets/transaction_tile.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/local/hive_service.dart';

class TransactionListScreen extends ConsumerStatefulWidget {
  const TransactionListScreen({super.key});

  @override
  ConsumerState<TransactionListScreen> createState() =>
      _TransactionListScreenState();
}

class _TransactionListScreenState extends ConsumerState<TransactionListScreen> {
  TransactionType? _filterType;
  String? _filterCategoryId;
  final _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final monthlyTransactions = ref.watch(monthlyTransactionsProvider);

    // Applica filtri
    var filtered = monthlyTransactions;

    // Ricerca testuale
    final query = _searchController.text.toLowerCase().trim();
    if (query.isNotEmpty) {
      filtered = filtered.where((t) {
        return t.description.toLowerCase().contains(query) ||
            (t.productName?.toLowerCase().contains(query) ?? false) ||
            t.categoryId.toLowerCase().contains(query) ||
            t.amount.toString().contains(query);
      }).toList();
    }

    if (_filterType != null) {
      filtered = filtered.where((t) => t.type == _filterType).toList();
    }
    if (_filterCategoryId != null) {
      filtered =
          filtered.where((t) => t.categoryId == _filterCategoryId).toList();
    }

    return SafeArea(
      child: ResponsiveContent(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  ResponsiveLayout.horizontalPadding(context), 16,
                  ResponsiveLayout.horizontalPadding(context), 0,
                ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Movimenti',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.cardDark,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.borderDark),
                        ),
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              _showSearch = !_showSearch;
                              if (!_showSearch) {
                                _searchController.clear();
                              }
                            });
                          },
                          icon: Icon(
                            _showSearch
                                ? Icons.close_rounded
                                : Icons.search_rounded,
                            color: _showSearch
                                ? AppTheme.expenseColor
                                : AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Formatters.formatMonthYear(selectedDate),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.white54),
                  ),

                  // Barra di ricerca
                  if (_showSearch) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Cerca per nome, prodotto, importo...',
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: Colors.white38),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                                icon: const Icon(Icons.clear_rounded,
                                    color: Colors.white38, size: 20),
                              )
                            : null,
                        filled: true,
                        fillColor: AppTheme.cardDark,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              const BorderSide(color: AppTheme.borderDark),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              const BorderSide(color: AppTheme.borderDark),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                              color: AppTheme.primaryColor, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Month nav
                  _MonthNavBar(
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

                  const SizedBox(height: 16),

                  // Filtri tipo
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'Tutti',
                          isSelected: _filterType == null,
                          onTap: () => setState(() => _filterType = null),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Spese',
                          isSelected: _filterType == TransactionType.expense,
                          color: AppTheme.expenseColor,
                          onTap: () => setState(() =>
                              _filterType = _filterType == TransactionType.expense
                                  ? null
                                  : TransactionType.expense),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Entrate',
                          isSelected: _filterType == TransactionType.income,
                          color: AppTheme.incomeColor,
                          onTap: () => setState(() =>
                              _filterType = _filterType == TransactionType.income
                                  ? null
                                  : TransactionType.income),
                        ),
                        const SizedBox(width: 16),
                        // Filtri categoria
                        ...HiveService.defaultCategories.map((cat) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _FilterChip(
                              label: cat.name,
                              isSelected: _filterCategoryId == cat.id,
                              color: Color(cat.colorValue),
                              onTap: () => setState(() =>
                                  _filterCategoryId =
                                      _filterCategoryId == cat.id
                                          ? null
                                          : cat.id),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Riepilogo
                  _QuickSummary(transactions: filtered),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Lista transazioni
          if (filtered.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.search_off_rounded,
                          size: 56,
                          color: Colors.white.withValues(alpha: 0.12)),
                      const SizedBox(height: 16),
                      Text(
                        'Nessun movimento trovato',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.white38),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveLayout.horizontalPadding(context),
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final transaction = filtered[index];
                    return TransactionTile(
                      transaction: transaction,
                      onDismissed: () {
                        ref
                            .read(allTransactionsProvider.notifier)
                            .delete(transaction.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Movimento eliminato'),
                            backgroundColor: AppTheme.cardDark,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            action: SnackBarAction(
                              label: 'Annulla',
                              textColor: AppTheme.primaryColor,
                              onPressed: () {
                                ref
                                    .read(allTransactionsProvider.notifier)
                                    .add(transaction);
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                  childCount: filtered.length,
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

class _MonthNavBar extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _MonthNavBar({
    required this.selectedDate,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left_rounded,
                color: Colors.white70, size: 22),
          ),
          Text(
            Formatters.formatMonthYear(selectedDate),
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right_rounded,
                color: Colors.white70, size: 22),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppTheme.primaryColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withValues(alpha: 0.2)
              : AppTheme.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? chipColor : AppTheme.borderDark,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? chipColor : Colors.white54,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _QuickSummary extends StatelessWidget {
  final List<TransactionModel> transactions;

  const _QuickSummary({required this.transactions});

  @override
  Widget build(BuildContext context) {
    double income = 0;
    double expense = 0;
    for (final t in transactions) {
      if (t.type == TransactionType.income) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }

    return Row(
      children: [
        Expanded(
          child: _SummaryChip(
            label: 'Entrate',
            amount: income,
            color: AppTheme.incomeColor,
            icon: Icons.arrow_downward_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryChip(
            label: 'Uscite',
            amount: expense,
            color: AppTheme.expenseColor,
            icon: Icons.arrow_upward_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryChip(
            label: 'Saldo',
            amount: income - expense,
            color: (income - expense) >= 0
                ? AppTheme.incomeColor
                : AppTheme.expenseColor,
            icon: Icons.account_balance_wallet_rounded,
          ),
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const _SummaryChip({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.white54, fontSize: 11),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              Formatters.formatCompact(amount),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


