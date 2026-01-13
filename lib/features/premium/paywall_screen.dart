import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/services/premium_service.dart';
import '../../core/services/service_locator.dart';

/// Paywall Screen - Premium subscription UI
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final PremiumService _premiumService = getIt<PremiumService>();
  int _selectedPackageIndex = 1; // Default to yearly (best value)
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    ImanFlowTheme.primaryGreenDark,
                    ImanFlowTheme.backgroundDark,
                  ]
                : [
                    ImanFlowTheme.primaryGreen,
                    ImanFlowTheme.backgroundLight,
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Features list
                      _buildFeaturesList(),
                      const SizedBox(height: 24),

                      // Subscription packages
                      _buildPackagesList(),
                      const SizedBox(height: 24),

                      // Purchase button
                      _buildPurchaseButton(),
                      const SizedBox(height: 16),

                      // Restore purchases
                      _buildRestoreButton(),
                      const SizedBox(height: 16),

                      // Terms
                      _buildTermsText(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ImanFlowTheme.accentGold,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Iman Flow Pro',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unlock your full spiritual potential',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      ('Unlimited AI Quran Insights', Icons.auto_awesome),
      ('Ad-Free Experience', Icons.block),
      ('Custom Dhikr Goals', Icons.trending_up),
      ('Premium Recitations', Icons.headphones),
      ('Advanced Statistics', Icons.analytics),
      ('Offline Quran Access', Icons.download),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: features.map((feature) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ImanFlowTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    feature.$2,
                    color: ImanFlowTheme.primaryGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    feature.$1,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.check_circle,
                  color: ImanFlowTheme.success,
                  size: 22,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPackagesList() {
    return Column(
      children: List.generate(_premiumService.packages.length, (index) {
        final package = _premiumService.packages[index];
        final isSelected = index == _selectedPackageIndex;
        final isBestValue = index == 1; // Yearly

        return GestureDetector(
          onTap: () => setState(() => _selectedPackageIndex = index),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? ImanFlowTheme.primaryGreen
                    : Colors.grey.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: ImanFlowTheme.primaryGreen.withOpacity(0.2),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? ImanFlowTheme.primaryGreen
                          : Colors.grey,
                      width: 2,
                    ),
                    color: isSelected
                        ? ImanFlowTheme.primaryGreen
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            package.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isBestValue) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: ImanFlowTheme.accentGold,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'BEST VALUE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        package.description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  package.price,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: ImanFlowTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPurchaseButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handlePurchase,
        style: ElevatedButton.styleFrom(
          backgroundColor: ImanFlowTheme.accentGold,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildRestoreButton() {
    return TextButton(
      onPressed: _handleRestore,
      child: Text(
        'Restore Purchases',
        style: TextStyle(
          color: ImanFlowTheme.primaryGreen,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return Text(
      'By continuing, you agree to our Terms of Service and Privacy Policy. '
      'Subscriptions auto-renew unless cancelled at least 24 hours before the end of the current period.',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.grey[500],
        fontSize: 11,
      ),
    );
  }

  Future<void> _handlePurchase() async {
    setState(() => _isLoading = true);

    final package = _premiumService.packages[_selectedPackageIndex];
    final success = await _premiumService.purchasePackage(package);

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Welcome to Iman Flow Pro!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleRestore() async {
    setState(() => _isLoading = true);

    final success = await _premiumService.restorePurchases();

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Purchases restored successfully!'
              : 'No previous purchases found'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (success) {
        Navigator.of(context).pop(true);
      }
    }
  }
}
