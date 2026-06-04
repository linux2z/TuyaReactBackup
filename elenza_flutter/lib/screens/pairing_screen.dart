import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../state/tuya_state.dart';

class PairingScreen extends StatefulWidget {
  const PairingScreen({super.key});

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  final _ssidController = TextEditingController(text: 'Elenza_Espresso_HQ');
  final _passwordController = TextEditingController();

  bool _isPairing = false;
  int _progress = 0;
  String _statusText = 'Standby - Awaiting Network Credentials';
  String? _errorMsg;
  Timer? _timer;

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _handlePairing() {
    final ssid = _ssidController.text.trim();
    if (ssid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in Wi-Fi SSID')),
      );
      return;
    }

    final tuyaState = Provider.of<TuyaState>(context, listen: false);
    if (tuyaState.homeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tuya Home ID not generated yet')),
      );
      return;
    }

    tuyaState.startEZPairing(ssid, _passwordController.text);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tuyaState = Provider.of<TuyaState>(context);
    
    if (_isPairing && !tuyaState.isPairingInProgress) {
      // Pairing finished (success or fail)
      if (tuyaState.activeDevice != null && tuyaState.activeDevice!.name.isNotEmpty) {
        // Success
        _progress = 100;
        _statusText = 'Device bound successfully!';
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      } else {
        // Failed
        _errorMsg = tuyaState.pairingStatus;
        _isPairing = false;
      }
    } else if (tuyaState.isPairingInProgress) {
      _isPairing = true;
      _statusText = tuyaState.pairingStatus;
      // Fake progress increment for visual feedback while waiting for real native callback
      if (_progress < 90) {
        _progress += 1;
      }
    }
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
                      'HARDWARE INTEGRATION',
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
                      'ECOSYSTEM PAIRING',
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

              if (!_isPairing) ...[
                const Text(
                  'Initialize the EZ Link transmitter. Power on the ELENZA machine and hold the Brew button for 5 seconds until the LED ring pulses yellow.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    height: 1.6,
                    color: ElenzaTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),

                const Text(
                  'WI-FI NETWORK NAME (SSID)',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: ElenzaTheme.textSecondary,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _ssidController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'SSID Name',
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'WI-FI PASSWORD',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: ElenzaTheme.textSecondary,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: '••••••••••••',
                  ),
                ),

                const SizedBox(height: 35),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    onPressed: _handlePairing,
                    child: const Text('INITIATE COUPLING WAVE'),
                  ),
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
                            Text(
                              '$_progress%',
                              style: const TextStyle(
                                fontFamily: 'Space Grotesk',
                                fontSize: 40,
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
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        _statusText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 30),
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(ElenzaTheme.bronzeAccent),
                      ),
                      if (_errorMsg != null) ...[
                        const SizedBox(height: 30),
                        Text(
                          _errorMsg!,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Colors.redAccent,
                          ),
                        ),
                        const SizedBox(height: 20),
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                               _isPairing = false;
                               _progress = 0;
                            });
                          },
                          child: const Text('Retry Calibration'),
                        ),
                      ],
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
}
