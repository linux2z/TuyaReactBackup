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
        title: Text('$name Completed', style: const TextStyle(color: ElenzaTheme.textPrimary)),
        content: Text('$name cycle completed successfully.', style: const TextStyle(color: ElenzaTheme.textSecondary)),
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ElenzaTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Maintenance',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (!_cleaning) ...[
              const Text(
                'Run regular diagnostic cycles to maintain optimal performance.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: ElenzaTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              _buildCycleCard(
                title: 'Backflush',
                desc: 'Cleans residual espresso oils from the group head. Requires blind basket.',
                icon: Icons.cleaning_services_outlined,
                onPressed: () => _startClean('Backflush'),
              ),
              const SizedBox(height: 16),
              _buildCycleCard(
                title: 'Descale',
                desc: 'Flushes mineral accumulations out of the boiler. Requires descaling agent.',
                icon: Icons.water_drop_outlined,
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
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$_cleaningProgress%',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: ElenzaTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Progress',
                            style: TextStyle(
                              fontSize: 12,
                              color: ElenzaTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'Running $_activeCycle...',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ElenzaTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please do not power off the machine.',
                      style: TextStyle(
                        fontSize: 14,
                        color: ElenzaTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCycleCard({
    required String title,
    required String desc,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ElenzaTheme.graphiteDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ElenzaTheme.graphiteLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: ElenzaTheme.textPrimary, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ElenzaTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 13,
              color: ElenzaTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: ElenzaTheme.bronzeAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Start Cycle',
                style: TextStyle(
                  color: ElenzaTheme.bronzeAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
