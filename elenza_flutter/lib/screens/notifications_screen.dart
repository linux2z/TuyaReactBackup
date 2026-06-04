import 'package:flutter/material.dart';
import '../theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alerts = [
      {
        'id': '1',
        'type': 'warning',
        'title': 'Low Water Level Threshold',
        'desc': 'Water tank level has dropped below 15%. Fill boiler tank with purified water before brewing.',
        'time': '10 mins ago',
      },
      {
        'id': '2',
        'type': 'success',
        'title': 'Firmware Flash Verified',
        'desc': 'Ecosystem was successfully upgraded to transponder build version v1.4.2.',
        'time': '2 hours ago',
      },
      {
        'id': '3',
        'type': 'info',
        'title': 'Descaling Cycle Recommendation',
        'desc': 'System has processed 150 shots. We recommend scheduling a backflush and group head wash.',
        'time': 'Yesterday',
      },
      {
        'id': '4',
        'type': 'success',
        'title': 'Burr Alignment Diagnostic',
        'desc': 'Grinder burr micro-spacing gap successfully calibrated at 180μm.',
        'time': '3 days ago',
      },
    ];

    return Scaffold(
      backgroundColor: ElenzaTheme.matteBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Center(
                child: Column(
                  children: [
                    Text(
                      'SYSTEM HARDWARE ALERTS',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: ElenzaTheme.bronzeAccent.withOpacity(0.8),
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'NOTIFICATIONS',
                      style: TextStyle(
                        fontFamily: 'Space Grotesk',
                        fontSize: 20,
                        letterSpacing: 4,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'ALERT LOGS',
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
                itemCount: alerts.length,
                itemBuilder: (context, index) {
                  final alert = alerts[index];
                  final type = alert['type'];
                  Color typeColor = ElenzaTheme.hydraulicCyan;
                  if (type == 'success') typeColor = ElenzaTheme.emeraldGreen;
                  if (type == 'warning') typeColor = Colors.redAccent;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: ElenzaTheme.graphiteDark,
                      border: Border.all(color: ElenzaTheme.graphiteLight, width: 1.0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: typeColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      alert['title'] as String,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              alert['time'] as String,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 9,
                                color: ElenzaTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          alert['desc'] as String,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            height: 1.6,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
