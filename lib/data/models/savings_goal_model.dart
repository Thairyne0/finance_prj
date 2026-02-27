import 'package:hive/hive.dart';

class SavingsGoalModel {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;
  final int iconCodePoint;
  final int colorValue;
  final DateTime createdAt;

  SavingsGoalModel({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    required this.iconCodePoint,
    required this.colorValue,
    required this.createdAt,
  });

  double get progress => targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0;
  double get remaining => (targetAmount - currentAmount).clamp(0.0, targetAmount);
  bool get isCompleted => currentAmount >= targetAmount;

  int get daysLeft {
    final diff = deadline.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  double get dailySavingsNeeded {
    if (daysLeft <= 0 || isCompleted) return 0;
    return remaining / daysLeft;
  }

  SavingsGoalModel copyWith({double? currentAmount}) {
    return SavingsGoalModel(
      id: id,
      name: name,
      targetAmount: targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline,
      iconCodePoint: iconCodePoint,
      colorValue: colorValue,
      createdAt: createdAt,
    );
  }
}

class SavingsGoalModelAdapter extends TypeAdapter<SavingsGoalModel> {
  @override
  final int typeId = 4;

  @override
  SavingsGoalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return SavingsGoalModel(
      id: fields[0] as String,
      name: fields[1] as String,
      targetAmount: fields[2] as double,
      currentAmount: fields[3] as double,
      deadline: fields[4] as DateTime,
      iconCodePoint: fields[5] as int,
      colorValue: fields[6] as int,
      createdAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SavingsGoalModel obj) {
    writer.writeByte(8);
    writer.writeByte(0); writer.write(obj.id);
    writer.writeByte(1); writer.write(obj.name);
    writer.writeByte(2); writer.write(obj.targetAmount);
    writer.writeByte(3); writer.write(obj.currentAmount);
    writer.writeByte(4); writer.write(obj.deadline);
    writer.writeByte(5); writer.write(obj.iconCodePoint);
    writer.writeByte(6); writer.write(obj.colorValue);
    writer.writeByte(7); writer.write(obj.createdAt);
  }
}

