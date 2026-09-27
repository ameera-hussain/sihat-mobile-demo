import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/billing_subscription_data.dart';
import '../providers/billing_subscription_provider.dart';
import '../../../core/constants/app_decorations.dart';

class PrimaryCardTile extends StatelessWidget {
  final CardPaymentDetails? card;

  const PrimaryCardTile({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Primary card',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 12),
        if (card != null)
          Column(
            children: [
              Container(
                decoration: cardDecoration,
                child: Material(
                  color: Colors.transparent,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    leading: Icon(
                      Icons.credit_card,
                      color: const Color(0xFF5D53A3),
                      size: 28,
                    ),
                    title: Text(
                      '${card!.brand} •••• ${card!.lastFourDigits}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    subtitle: Text(
                      'Expires ${card!.expiryDate.month.toString().padLeft(2, '0')}/${card!.expiryDate.year.toString().substring(2)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: Colors.grey[400],
                    ),
                    onTap: () {
                      // FUTURE: Navigate to add/manage card flow
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Card management - coming soon')),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Card'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5D53A3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    /// Navigate to add card flow
                    /// For this simulates adding a test card
                    final newCard = CardPaymentDetails(
                      paymentToken: 'tok_test_new_card_${DateTime.now().millisecondsSinceEpoch}',
                      cardHolderName: 'Jane Smith',
                      lastFourDigits: '5678',
                      brand: 'MasterCard',
                      expiryDate: DateTime(2029, 12),
                    );
                    context.read<BillingSubscriptionProvider>().updatePrimaryCard(newCard);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('New card added as primary'),
                      ),
                    );
                  },
                ),
              ),
            ],
          )
        /// added this ELSE block for no card on file and managing scenario where a card is removed or not there.
        else
          Container(
            decoration: cardDecoration,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No card on file',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add card'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5D53A3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                      ),
                      onPressed: () {
                        /// This will be replaced with real add card screen integration
                        /// For this simulates adding a test card
                        final newCard = CardPaymentDetails(
                          paymentToken: 'tok_test_new_card_2024',
                          cardHolderName: 'Jane Smith',
                          lastFourDigits: '5678',
                          brand: 'MasterCard',
                          expiryDate: DateTime(2029, 12),
                        );
                        context.read<BillingSubscriptionProvider>().updatePrimaryCard(newCard);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('New card added as primary'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
