import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MY ACTIVITY & LEDGER'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildActivityItem('Deposit via UPI', '+ Rs 1,000.00', 'Completed', 'DEP-89F3A1', AppTheme.primaryGreen),
          _buildActivityItem('Daily Spin Reward', '+ Rs 5.00', 'Completed', 'SPIN-90A1B2', AppTheme.accentGold),
          _buildActivityItem('Aviator Cashout (1.8x)', '+ Rs 90.00', 'Completed', 'PAY-AVI-401', AppTheme.primaryGreen),
          _buildActivityItem('Mines Wager', '- Rs 50.00', 'Completed', 'MNE-701F', Colors.redAccent),
          _buildActivityItem('Withdrawal Request', '- Rs 800.00', 'Completed', 'WTH-331B', Colors.redAccent),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String amount, String status, String ref, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text('Ref: $ref', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              Text(status, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
