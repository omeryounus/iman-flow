import 'dart:async';
import 'package:flutter/foundation.dart';

/// Premium subscription tiers
enum PremiumTier {
  free,
  monthly,
  yearly,
  lifetime,
}

/// Premium feature flags
class PremiumFeatures {
  final bool unlimitedAI;
  final bool adFree;
  final bool customDhikrGoals;
  final bool premiumRecitations;
  final bool advancedStats;
  final bool offlineQuran;

  const PremiumFeatures({
    this.unlimitedAI = false,
    this.adFree = false,
    this.customDhikrGoals = false,
    this.premiumRecitations = false,
    this.advancedStats = false,
    this.offlineQuran = false,
  });

  static const free = PremiumFeatures();
  
  static const premium = PremiumFeatures(
    unlimitedAI: true,
    adFree: true,
    customDhikrGoals: true,
    premiumRecitations: true,
    advancedStats: true,
    offlineQuran: true,
  );
}

/// Subscription package info
class SubscriptionPackage {
  final String id;
  final String title;
  final String description;
  final String price;
  final PremiumTier tier;
  final Duration duration;

  const SubscriptionPackage({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.tier,
    required this.duration,
  });
}

/// Premium Service - Manages subscriptions via RevenueCat
/// Falls back to demo mode when RevenueCat is not configured
class PremiumService {
  // Singleton
  static final PremiumService _instance = PremiumService._internal();
  factory PremiumService() => _instance;
  PremiumService._internal();

  // State
  final _isPremiumController = StreamController<bool>.broadcast();
  Stream<bool> get isPremiumStream => _isPremiumController.stream;
  
  bool _isPremium = false;
  bool get isPremium => _isPremium;
  
  PremiumTier _currentTier = PremiumTier.free;
  PremiumTier get currentTier => _currentTier;
  
  PremiumFeatures _features = PremiumFeatures.free;
  PremiumFeatures get features => _features;

  bool _isInitialized = false;
  bool _isDemoMode = true;

  /// Available subscription packages
  final List<SubscriptionPackage> packages = const [
    SubscriptionPackage(
      id: 'iman_flow_lifetime',
      title: 'Lifetime Access',
      description: 'One-time purchase, forever access',
      price: '\$2.99', // Fallback display string, actual price from Store
      tier: PremiumTier.lifetime,
      duration: Duration(days: 36500), // ~100 years
    ),
  ];

  /// Initialize the premium service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // TODO: Initialize RevenueCat when API key is available
      // await Purchases.configure(PurchasesConfiguration('YOUR_REVENUECAT_API_KEY'));
      // await _checkSubscriptionStatus();
      
      // For now, run in demo mode
      _isDemoMode = true;
      _isInitialized = true;
      
      if (kDebugMode) {
        print('PremiumService: Running in demo mode (RevenueCat not configured)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('PremiumService: Initialization failed, running in demo mode: $e');
      }
      _isDemoMode = true;
      _isInitialized = true;
    }
  }

  /// Purchase a subscription package (demo mode simulates success)
  Future<bool> purchasePackage(SubscriptionPackage package) async {
    if (_isDemoMode) {
      // Demo mode - simulate purchase
      await Future.delayed(const Duration(seconds: 1));
      _setPremiumStatus(true, package.tier);
      return true;
    }

    try {
      // TODO: Implement actual RevenueCat purchase
      // final customerInfo = await Purchases.purchasePackage(rcPackage);
      // return customerInfo.entitlements.active.containsKey('premium');
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('PremiumService: Purchase failed: $e');
      }
      return false;
    }
  }

  /// Restore purchases
  Future<bool> restorePurchases() async {
    if (_isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return false; // No purchases to restore in demo
    }

    try {
      // TODO: Implement actual restore
      // final customerInfo = await Purchases.restorePurchases();
      // return customerInfo.entitlements.active.containsKey('premium');
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('PremiumService: Restore failed: $e');
      }
      return false;
    }
  }

  /// Toggle premium status (demo mode only, for testing)
  void toggleDemoPremium() {
    if (!_isDemoMode) return;
    _setPremiumStatus(!_isPremium, _isPremium ? PremiumTier.free : PremiumTier.monthly);
  }

  /// Check if a specific feature is available
  bool hasFeature(String featureName) {
    switch (featureName) {
      case 'unlimitedAI':
        return _features.unlimitedAI;
      case 'adFree':
        return _features.adFree;
      case 'customDhikrGoals':
        return _features.customDhikrGoals;
      case 'premiumRecitations':
        return _features.premiumRecitations;
      case 'advancedStats':
        return _features.advancedStats;
      case 'offlineQuran':
        return _features.offlineQuran;
      default:
        return _isPremium;
    }
  }

  void _setPremiumStatus(bool isPremium, PremiumTier tier) {
    _isPremium = isPremium;
    _currentTier = tier;
    _features = isPremium ? PremiumFeatures.premium : PremiumFeatures.free;
    _isPremiumController.add(_isPremium);
  }

  void dispose() {
    _isPremiumController.close();
  }
}
