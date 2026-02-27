import '../models/budget_model.dart';
import '../local/hive_service.dart';

class BudgetRepository {
  List<BudgetModel> getAll() {
    return HiveService.budgetBox.values.toList();
  }

  List<BudgetModel> getByMonth(int year, int month) {
    return getAll().where((b) => b.year == year && b.month == month).toList();
  }

  BudgetModel? getByCategory(String categoryId, int year, int month) {
    final all = getByMonth(year, month);
    final matches = all.where((b) => b.categoryId == categoryId);
    return matches.isEmpty ? null : matches.first;
  }

  Future<void> add(BudgetModel budget) async {
    await HiveService.budgetBox.put(budget.id, budget);
  }

  Future<void> delete(String id) async {
    await HiveService.budgetBox.delete(id);
  }

  Future<void> deleteAll() async {
    await HiveService.budgetBox.clear();
  }
}

