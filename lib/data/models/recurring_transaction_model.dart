import 'package:hive/hive.dart';

class RecurringTransactionModel {
  final String id;
  final double amount;
  final int type; // 0 = income, 1 = expense
  final String categoryId;
  final String description;
  final String? productName;
  final int dayOfMonth; // 1-28 giorno del mese in cui si ripete
  final bool isActive;

  RecurringTransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.description,
    this.productName,
    required this.dayOfMonth,
    this.isActive = true,
  });
}

class RecurringTransactionModelAdapter extends TypeAdapter<RecurringTransactionModel> {
  @override
  final int typeId = 3;

  @override
  RecurringTransactionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return RecurringTransactionModel(
      id: fields[0] as String,
      amount: fields[1] as double,
      type: fields[2] as int,
      categoryId: fields[3] as String,
      description: fields[4] as String,
      productName: fields[5] as String?,
      dayOfMonth: fields[6] as int,
      isActive: fields[7] as bool? ?? true,
    );
  }

  @override
  void write(BinaryWriter writer, RecurringTransactionModel obj) {
    writer.writeByte(8);
    writer.writeByte(0); writer.write(obj.id);
    writer.writeByte(1); writer.write(obj.amount);
    writer.writeByte(2); writer.write(obj.type);
    writer.writeByte(3); writer.write(obj.categoryId);
    writer.writeByte(4); writer.write(obj.description);
    writer.writeByte(5); writer.write(obj.productName);
    writer.writeByte(6); writer.write(obj.dayOfMonth);
    writer.writeByte(7); writer.write(obj.isActive);
  }
}

