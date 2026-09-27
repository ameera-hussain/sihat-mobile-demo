sealed class PaymentMethodDetails {
  const PaymentMethodDetails();
}

class CardPaymentDetails extends PaymentMethodDetails {
  final String paymentToken;
  final String cardHolderName;
  final String lastFourDigits;
  final String brand;
  final DateTime expiryDate;
  const CardPaymentDetails({
    required this.paymentToken,
    required this.cardHolderName,
    required this.lastFourDigits,
    required this.brand,
    required this.expiryDate,
  });
}

class EWalletPaymentDetails extends PaymentMethodDetails {
  final String walletId;
  final String provider; // "GrabPay", "Touch 'n Go"
  const EWalletPaymentDetails({required this.walletId, required this.provider});
}

class BankTransferPaymentDetails extends PaymentMethodDetails {
  final String bankName;
  final String accountLastFourDigits; // never full account number client-side either
  const BankTransferPaymentDetails({required this.bankName, required this.accountLastFourDigits});
}

class CashPaymentDetails extends PaymentMethodDetails {
  const CashPaymentDetails();
}

class BillingInfo {
  final String billingAddress;
  final PaymentMethodDetails paymentMethod;
  final DateTime? nextBillingDate; // nullable — cash/one-off payments have no recurring date

  const BillingInfo({
    required this.billingAddress,
    required this.paymentMethod,
    this.nextBillingDate,
  });
}

String describe(PaymentMethodDetails m) => switch (m) {
  CardPaymentDetails(:final brand, :final lastFourDigits) => '$brand •••• $lastFourDigits',
  EWalletPaymentDetails(:final provider) => provider,
  BankTransferPaymentDetails(:final bankName) => bankName,
  CashPaymentDetails() => 'Cash',
};

enum SubscriptionType { general, carePlan }

enum TransactionType { charge, refund }

class SubscriptionInfo {
  final String planName;
  final String? description; // populated for care plans, optional for general
  final SubscriptionType type;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final int loyaltyTokens; // for your future tokens/loyalty system

  const SubscriptionInfo({
    required this.planName,
    this.description,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    this.loyaltyTokens = 0,
  });
}