import '../models/savings_goal_model.dart';
import '../local/hive_service.dart';

class SavingsRepository {
  List<SavingsGoalModel> getAll() {
    final goals = HiveService.savingsBox.values.toList();
    goals.sort((a, b) => a.deadline.compareTo(b.deadline));
    return goals;
  }

  Future<void> add(SavingsGoalModel goal) async {
    await HiveService.savingsBox.put(goal.id, goal);
  }

  Future<void> update(SavingsGoalModel goal) async {
    await HiveService.savingsBox.put(goal.id, goal);
  }

  Future<void> addAmount(String id, double amount) async {
    final goal = HiveService.savingsBox.get(id);
    if (goal != null) {
      final updated = goal.copyWith(currentAmount: goal.currentAmount + amount);
      await HiveService.savingsBox.put(id, updated);
    }
  }

  Future<void> delete(String id) async {
    await HiveService.savingsBox.delete(id);
  }
}

