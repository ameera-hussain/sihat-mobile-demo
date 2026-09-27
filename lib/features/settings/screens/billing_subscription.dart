import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/billing_subscription_provider.dart';
import '../widgets/primary_card_tile.dart';
import '../widgets/care_plan_section.dart';
import '../widgets/tokens_section.dart';
import '../widgets/transaction_preview_list.dart';

class BillingSubscriptionScreen extends StatelessWidget {
  const BillingSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing & Subscription'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/settings');
          },
        ),
      ),
      backgroundColor: Colors.grey[50],
      body: Consumer<BillingSubscriptionProvider>(
        builder: (context, provider, _) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              // Primary Card Section
              PrimaryCardTile(card: provider.primaryCard),
              const SizedBox(height: 24),

              // Care Plan Section
              CarePlanSection(carePlanStatus: provider.carePlanStatus),
              const SizedBox(height: 24),

              // Tokens Section (greyed out / disabled)
              TokensSection(tokenBalance: provider.tokenBalance),
              const SizedBox(height: 24),

              // Transaction History Section
              TransactionPreviewList(
                transactions: provider.recentTransactions,
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}
