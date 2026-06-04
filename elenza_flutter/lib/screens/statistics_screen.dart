import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../state/telemetry_state.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final telemetryState = Provider.of<TelemetryState>(context);
    final logs = telemetryState.logs;
    final weeklyIndex = telemetryState.weeklyIndex;

    final days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

    // Calculate total weekly cups
    int totalWeeklyCups = weeklyIndex.fold(0, (sum, val) => sum + val.toInt());

    return Scaffold(
      backgroundColor: ElenzaTheme.matteBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Back Arrow
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
                      'SYSTEM METRICS PLATFORM',
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
                      'STATISTICS',
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

              // Weekly Index Bar Chart Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ElenzaTheme.graphiteDark,
                  border: Border.all(color: ElenzaTheme.graphiteLight, width: 1.0),
                  borderRadius: BorderRadius.circular(24),
                ),
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
                              'Weekly Index',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: ElenzaTheme.textMuted,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$totalWeeklyCups Shots Extracted',
                              style: const TextStyle(
                                fontFamily: 'Space Grotesk',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: ElenzaTheme.emeraldGreen.withOpacity(0.1),
                            border: Border.all(color: ElenzaTheme.emeraldGreen.withOpacity(0.2)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '+15% VS LAST WEEK',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: ElenzaTheme.emeraldGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Custom bar chart columns
                    SizedBox(
                      height: 140,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(weeklyIndex.length, (idx) {
                          final val = weeklyIndex[idx];
                          final day = days[idx];
                          final isFriday = day == 'Fr';

                          return Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Container(
                                    width: 8,
                                    decoration: BoxDecoration(
                                      color: isFriday
                                          ? ElenzaTheme.bronzeAccent.withOpacity(0.1)
                                          : Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        FractionallySizedBox(
                                          heightFactor: (val / 100.0).clamp(0.0, 1.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: isFriday
                                                  ? ElenzaTheme.bronzeAccent
                                                  : Colors.white.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  day,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 10,
                                    color: isFriday ? ElenzaTheme.bronzeAccent : ElenzaTheme.textMuted,
                                    fontWeight: isFriday ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Quick Stats Grid
              Row(
                children: [
                  _buildQuickStatCard('💧', 'Water Index', '8.4 Liters'),
                  _buildQuickStatCard('🛡️', 'Energy Rating', 'A+++ Grade'),
                ],
              ),

              const SizedBox(height: 16),

              // Activity History Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ElenzaTheme.graphiteDark,
                  border: Border.all(color: ElenzaTheme.graphiteLight, width: 1.0),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ELENZA ACTIVITY HISTORY',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: ElenzaTheme.textMuted,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        final log = logs[index];
                        final isSuccess = log.type == 'success';
                        final color = isSuccess ? ElenzaTheme.emeraldGreen : ElenzaTheme.hydraulicCyan;

                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Color(0x05FFFFFF), width: 1.0),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        log.title,
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 11,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                log.time,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 9,
                                  color: ElenzaTheme.textMuted,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStatCard(String icon, String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ElenzaTheme.graphiteDark,
          border: Border.all(color: ElenzaTheme.graphiteLight, width: 1.0),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontFamily: 'Space Grotesk',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
}
