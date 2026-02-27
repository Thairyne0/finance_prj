import 'package:hive/hive.dart';

class BudgetModel {
  final String id;
  final String categoryId;
  final double limit;
  final int month;
  final int year;

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.limit,
    required this.month,
    required this.year,
  });

  double percentUsed(double spent) => limit > 0 ? (spent / limit).clamp(0.0, 1.5) : 0;
  double remaining(double spent) => limit - spent;
  bool isOverBudget(double spent) => spent > limit;
}

class BudgetModelAdapter extends TypeAdapter<BudgetModel> {
  @override
  final int typeId = 2;

  @override
  BudgetModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return BudgetModel(
      id: fields[0] as String,
      categoryId: fields[1] as String,
      limit: fields[2] as double,
      month: fields[3] as int,
      year: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, BudgetModel obj) {
    writer.writeByte(5);
    writer.writeByte(0); writer.write(obj.id);
    writer.writeByte(1); writer.write(obj.categoryId);
    writer.writeByte(2); writer.write(obj.limit);
    writer.writeByte(3); writer.write(obj.month);
    writer.writeByte(4); writer.write(obj.year);
  }
}

