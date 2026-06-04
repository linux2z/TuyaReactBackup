import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LogItem {
  final String id;
  final String title;
  final String time;
  final String type; // 'success' | 'info' | 'warning'

  LogItem({
    required this.id,
    required this.title,
    required this.time,
    required this.type,
  });
}

class TelemetryState extends ChangeNotifier {
  static const _telemetryEvents = EventChannel('com.elenza.app/telemetry_events');
  static const _controlChannel = MethodChannel('com.elenza.app/control');

  double _waterTank = 85.0; // %
  double _beanHopper = 88.0; // %
  double _filterLife = 92.0; // %
  double _boilerTemp = 93.0; // °C
  double _pumpPressure = 0.0; // Bar
  double _flowRate = 0.0; // ml/s
  String _machineState = 'Ready'; // 'Ready' | 'Preheating' | 'Calibrating' | 'Brewing' | 'Offline'
  bool _isOnline = true;
  int _extractionSeconds = 0;

  List<LogItem> _logs = [
    LogItem(id: '1', title: 'Double Espresso extraction complete', time: '9:41 AM', type: 'success'),
    LogItem(id: '2', title: 'Calibrated boiler thermodynamic wave init', time: '8:15 AM', type: 'info'),
    LogItem(id: '3', title: 'Automatic group head cleaning cycle completed', time: 'Yesterday', type: 'success'),
  ];

  List<double> _pressureCurve = [];
  List<double> _flowCurve = [];
  List<double> _weeklyIndex = [60, 40, 55, 50, 85, 45, 35]; // Mon-Sun

  StreamSubscription? _telemetrySubscription;
  Timer? _mockTimer;

  // Getters
  double get waterTank => _waterTank;
  double get beanHopper => _beanHopper;
  double get filterLife => _filterLife;
  double get boilerTemp => _boilerTemp;
  double get pumpPressure => _pumpPressure;
  double get flowRate => _flowRate;
  String get machineState => _machineState;
  bool get isOnline => _isOnline;
  int get extractionSeconds => _extractionSeconds;
  List<LogItem> get logs => _logs;
  List<double> get pressureCurve => _pressureCurve;
  List<double> get flowCurve => _flowCurve;
  List<double> get weeklyIndex => _weeklyIndex;

  // Bean Profiles
  final List<Map<String, dynamic>> _myBeans = [];
  List<Map<String, dynamic>> get myBeans => _myBeans;

  void addBeanProfile(String name, double temp, double pressure, double flow, double time) {
    _myBeans.add({
      'name': name,
      'temp': temp,
      'pressure': pressure,
      'flow': flow,
      'time': time,
      'addedOn': DateTime.now().toIso8601String(),
    });
    notifyListeners();
  }

  void addLog(String title, {String type = 'info'}) {
    final now = DateTime.now();
    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";
    _logs.insert(0, LogItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      time: timeStr,
      type: type,
    ));
    if (_logs.length > 10) {
      _logs = _logs.sublist(0, 10);
    }
    notifyListeners();
  }

  void resetCurves() {
    _pressureCurve.clear();
    _flowCurve.clear();
    _extractionSeconds = 0;
    notifyListeners();
  }

  Future<void> startTelemetry(String devId) async {
    _telemetrySubscription?.cancel();
    _telemetrySubscription = _telemetryEvents.receiveBroadcastStream(devId).listen((data) {
      if (data is Map) {
        final dps = data['dps'] as Map?;
        if (dps != null) {
          _updateDps(dps);
        }
      }
    }, onError: (err) {
      addLog('Telemetry connection failed. Running in standalone mode.', type: 'warning');
    });
  }

  void _updateDps(Map dps) {
    if (dps['101'] != null) _boilerTemp = (dps['101'] as num).toDouble();
    if (dps['102'] != null) {
      _pumpPressure = (dps['102'] as num).toDouble();
      if (_machineState == 'Brewing') {
        _pressureCurve.add(_pumpPressure);
      }
    }
    if (dps['103'] != null) {
      _flowRate = (dps['103'] as num).toDouble();
      if (_machineState == 'Brewing') {
        _flowCurve.add(_flowRate);
      }
    }
    if (dps['104'] != null) _waterTank = (dps['104'] as num).toDouble();
    if (dps['105'] != null) _beanHopper = (dps['105'] as num).toDouble();
    if (dps['106'] != null) _filterLife = (dps['106'] as num).toDouble();
    notifyListeners();
  }

  Future<void> stopTelemetry(String devId) async {
    _telemetrySubscription?.cancel();
    _telemetrySubscription = null;
    _mockTimer?.cancel();
    _mockTimer = null;
  }

  Future<void> triggerPreheat(String devId) async {
    _machineState = 'Preheating';
    _boilerTemp = 22.0;
    notifyListeners();
    
    addLog('Preheat phase initiated: Thermodynamic induction loading', type: 'info');

    try {
      await _controlChannel.invokeMethod('sendCommands', {
        'devId': devId,
        'commands': {'107': true},
      });
    } catch (e) {
      // ignore, mock takes over
    }

    _mockTimer?.cancel();
    _mockTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_boilerTemp < 93.0) {
        _boilerTemp += Random().nextInt(8) + 4;
        if (_boilerTemp > 93.0) _boilerTemp = 93.0;
        notifyListeners();
      } else {
        timer.cancel();
        _machineState = 'Ready';
        addLog('Calibrated boiler thermo stabilization at 93°C', type: 'success');
        notifyListeners();
      }
    });
  }

  Future<void> triggerBrewSession(String devId, double targetTemp, double targetYield) async {
    _machineState = 'Brewing';
    _extractionSeconds = 0;
    _pressureCurve = [0.0];
    _flowCurve = [0.0];
    _pumpPressure = 0.0;
    _flowRate = 0.0;
    notifyListeners();

    addLog('Triggering Brew Session: Target ${targetYield.toInt()}ml at ${targetTemp.toInt()}°C', type: 'info');

    try {
      await _controlChannel.invokeMethod('sendCommands', {
        'devId': devId,
        'commands': {
          '108': true,
          '101': targetTemp,
          '109': targetYield,
        },
      });
    } catch (e) {
      // ignore
    }

    _mockTimer?.cancel();
    _mockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _extractionSeconds++;
      double pressure = 0.0;
      double flow = 0.0;

      if (_extractionSeconds <= 3) {
        pressure = 2.0 + Random().nextDouble() * 0.4;
        flow = 0.4 + Random().nextDouble() * 0.1;
      } else if (_extractionSeconds <= 15) {
        pressure = 9.0 + Random().nextDouble() * 0.3;
        flow = 2.0 + Random().nextDouble() * 0.2;
      } else if (_extractionSeconds <= 25) {
        pressure = 8.5 - (_extractionSeconds - 15) * 0.1 + Random().nextDouble() * 0.2;
        flow = 2.2 + (_extractionSeconds - 15) * 0.05;
      } else {
        pressure = 7.0 - (_extractionSeconds - 25) * 0.6;
        flow = 1.0 - (_extractionSeconds - 25) * 0.2;
      }

      if (pressure < 0) pressure = 0;
      if (flow < 0) flow = 0;

      _pumpPressure = double.parse(pressure.toStringAsFixed(1));
      _flowRate = double.parse(flow.toStringAsFixed(1));
      _pressureCurve.add(_pumpPressure);
      _flowCurve.add(_flowRate);
      _waterTank = max(10.0, _waterTank - 0.25);
      
      notifyListeners();

      if (_extractionSeconds >= 28) {
        timer.cancel();
        _machineState = 'Ready';
        _pumpPressure = 0.0;
        _flowRate = 0.0;
        addLog('Espresso Extraction complete: Yielded ${targetYield.toInt()}ml in 28s', type: 'success');
        
        // Increment Friday weekly count
        _weeklyIndex[4] = _weeklyIndex[4] + 1;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _telemetrySubscription?.cancel();
    _mockTimer?.cancel();
    super.dispose();
  }
}
