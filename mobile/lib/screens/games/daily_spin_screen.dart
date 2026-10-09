import 'package:flutter/material.dart';
import 'dart:math';
import '../../theme/app_theme.dart';

class DailySpinScreen extends StatefulWidget {
  const DailySpinScreen({super.key});

  @override
  State<DailySpinScreen> createState() => _DailySpinScreenState();
}

class _DailySpinScreenState extends State<DailySpinScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isSpinning = false;
  bool _hasSpunToday = false;
  double _lastWon = 0.0;

  final List<double> _wheelSectors = [0.0, 1.0, 2.0, 3.0, 5.0, 7.0, 10.0, 0.0];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.decelerate);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spinWheel() {
    if (_isSpinning || _hasSpunToday) return;

    setState(() {
      _isSpinning = true;
    });

    final randomSectorIndex = Random().nextInt(_wheelSectors.length);
    final targetWon = _wheelSectors[randomSectorIndex];

    final double endRotation = 5.0 * 2 * pi + (randomSectorIndex * (2 * pi / _wheelSectors.length));

    _animation = Tween<double>(begin: 0, end: endRotation).animate(
      CurvedAnimation(parent: _controller, curve: Curves.decelerate),
    );

    _controller.forward(from: 0).then((_) {
      setState(() {
        _isSpinning = false;
        _hasSpunToday = true;
        _lastWon = targetWon;
      });

      _showPrizeDialog(targetWon);
    });
  }

  void _showPrizeDialog(double amount) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text('🎉 DAILY SPIN RESULT', style: TextStyle(color: AppTheme.accentGold)),
        content: Text(
          amount > 0
              ? 'Congratulations! You won Rs ${amount.toStringAsFixed(2)} directly credited to your wallet!'
              : 'You landed on Rs 0.00. Spin again tomorrow!',
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
            child: const Text('CLAIM'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FREE DAILY SPIN WHEEL'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'SPIN & WIN DAILY CASH',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentGold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Win free cash rewards from Rs 0 up to Rs 10 every 24 hours!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 36),

              // Wheel Container
              Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _animation.value,
                        child: Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const SweepGradient(
                              colors: [
                                Colors.purple, Colors.blue, Colors.green,
                                Colors.yellow, Colors.orange, Colors.red,
                                Colors.teal, Colors.indigo
                              ],
                            ),
                            border: Border.all(color: AppTheme.accentGold, width: 6),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentGold.withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Stack(
                            children: List.generate(_wheelSectors.length, (index) {
                              final angle = (index * (2 * pi / _wheelSectors.length));
                              return Transform.rotate(
                                angle: angle,
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: Text(
                                      'Rs ${_wheelSectors[index].toInt()}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      );
                    },
                  ),

                  // Center Pointer Indicator
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: AppTheme.darkBackground,
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(BorderSide(color: AppTheme.accentGold, width: 3)),
                    ),
                    child: const Icon(Icons.navigation, color: AppTheme.accentGold, size: 28),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Spin Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: (_isSpinning || _hasSpunToday) ? null : _spinWheel,
                  icon: const Icon(Icons.rotate_right),
                  label: Text(_hasSpunToday ? 'CLAIMED TODAY (NEXT IN 24H)' : 'SPIN WHEEL NOW'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
