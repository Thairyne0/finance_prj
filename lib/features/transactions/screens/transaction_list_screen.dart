import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/widgets/transaction_tile.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/local/hive_service.dart';
import '../../../widget/tm_widgets.dart';

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
        child: TmFadeScroll(
          topFadeHeight: 24,
          bottomFadeHeight: 40,
          child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  ResponsiveLayout.horizontalPadding(context),
                  ResponsiveLayout.topPadding(context),
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
                  TmMonthSelector(
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
                        TmFilterChip(
                          label: 'Tutti',
                          isSelected: _filterType == null,
                          onTap: () => setState(() => _filterType = null),
                        ),
                        const SizedBox(width: 8),
                        TmFilterChip(
                          label: 'Spese',
                          isSelected: _filterType == TransactionType.expense,
                          color: AppTheme.expenseColor,
                          onTap: () => setState(() =>
                              _filterType = _filterType == TransactionType.expense
                                  ? null
                                  : TransactionType.expense),
                        ),
                        const SizedBox(width: 8),
                        TmFilterChip(
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
                            child: TmFilterChip(
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
                child: const TmEmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'Nessun movimento trovato',
                  subtitle: '',
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
          child: TmSummaryChip(
            label: 'Entrate',
            amount: income,
            color: AppTheme.incomeColor,
            icon: Icons.arrow_downward_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TmSummaryChip(
            label: 'Uscite',
            amount: expense,
            color: AppTheme.expenseColor,
            icon: Icons.arrow_upward_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TmSummaryChip(
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



