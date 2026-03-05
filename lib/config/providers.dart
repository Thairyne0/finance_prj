import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/crypto_service.dart';
import '../core/services/notification_service.dart';
import '../data/local/hive_service.dart';
import '../data/repositories/transaction_repository.dart';
import '../data/repositories/budget_repository.dart';
import '../data/repositories/recurring_repository.dart';
import '../data/repositories/savings_repository.dart';
import '../data/models/transaction_model.dart';
import '../data/models/budget_model.dart';
import '../data/models/recurring_transaction_model.dart';
import '../data/models/savings_goal_model.dart';
import '../data/models/monthly_report.dart';

// ──────────────────────────────────────────
// THEME MODE
// ──────────────────────────────────────────
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? true;
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggle() async {
    final prefs = await SharedPreferences.getInstance();
    if (state == ThemeMode.dark) {
      state = ThemeMode.light;
      await prefs.setBool('isDarkMode', false);
    } else {
      state = ThemeMode.dark;
      await prefs.setBool('isDarkMode', true);
    }
  }

  bool get isDark => state == ThemeMode.dark;
}
// ──────────────────────────────────────────
// REPOSITORIES
// ──────────────────────────────────────────
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository();
});

final recurringRepositoryProvider = Provider<RecurringRepository>((ref) {
  return RecurringRepository();
});

final savingsRepositoryProvider = Provider<SavingsRepository>((ref) {
  return SavingsRepository();
});

// ──────────────────────────────────────────
// TRANSACTIONS
// ──────────────────────────────────────────
final allTransactionsProvider =
    StateNotifierProvider<TransactionListNotifier, List<TransactionModel>>(
        (ref) {
  final repo = ref.read(transactionRepositoryProvider);
  return TransactionListNotifier(repo, ref);
});

class TransactionListNotifier extends StateNotifier<List<TransactionModel>> {
  final TransactionRepository _repo;
  final Ref _ref;

  TransactionListNotifier(this._repo, this._ref) : super([]) {
    refresh();
  }

  void refresh() {
    state = _repo.getAll();
  }

  Future<void> add(TransactionModel transaction) async {
    await _repo.add(transaction);
    refresh();
    // Controlla budget e invia notifiche push se necessario
    if (transaction.type == TransactionType.expense) {
      _checkBudgetNotifications(transaction.categoryId);
    }
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    refresh();
  }

  Future<void> update(TransactionModel transaction) async {
    await _repo.update(transaction);
    refresh();
    if (transaction.type == TransactionType.expense) {
      _checkBudgetNotifications(transaction.categoryId);
    }
  }

  Future<void> deleteAll() async {
    await _repo.deleteAll();
    refresh();
  }

  void _checkBudgetNotifications(String categoryId) {
    try {
      final budgetStatus = _ref.read(budgetStatusProvider);
      final entry = budgetStatus[categoryId];
      if (entry == null) return;

      final percent = entry.budget.limit > 0
          ? entry.spent / entry.budget.limit
          : 0.0;

      if (percent >= 0.8) {
        final cat = HiveService.getCategoryById(categoryId);
        NotificationService.showBudgetAlert(
          categoryName: cat.name,
          percent: percent,
          isOver: percent >= 1.0,
        );
      }
    } catch (e) {
      // Non critico: ignora se i provider non sono pronti
    }
  }
}

// ──────────────────────────────────────────
// FILTERING & SEARCH
// ──────────────────────────────────────────
final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final monthlyTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final all = ref.watch(allTransactionsProvider);
  final selected = ref.watch(selectedDateProvider);
  return all
      .where(
          (t) => t.date.year == selected.year && t.date.month == selected.month)
      .toList();
});

final filteredTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final transactions = ref.watch(monthlyTransactionsProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();

  if (query.isEmpty) return transactions;

  return transactions.where((t) {
    return t.description.toLowerCase().contains(query) ||
        (t.productName?.toLowerCase().contains(query) ?? false) ||
        t.categoryId.toLowerCase().contains(query) ||
        t.amount.toString().contains(query);
  }).toList();
});

final monthlyReportProvider = Provider<MonthlyReport>((ref) {
  final transactions = ref.watch(monthlyTransactionsProvider);
  final selected = ref.watch(selectedDateProvider);

  double income = 0;
  double expense = 0;

  for (final t in transactions) {
    if (t.type == TransactionType.income) {
      income += t.amount;
    } else {
      expense += t.amount;
    }
  }

  return MonthlyReport(
    year: selected.year,
    month: selected.month,
    totalIncome: income,
    totalExpense: expense,
  );
});

final recentTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final all = ref.watch(allTransactionsProvider);
  final sorted = List<TransactionModel>.from(all)
    ..sort((a, b) => b.date.compareTo(a.date));
  return sorted.take(10).toList();
});

// ──────────────────────────────────────────
// PATRIMONIO TOTALE (tutte le transazioni)
// ──────────────────────────────────────────
final totalPatrimonioProvider = Provider<double>((ref) {
  final all = ref.watch(allTransactionsProvider);
  double total = 0;
  for (final t in all) {
    if (t.type == TransactionType.income) {
      total += t.amount;
    } else {
      total -= t.amount;
    }
  }
  return total;
});

final totalIncomeAllTimeProvider = Provider<double>((ref) {
  final all = ref.watch(allTransactionsProvider);
  double total = 0;
  for (final t in all) {
    if (t.type == TransactionType.income) {
      total += t.amount;
    }
  }
  return total;
});

final totalExpenseAllTimeProvider = Provider<double>((ref) {
  final all = ref.watch(allTransactionsProvider);
  double total = 0;
  for (final t in all) {
    if (t.type == TransactionType.expense) {
      total += t.amount;
    }
  }
  return total;
});

// ──────────────────────────────────────────
// CHARTS
// ──────────────────────────────────────────
final lastSixMonthsReportsProvider = Provider<List<MonthlyReport>>((ref) {
  final all = ref.watch(allTransactionsProvider);
  final now = DateTime.now();
  final reports = <MonthlyReport>[];

  for (int i = 5; i >= 0; i--) {
    final month = DateTime(now.year, now.month - i, 1);
    double income = 0;
    double expense = 0;

    for (final t in all) {
      if (t.date.year == month.year && t.date.month == month.month) {
        if (t.type == TransactionType.income) {
          income += t.amount;
        } else {
          expense += t.amount;
        }
      }
    }

    reports.add(MonthlyReport(
      year: month.year,
      month: month.month,
      totalIncome: income,
      totalExpense: expense,
    ));
  }

  return reports;
});

final categorySpendingProvider = Provider<Map<String, double>>((ref) {
  final transactions = ref.watch(monthlyTransactionsProvider);
  final spending = <String, double>{};

  for (final t
      in transactions.where((t) => t.type == TransactionType.expense)) {
    spending[t.categoryId] = (spending[t.categoryId] ?? 0) + t.amount;
  }

  return spending;
});

// ──────────────────────────────────────────
// BUDGETS
// ──────────────────────────────────────────
final allBudgetsProvider =
    StateNotifierProvider<BudgetListNotifier, List<BudgetModel>>((ref) {
  final repo = ref.read(budgetRepositoryProvider);
  return BudgetListNotifier(repo);
});

class BudgetListNotifier extends StateNotifier<List<BudgetModel>> {
  final BudgetRepository _repo;

  BudgetListNotifier(this._repo) : super([]) {
    refresh();
  }

  void refresh() {
    state = _repo.getAll();
  }

  Future<void> add(BudgetModel budget) async {
    await _repo.add(budget);
    refresh();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    refresh();
  }
}

final monthlyBudgetsProvider = Provider<List<BudgetModel>>((ref) {
  final all = ref.watch(allBudgetsProvider);
  final selected = ref.watch(selectedDateProvider);
  return all
      .where((b) => b.year == selected.year && b.month == selected.month)
      .toList();
});

/// Mappa categoryId -> {budget, spent}
final budgetStatusProvider =
    Provider<Map<String, ({BudgetModel budget, double spent})>>((ref) {
  final budgets = ref.watch(monthlyBudgetsProvider);
  final spending = ref.watch(categorySpendingProvider);
  final result = <String, ({BudgetModel budget, double spent})>{};

  for (final b in budgets) {
    result[b.categoryId] = (
      budget: b,
      spent: spending[b.categoryId] ?? 0,
    );
  }

  return result;
});

// ──────────────────────────────────────────
// RECURRING TRANSACTIONS
// ──────────────────────────────────────────
final allRecurringProvider = StateNotifierProvider<RecurringListNotifier,
    List<RecurringTransactionModel>>((ref) {
  final repo = ref.read(recurringRepositoryProvider);
  return RecurringListNotifier(repo);
});

class RecurringListNotifier
    extends StateNotifier<List<RecurringTransactionModel>> {
  final RecurringRepository _repo;

  RecurringListNotifier(this._repo) : super([]) {
    refresh();
  }

  void refresh() {
    state = _repo.getAll();
  }

  Future<void> add(RecurringTransactionModel recurring) async {
    await _repo.add(recurring);
    refresh();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    refresh();
  }

  Future<void> toggleActive(String id) async {
    await _repo.toggleActive(id);
    refresh();
  }
}

/// Lista di alert budget: categorie al >=80% o superate
final budgetAlertsProvider = Provider<List<({String categoryId, double percent, bool isOver})>>((ref) {
  final status = ref.watch(budgetStatusProvider);
  final alerts = <({String categoryId, double percent, bool isOver})>[];
  for (final entry in status.entries) {
    final percent = entry.value.budget.limit > 0
        ? entry.value.spent / entry.value.budget.limit
        : 0.0;
    if (percent >= 0.8) {
      alerts.add((
        categoryId: entry.key,
        percent: percent,
        isOver: entry.value.spent > entry.value.budget.limit,
      ));
    }
  }
  alerts.sort((a, b) => b.percent.compareTo(a.percent));
  return alerts;
});

// ──────────────────────────────────────────
// UPCOMING RECURRING TRANSACTIONS
// ──────────────────────────────────────────

/// Prossime transazioni ricorrenti con giorni mancanti
final upcomingRecurringProvider =
    Provider<List<({RecurringTransactionModel recurring, int daysUntil})>>((ref) {
  final allRecurring = ref.watch(allRecurringProvider);
  final active = allRecurring.where((r) => r.isActive).toList();
  if (active.isEmpty) return [];

  final now = DateTime.now();
  final today = now.day;

  final result = <({RecurringTransactionModel recurring, int daysUntil})>[];

  for (final r in active) {
    int daysUntil;
    if (r.dayOfMonth >= today) {
      // Ancora questo mese
      daysUntil = r.dayOfMonth - today;
    } else {
      // Prossimo mese
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      daysUntil = (daysInMonth - today) + r.dayOfMonth;
    }
    result.add((recurring: r, daysUntil: daysUntil));
  }

  result.sort((a, b) => a.daysUntil.compareTo(b.daysUntil));
  return result.take(5).toList();
});

// ──────────────────────────────────────────
// PATRIMONIO OVER TIME
// ──────────────────────────────────────────

/// Saldo cumulativo mese per mese per il grafico patrimonio nel tempo
final patrimonioOverTimeProvider =
    Provider<List<({DateTime month, double balance})>>((ref) {
  final all = ref.watch(allTransactionsProvider);
  if (all.isEmpty) return [];

  // Raggruppa per anno/mese
  final monthMap = <String, double>{};
  DateTime? earliest;
  for (final t in all) {
    final key = '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}';
    final amount = t.type == TransactionType.income ? t.amount : -t.amount;
    monthMap[key] = (monthMap[key] ?? 0) + amount;
    if (earliest == null || t.date.isBefore(earliest)) {
      earliest = t.date;
    }
  }

  if (earliest == null) return [];

  // Costruisce la lista cumulativa dal mese più vecchio ad oggi
  final now = DateTime.now();
  final result = <({DateTime month, double balance})>[];
  double cumulative = 0;

  var cursor = DateTime(earliest.year, earliest.month, 1);
  while (cursor.isBefore(DateTime(now.year, now.month + 1, 1))) {
    final key = '${cursor.year}-${cursor.month.toString().padLeft(2, '0')}';
    cumulative += (monthMap[key] ?? 0);
    result.add((month: cursor, balance: cumulative));
    cursor = DateTime(cursor.year, cursor.month + 1, 1);
  }

  return result;
});

// ──────────────────────────────────────────
// SAVINGS GOALS
// ──────────────────────────────────────────
final allSavingsProvider =
    StateNotifierProvider<SavingsListNotifier, List<SavingsGoalModel>>((ref) {
  final repo = ref.read(savingsRepositoryProvider);
  return SavingsListNotifier(repo);
});

class SavingsListNotifier extends StateNotifier<List<SavingsGoalModel>> {
  final SavingsRepository _repo;

  SavingsListNotifier(this._repo) : super([]) {
    refresh();
  }

  void refresh() {
    state = _repo.getAll();
  }

  Future<void> add(SavingsGoalModel goal) async {
    await _repo.add(goal);
    refresh();
  }

  Future<void> addAmount(String id, double amount) async {
    await _repo.addAmount(id, amount);
    refresh();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    refresh();
  }
}

// ──────────────────────────────────────────
// CRYPTO
// ──────────────────────────────────────────

/// Prezzo BTC real-time da CoinGecko — refresh ogni 90s, con cache e retry
final bitcoinPriceProvider = FutureProvider<CryptoPrice>((ref) async {
  final price = await CryptoService.fetchBitcoinPrice();
  // Schedula il prossimo refresh dopo 90s
  Future.delayed(const Duration(seconds: 90), () {
    if (ref.state.hasValue) {
      ref.invalidateSelf();
    }
  });
  return price;
});

/// Quantità di BTC posseduta dall'utente (salvata in SharedPreferences)
final userBtcAmountProvider =
    StateNotifierProvider<UserBtcAmountNotifier, double>((ref) {
  return UserBtcAmountNotifier();
});

class UserBtcAmountNotifier extends StateNotifier<double> {
  static const _key = 'user_btc_amount';

  UserBtcAmountNotifier() : super(0.0) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getDouble(_key) ?? 0.0;
  }

  Future<void> set(double amount) async {
    state = amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key, amount);
  }
}

/// Valore portafoglio BTC in EUR
final btcPortfolioValueProvider = Provider<AsyncValue<double>>((ref) {
  final priceAsync = ref.watch(bitcoinPriceProvider);
  final btcAmount = ref.watch(userBtcAmountProvider);
  return priceAsync.whenData((price) => price.priceEur * btcAmount);
});

