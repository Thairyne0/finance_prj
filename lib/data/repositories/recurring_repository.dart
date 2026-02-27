import '../models/recurring_transaction_model.dart';
import '../local/hive_service.dart';

class RecurringRepository {
  List<RecurringTransactionModel> getAll() {
    return HiveService.recurringBox.values.toList();
  }

  List<RecurringTransactionModel> getActive() {
    return getAll().where((r) => r.isActive).toList();
  }

  Future<void> add(RecurringTransactionModel recurring) async {
    await HiveService.recurringBox.put(recurring.id, recurring);
  }

  Future<void> delete(String id) async {
    await HiveService.recurringBox.delete(id);
  }

  Future<void> toggleActive(String id) async {
    final item = HiveService.recurringBox.get(id);
    if (item != null) {
      final updated = RecurringTransactionModel(
        id: item.id,
        amount: item.amount,
        type: item.type,
        categoryId: item.categoryId,
        description: item.description,
        productName: item.productName,
        dayOfMonth: item.dayOfMonth,
        isActive: !item.isActive,
      );
      await HiveService.recurringBox.put(id, updated);
    }
  }
}

