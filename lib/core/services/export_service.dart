import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/budget_model.dart';
import '../../data/models/recurring_transaction_model.dart';
import '../../data/models/savings_goal_model.dart';
import '../../data/local/hive_service.dart';

class ExportService {
  /// Esporta le transazioni in CSV e condividi
  static Future<void> exportToCsv(List<TransactionModel> transactions) async {
    final rows = <List<dynamic>>[
      ['Data', 'Tipo', 'Categoria', 'Descrizione', 'Prodotto', 'Metodo', 'Conto', 'Importo'],
    ];

    for (final t in transactions) {
      final cat = HiveService.getCategoryById(t.categoryId);
      rows.add([
        '${t.date.day}/${t.date.month}/${t.date.year}',
        t.type == TransactionType.income ? 'Entrata' : 'Spesa',
        cat.name,
        t.description,
        t.productName ?? '',
        t.paymentLabel,
        t.accountName ?? '',
        t.type == TransactionType.expense ? '-${t.amount}' : t.amount,
      ]);
    }

    final csvData = const ListToCsvConverter().convert(rows);
    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/finanze_export_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csvData);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Esportazione FinanceApp',
    );
  }

  /// Esporta backup completo in JSON
  static Future<void> exportBackupJson() async {
    final transactions = HiveService.transactionBox.values.toList();
    final budgets = HiveService.budgetBox.values.toList();
    final recurring = HiveService.recurringBox.values.toList();
    final savings = HiveService.savingsBox.values.toList();

    final backup = {
      'version': 1,
      'exportDate': DateTime.now().toIso8601String(),
      'transactions': transactions.map((t) => {
            'id': t.id,
            'amount': t.amount,
            'type': t.type.index,
            'categoryId': t.categoryId,
            'description': t.description,
            'productName': t.productName,
            'paymentMethod': t.paymentMethod.index,
            'accountName': t.accountName,
            'date': t.date.toIso8601String(),
            'createdAt': t.createdAt.toIso8601String(),
          }).toList(),
      'budgets': budgets.map((b) => {
            'id': b.id,
            'categoryId': b.categoryId,
            'limit': b.limit,
            'month': b.month,
            'year': b.year,
          }).toList(),
      'recurring': recurring.map((r) => {
            'id': r.id,
            'amount': r.amount,
            'type': r.type,
            'categoryId': r.categoryId,
            'description': r.description,
            'productName': r.productName,
            'dayOfMonth': r.dayOfMonth,
            'isActive': r.isActive,
          }).toList(),
      'savings': savings.map((s) => {
            'id': s.id,
            'name': s.name,
            'targetAmount': s.targetAmount,
            'currentAmount': s.currentAmount,
            'deadline': s.deadline.toIso8601String(),
            'iconCodePoint': s.iconCodePoint,
            'colorValue': s.colorValue,
            'createdAt': s.createdAt.toIso8601String(),
          }).toList(),
    };

    final jsonStr = const JsonEncoder.withIndent('  ').convert(backup);
    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/financeapp_backup_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(jsonStr);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Backup FinanceApp',
    );
  }

  /// Importa backup completo da JSON string (transazioni, budget, ricorrenti, obiettivi)
  static Future<int> importBackupJson(String jsonStr) async {
    try {
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      int count = 0;

      // Import transactions
      if (data['transactions'] != null) {
        for (final t in data['transactions'] as List) {
          final transaction = TransactionModel(
            id: t['id'],
            amount: (t['amount'] as num).toDouble(),
            type: TransactionType.values[t['type']],
            categoryId: t['categoryId'],
            description: t['description'] ?? '',
            productName: t['productName'],
            paymentMethod: t['paymentMethod'] != null
                ? PaymentMethod.values[t['paymentMethod']]
                : PaymentMethod.cash,
            accountName: t['accountName'],
            date: DateTime.parse(t['date']),
            createdAt: DateTime.parse(t['createdAt']),
          );
          await HiveService.transactionBox.put(transaction.id, transaction);
          count++;
        }
      }

      // Import budgets
      if (data['budgets'] != null) {
        for (final b in data['budgets'] as List) {
          final budget = BudgetModel(
            id: b['id'],
            categoryId: b['categoryId'],
            limit: (b['limit'] as num).toDouble(),
            month: b['month'],
            year: b['year'],
          );
          await HiveService.budgetBox.put(budget.id, budget);
          count++;
        }
      }

      // Import recurring transactions
      if (data['recurring'] != null) {
        for (final r in data['recurring'] as List) {
          final recurring = RecurringTransactionModel(
            id: r['id'],
            amount: (r['amount'] as num).toDouble(),
            type: r['type'],
            categoryId: r['categoryId'],
            description: r['description'] ?? '',
            productName: r['productName'],
            dayOfMonth: r['dayOfMonth'],
            isActive: r['isActive'] ?? true,
          );
          await HiveService.recurringBox.put(recurring.id, recurring);
          count++;
        }
      }

      // Import savings goals
      if (data['savings'] != null) {
        for (final s in data['savings'] as List) {
          final goal = SavingsGoalModel(
            id: s['id'],
            name: s['name'],
            targetAmount: (s['targetAmount'] as num).toDouble(),
            currentAmount: (s['currentAmount'] as num).toDouble(),
            deadline: DateTime.parse(s['deadline']),
            iconCodePoint: s['iconCodePoint'],
            colorValue: s['colorValue'],
            createdAt: DateTime.parse(s['createdAt']),
          );
          await HiveService.savingsBox.put(goal.id, goal);
          count++;
        }
      }

      return count;
    } catch (e) {
      debugPrint('Import error: $e');
      return -1;
    }
  }
}



