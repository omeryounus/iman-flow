import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../shared/widgets/glass_widgets.dart';
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
  int _selectedPackageIndex = 0;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ImanFlowTheme.emeraldGlow.withOpacity(0.3),
              ImanFlowTheme.primaryGreenDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      _buildFeaturesList(),
                      const SizedBox(height: 24),
                      _buildPackagesList(),
                      const SizedBox(height: 24),
                      _buildPurchaseButton(),
                      const SizedBox(height: 16),
                      _buildRestoreButton(),
                      const SizedBox(height: 16),
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
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ImanFlowTheme.gold.withOpacity(0.2),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: ImanFlowTheme.gold.withOpacity(0.3), blurRadius: 40)],
            ),
            child: const Icon(Icons.star_rounded, size: 50, color: ImanFlowTheme.gold),
          ),
          const SizedBox(height: 16),
          const Text('Iman Flow Pro', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Unlock your full spiritual potential', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16)),
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
       ('Offline Access', Icons.download_rounded),
    ];

    return Glass(
      radius: 20,
      padding: const EdgeInsets.all(20),
      child: Column(
         children: features.map((f) => Padding(
           padding: const EdgeInsets.symmetric(vertical: 8),
           child: Row(
             children: [
               Icon(f.$2, color: ImanFlowTheme.gold, size: 20),
               const SizedBox(width: 12),
               Expanded(child: Text(f.$1, style: const TextStyle(color: Colors.white, fontSize: 15))),
               const Icon(Icons.check_circle_rounded, color: ImanFlowTheme.emeraldGlow, size: 18),
             ],
           ),
         )).toList(),
      ),
    );
  }

  Widget _buildPackagesList() {
    return Column(
      children: List.generate(_premiumService.packages.length, (index) {
        final package = _premiumService.packages[index];
        final isSelected = index == _selectedPackageIndex;

        return GestureDetector(
          onTap: () => setState(() => _selectedPackageIndex = index),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Glass(
              radius: 16,
              padding: const EdgeInsets.all(16),
              color: isSelected ? ImanFlowTheme.emeraldGlow.withOpacity(0.2) : null,
              border: isSelected ? Border.all(color: ImanFlowTheme.gold) : null,
              child: Row(
                children: [
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: isSelected ? ImanFlowTheme.gold : Colors.white24, width: 2),
                      color: isSelected ? ImanFlowTheme.gold : Colors.transparent,
                    ),
                    child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.black) : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(package.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(package.description, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                      ],
                    ),
                  ),
                  Text(package.price, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: ImanFlowTheme.gold)),
                ],
              ),
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
          backgroundColor: ImanFlowTheme.gold,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading 
           ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
           : const Text('Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildRestoreButton() {
    return TextButton(
      onPressed: _handleRestore,
      child: const Text('Restore Purchases', style: TextStyle(color: Colors.white70, fontSize: 14)),
    );
  }

  Widget _buildTermsText() {
    return Text(
      'By continuing, you agree to our Terms of Service & Privacy Policy.\nAuto-renews unless cancelled 24h before end of period.',
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10),
    );
  }

  Future<void> _handlePurchase() async {
    setState(() => _isLoading = true);
    final package = _premiumService.packages[_selectedPackageIndex];
    final success = await _premiumService.purchasePackage(package);
    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🎉 Welcome to Iman Flow Pro!')));
    }
  }

  Future<void> _handleRestore() async {
    setState(() => _isLoading = true);
    final success = await _premiumService.restorePurchases();
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? 'Purchases restored successfully!' : 'No previous purchases found', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), 
        backgroundColor: success ? ImanFlowTheme.gold : ImanFlowTheme.error));
      if (success) Navigator.of(context).pop(true);
    }
  }
}
