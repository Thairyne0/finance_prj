class MonthlyReport {
  final int year;
  final int month;
  final double totalIncome;
  final double totalExpense;

  MonthlyReport({
    required this.year,
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
  });

  double get balance => totalIncome - totalExpense;

  double get savingsRate =>
      totalIncome > 0 ? (balance / totalIncome) * 100 : 0;
}

