import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'games/daily_spin_screen.dart';
import 'games/aviator_screen.dart';
import 'games/mines_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.flash_on, color: Colors.black, size: 20),
            ),
            const SizedBox(width: 8),
            const Text(
              'REALCASH',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: AppTheme.primaryGreen,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wallet Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B3B2B), Color(0xFF0F2018)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Balance',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Rs 1,250.00',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: const Text('DEPOSIT'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Daily Spin Banner
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DailySpinScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3A2800), Color(0xFF1E1500)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.accentGold.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppTheme.accentGold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.stars, color: Colors.black, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'FREE DAILY SPIN WHEEL',
                            style: TextStyle(
                              color: AppTheme.accentGold,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Win guaranteed free rewards up to Rs 10 daily!',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppTheme.accentGold),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Trending Casino Games
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'POPULAR GAMES',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  'See All',
                  style: TextStyle(color: AppTheme.primaryGreen, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 165,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildGameCard(
                    context,
                    title: 'AVIATOR',
                    subtitle: 'Multiplier Crash',
                    icon: Icons.airplanemode_active,
                    color: Colors.redAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AviatorScreen()),
                      );
                    },
                  ),
                  _buildGameCard(
                    context,
                    title: 'MINES',
                    subtitle: '5x5 Grid Sweeper',
                    icon: Icons.grid_on,
                    color: Colors.blueAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MinesScreen()),
                      );
                    },
                  ),
                  _buildGameCard(
                    context,
                    title: 'CHICKEN ROAD',
                    subtitle: 'Step Multiplier',
                    icon: Icons.directions_walk,
                    color: Colors.orangeAccent,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Live Sports Matches
            const Text(
              'LIVE & UPCOMING MATCHES',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            _buildMatchCard(
              sport: 'CRICKET',
              tournament: 'IPL Premier League',
              teamA: 'Mumbai Indians',
              teamB: 'Chennai Super Kings',
              score: '184/5 (19.2) - 182/6 (20.0)',
              oddsA: '1.75',
              oddsDraw: '15.0',
              oddsB: '2.10',
              isLive: true,
            ),
            const SizedBox(height: 12),
            _buildMatchCard(
              sport: 'FOOTBALL',
              tournament: 'UEFA Champions League',
              teamA: 'Real Madrid',
              teamB: 'Manchester City',
              score: '2 - 1',
              oddsA: '2.05',
              oddsDraw: '3.40',
              oddsB: '3.10',
              isLive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchCard({
    required String sport,
    required String tournament,
    required String teamA,
    required String teamB,
    required String score,
    required String oddsA,
    required String oddsDraw,
    required String oddsB,
    required bool isLive,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$sport • $tournament',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
              if (isLive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  teamA,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  score,
                  style: const TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Text(
                  teamB,
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _buildOddsButton('1', oddsA)),
              const SizedBox(width: 8),
              Expanded(child: _buildOddsButton('X', oddsDraw)),
              const SizedBox(width: 8),
              Expanded(child: _buildOddsButton('2', oddsB)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOddsButton(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardSecondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          Text(value, style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
