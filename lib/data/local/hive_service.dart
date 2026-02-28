import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/budget_model.dart';
import '../models/recurring_transaction_model.dart';
import '../models/savings_goal_model.dart';

class HiveService {
  static const String transactionBoxName = 'transactions';
  static const String budgetBoxName = 'budgets';
  static const String recurringBoxName = 'recurring';
  static const String savingsBoxName = 'savings_goals';
  static const String settingsBoxName = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TransactionTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(PaymentMethodAdapter());
    }
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TransactionModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(BudgetModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(RecurringTransactionModelAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(SavingsGoalModelAdapter());
    }

    await _openBoxSafe<TransactionModel>(transactionBoxName);
    await _openBoxSafe<BudgetModel>(budgetBoxName);
    await _openBoxSafe<RecurringTransactionModel>(recurringBoxName);
    await _openBoxSafe<SavingsGoalModel>(savingsBoxName);
    await _openBoxSafe<dynamic>(settingsBoxName);
  }

  static Future<void> _openBoxSafe<T>(String name) async {
    try {
      await Hive.openBox<T>(name);
    } catch (e) {
      debugPrint('Hive box $name corrupted, recreating: $e');
      await Hive.deleteBoxFromDisk(name);
      await Hive.openBox<T>(name);
    }
  }

  static Box<TransactionModel> get transactionBox =>
      Hive.box<TransactionModel>(transactionBoxName);

  static Box<BudgetModel> get budgetBox =>
      Hive.box<BudgetModel>(budgetBoxName);

  static Box<RecurringTransactionModel> get recurringBox =>
      Hive.box<RecurringTransactionModel>(recurringBoxName);

  static Box<SavingsGoalModel> get savingsBox =>
      Hive.box<SavingsGoalModel>(savingsBoxName);

  static Box<dynamic> get settingsBox =>
      Hive.box<dynamic>(settingsBoxName);

  // Valuta corrente
  static String get currentCurrency =>
      settingsBox.get('currency', defaultValue: '€') as String;

  static Future<void> setCurrency(String symbol) async =>
      settingsBox.put('currency', symbol);

  static List<CategoryModel> get defaultCategories => [
        CategoryModel(
          id: 'food',
          name: 'Cibo',
          iconCodePoint: Icons.restaurant.codePoint,
          colorValue: Colors.orange.toARGB32(),
        ),
        CategoryModel(
          id: 'transport',
          name: 'Trasporto',
          iconCodePoint: Icons.directions_car.codePoint,
          colorValue: Colors.blue.toARGB32(),
        ),
        CategoryModel(
          id: 'shopping',
          name: 'Shopping',
          iconCodePoint: Icons.shopping_bag.codePoint,
          colorValue: Colors.pink.toARGB32(),
        ),
        CategoryModel(
          id: 'bills',
          name: 'Bollette',
          iconCodePoint: Icons.receipt_long.codePoint,
          colorValue: Colors.red.toARGB32(),
        ),
        CategoryModel(
          id: 'entertainment',
          name: 'Svago',
          iconCodePoint: Icons.movie.codePoint,
          colorValue: Colors.purple.toARGB32(),
        ),
        CategoryModel(
          id: 'health',
          name: 'Salute',
          iconCodePoint: Icons.local_hospital.codePoint,
          colorValue: Colors.green.toARGB32(),
        ),
        CategoryModel(
          id: 'education',
          name: 'Istruzione',
          iconCodePoint: Icons.school.codePoint,
          colorValue: Colors.indigo.toARGB32(),
        ),
        CategoryModel(
          id: 'salary',
          name: 'Stipendio',
          iconCodePoint: Icons.account_balance_wallet.codePoint,
          colorValue: Colors.teal.toARGB32(),
        ),
        CategoryModel(
          id: 'freelance',
          name: 'Freelance',
          iconCodePoint: Icons.laptop_mac.codePoint,
          colorValue: Colors.cyan.toARGB32(),
        ),
        CategoryModel(
          id: 'other_income',
          name: 'Altre Entrate',
          iconCodePoint: Icons.attach_money.codePoint,
          colorValue: Colors.lightGreen.toARGB32(),
        ),
        CategoryModel(
          id: 'other',
          name: 'Altro',
          iconCodePoint: Icons.more_horiz.codePoint,
          colorValue: Colors.grey.toARGB32(),
        ),
      ];

  static List<CategoryModel> get expenseCategories =>
      defaultCategories.where((c) =>
          !['salary', 'freelance', 'other_income'].contains(c.id)).toList();

  static List<CategoryModel> get incomeCategories =>
      defaultCategories.where((c) =>
          ['salary', 'freelance', 'other_income'].contains(c.id)).toList();

  static CategoryModel getCategoryById(String id) {
    return defaultCategories.firstWhere(
      (c) => c.id == id,
      orElse: () => defaultCategories.last,
    );
  }
}

