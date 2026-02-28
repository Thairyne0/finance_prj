import 'package:hive/hive.dart';

enum TransactionType { income, expense }

/// Metodo di pagamento: contanti o conto
enum PaymentMethod { cash, bankAccount }

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 1;

  @override
  TransactionType read(BinaryReader reader) {
    return TransactionType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    writer.writeByte(obj.index);
  }
}

class PaymentMethodAdapter extends TypeAdapter<PaymentMethod> {
  @override
  final int typeId = 5;

  @override
  PaymentMethod read(BinaryReader reader) {
    return PaymentMethod.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, PaymentMethod obj) {
    writer.writeByte(obj.index);
  }
}

class TransactionModel {
  final String id;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final String description;
  final String? productName;
  final DateTime date;
  final DateTime createdAt;
  final PaymentMethod paymentMethod;
  final String? accountName;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.description,
    this.productName,
    required this.date,
    required this.createdAt,
    this.paymentMethod = PaymentMethod.cash,
    this.accountName,
  });

  TransactionModel copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    String? categoryId,
    String? description,
    String? productName,
    DateTime? date,
    DateTime? createdAt,
    PaymentMethod? paymentMethod,
    String? accountName,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      productName: productName ?? this.productName,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      accountName: accountName ?? this.accountName,
    );
  }

  /// Label leggibile per il metodo di pagamento
  String get paymentLabel {
    if (paymentMethod == PaymentMethod.cash) return 'Contanti';
    if (accountName != null && accountName!.isNotEmpty) return accountName!;
    return 'Conto';
  }

  /// Icona per il metodo di pagamento
  int get paymentIconCodePoint {
    return paymentMethod == PaymentMethod.cash
        ? 0xe25a // Icons.payments_rounded
        : 0xef63; // Icons.account_balance_rounded
  }
}

class TransactionModelAdapter extends TypeAdapter<TransactionModel> {
  @override
  final int typeId = 0;

  @override
  TransactionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return TransactionModel(
      id: fields[0] as String,
      amount: fields[1] as double,
      type: fields[2] as TransactionType,
      categoryId: fields[3] as String,
      description: fields[4] as String,
      productName: fields[5] as String?,
      date: fields[6] as DateTime,
      createdAt: fields[7] as DateTime,
      paymentMethod: fields[8] as PaymentMethod? ?? PaymentMethod.cash,
      accountName: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionModel obj) {
    writer.writeByte(10);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.amount);
    writer.writeByte(2);
    writer.write(obj.type);
    writer.writeByte(3);
    writer.write(obj.categoryId);
    writer.writeByte(4);
    writer.write(obj.description);
    writer.writeByte(5);
    writer.write(obj.productName);
    writer.writeByte(6);
    writer.write(obj.date);
    writer.writeByte(7);
    writer.write(obj.createdAt);
    writer.writeByte(8);
    writer.write(obj.paymentMethod);
    writer.writeByte(9);
    writer.write(obj.accountName);
  }
}

