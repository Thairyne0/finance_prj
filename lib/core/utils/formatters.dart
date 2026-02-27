import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _currencyFormat = NumberFormat.currency(
    locale: 'it_IT',
    symbol: '€',
    decimalDigits: 2,
  );

  static final _dateFormat = DateFormat('dd MMM yyyy', 'it_IT');
  static final _monthYearFormat = DateFormat('MMMM yyyy', 'it_IT');
  static final _shortMonthFormat = DateFormat('MMM', 'it_IT');
  static final _dayMonthFormat = DateFormat('dd/MM', 'it_IT');

  static String formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }

  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  static String formatMonthYear(DateTime date) {
    final formatted = _monthYearFormat.format(date);
    return '${formatted[0].toUpperCase()}${formatted.substring(1)}';
  }

  static String formatShortMonth(DateTime date) {
    final formatted = _shortMonthFormat.format(date);
    return '${formatted[0].toUpperCase()}${formatted.substring(1)}';
  }

  static String formatDayMonth(DateTime date) {
    return _dayMonthFormat.format(date);
  }

  static String formatCompact(double amount) {
    if (amount.abs() >= 1000000) {
      return '€${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount.abs() >= 1000) {
      return '€${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '€${amount.toStringAsFixed(0)}';
  }
}

