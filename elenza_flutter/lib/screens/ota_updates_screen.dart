import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../state/tuya_state.dart';

class OtaUpdatesScreen extends StatefulWidget {
  const OtaUpdatesScreen({super.key});

  @override
  State<OtaUpdatesScreen> createState() => _OtaUpdatesScreenState();
}

class _OtaUpdatesScreenState extends State<OtaUpdatesScreen> {
  bool _checking = false;
  bool _upgrading = false;
  int _progress = 0;
  Map<String, dynamic>? _otaInfo;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _handleCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _handleCheck() async {
    setState(() {
      _checking = true;
    });

    // Mock initial server checking
    await Future.delayed(const Duration(milliseconds: 1200));

    if (mounted) {
      setState(() {
        _otaInfo = {
          'current': '1.4.2',
          'next': '1.5.0',
          'desc': 'Calibrated boiler thermodynamic wave enhancements, burr coupling gap micro-adjustments, and Matter protocol additions.',
          'hasUpgrade': true,
        };
        _checking = false;
      });
    }
  }

  void _handleUpgrade() {
    setState(() {
      _upgrading = true;
      _progress = 0;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      setState(() {
        _progress += 10;
        if (_progress >= 100) {
          timer.cancel();
          _upgrading = false;
          _otaInfo = {
            'current': '1.5.0',
            'next': '1.5.0',
            'desc': 'System is fully aligned with Tuya repositories.',
            'hasUpgrade': false,
          };
          _showCompleteDialog();
        }
      });
    });
  }

  void _showCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ElenzaTheme.graphiteDark,
        title: const Text('Upgrade Successful', style: TextStyle(color: ElenzaTheme.bronzeAccent)),
        content: const Text('Ecosystem updated. Booting new firmware kernel.', style: TextStyle(color: Colors.white)),
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
    final tuyaState = Provider.of<TuyaState>(context);
    final activeDevice = tuyaState.activeDevice;

    return Scaffold(
      backgroundColor: ElenzaTheme.matteBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
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
                      'HARDWARE TRANSPONDER UPDATES',
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
                      'OTA FIRMWARE',
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
              const SizedBox(height: 40),

              if (_checking) ...[
                const SizedBox(height: 60),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(ElenzaTheme.bronzeAccent),
                ),
                const SizedBox(height: 20),
                const Text(
                  'CONNECTING TUYA UPDATE CLUSTERS...',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: ElenzaTheme.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ] else if (_otaInfo != null) ...[
                // Comparison Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: ElenzaTheme.graphiteDark,
                    border: Border.all(color: ElenzaTheme.graphiteLight, width: 1.0),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'FIRMWARE BUILD COMPARATOR',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: ElenzaTheme.textMuted,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text(
                                'Current Version',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 9,
                                  color: ElenzaTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _otaInfo!['current'] as String,
                                style: const TextStyle(
                                  fontFamily: 'Space Grotesk',
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const Icon(Icons.arrow_forward, color: Colors.white30, size: 24),
                          Column(
                            children: [
                              const Text(
                                'Target Version',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 9,
                                  color: ElenzaTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _otaInfo!['next'] as String,
                                style: TextStyle(
                                  fontFamily: 'Space Grotesk',
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: (_otaInfo!['hasUpgrade'] as bool)
                                      ? ElenzaTheme.bronzeAccent
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(height: 1, color: Colors.white.withOpacity(0.03)),
                      const SizedBox(height: 20),
                      const Text(
                        'Calibrated Release Notes',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9,
                          color: ElenzaTheme.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _otaInfo!['desc'] as String,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          height: 1.6,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                if (_otaInfo!['hasUpgrade'] as bool) ...[
                  if (!_upgrading)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        onPressed: activeDevice == null ? null : _handleUpgrade,
                        child: const Text('INITIATE FIRMWARE FLASH'),
                      ),
                    )
                  else
                    Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              FractionallySizedBox(
                                widthFactor: _progress / 100.0,
                                child: Container(
                                  color: ElenzaTheme.bronzeAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'FLASHING TRANSPONDER KERNEL: $_progress% COMPLETE',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            color: ElenzaTheme.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                ] else
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: const [
                          Icon(Icons.check_circle_outline, color: ElenzaTheme.emeraldGreen, size: 36),
                          SizedBox(height: 12),
                          Text(
                            'System kernel fully synchronized with cloud servers',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: ElenzaTheme.emeraldGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
