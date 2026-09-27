import 'package:flutter/foundation.dart';
import '../models/billing_subscription_data.dart';
import '../../../mock_data/mock_billing_subscription.dart';
import '../../payments/models/payment_models.dart';

/// Sealed class to represent care plan status with derived state
sealed class CarePlanStatus {
  const CarePlanStatus();
}

class NoPlan extends CarePlanStatus {
  const NoPlan();
}

class ExpiredPlan extends CarePlanStatus {
  final SubscriptionInfo subscription;
  const ExpiredPlan(this.subscription);
}

class ActivePlan extends CarePlanStatus {
  final SubscriptionInfo subscription;
  const ActivePlan(this.subscription);
}

class BillingSubscriptionProvider extends ChangeNotifier {
  // Wire to mock data for now; swap for real API calls later
  late CardPaymentDetails? _primaryCard;
  late SubscriptionInfo? _rawCarePlan;
  late int _tokenBalance;
  late List<Transaction> _allTransactions;

  BillingSubscriptionProvider() {
    _primaryCard = MockBillingInformationData.mockPrimaryCard;
    _rawCarePlan = MockBillingInformationData.mockCarePlanActive;
    _tokenBalance = MockBillingInformationData.mockTokenBalance;
    _allTransactions = MockBillingInformationData.mockRecentTransactions;
  }

  /// Primary card for recurring billing, nullable if no card on file
  CardPaymentDetails? get primaryCard => _primaryCard;

  /// Derived care plan status (noPlan / expired / active)
  CarePlanStatus get carePlanStatus {
    final plan = _rawCarePlan;
    if (plan == null) {
      return const NoPlan();
    }
    if (!plan.isActive) {
      return ExpiredPlan(plan);
    }
    return ActivePlan(plan);
  }

  /// Token balance (currently unused, greyed out in UI)
  int get tokenBalance => _tokenBalance;

  /// Recent transactions (top 3, sorted by date descending)
  List<Transaction> get recentTransactions {
    final sorted = List<Transaction>.from(_allTransactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(3).toList();
  }

  /// Allows swapping the underlying data source without changing the public interface
  /// This method can be called when switching from mock to real API
  void updateFromMockData(
    CardPaymentDetails? card,
    SubscriptionInfo? plan,
    int tokens,
    List<Transaction> transactions,
  ) {
    // This approach lets us keep the same provider interface
    // while making the underlying source flexible
    notifyListeners();
  }

  /// Update primary card (for adding/replacing the card)
  /// This will be called when the add card flow completes
  void updatePrimaryCard(CardPaymentDetails newCard) {
    _primaryCard = newCard;
    notifyListeners();
  }
}
