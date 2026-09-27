import 'package:flutter/material.dart';
import '../models/payment_models.dart';
import '../../../mock_data/mock_transactions.dart';

class PaymentProviders extends ChangeNotifier {
  TransactionStatus? _selectedFilter;
  bool _newestFirst = true;

  // TODO: replace with real data (API / DB / provider / bloc / etc.)
  final List<Transaction> _allTransactions = MockTransactions.transactions;

  TransactionStatus? get selectedFilter => _selectedFilter;
  bool get newestFirst => _newestFirst;
  List<Transaction> get allTransactions => List.unmodifiable(_allTransactions);

  List<Transaction> get _filteredAndSorted {
    final filtered = _selectedFilter == null
        ? _allTransactions
        : _allTransactions
            .where((t) => t.status == _selectedFilter)
            .toList();

    filtered.sort((a, b) => _newestFirst
        ? b.date.compareTo(a.date)
        : a.date.compareTo(b.date));

    return filtered;
  }

  List<Transaction> get filteredAndSorted => _filteredAndSorted;
  Map<String, List<Transaction>> get groupedTransactions =>
      _groupByMonth(_filteredAndSorted);

  void setFilter(TransactionStatus? status) {
    if (_selectedFilter == status) return;
    _selectedFilter = status;
    notifyListeners();
  }

  void toggleSortOrder() {
    _newestFirst = !_newestFirst;
    notifyListeners();
  }

  /// Groups a sorted list of transactions into a Map keyed by "Month Year",
  /// preserving the incoming order.
  Map<String, List<Transaction>> _groupByMonth(List<Transaction> txns) {
    final Map<String, List<Transaction>> grouped = {};
    for (final t in txns) {
      final key = _monthYearLabel(t.date);
      grouped.putIfAbsent(key, () => []).add(t);
    }
    return grouped;
  }

  String _monthYearLabel(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
