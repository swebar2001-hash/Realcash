import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../theme/app_theme.dart';

class AviatorScreen extends StatefulWidget {
  const AviatorScreen({super.key});

  @override
  State<AviatorScreen> createState() => _AviatorScreenState();
}

class _AviatorScreenState extends State<AviatorScreen> {
  double _currentMultiplier = 1.00;
  bool _isPlaying = false;
  bool _isCrashed = false;
  Timer? _gameTimer;
  double _betAmount = 50.0;
  double _payout = 0.0;
  double _crashTarget = 2.45;

  void _startFlight() {
    if (_isPlaying) return;

    setState(() {
      _isPlaying = true;
      _isCrashed = false;
      _currentMultiplier = 1.00;
      _crashTarget = 1.01 + Random().nextDouble() * 4.5;
    });

    _gameTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_currentMultiplier >= _crashTarget) {
        timer.cancel();
        setState(() {
          _isPlaying = false;
          _isCrashed = true;
        });
      } else {
        setState(() {
          _currentMultiplier = roundDouble(_currentMultiplier + 0.05, 2);
        });
      }
    });
  }

  void _cashOut() {
    if (!_isPlaying || _isCrashed) return;

    _gameTimer?.cancel();
    final winPayout = roundDouble(_betAmount * _currentMultiplier, 2);

    setState(() {
      _isPlaying = false;
      _payout = winPayout;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('CASHED OUT at ${_currentMultiplier.toStringAsFixed(2)}x! Won Rs $winPayout'),
        backgroundColor: AppTheme.primaryGreenDark,
      ),
    );
  }

  double roundDouble(double val, int places) {
    num mod = pow(10, places);
    return ((val * mod).round().toDouble() / mod);
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AVIATOR — MULTIPLIER CRASH'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Flight Graph Area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF140809),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_isCrashed)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'FLEW AWAY!',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Crashed @ ${_currentMultiplier.toStringAsFixed(2)}x',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                          ),
                        ],
                      )
                    else
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.airplanemode_active,
                            color: _isPlaying ? AppTheme.primaryGreen : AppTheme.textSecondary,
                            size: 64,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${_currentMultiplier.toStringAsFixed(2)}x',
                            style: TextStyle(
                              color: _isPlaying ? AppTheme.primaryGreen : Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Controls Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('BET AMOUNT:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Rs ${_betAmount.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Slider(
                    value: _betAmount,
                    min: 10,
                    max: 500,
                    divisions: 49,
                    activeColor: AppTheme.primaryGreen,
                    onChanged: (val) {
                      if (!_isPlaying) {
                        setState(() {
                          _betAmount = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: _isPlaying
                        ? ElevatedButton.icon(
                            onPressed: _cashOut,
                            icon: const Icon(Icons.touch_app),
                            label: Text('CASH OUT (Rs ${(_betAmount * _currentMultiplier).toStringAsFixed(2)})'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentGold,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: _startFlight,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('BET & START ROUND'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
