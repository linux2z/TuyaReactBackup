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
    final settingsMenu = [
      {
        'title': 'Maintenance Center',
        'icon': '🧼',
        'desc': 'Backflush, descale, and clean group head',
        'widget': const MaintenanceScreen(),
      },
      {
        'title': 'Device Management',
        'icon': '📱',
        'desc': 'Tuya device ID, product signature, RSSI values',
        'widget': const DeviceManagementScreen(),
      },
      {
        'title': 'OTA Firmware Updates',
        'icon': '📡',
        'desc': 'Check and apply hardware flash updates',
        'widget': const OtaUpdatesScreen(),
      },
      {
        'title': 'Notifications Center',
        'icon': '🔔',
        'desc': 'Hardware alerts, water levels, cleaning prompts',
        'widget': const NotificationsScreen(),
      },
      {
        'title': 'Advanced DP Telemetry',
        'icon': '🔌',
        'desc': 'Direct Data-Point logger and controller',
        'widget': const AdvancedTelemetryScreen(),
      },
      {
        'title': 'Barista User Profile',
        'icon': '👤',
        'desc': 'Tuya account session status, cloud cluster',
        'widget': const UserProfileScreen(),
      },
      {
        'title': 'Calibration Statistics',
        'icon': '📊',
        'desc': 'Historical extraction curves and usage metrics',
        'widget': const StatisticsScreen(),
      },
    ];

    return Scaffold(
      backgroundColor: ElenzaTheme.matteBlack,
      appBar: AppBar(
        title: Column(
          children: const [
            Text(
              'SYSTEM HARDWARE DECK',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Color(0xA8FFFFFF),
                letterSpacing: 2.0,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'SYSTEM SETTINGS',
              style: TextStyle(
                fontFamily: 'Space Grotesk',
                fontSize: 16,
                letterSpacing: 6,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'HARDWARE CONTROLS',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: ElenzaTheme.textMuted,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: settingsMenu.length,
              itemBuilder: (context, index) {
                final item = settingsMenu[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => item['widget'] as Widget,
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ElenzaTheme.graphiteDark,
                      border: Border.all(color: ElenzaTheme.graphiteLight, width: 1.0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: ElenzaTheme.graphiteMedium,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    item['icon'] as String,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title'] as String,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['desc'] as String,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 10,
                                        color: ElenzaTheme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward,
                          color: ElenzaTheme.bronzeAccent,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
