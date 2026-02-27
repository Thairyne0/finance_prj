import 'package:flutter/material.dart';
import '../../data/models/transaction_model.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'FinanceApp';
  static const String currencySymbol = '€';
  static const String currencyLocale = 'it_IT';

  static IconData transactionTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return Icons.arrow_downward_rounded;
      case TransactionType.expense:
        return Icons.arrow_upward_rounded;
    }
  }
}

