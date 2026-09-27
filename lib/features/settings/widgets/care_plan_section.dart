import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/billing_subscription_provider.dart';
import '../../../core/constants/app_decorations.dart';

class CarePlanSection extends StatelessWidget {
  final CarePlanStatus carePlanStatus;

  const CarePlanSection({super.key, required this.carePlanStatus});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Care plan',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 12),
        _buildCarePlanContent(context),
      ],
    );
  }

  Widget _buildCarePlanContent(BuildContext context) {
    return switch (carePlanStatus) {
      NoPlan() => _buildNoPlan(context),
      ExpiredPlan(:final subscription) => _buildExpiredPlan(context, subscription),
      ActivePlan(:final subscription) => _buildActivePlan(context, subscription),
    };
  }

  Widget _buildNoPlan(BuildContext context) {
    return Container(
      decoration: cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No Active Care Plans',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D53A3),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  /// Navigate to Care Plan page
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Care plans - coming soon')),
                  );
                },
                child: const Text('Explore plans'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiredPlan(BuildContext context, subscription) {
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final expiredDate = dateFormatter.format(subscription.endDate);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: cardRadius,
        border: Border.all(
          color: const Color(0xFFFFB74D).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subscription.planName,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Expired on $expiredDate',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB74D),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  /// Navigate to Care Plan page
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Renew plan - coming soon')),
                  );
                },
                child: const Text('Renew plan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivePlan(BuildContext context, subscription) {
    final dateFormatter = DateFormat('dd MMM yyyy');
    final nextChargeDate = subscription.endDate; // Using endDate as reference; adjust if needed

    return Container(
      decoration: cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subscription.planName,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF5D53A3),
                  ),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall,
                children: [
                  const TextSpan(text: 'Next charge: '),
                  TextSpan(
                    text: dateFormatter.format(nextChargeDate),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF5D53A3)),
                  foregroundColor: const Color(0xFF5D53A3),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                ),
                onPressed: () {
                  /// Navigate to Care Plan page with cancellation option
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cancel plan - coming soon')),
                  );
                },
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
