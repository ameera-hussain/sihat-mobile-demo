import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../payments/models/payment_models.dart';
import '../../../core/constants/app_decorations.dart';

class TransactionPreviewList extends StatelessWidget {
  final List<Transaction> transactions;

  const TransactionPreviewList({super.key, required this.transactions});

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.successful:
        return Colors.green;
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getTransactionIcon(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('refund')) {
      return Icons.reply;
    }
    return Icons.arrow_outward;
  }

  String _formatDate(DateTime date) {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'Today';
    }
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    }

    return DateFormat('dd MMM').format(date);
  }

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction history',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: cardDecoration,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No transactions yet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[400],
                    ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction history',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: cardDecoration,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: List.generate(
                transactions.length,
                (index) {
                  final transaction = transactions[index];
                  final statusColor = _getStatusColor(transaction.status);
                  final icon = _getTransactionIcon(transaction.title);
                  final dateLabel = _formatDate(transaction.date);

                  return Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: statusColor.withValues(alpha: 0.15),
                          child: Icon(icon, color: statusColor, size: 20),
                        ),
                        title: Text(
                          transaction.title,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        subtitle: Text(
                          dateLabel,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[500],
                              ),
                        ),
                        trailing: Text(
                          'RM ${transaction.amount.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                        ),
                      ),
                      if (index < transactions.length - 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Divider(
                            height: 1,
                            color: Colors.grey[200],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
