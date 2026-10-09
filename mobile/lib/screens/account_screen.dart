import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'wallet_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ACCOUNT & LEGAL'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Wallet Quick Access
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('FINANCIAL MANAGEMENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen()));
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('DEPOSIT'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen()));
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('WITHDRAW'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentGold, foregroundColor: Colors.black),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Legal Disclaimer Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'TERMS & DISCLAIMER',
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                SizedBox(height: 8),
                Text(
                  '1. Players must deposit and play games before requesting withdrawals.\n'
                  '2. Minimum withdrawal threshold is set to Rs 800.\n'
                  '3. Daily Spin gives guaranteed random rewards from Rs 0 to Rs 10 maximum per 24 hours.\n'
                  '4. Gaming involves financial risk. Play responsibly.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
