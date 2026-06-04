import 'package:flutter/material.dart';
import '../theme.dart';

class CommunityTab extends StatelessWidget {
  const CommunityTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ELENZA CONNECT',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: ElenzaTheme.textMuted,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'COMMUNITY',
              style: TextStyle(
                fontFamily: 'Space Grotesk',
                fontSize: 24,
                letterSpacing: 4,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Tab Row (Forum, Q&A, Following)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text('Forum', style: TextStyle(color: ElenzaTheme.bronzeAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Q&A', style: TextStyle(color: ElenzaTheme.textSecondary, fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Following', style: TextStyle(color: ElenzaTheme.textSecondary, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(color: ElenzaTheme.graphiteLight),
            const SizedBox(height: 10),

            Expanded(
              child: ListView(
                children: [
                  _buildPostCard('Amalfi', 'Barista Pro', '2h ago', 'How to improve extraction consistency?', 12, 8),
                  _buildPostCard('MK', 'Coffee Enthusiast', '5h ago', 'Share your go-to espresso recipe!', 24, 16),
                  _buildPostCard('Luca', 'Barista Pro', '1d ago', 'Descaling tips for Modena R', 18, 6),
                ],
              ),
            ),
            const SizedBox(height: 80), // Padding for nav bar
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(String author, String role, String time, String title, int comments, int likes) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ElenzaTheme.graphiteDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ElenzaTheme.graphiteLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: ElenzaTheme.graphiteLight,
                radius: 16,
                child: Text(author[0], style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(author, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(role, style: const TextStyle(color: ElenzaTheme.textSecondary, fontSize: 10)),
                ],
              ),
              const Spacer(),
              Text(time, style: const TextStyle(color: ElenzaTheme.textMuted, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.chat_bubble_outline, color: ElenzaTheme.textSecondary, size: 16),
              const SizedBox(width: 6),
              Text('$comments', style: const TextStyle(color: ElenzaTheme.textSecondary, fontSize: 12)),
              const SizedBox(width: 16),
              Icon(Icons.favorite_border, color: ElenzaTheme.textSecondary, size: 16),
              const SizedBox(width: 6),
              Text('$likes', style: const TextStyle(color: ElenzaTheme.textSecondary, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
