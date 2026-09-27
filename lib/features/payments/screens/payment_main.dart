import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/payment_providers.dart';
import '../widgets/filter_bar.dart';
import '../widgets/month_header.dart';
import '../widgets/transaction_tile.dart';

class PaymentMainScreen extends StatelessWidget {

  const PaymentMainScreen({super.key});

@override
  Widget build(BuildContext context) {
    return Consumer<PaymentProviders>(
      builder: (context, provider, _) {
        final grouped = provider.groupedTransactions;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: const Text(
              'Transactions',
              style: TextStyle(color: Color(0xFF5D53A3), fontWeight: FontWeight.w600),
            ),
            actions: [
              IconButton(
                tooltip: provider.newestFirst ? 'Newest first' : 'Oldest first',
                icon: Icon(
                  provider.newestFirst
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  color: Color(0xFF5D53A3),
                ),
                onPressed: provider.toggleSortOrder,
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FilterBar(
                selected: provider.selectedFilter,
                onSelected: provider.setFilter,
              ),
              const Divider(height: 1),
              Expanded(
                child: grouped.isEmpty
                    ? const Center(child: Text('No transactions found'))
                    : ListView(
                        children: [
                          for (final entry in grouped.entries) ...[
                            MonthHeader(label: entry.key),
                            for (final txn in entry.value)
                              TransactionTile(transaction: txn),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
  





