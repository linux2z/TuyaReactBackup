import 'package:flutter/material.dart';
import '../theme.dart';
import 'maintenance_screen.dart';
import 'device_management_screen.dart';
import 'ota_updates_screen.dart';
import 'notifications_screen.dart';
import 'advanced_telemetry_screen.dart';
import 'user_profile_screen.dart';
import 'statistics_screen.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ElenzaTheme.matteBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Settings',
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
            // Profil & App Section
            const Text(
              'Profile & App',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: ElenzaTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: ElenzaTheme.graphiteDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ElenzaTheme.graphiteLight),
              ),
              child: Column(
                children: [
                  _buildSettingsRow(context, 'Profile', Icons.person_outline, const UserProfileScreen()),
                  _buildDivider(),
                  _buildSettingsRow(context, 'Push Notifications', Icons.notifications_none, const NotificationsScreen()),
                  _buildDivider(),
                  _buildSettingsRow(context, 'WLAN / Bluetooth', Icons.wifi, const DeviceManagementScreen()),
                  _buildDivider(),
                  _buildSettingsRow(context, 'Advanced Telemetry', Icons.developer_board, const AdvancedTelemetryScreen()),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Machine Section
            const Text(
              'Machine',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: ElenzaTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: ElenzaTheme.graphiteDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ElenzaTheme.graphiteLight),
              ),
              child: Column(
                children: [
                  _buildSettingsRow(context, 'Modena R Settings', Icons.coffee_maker_outlined, const DeviceManagementScreen()),
                  _buildDivider(),
                  _buildSettingsRow(context, 'Maintenance Center', Icons.cleaning_services_outlined, const MaintenanceScreen()),
                  _buildDivider(),
                  _buildSettingsRow(context, 'OTA Updates', Icons.system_update_alt, const OtaUpdatesScreen()),
                  _buildDivider(),
                  _buildSettingsRow(context, 'Statistics', Icons.bar_chart, const StatisticsScreen()),
                ],
              ),
            ),
            
            const SizedBox(height: 100), // Bottom padding for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsRow(BuildContext context, String title, IconData icon, Widget targetScreen) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => targetScreen),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: ElenzaTheme.textSecondary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ElenzaTheme.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: ElenzaTheme.textSecondary, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: ElenzaTheme.graphiteLight,
      indent: 56,
    );
  }
}
