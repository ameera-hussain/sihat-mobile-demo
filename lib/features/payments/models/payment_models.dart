 enum TransactionStatus { successful, pending, cancelled }

class Transaction {
  final String title;
  final double amount;
  final DateTime date;
  final TransactionStatus status;

  Transaction({
    required this.title,
    required this.amount,
    required this.date,
    required this.status,
  });
}