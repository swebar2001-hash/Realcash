import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SportsScreen extends StatefulWidget {
  const SportsScreen({super.key});

  @override
  State<SportsScreen> createState() => _SportsScreenState();
}

class _SportsScreenState extends State<SportsScreen> {
  String _selectedSport = 'ALL';

  final List<String> _sportsList = ['ALL', 'CRICKET', 'FOOTBALL', 'TENNIS', 'BASKETBALL'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SPORTS DASHBOARD'),
        actions: [
          IconButton(icon: const Icon(Icons.tune), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Sports Category Selector
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _sportsList.length,
              itemBuilder: (context, index) {
                final sport = _sportsList[index];
                final isSelected = _selectedSport == sport;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSport = sport;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryGreen : AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      sport,
                      style: TextStyle(
                        color: isSelected ? Colors.black : AppTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Matches List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSportCard(
                  sport: 'CRICKET',
                  league: 'IPL 2026',
                  teamA: 'Mumbai Indians',
                  teamB: 'Chennai Super Kings',
                  score: '184/5 (19.2) - 182/6 (20.0)',
                  oddsA: '1.75',
                  oddsDraw: '15.0',
                  oddsB: '2.10',
                ),
                const SizedBox(height: 12),
                _buildSportCard(
                  sport: 'FOOTBALL',
                  league: 'Champions League',
                  teamA: 'Real Madrid',
                  teamB: 'Manchester City',
                  score: '2 - 1',
                  oddsA: '2.05',
                  oddsDraw: '3.40',
                  oddsB: '3.10',
                ),
                const SizedBox(height: 12),
                _buildSportCard(
                  sport: 'TENNIS',
                  league: 'Wimbledon Finals',
                  teamA: 'Carlos Alcaraz',
                  teamB: 'Jannik Sinner',
                  score: '2 - 1 Sets',
                  oddsA: '1.85',
                  oddsDraw: '-',
                  oddsB: '1.95',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSportCard({
    required String sport,
    required String league,
    required String teamA,
    required String teamB,
    required String score,
    required String oddsA,
    required String oddsDraw,
    required String oddsB,
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
              Text('$sport • $league', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              const Text('LIVE', style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(teamA, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(score, style: const TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
              Text(teamB, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _buildOddsBox('1', oddsA)),
              const SizedBox(width: 8),
              Expanded(child: _buildOddsBox('X', oddsDraw)),
              const SizedBox(width: 8),
              Expanded(child: _buildOddsBox('2', oddsB)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOddsBox(String label, String value) {
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
