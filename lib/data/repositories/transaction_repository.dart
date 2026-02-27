import 'package:hive/hive.dart';
import '../models/transaction_model.dart';
import '../local/hive_service.dart';

class TransactionRepository {
  Box<TransactionModel> get _box => HiveService.transactionBox;

  List<TransactionModel> getAll() {
    final transactions = _box.values.toList();
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  List<TransactionModel> getByMonth(int year, int month) {
    return getAll()
        .where((t) => t.date.year == year && t.date.month == month)
        .toList();
  }

  List<TransactionModel> getByType(TransactionType type) {
    return getAll().where((t) => t.type == type).toList();
  }

  List<TransactionModel> getByCategory(String categoryId) {
    return getAll().where((t) => t.categoryId == categoryId).toList();
  }

  Future<void> add(TransactionModel transaction) async {
    await _box.put(transaction.id, transaction);
  }

  Future<void> update(TransactionModel transaction) async {
    await _box.put(transaction.id, transaction);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  List<TransactionModel> getRecent({int limit = 5}) {
    final all = getAll();
    return all.take(limit).toList();
  }
}

