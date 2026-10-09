import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double _balance = 1250.00;
  bool _hasDeposited = true;
  bool _hasPlayed = true;
  final TextEditingController _amountController = TextEditingController();
  final double _minWithdrawalThreshold = 800.0;

  void _deposit(double amount) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deposited Rs ${amount.toStringAsFixed(2)} successfully!')),
    );
    setState(() {
      _balance += amount;
      _hasDeposited = true;
    });
  }

  void _processWithdrawal() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    if (!_hasDeposited || !_hasPlayed) {
      _showErrorDialog(
        'Withdrawal Locked',
        'Withdrawal functionality is unlocked only after you deposit money and play games on the platform.',
      );
      return;
    }

    if (amount < _minWithdrawalThreshold) {
      _showErrorDialog(
        'Minimum Withdrawal Limit',
        'Minimum withdrawal amount requirement is Rs ${_minWithdrawalThreshold.toStringAsFixed(2)}.',
      );
      return;
    }

    if (_balance < amount) {
      _showErrorDialog(
        'Insufficient Balance',
        'Your account balance (Rs ${_balance.toStringAsFixed(2)}) is less than the requested amount.',
      );
      return;
    }

    setState(() {
      _balance -= amount;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Withdrawal request of Rs ${amount.toStringAsFixed(2)} submitted!'),
        backgroundColor: AppTheme.primaryGreenDark,
      ),
    );
    _amountController.clear();
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: Text(title, style: const TextStyle(color: AppTheme.accentRed)),
        content: Text(message, style: const TextStyle(color: AppTheme.textPrimary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(color: AppTheme.primaryGreen)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WALLET & TRANSACTIONS'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.4)),
              ),
              child: Column(
                children: [
                  const Text(
                    'AVAILABLE BALANCE',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, letterSpacing: 1.1),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rs ${_balance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // DEPOSIT SECTION
            const Text(
              'DEPOSIT MONEY',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select minimum deposit tier (Min Rs 100):',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildDepositPresetButton(100.0)),
                const SizedBox(width: 8),
                Expanded(child: _buildDepositPresetButton(200.0)),
                const SizedBox(width: 8),
                Expanded(child: _buildDepositPresetButton(500.0)),
                const SizedBox(width: 8),
                Expanded(child: _buildDepositPresetButton(1000.0)),
              ],
            ),
            const SizedBox(height: 28),

            // WITHDRAWAL SECTION
            const Text(
              'WITHDRAW MONEY',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter amount (Min Rs 800)',
                hintStyle: const TextStyle(color: AppTheme.textSecondary),
                prefixText: 'Rs ',
                prefixStyle: const TextStyle(color: AppTheme.primaryGreen),
                filled: true,
                fillColor: AppTheme.cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _processWithdrawal,
                icon: const Icon(Icons.download_outlined),
                label: const Text('REQUEST WITHDRAWAL (RS 800 MIN)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // DISCLAIMER BOX
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
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'LEGAL & FINANCIAL DISCLAIMER',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• RealCash complies with mandatory responsible gaming guidelines.\n'
                    '• Minimum withdrawal threshold of Rs 800 applies after deposit and gameplay.\n'
                    '• Users under 18 years of age are strictly prohibited from participating.\n'
                    '• Gaming involves financial risk. Please play responsibly.',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepositPresetButton(double amount) {
    return ElevatedButton(
      onPressed: () => _deposit(amount),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.cardBg,
        foregroundColor: AppTheme.primaryGreen,
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(color: AppTheme.primaryGreen),
      ),
      child: Text('Rs ${amount.toInt()}'),
    );
  }
}
