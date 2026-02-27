import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/transaction_model.dart';
import '../../data/local/hive_service.dart';

class ExportService {
  /// Esporta le transazioni in CSV e condividi
  static Future<void> exportToCsv(List<TransactionModel> transactions) async {
    final rows = <List<dynamic>>[
      ['Data', 'Tipo', 'Categoria', 'Descrizione', 'Prodotto', 'Importo'],
    ];

    for (final t in transactions) {
      final cat = HiveService.getCategoryById(t.categoryId);
      rows.add([
        '${t.date.day}/${t.date.month}/${t.date.year}',
        t.type == TransactionType.income ? 'Entrata' : 'Spesa',
        cat.name,
        t.description,
        t.productName ?? '',
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

  /// Importa backup da JSON string
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
            date: DateTime.parse(t['date']),
            createdAt: DateTime.parse(t['createdAt']),
          );
          await HiveService.transactionBox.put(transaction.id, transaction);
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



