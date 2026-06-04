import 'package:flutter/material.dart';
import '../theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ElenzaTheme.matteBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ElenzaTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Alerts',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotificationCard(
              'Clean Machine',
              'Today, 08:30',
              'Group head needs backflushing after 50 extractions.',
              Icons.cleaning_services_outlined,
              ElenzaTheme.bronzeAccent,
            ),
            const SizedBox(height: 16),
            _buildNotificationCard(
              'Refill Water',
              'Yesterday, 14:15',
              'Water tank is below 10%. Please refill to prevent pump damage.',
              Icons.water_drop_outlined,
              ElenzaTheme.infoBlue,
            ),
            const SizedBox(height: 16),
            _buildNotificationCard(
              'Software Update',
              '12.05.2023',
              'Version 1.2 is available. Includes new thermal profiles.',
              Icons.system_update_alt,
              ElenzaTheme.textPrimary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(String title, String time, String desc, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ElenzaTheme.graphiteDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ElenzaTheme.graphiteLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: ElenzaTheme.textPrimary,
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 10,
                        color: ElenzaTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ElenzaTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
