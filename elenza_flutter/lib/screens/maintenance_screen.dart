import 'dart:async';
import 'package:flutter/material.dart';
import '../theme.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  bool _cleaning = false;
  int _cleaningProgress = 0;
  String? _activeCycle;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startClean(String name) {
    setState(() {
      _activeCycle = name;
      _cleaning = true;
      _cleaningProgress = 0;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      setState(() {
        _cleaningProgress += 10;
        if (_cleaningProgress >= 100) {
          timer.cancel();
          _cleaning = false;
          _activeCycle = null;
          _showCompleteDialog(name);
        }
      });
    });
  }

  void _showCompleteDialog(String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ElenzaTheme.graphiteDark,
        title: Text('$name Cycle Completed', style: const TextStyle(color: ElenzaTheme.bronzeAccent)),
        content: Text('$name cycle completed successfully. Group head is clean and recalibrated!', style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: ElenzaTheme.bronzeAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ElenzaTheme.matteBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Top Navigation Row
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
                      'THERMODYNAMIC REHABILITATION',
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
                      'MAINTENANCE CENTER',
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

              if (!_cleaning) ...[
                const Text(
                  'Run regular diagnostic cycles to maintain absolute temperature consistency, group head flow calibration, and scale-free boiler pipelines.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    height: 1.6,
                    color: ElenzaTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),

                // Group head backflush card
                _buildCycleCard(
                  title: 'Backflush Group Head',
                  desc: 'Deploys standard high pressure cycles to clean residual espresso oils. Requires standard blind basket and cleaning tablet.',
                  btnText: 'START BACKFLUSH CYCLE',
                  onPressed: () => _startClean('Backflush'),
                ),

                const SizedBox(height: 20),

                // Boiler descaling card
                _buildCycleCard(
                  title: 'Descale Pipeline Boiler',
                  desc: 'Flushes mineral accumulations out of the thermodynamic copper tubes. Requires descaling agent in water tank reservoir.',
                  btnText: 'START DESCALING CYCLE',
                  onPressed: () => _startClean('Descaling'),
                ),
              ] else ...[
                const SizedBox(height: 60),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: ElenzaTheme.bronzeAccent, width: 4.0),
                          color: Colors.white.withOpacity(0.01),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(ElenzaTheme.bronzeAccent),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '$_cleaningProgress%',
                              style: const TextStyle(
                                fontFamily: 'Space Grotesk',
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              'COMPLETE',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 8,
                                color: ElenzaTheme.textMuted,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'Executing $_activeCycle Cycle',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Modulating high-pressure pump waves and boiling flow gates to purge lines...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            height: 1.6,
                            color: ElenzaTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCycleCard({
    required String title,
    required String desc,
    required String btnText,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ElenzaTheme.graphiteDark,
        border: Border.all(color: ElenzaTheme.graphiteLight, width: 1.0),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Space Grotesk',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              height: 1.6,
              color: ElenzaTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onPressed,
              child: Text(btnText),
            ),
          ),
        ],
      ),
    );
  }
}
