import 'package:flutter/material.dart';
import 'dart:math';
import '../../theme/app_theme.dart';

class MinesScreen extends StatefulWidget {
  const MinesScreen({super.key});

  @override
  State<MinesScreen> createState() => _MinesScreenState();
}

class _MinesScreenState extends State<MinesScreen> {
  final int _gridSize = 25;
  int _minesCount = 3;
  double _betAmount = 50.0;
  bool _isPlaying = false;
  bool _isGameOver = false;

  Set<int> _minePositions = {};
  Set<int> _revealedTiles = {};
  double _currentMultiplier = 1.0;

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _isGameOver = false;
      _revealedTiles.clear();
      _currentMultiplier = 1.0;

      // Random mines
      _minePositions.clear();
      final random = Random();
      while (_minePositions.length < _minesCount) {
        _minePositions.add(random.nextInt(_gridSize));
      }
    });
  }

  void _revealTile(int index) {
    if (!_isPlaying || _revealedTiles.contains(index) || _isGameOver) return;

    if (_minePositions.contains(index)) {
      // Hit a mine!
      setState(() {
        _isGameOver = true;
        _isPlaying = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('BOOM! You hit a mine! Bet lost.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } else {
      setState(() {
        _revealedTiles.add(index);
        _currentMultiplier = roundDouble(1.0 + (_revealedTiles.length * (0.15 + (_minesCount * 0.08))), 2);
      });
    }
  }

  void _cashOut() {
    if (!_isPlaying || _revealedTiles.isEmpty) return;

    final winPayout = roundDouble(_betAmount * _currentMultiplier, 2);
    setState(() {
      _isPlaying = false;
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MINES — 5x5 GRID'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Stats Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatBox('MINES', '$_minesCount', Colors.redAccent),
                _buildStatBox('SAFE TILES', '${_revealedTiles.length}', AppTheme.primaryGreen),
                _buildStatBox('MULTIPLIER', '${_currentMultiplier.toStringAsFixed(2)}x', AppTheme.accentGold),
              ],
            ),
            const SizedBox(height: 20),

            // 5x5 Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _gridSize,
              itemBuilder: (context, index) {
                final isRevealed = _revealedTiles.contains(index);
                final isMine = _minePositions.contains(index);
                final showMine = _isGameOver && isMine;

                return GestureDetector(
                  onTap: () => _revealTile(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: showMine
                          ? Colors.redAccent.withOpacity(0.4)
                          : (isRevealed ? AppTheme.primaryGreen.withOpacity(0.25) : AppTheme.cardBg),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isRevealed
                            ? AppTheme.primaryGreen
                            : (showMine ? Colors.redAccent : Colors.white.withOpacity(0.1)),
                      ),
                    ),
                    child: Center(
                      child: showMine
                          ? const Icon(Icons.dangerous, color: Colors.redAccent, size: 28)
                          : (isRevealed
                              ? const Icon(Icons.diamond, color: AppTheme.accentGold, size: 28)
                              : const Icon(Icons.help_outline, color: AppTheme.textSecondary, size: 20)),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Action Buttons
            if (_isPlaying)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _revealedTiles.isNotEmpty ? _cashOut : null,
                  icon: const Icon(Icons.monetization_on),
                  label: Text('CASH OUT (Rs ${(_betAmount * _currentMultiplier).toStringAsFixed(2)})'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _startGame,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('START NEW MINES ROUND'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String title, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          Text(val, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
