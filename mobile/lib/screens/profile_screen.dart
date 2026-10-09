import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('USER PROFILE'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.primaryGreen,
              child: Icon(Icons.person, size: 48, color: Colors.black),
            ),
            const SizedBox(height: 12),
            const Text(
              'Test Player',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              'testplayer@gamezone.com',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),

            // Settings options
            _buildProfileTile(Icons.verified_user, 'Identity Verification (KYC)', 'Verified'),
            _buildProfileTile(Icons.security, 'Security & Passwords', 'Updated'),
            _buildProfileTile(Icons.shield, 'Responsible Gaming Limits', 'Active'),
            _buildProfileTile(Icons.support_agent, 'Help & Support', '24/7 Available'),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile(IconData icon, String title, String status) {
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
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryGreen),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          Text(status, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}
