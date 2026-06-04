import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../state/tuya_state.dart';
import '../state/telemetry_state.dart';

class AdvancedTelemetryScreen extends StatefulWidget {
  const AdvancedTelemetryScreen({super.key});

  @override
  State<AdvancedTelemetryScreen> createState() => _AdvancedTelemetryScreenState();
}

class _AdvancedTelemetryScreenState extends State<AdvancedTelemetryScreen> {
  final _dpIdController = TextEditingController(text: '101');
  final _payloadController = TextEditingController(text: '95');

  bool _isOnline = true;
  bool _bleScanning = false;
  List<Map<String, dynamic>> _bleDevices = [];

  final List<String> _terminalLogs = [
    'SYSTEM DECK INITIALIZED: Listening on Tuya secure MQTT cluster...',
    'RESOLVED NODE: us.coap.tuya.com (TLS 1.3)',
    'GATEWAY STATUS: WebSocket Connected (Online)',
  ];

  @override
  void dispose() {
    _dpIdController.dispose();
    _payloadController.dispose();
    super.dispose();
  }

  void _addLog(String msg) {
    final now = DateTime.now();
    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    setState(() {
      _terminalLogs.insert(0, '[$timeStr] $msg');
      if (_terminalLogs.length > 50) {
        _terminalLogs.removeLast();
      }
    });
  }

  void _handleSendDp() {
    final dp = _dpIdController.text.trim();
    final val = _payloadController.text.trim();

    if (dp.isEmpty || val.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out both target DP and payload value')),
      );
      return;
    }

    final telemetryState = Provider.of<TelemetryState>(context, listen: false);

    // Replicate React Native logic updates
    if (dp == '101') {
      // Boiler Temp
      final temp = double.tryParse(val) ?? 95.0;
      telemetryState.triggerPreheat('dev_elenza_pro_calibrator'); // triggers Heating or sets temp
      _addLog('TX PACKET: DP 101 (Boiler Temp) -> $temp°C');
    } else if (dp == '104') {
      // Water level
      _addLog('TX PACKET: DP 104 (Water Level) -> $val%');
    } else if (dp == '105') {
      // Bean hopper
      _addLog('TX PACKET: DP 105 (Bean Hopper) -> $val%');
    } else {
      _addLog('TX PACKET: Custom DP $dp -> "$val"');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dispatched payload DP $dp with value "$val"')),
    );
  }

  void _handleToggleOnline(bool val) {
    setState(() {
      _isOnline = val;
    });
    if (!val) {
      _addLog('GATEWAY ALERT: WiFi Socket Disconnected. Activating offline telemetry buffer...');
    } else {
      _addLog('GATEWAY STATUS: WiFi Socket Re-established. Purging 12 buffered telemetry frames...');
    }
  }

  void _handleStartBleScan() {
    if (_bleScanning) {
      setState(() {
        _bleScanning = false;
      });
      _addLog('BLE ENGINE: Scanning suspended.');
    } else {
      setState(() {
        _bleDevices.clear();
        _bleScanning = true;
      });
      _addLog('BLE ENGINE: Initiating BLE active discovery transponder...');

      // Mock BLE discover after short delay
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted && _bleScanning) {
          final mockDevice = {
            'mac': 'BC:8A:29:CF:E1:92',
            'name': 'ELENZA Pro Hybrid',
            'productId': 'zt36shl6ah0sffsj',
            'rssi': -52,
          };
          _addLog('BLE FOUND: ${mockDevice['name']} [MAC: ${mockDevice['mac']}]');
          setState(() {
            _bleDevices.add(mockDevice);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final telemetryState = Provider.of<TelemetryState>(context);
    final boilerTemp = telemetryState.boilerTemp;
    final pumpPressure = telemetryState.pumpPressure;
    final flowRate = telemetryState.flowRate;
    final waterTank = telemetryState.waterTank;
    final beanHopper = telemetryState.beanHopper;
    final filterLife = telemetryState.filterLife;

    final dps = [
      {'dpId': '101', 'name': 'Boiler Temperature Target', 'current': '${boilerTemp.toInt()}°C'},
      {'dpId': '102', 'name': 'Pump Extraction Pressure', 'current': '${pumpPressure.toStringAsFixed(1)} Bar'},
      {'dpId': '103', 'name': 'Flow Meter Velocity', 'current': '${flowRate.toStringAsFixed(1)} ml/s'},
      {'dpId': '104', 'name': 'Water Tank Reservoir Remaining', 'current': '${waterTank.toInt()}%'},
      {'dpId': '105', 'name': 'Bean Hopper Load Index', 'current': '${beanHopper.toInt()}%'},
      {'dpId': '106', 'name': 'Filter Core Lifecycle Remaining', 'current': '${filterLife.toInt()}%'},
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
                      'SYSTEM HARDWARE DECK',
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
                      'DEVELOPER CONSOLE',
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

              // Network Simulator Card
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
                      'ECOSYSTEM RECONNECT & BUFFER SIMULATOR',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: ElenzaTheme.textMuted,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ecosystem Connection Gateway',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isOnline ? 'Online (MQTT Connected)' : 'Offline (Buffering active telemetry)',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10,
                                  color: ElenzaTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isOnline,
                          onChanged: _handleToggleOnline,
                          activeColor: ElenzaTheme.bronzeAccent,
                          activeTrackColor: ElenzaTheme.bronzeAccent.withOpacity(0.3),
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: const Color(0xFF3A3A3A),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Raw DP Input Console Card
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
                      'DP REGISTER COMPILER',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: ElenzaTheme.textMuted,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'DP ID',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 8,
                                  color: ElenzaTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _dpIdController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                decoration: const InputDecoration(
                                  hintText: 'e.g. 101',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'VALUE PAYLOAD',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 8,
                                  color: ElenzaTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _payloadController,
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                decoration: const InputDecoration(
                                  hintText: 'e.g. 95',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _handleSendDp,
                        child: const Text('DISPATCH DATA POINT PACKET'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // BLE Discovery Coupler Card
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'BLE DISCOVERY COUPLER',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: ElenzaTheme.textMuted,
                            letterSpacing: 1.0,
                          ),
                        ),
                        GestureDetector(
                          onTap: _handleStartBleScan,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: ElenzaTheme.bronzeAccent),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                if (_bleScanning) ...[
                                  const SizedBox(
                                    width: 10,
                                    height: 10,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(ElenzaTheme.bronzeAccent),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Text(
                                  _bleScanning ? 'SUSPEND' : 'DISCOVER BLE',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: ElenzaTheme.bronzeAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (_bleDevices.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _bleDevices.length,
                        itemBuilder: (context, index) {
                          final dev = _bleDevices[index];
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
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dev['name'] as String,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'MAC: ${dev['mac']} | RSSI: ${dev['rssi']}dBm',
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 9,
                                        color: ElenzaTheme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'PID: ${dev['productId']}',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: ElenzaTheme.bronzeAccent,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    else
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            'No active Bluetooth modules scanning',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              color: ElenzaTheme.textMuted,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // DP Schema list
              const Text(
                'ACTIVE DP SCHEMA CONFIG',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: ElenzaTheme.textMuted,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: ElenzaTheme.graphiteDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ElenzaTheme.graphiteLight, width: 1.0),
                ),
                padding: const EdgeInsets.all(16),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: dps.length,
                  itemBuilder: (context, index) {
                    final dp = dps[index];
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
                          Text(
                            'DP ${dp['dpId']}',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: ElenzaTheme.bronzeAccent,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              dp['name'] as String,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          Text(
                            dp['current'] as String,
                            style: const TextStyle(
                              fontFamily: 'Space Grotesk',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Terminal Logs
              const Text(
                'WEBSOCKET TELEMETRY LOGS (REAL-TIME)',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: ElenzaTheme.textMuted,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 160,
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _terminalLogs.length,
                  itemBuilder: (context, index) {
                    return Text(
                      _terminalLogs[index],
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 9,
                        color: Color(0xFF00FF66),
                        height: 1.5,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
