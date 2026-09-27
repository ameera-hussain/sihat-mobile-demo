import '../../features/payments/models/payment_models.dart';

class MockTransactions {
  static final List<Transaction> transactions = [
    Transaction(title: 'Consultation', amount: 54.20, date: DateTime(2026, 7, 3), status: TransactionStatus.successful),
    Transaction(title: 'Glucometer', amount: 15.99, date: DateTime(2026, 7, 1), status: TransactionStatus.pending),
    Transaction(title: 'Refund - MRIC Pharmacy', amount: 22.10, date: DateTime(2026, 6, 28), status: TransactionStatus.cancelled),
    Transaction(title: 'MRIC Clinic', amount: 250.00, date: DateTime(2026, 6, 25), status: TransactionStatus.successful),
    Transaction(title: 'Hospital Kuala Lumpur', amount: 550.00, date: DateTime(2026, 6, 10), status: TransactionStatus.successful),
    Transaction(title: 'Eye Examination', amount: 40.00, date: DateTime(2026, 5, 15), status: TransactionStatus.pending),
    Transaction(title: 'Physiotherapy', amount: 150.00, date: DateTime(2026, 5, 12), status: TransactionStatus.successful),
    Transaction(title: 'Blood Test Package', amount: 100.00, date: DateTime(2026, 5, 2), status: TransactionStatus.cancelled),
  ];
}