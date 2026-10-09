import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'games/aviator_screen.dart';
import 'games/mines_screen.dart';
import 'games/daily_spin_screen.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CASINO GAMES CATALOGUE'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          _buildGameGridTile(
            context,
            title: 'AVIATOR',
            desc: 'Crash Multiplier',
            icon: Icons.airplanemode_active,
            color: Colors.redAccent,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AviatorScreen()));
            },
          ),
          _buildGameGridTile(
            context,
            title: 'MINES',
            desc: '5x5 Bomb Sweeper',
            icon: Icons.grid_on,
            color: Colors.blueAccent,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MinesScreen()));
            },
          ),
          _buildGameGridTile(
            context,
            title: 'FREE DAILY SPIN',
            desc: 'Win up to Rs 10',
            icon: Icons.stars,
            color: AppTheme.accentGold,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DailySpinScreen()));
            },
          ),
          _buildGameGridTile(
            context,
            title: 'CHICKEN ROAD',
            desc: 'Road Crossing',
            icon: Icons.directions_walk,
            color: Colors.orangeAccent,
            onTap: () {},
          ),
          _buildGameGridTile(
            context,
            title: 'CARD HI-LO',
            desc: 'Higher or Lower',
            icon: Icons.style,
            color: Colors.purpleAccent,
            onTap: () {},
          ),
          _buildGameGridTile(
            context,
            title: 'TOWER CLIMB',
            desc: 'Level Escalator',
            icon: Icons.stairs,
            color: Colors.tealAccent,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildGameGridTile(
    BuildContext context, {
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
