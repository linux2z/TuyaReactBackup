import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../state/tuya_state.dart';
import '../state/telemetry_state.dart';
import 'user_profile_screen.dart';
import 'notifications_screen.dart';
import 'pairing_screen.dart';

class ConsoleTab extends StatefulWidget {
  const ConsoleTab({super.key});

  @override
  State<ConsoleTab> createState() => _ConsoleTabState();
}

class _ConsoleTabState extends State<ConsoleTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tuyaState = Provider.of<TuyaState>(context, listen: false);
      if (tuyaState.activeDevice != null) {
        Provider.of<TelemetryState>(context, listen: false)
            .startTelemetry(tuyaState.activeDevice!.devId);
      }
    });
  }

  void _handlePreheat() {
    final tuyaState = Provider.of<TuyaState>(context, listen: false);
    final telemetryState = Provider.of<TelemetryState>(context, listen: false);

    if (tuyaState.activeDevice == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: ElenzaTheme.graphiteDark,
          title: const Text('Ecosystem Alert', style: TextStyle(color: ElenzaTheme.bronzeAccent)),
          content: const Text('No active ELENZA machine bonded. Please pair a device first.', style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK', style: TextStyle(color: ElenzaTheme.bronzeAccent)),
            ),
          ],
        ),
      );
      return;
    }
    telemetryState.triggerPreheat(tuyaState.activeDevice!.devId);
  }

  @override
  Widget build(BuildContext context) {
    final tuyaState = Provider.of<TuyaState>(context);
    final telemetryState = Provider.of<TelemetryState>(context);

    final activeDevice = tuyaState.activeDevice;
    final waterTank = telemetryState.waterTank;
    final beanHopper = telemetryState.beanHopper;
    final filterLife = telemetryState.filterLife;
    final boilerTemp = telemetryState.boilerTemp;
    final machineState = telemetryState.machineState;
    final logs = telemetryState.logs;

    return Scaffold(
      backgroundColor: ElenzaTheme.matteBlack,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.person_outline, color: Colors.white),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const UserProfileScreen()),
            );
          },
        ),
        title: Column(
          children: const [
            Text(
              'IoT Smart Ecosystem',
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
              'E L E N Z A',
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
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                  );
                },
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: ElenzaTheme.bronzeAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 40),
        child: Column(
          children: [
            // Hero Machine Card
            Container(
              decoration: BoxDecoration(
                color: ElenzaTheme.graphiteDark,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: ElenzaTheme.graphiteLight, width: 1.0),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ELENZA PRO PLATFORM',
                            style: TextStyle(
                              fontFamily: 'Space Grotesk',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: ElenzaTheme.bronzeAccent,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'PID: ${activeDevice?.devId ?? 'Awaiting Link'}',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 8,
                              color: ElenzaTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                      if (activeDevice != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: ElenzaTheme.graphiteLight, width: 1.0),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: ElenzaTheme.emeraldGreen,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: ElenzaTheme.emeraldGreen,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                machineState == 'Offline' ? 'OFFLINE' : 'ONLINE',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: ElenzaTheme.emeraldGreen,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ElenzaTheme.bronzeAccent,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const PairingScreen()),
                            );
                          },
                          child: const Text('PAIR MACHINE'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Machine Image Container
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/machine.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: ElenzaTheme.graphiteMedium,
                              child: const Icon(
                                Icons.coffee_maker,
                                size: 50,
                                color: ElenzaTheme.bronzeAccent,
                              ),
                            );
                          },
                        ),
                        Container(
                          color: Colors.black.withOpacity(0.25),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Triple Quick Metrics Grid
            Row(
              children: [
                _buildMetricCard(
                  icon: '🛡️',
                  label: 'Health',
                  value: '100',
                  unit: '%',
                ),
                _buildMetricCard(
                  icon: '🫘',
                  label: 'Beans',
                  value: beanHopper.toInt().toString(),
                  unit: '%',
                ),
                _buildMetricCard(
                  icon: '🌡️',
                  label: 'Boiler',
                  value: boilerTemp.toInt().toString(),
                  unit: '°C',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Vertical Resource Gauges
            Row(
              children: [
                // Water Tank Gauge
                _buildGaugeCard(
                  title: 'Water Tank',
                  value: '${waterTank.toInt()}%',
                  level: waterTank,
                  color: ElenzaTheme.hydraulicCyan,
                ),
                // Filter Life Gauge
                _buildGaugeCard(
                  title: 'Filter Life',
                  value: '${filterLife.toInt()}%',
                  level: filterLife,
                  color: ElenzaTheme.emeraldGreen,
                ),
                // Status Card
                Expanded(
                  child: Container(
                    height: 100,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ElenzaTheme.graphiteDark,
                      border: Border.all(color: ElenzaTheme.graphiteLight, width: 1.0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '⚡',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'STATUS',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: ElenzaTheme.textMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          machineState,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Space Grotesk',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: ElenzaTheme.hydraulicCyan,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Barista Intelligence Recommendation Card
            Container(
              decoration: BoxDecoration(
                color: ElenzaTheme.graphiteDark,
                border: Border.all(color: ElenzaTheme.graphiteLight, width: 1.0),
                borderRadius: BorderRadius.circular(24),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 4,
                    child: Container(color: ElenzaTheme.bronzeAccent),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Text('💡', style: TextStyle(fontSize: 14)),
                            SizedBox(width: 8),
                            Text(
                              'BARISTA INTELLIGENCE RECOMMENDATION',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: ElenzaTheme.bronzeAccent,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              height: 1.6,
                              color: Colors.white60,
                            ),
                            children: const [
                              TextSpan(text: 'Your brewing timeline indicates an 8:00 AM coffee routine. We recommend pre-heating the group head at 7:55 AM for a calibrated '),
                              TextSpan(
                                text: 'Double Espresso',
                                style: TextStyle(
                                  color: ElenzaTheme.bronzeAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(text: ' shot today.'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Brewing Logs Card
            Container(
              decoration: BoxDecoration(
                color: ElenzaTheme.graphiteDark,
                border: Border.all(color: ElenzaTheme.graphiteLight, width: 1.0),
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'LATEST BREWING LOGS',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: ElenzaTheme.textMuted,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: logs.length > 3 ? 3 : logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      final isSuccess = log.type == 'success';
                      final color = isSuccess ? ElenzaTheme.emeraldGreen : ElenzaTheme.hydraulicCyan;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: color, width: 1.0),
                              ),
                              child: Center(
                                child: Text(
                                  '✓',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    log.title,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    log.time,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 8,
                                      color: ElenzaTheme.textMuted,
                                    ),
                                  ),
                                ],
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

            const SizedBox(height: 20),

            // Bottom Preheat CTA
            Container(
              decoration: BoxDecoration(
                color: ElenzaTheme.graphiteDark,
                border: Border.all(color: ElenzaTheme.graphiteLight, width: 1.0),
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Quick Pre-Heat',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Stabilize Thermodynamic boilers',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9,
                          color: ElenzaTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: machineState == 'Preheating' ? null : _handlePreheat,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: machineState == 'Preheating'
                            ? const Color(0xFF2A2A2A)
                            : ElenzaTheme.bronzeAccent,
                        borderRadius: BorderRadius.circular(14),
                        border: machineState == 'Preheating'
                            ? Border.all(color: ElenzaTheme.graphiteLight)
                            : null,
                      ),
                      child: Text(
                        machineState == 'Preheating' ? 'HEATING...' : 'PREHEAT NOW',
                        style: TextStyle(
                          fontFamily: 'Space Grotesk',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: machineState == 'Preheating' ? Colors.white70 : Colors.black,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String icon,
    required String label,
    required String value,
    required String unit,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ElenzaTheme.graphiteDark,
          border: Border.all(color: ElenzaTheme.graphiteLight, width: 1.0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: ElenzaTheme.textMuted,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                children: [
                  TextSpan(text: value),
                  TextSpan(
                    text: unit,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white30,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGaugeCard({
    required String title,
    required String value,
    required double level,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.white30,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontFamily: 'Space Grotesk',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 6,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(3),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    height: 48 * (level / 100.0),
                    width: double.infinity,
                    color: color,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
