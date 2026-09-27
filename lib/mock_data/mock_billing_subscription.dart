import '../features/settings/models/billing_subscription_data.dart';
import '../features/payments/models/payment_models.dart';

class MockBillingInformationData {
  // Primary card for recurring billing
  static final CardPaymentDetails mockPrimaryCard = CardPaymentDetails(
    paymentToken: 'tok_primary_card_2024',
    cardHolderName: 'John Doe',
    lastFourDigits: '4821',
    brand: 'Visa',
    expiryDate: DateTime(2028, 9),
  );

  // Active care plan with next billing date
  static final SubscriptionInfo mockActiveCarePlan = SubscriptionInfo(
    planName: 'Weight management plan',
    description: 'Comprehensive weight management with monthly check-ins',
    type: SubscriptionType.carePlan,
    startDate: DateTime(2026, 1, 15),
    endDate: DateTime(2026, 12, 31),
    isActive: true,
    loyaltyTokens: 50,
  );

  // Expired care plan
  static final SubscriptionInfo mockExpiredCarePlan = SubscriptionInfo(
    planName: 'Diabetes management plan',
    description: 'Monthly diabetes monitoring and consultation',
    type: SubscriptionType.carePlan,
    startDate: DateTime(2025, 6, 15),
    endDate: DateTime(2026, 6, 14),
    isActive: false,
    loyaltyTokens: 0,
  );

  // For the active scenario, use this instead of null
  static final SubscriptionInfo mockCarePlanActive = mockActiveCarePlan;

  // For the no-plan scenario
  static final SubscriptionInfo? mockCarePlanNone = null;

  // Mock token balance
  static const int mockTokenBalance = 0;

  // Mock transactions - filtered to charge/refund types
  static final List<Transaction> mockRecentTransactions = [
    Transaction(
      title: 'Wieght Managemet Plan - Monthly Charge',
      amount: 54.20,
      date: DateTime(2026, 7, 3),
      status: TransactionStatus.successful,
    ),
    Transaction(
      title: 'Refund - MRIC Pharmacy',
      amount: 22.10,
      date: DateTime(2026, 6, 28),
      status: TransactionStatus.successful,
    ),
    Transaction(
      title: 'MRIC Clinic',
      amount: 250.00,
      date: DateTime(2026, 6, 25),
      status: TransactionStatus.successful,
    ),
  ];

  // Additional transactions for broader preview if needed
  static final List<Transaction> mockAllBillingTransactions = [
    Transaction(
      title: 'Consultation',
      amount: 54.20,
      date: DateTime(2026, 7, 3),
      status: TransactionStatus.successful,
    ),
    Transaction(
      title: 'Refund - MRIC Pharmacy',
      amount: 22.10,
      date: DateTime(2026, 6, 28),
      status: TransactionStatus.successful,
    ),
    Transaction(
      title: 'MRIC Clinic',
      amount: 250.00,
      date: DateTime(2026, 6, 25),
      status: TransactionStatus.successful,
    ),
    Transaction(
      title: 'Glucometer',
      amount: 15.99,
      date: DateTime(2026, 7, 1),
      status: TransactionStatus.pending,
    ),
    Transaction(
      title: 'Hospital Kuala Lumpur',
      amount: 550.00,
      date: DateTime(2026, 6, 10),
      status: TransactionStatus.successful,
    ),
  ];
}