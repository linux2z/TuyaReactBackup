import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../state/tuya_state.dart';

class DeviceManagementScreen extends StatelessWidget {
  const DeviceManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tuyaState = Provider.of<TuyaState>(context);
    final activeDevice = tuyaState.activeDevice;

    void handleUnbind() {
      tuyaState.setActiveDevice(null);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: ElenzaTheme.graphiteDark,
          title: const Text('Device Unbound', style: TextStyle(color: ElenzaTheme.bronzeAccent)),
          content: const Text('Device unbound successfully from Tuya account context.', style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('OK', style: TextStyle(color: ElenzaTheme.bronzeAccent)),
            ),
          ],
        ),
      );
    }

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
                      'TUYA DEVICE SIGNATURE',
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
                      'HARDWARE DETAILS',
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

              // Hardware Info Card
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
                      'ACTIVE SIGNATURE',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: ElenzaTheme.textMuted,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildRow('Device Name', activeDevice?.name ?? 'No machine linked'),
                    _buildRow('Device Identifier (Id)', activeDevice?.devId ?? 'dev_elenza_pro_calibrator'),
                    _buildRow('Product Type ID', activeDevice?.productId ?? 'zt36shl6ah0sffsj'),
                    _buildRow('Firmware Build', 'v1.4.2-Production'),
                    _buildRow('Cloud RSSI', '-42 dBm (Excellent)'),
                    _buildRow('Network Protocol', 'MQTT over TLS 1.3'),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Unbind Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent, width: 1.0),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: activeDevice == null ? null : handleUnbind,
                  child: const Text('UNBIND & REMOVE DEVICE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String val) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0x05FFFFFF), width: 1.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: Colors.white.withOpacity(0.55),
            ),
          ),
          Text(
            val,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
