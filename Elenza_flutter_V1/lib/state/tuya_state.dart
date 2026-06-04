import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TuyaUser {
  final String uid;
  final String email;
  final String sid;

  TuyaUser({required this.uid, required this.email, required this.sid});

  factory TuyaUser.fromMap(Map<dynamic, dynamic> map) {
    return TuyaUser(
      uid: map['uid'] as String? ?? '',
      email: map['email'] as String? ?? '',
      sid: map['sid'] as String? ?? '',
    );
  }
}

class TuyaDevice {
  final String devId;
  final String name;
  final String productId;
  final bool isOnline;

  TuyaDevice({
    required this.devId,
    required this.name,
    required this.productId,
    required this.isOnline,
  });

  factory TuyaDevice.fromMap(Map<dynamic, dynamic> map) {
    return TuyaDevice(
      devId: map['devId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      productId: map['productId'] as String? ?? '',
      isOnline: map['isOnline'] as bool? ?? false,
    );
  }
}

class TuyaRegion {
  final String code;
  final String name;

  TuyaRegion({required this.code, required this.name});
}

class TuyaState extends ChangeNotifier {
  static const _authChannel = MethodChannel('com.elenza.app/auth');
  static const _pairingChannel = MethodChannel('com.elenza.app/pairing');
  static const _pairingEvents = EventChannel('com.elenza.app/pairing_events');

  TuyaUser? _user;
  TuyaRegion _region = TuyaRegion(code: '1', name: 'USA/Americas');
  double? _homeId;
  String? _homeName;
  List<TuyaDevice> _devices = [];
  TuyaDevice? _activeDevice;
  bool _isLoading = false;
  String? _error;

  StreamSubscription? _pairingSubscription;
  List<Map<String, dynamic>> _discoveredBleDevices = [];
  bool _isPairingInProgress = false;
  String _pairingStatus = '';

  TuyaUser? get user => _user;
  TuyaRegion get region => _region;
  double? get homeId => _homeId;
  String? get homeName => _homeName;
  List<TuyaDevice> get devices => _devices;
  TuyaDevice? get activeDevice => _activeDevice;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Map<String, dynamic>> get discoveredBleDevices => _discoveredBleDevices;
  bool get isPairingInProgress => _isPairingInProgress;
  String get pairingStatus => _pairingStatus;

  void setRegion(TuyaRegion region) {
    _region = region;
    notifyListeners();
  }

  void setActiveDevice(TuyaDevice? device) {
    _activeDevice = device;
    notifyListeners();
  }

  Future<bool> checkSession() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final session = await _authChannel.invokeMethod('isLoggedIn');
      if (session != null) {
        _user = TuyaUser.fromMap(session as Map<dynamic, dynamic>);
        await loadHomeContext();
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (err) {
      _error = err.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final session = await _authChannel.invokeMethod('loginWithEmail', {
        'email': email,
        'password': password,
        'countryCode': _region.code,
      });

      if (session != null) {
        _user = TuyaUser.fromMap(session as Map<dynamic, dynamic>);
        await loadHomeContext();
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (err) {
      _error = err.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String code) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final session = await _authChannel.invokeMethod('registerWithEmail', {
        'email': email,
        'password': password,
        'code': code,
        'countryCode': _region.code,
      });

      if (session != null) {
        _user = TuyaUser.fromMap(session as Map<dynamic, dynamic>);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (err) {
      _error = err.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendCode(String email) async {
    try {
      await _authChannel.invokeMethod('sendVerificationCode', {
        'email': email,
        'countryCode': _region.code,
      });
      return true;
    } catch (err) {
      _error = err.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authChannel.invokeMethod('logout');
    } catch (e) {
      // ignore
    }
    _user = null;
    _homeId = null;
    _homeName = null;
    _devices = [];
    _activeDevice = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadHomeContext() async {
    try {
      final home = await _authChannel.invokeMethod('getOrCreateHome');
      if (home != null) {
        final homeMap = home as Map<dynamic, dynamic>;
        _homeId = (homeMap['homeId'] as num?)?.toDouble();
        _homeName = homeMap['name'] as String?;

        // Seed default devices to match React Native setup
        final mockElenzaMachine = TuyaDevice(
          devId: 'dev_elenza_pro_calibrator',
          name: 'ELENZA Pro calibrator',
          productId: 'zt36shl6ah0sffsj',
          isOnline: true,
        );
        _devices = [mockElenzaMachine];
        _activeDevice = mockElenzaMachine;
      }
    } catch (err) {
      _error = err.toString();
    }
    notifyListeners();
  }

  // --- Pairing & BLE Methods ---

  void startBleScan() async {
    _discoveredBleDevices.clear();
    _isPairingInProgress = true;
    _pairingStatus = 'Scanning for BLE espresso machines...';
    notifyListeners();

    _setupPairingEventsListener();

    try {
      await _pairingChannel.invokeMethod('startBleScan');
    } catch (e) {
      _pairingStatus = 'Failed to start BLE scan: $e';
      _isPairingInProgress = false;
      notifyListeners();
    }
  }

  void stopBleScan() async {
    try {
      await _pairingChannel.invokeMethod('stopBleScan');
    } catch (e) {
      // ignore
    }
    _pairingStatus = 'Scan stopped';
    _isPairingInProgress = false;
    notifyListeners();
  }

  void startBlePairing(String mac, String productId, String uuid) async {
    _isPairingInProgress = true;
    _pairingStatus = 'Pairing with BLE machine ($mac)...';
    notifyListeners();

    try {
      final token = await _pairingChannel.invokeMethod('getPairingToken', {'homeId': _homeId});
      await _pairingChannel.invokeMethod('startBlePairing', {
        'mac': mac,
        'productId': productId,
        'uuid': uuid,
        'homeId': _homeId,
        'token': token,
      });
    } catch (e) {
      _pairingStatus = 'Pairing initiation failed: $e';
      _isPairingInProgress = false;
      notifyListeners();
    }
  }

  void startEZPairing(String ssid, String wifiPass) async {
    _isPairingInProgress = true;
    _pairingStatus = 'Pairing via EZ mode (Wi-Fi)...';
    notifyListeners();

    _setupPairingEventsListener();

    try {
      final token = await _pairingChannel.invokeMethod('getPairingToken', {'homeId': _homeId});
      await _pairingChannel.invokeMethod('startEZPairing', {
        'token': token,
        'ssid': ssid,
        'wifiPass': wifiPass,
        'timeout': 100,
      });
    } catch (e) {
      _pairingStatus = 'EZ Pairing failed: $e';
      _isPairingInProgress = false;
      notifyListeners();
    }
  }

  void stopPairing() async {
    try {
      await _pairingChannel.invokeMethod('stopPairing');
    } catch (e) {
      // ignore
    }
    _pairingSubscription?.cancel();
    _pairingSubscription = null;
    _isPairingInProgress = false;
    _pairingStatus = 'Pairing cancelled';
    notifyListeners();
  }

  void _setupPairingEventsListener() {
    _pairingSubscription?.cancel();
    _pairingSubscription = _pairingEvents.receiveBroadcastStream().listen((data) {
      if (data is Map) {
        final event = data['event'] as String?;
        if (event == 'onBleDeviceDiscovered') {
          final device = data['device'] as Map?;
          if (device != null) {
            final devMac = device['mac'] as String? ?? '';
            // Add if not already present
            if (!_discoveredBleDevices.any((d) => d['mac'] == devMac)) {
              _discoveredBleDevices.add(Map<String, dynamic>.from(device));
              _pairingStatus = 'Discovered ${device['name'] ?? 'Machine'}';
              notifyListeners();
            }
          }
        } else if (event == 'onPairingSuccess') {
          final deviceMap = data['device'] as Map?;
          if (deviceMap != null) {
            final newDev = TuyaDevice.fromMap(deviceMap);
            // Re-seed devices
            if (!_devices.any((d) => d.devId == newDev.devId)) {
              _devices.add(newDev);
            }
            _activeDevice = newDev;
            _isPairingInProgress = false;
            _pairingStatus = 'Successfully bonded ${newDev.name}!';
            notifyListeners();
          }
        } else if (event == 'onPairingFailure') {
          _isPairingInProgress = false;
          final errorMsg = data['errorMsg'] as String? ?? 'Unknown error';
          _pairingStatus = 'Pairing failed: $errorMsg';
          notifyListeners();
        }
      }
    });
  }

  @override
  void dispose() {
    _pairingSubscription?.cancel();
    super.dispose();
  }
}
