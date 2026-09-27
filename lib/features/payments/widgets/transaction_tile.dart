import 'package:flutter/material.dart';
import '../models/payment_models.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;

  const TransactionTile({super.key, required this.transaction});

  Color _statusColor(BuildContext context) {
    switch (transaction.status) {
      case TransactionStatus.successful:
        return Colors.green;
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.cancelled:
        return Colors.red;
    }
  }

  String _formattedDateTime(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final dateLabel = localizations.formatMediumDate(transaction.date);
    final timeLabel = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(transaction.date),
    );
    return '$dateLabel, $timeLabel';
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(context);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(Icons.swap_horiz, color: color),
      ),
      title: Text(transaction.title),
      subtitle: Text(
        _formattedDateTime(context),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Text(
        'RM ${transaction.amount.toStringAsFixed(2)}',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
      onTap: () {
        // TODO: navigate to transaction detail page
      },
    );
  }
}