import 'package:flutter/material.dart';
import '../models/payment_models.dart';

class FilterBar extends StatelessWidget {

  final TransactionStatus? selected;
  final ValueChanged<TransactionStatus?> onSelected;

  const FilterBar({super.key, required this.selected, required this.onSelected});

  Color _statusColor(TransactionStatus? status) {
    switch (status) {
      case TransactionStatus.successful:
        return Colors.green;
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.cancelled:
        return Colors.red;
      case null:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = <String, TransactionStatus?>{
      'All': null,
      'Successful': TransactionStatus.successful,
      'Pending': TransactionStatus.pending,
      'Cancelled': TransactionStatus.cancelled,
    };

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          for (final entry in options.entries)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Builder(
                builder: (context) {
                  final isSelected = selected == entry.value;
                  final baseColor = _statusColor(entry.value);

                  return ChoiceChip(
                    label: Text(entry.key),
                    selected: isSelected,
                    showCheckmark: false,
                    selectedColor: baseColor.withValues(alpha: 0.18),
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    side: BorderSide(
                      color: isSelected
                          ? baseColor.withValues(alpha: 0.50)
                          : Colors.transparent,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? baseColor.withValues(alpha: 0.95)
                          : Color(0xFF5D53A3).withValues(alpha: 0.75),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    onSelected: (_) => onSelected(entry.value),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}