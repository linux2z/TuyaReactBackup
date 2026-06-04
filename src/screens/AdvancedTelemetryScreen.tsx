import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ScrollView, TextInput, Switch, ActivityIndicator, NativeModules, NativeEventEmitter } from 'react-native';
import { useTelemetryStore } from 'src/state/telemetryStore';
import { useTuyaStore } from 'src/state/tuyaStore';
import { ElenzaTheme } from 'src/theme/ElenzaTheme';

const { TuyaPairing } = NativeModules;
const pairingEmitter = TuyaPairing ? new NativeEventEmitter(TuyaPairing) : null;

export function AdvancedTelemetryScreen({ navigation }: any) {
  const activeDevice = useTuyaStore((state) => state.activeDevice);

  const waterTank = useTelemetryStore((state) => state.waterTank);
  const beanHopper = useTelemetryStore((state) => state.beanHopper);
  const filterLife = useTelemetryStore((state) => state.filterLife);
  const boilerTemp = useTelemetryStore((state) => state.boilerTemp);
  const pumpPressure = useTelemetryStore((state) => state.pumpPressure);
  const flowRate = useTelemetryStore((state) => state.flowRate);

  const [targetDp, setTargetDp] = useState('101');
  const [valToSet, setValToSet] = useState('95');
  const [isOnline, setIsOnline] = useState(true);
  const [bleScanning, setBleScanning] = useState(false);
  const [bleDevices, setBleDevices] = useState<any[]>([]);

  // Scrolling terminal logs
  const [logs, setLogs] = useState<string[]>([
    'SYSTEM DECK INITIALIZED: Listening on Tuya secure MQTT cluster...',
    'RESOLVED NODE: us.coap.tuya.com (TLS 1.3)',
    'GATEWAY STATUS: WebSocket Connected (Online)',
  ]);

  useEffect(() => {
    let bleListener: any = null;

    if (pairingEmitter) {
      bleListener = pairingEmitter.addListener('onBleDeviceDiscovered', (device) => {
        if (device) {
          setBleDevices((prev) => {
            const exists = prev.some((d) => d.mac === device.mac);
            if (!exists) {
              addLog(`BLE FOUND: ${device.name || 'Unknown'} [MAC: ${device.mac}]`);
              return [...prev, device];
            }
            return prev;
          });
        }
      });
    }

    return () => {
      bleListener?.remove();
      if (TuyaPairing) {
        TuyaPairing.stopBleScan();
      }
    };
  }, []);

  const addLog = (msg: string) => {
    const time = new Date().toLocaleTimeString();
    setLogs((prev) => [`[${time}] ${msg}`, ...prev.slice(0, 49)]);
  };

  const handleSendDp = () => {
    if (!targetDp || !valToSet) {
      alert('Please fill out both target DP and payload value');
      return;
    }
    
    // Update local state and trigger WebSocket traffic logs
    if (targetDp === '101') {
      useTelemetryStore.setState({ boilerTemp: Number(valToSet) });
      addLog(`TX PACKET: DP 101 (Boiler Temp) -> ${valToSet}°C`);
    } else if (targetDp === '104') {
      useTelemetryStore.setState({ waterTank: Number(valToSet) });
      addLog(`TX PACKET: DP 104 (Water Level) -> ${valToSet}%`);
    } else if (targetDp === '105') {
      useTelemetryStore.setState({ beanHopper: Number(valToSet) });
      addLog(`TX PACKET: DP 105 (Bean Hopper) -> ${valToSet}%`);
    } else {
      addLog(`TX PACKET: Custom DP ${targetDp} -> "${valToSet}"`);
    }
    alert(`Dispatched payload DP ${targetDp} with value "${valToSet}"`);
  };

  const handleToggleOnline = (val: boolean) => {
    setIsOnline(val);
    if (!val) {
      addLog('GATEWAY ALERT: WiFi Socket Disconnected. Activating offline telemetry buffer...');
    } else {
      addLog('GATEWAY STATUS: WiFi Socket Re-established. Purging 12 buffered telemetry frames...');
    }
  };

  const handleStartBleScan = () => {
    if (bleScanning) {
      if (TuyaPairing) TuyaPairing.stopBleScan();
      setBleScanning(false);
      addLog('BLE ENGINE: Scanning suspended.');
    } else {
      setBleDevices([]);
      setBleScanning(true);
      addLog('BLE ENGINE: Initiating BLE active discovery transponder...');
      if (TuyaPairing) {
        TuyaPairing.startBleScan();
      } else {
        // Fallback Mock results
        setTimeout(() => {
          const mockDevice = {
            mac: 'BC:8A:29:CF:E1:92',
            name: 'ELENZA Pro Hybrid',
            productId: 'zt36shl6ah0sffsj',
            rssi: -52,
          };
          addLog(`BLE FOUND: ${mockDevice.name} [MAC: ${mockDevice.mac}]`);
          setBleDevices([mockDevice]);
        }, 1200);
      }
    }
  };

  const dps = [
    { dpId: '101', name: 'Boiler Temperature Target', current: `${boilerTemp}°C` },
    { dpId: '102', name: 'Pump Extraction Pressure', current: `${pumpPressure} Bar` },
    { dpId: '103', name: 'Flow Meter Velocity', current: `${flowRate} ml/s` },
    { dpId: '104', name: 'Water Tank Reservoir Remaining', current: `${waterTank}%` },
    { dpId: '105', name: 'Bean Hopper Load Index', current: `${beanHopper}%` },
    { dpId: '106', name: 'Filter Core Lifecycle Remaining', current: `${filterLife}%` },
  ];

  return (
    <ScrollView contentContainerStyle={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backBtn} onPress={() => navigation.goBack()}>
          <Text style={styles.backArrow}>←</Text>
        </TouchableOpacity>
        <Text style={ElenzaTheme.typography.brandSubtitle}>SYSTEM HARDWARE DECK</Text>
        <Text style={styles.brandTitle}>DEVELOPER CONSOLE</Text>
      </View>

      {/* Network Sim Card */}
      <View style={styles.card}>
        <Text style={styles.cardTitle}>ECOSYSTEM RECONNECT & BUFFER SIMULATOR</Text>
        <View style={styles.switchRow}>
          <View>
            <Text style={styles.switchLbl}>Ecosystem Connection Gateway</Text>
            <Text style={styles.switchDesc}>{isOnline ? 'Online (MQTT Connected)' : 'Offline (Buffering active telemetry)'}</Text>
          </View>
          <Switch 
            value={isOnline} 
            onValueChange={handleToggleOnline}
            trackColor={{ false: '#3a3a3a', true: ElenzaTheme.colors.bronze }}
            thumbColor={isOnline ? '#000' : '#fff'}
          />
        </View>
      </View>

      {/* Raw DP input console */}
      <View style={styles.card}>
        <Text style={styles.cardTitle}>DP REGISTER COMPILER</Text>
        
        <View style={styles.rowInput}>
          <View style={{ flex: 1, marginRight: 10 }}>
            <Text style={styles.lbl}>DP ID</Text>
            <TextInput 
              style={styles.input}
              placeholder="e.g. 101"
              placeholderTextColor="rgba(255,255,255,0.2)"
              value={targetDp}
              onChangeText={setTargetDp}
              keyboardType="numeric"
            />
          </View>
          <View style={{ flex: 2 }}>
            <Text style={styles.lbl}>Value Payload</Text>
            <TextInput 
              style={styles.input}
              placeholder="e.g. 95"
              placeholderTextColor="rgba(255,255,255,0.2)"
              value={valToSet}
              onChangeText={setValToSet}
            />
          </View>
        </View>

        <TouchableOpacity style={styles.sendBtn} onPress={handleSendDp}>
          <Text style={styles.sendText}>DISPATCH DATA POINT PACKET</Text>
        </TouchableOpacity>
      </View>

      {/* BLE discovery widget */}
      <View style={styles.card}>
        <View style={styles.bleHeader}>
          <Text style={styles.cardTitle}>BLE DISCOVERY COUPLER</Text>
          <TouchableOpacity style={styles.bleScanBtn} onPress={handleStartBleScan}>
            {bleScanning ? <ActivityIndicator size="small" color={ElenzaTheme.colors.bronze} /> : null}
            <Text style={styles.bleScanText}>{bleScanning ? 'SUSPEND' : 'DISCOVER BLE'}</Text>
          </TouchableOpacity>
        </View>

        {bleDevices.length > 0 ? (
          bleDevices.map((dev) => (
            <View key={dev.mac} style={styles.bleItem}>
              <View>
                <Text style={styles.bleName}>{dev.name}</Text>
                <Text style={styles.bleMac}>MAC: {dev.mac} | RSSI: {dev.rssi}dBm</Text>
              </View>
              <Text style={styles.blePid}>PID: {dev.productId}</Text>
            </View>
          ))
        ) : (
          <Text style={styles.emptyBle}>No active Bluetooth modules scanning</Text>
        )}
      </View>

      {/* DP list */}
      <Text style={styles.sectionTitle}>ACTIVE DP SCHEMA CONFIG</Text>
      <View style={styles.dpList}>
        {dps.map((dp) => (
          <View key={dp.dpId} style={styles.dpRow}>
            <Text style={styles.dpIdText}>DP {dp.dpId}</Text>
            <Text style={styles.dpNameText}>{dp.name}</Text>
            <Text style={styles.dpValText}>{dp.current}</Text>
          </View>
        ))}
      </View>

      {/* Terminal Logs Window */}
      <Text style={styles.sectionTitle}>WEBSOCKET TELEMETRY LOGS (REAL-TIME)</Text>
      <View style={styles.terminal}>
        <ScrollView style={styles.terminalScroll} nestedScrollEnabled={true}>
          {logs.map((log, idx) => (
            <Text key={idx} style={styles.terminalText}>{log}</Text>
          ))}
        </ScrollView>
      </View>

    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flexGrow: 1,
    backgroundColor: ElenzaTheme.colors.background,
    padding: 24,
    paddingTop: 60,
  },
  header: {
    alignItems: 'center',
    marginBottom: 30,
  },
  backBtn: {
    position: 'absolute',
    left: 0,
    top: -10,
    padding: 10,
  },
  backArrow: {
    color: '#fff',
    fontSize: 20,
  },
  brandTitle: {
    ...ElenzaTheme.typography.brandTitle,
    fontSize: 20,
    marginTop: 8,
    letterSpacing: 4,
  },
  card: {
    backgroundColor: ElenzaTheme.colors.surface,
    borderColor: ElenzaTheme.colors.borderLight,
    borderWidth: 1,
    borderRadius: 24,
    padding: 20,
    marginBottom: 20,
  },
  cardTitle: {
    fontFamily: 'Inter',
    fontSize: 8,
    fontWeight: 'bold',
    color: ElenzaTheme.colors.textMuted,
    letterSpacing: 1.0,
    marginBottom: 16,
    textTransform: 'uppercase',
  },
  switchRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  switchLbl: {
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: 'bold',
    color: '#fff',
  },
  switchDesc: {
    fontFamily: 'Inter',
    fontSize: 10,
    color: ElenzaTheme.colors.textMuted,
    marginTop: 4,
  },
  rowInput: {
    flexDirection: 'row',
  },
  lbl: {
    fontFamily: 'Inter',
    fontSize: 8,
    color: ElenzaTheme.colors.textSecondary,
    marginBottom: 6,
    textTransform: 'uppercase',
  },
  input: {
    backgroundColor: 'rgba(0,0,0,0.3)',
    borderWidth: 1,
    borderColor: ElenzaTheme.colors.borderLight,
    padding: 12,
    borderRadius: 12,
    color: '#fff',
    fontSize: 12,
    marginBottom: 16,
  },
  sendBtn: {
    backgroundColor: ElenzaTheme.colors.bronze,
    paddingVertical: 14,
    borderRadius: 14,
    alignItems: 'center',
  },
  sendText: {
    fontFamily: 'Space Grotesk',
    fontSize: 9,
    fontWeight: 'bold',
    color: '#000',
    letterSpacing: 1.0,
  },
  bleHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
  },
  bleScanBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    borderColor: ElenzaTheme.colors.bronze,
    borderWidth: 1,
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 8,
  },
  bleScanText: {
    fontFamily: 'Inter',
    fontSize: 8,
    fontWeight: 'bold',
    color: ElenzaTheme.colors.bronze,
    marginLeft: 4,
  },
  bleItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 10,
    borderBottomWidth: 1,
    borderColor: 'rgba(255,255,255,0.02)',
  },
  bleName: {
    fontFamily: 'Inter',
    fontSize: 11,
    fontWeight: 'bold',
    color: '#fff',
  },
  bleMac: {
    fontFamily: 'Inter',
    fontSize: 9,
    color: ElenzaTheme.colors.textMuted,
    marginTop: 2,
  },
  blePid: {
    fontFamily: 'Inter',
    fontSize: 9,
    fontWeight: 'bold',
    color: ElenzaTheme.colors.bronze,
  },
  emptyBle: {
    fontFamily: 'Inter',
    fontSize: 10,
    color: ElenzaTheme.colors.textMuted,
    textAlign: 'center',
    paddingVertical: 10,
  },
  sectionTitle: {
    fontFamily: 'Inter',
    fontSize: 10,
    fontWeight: 'bold',
    color: ElenzaTheme.colors.textMuted,
    letterSpacing: 1.5,
    marginBottom: 16,
    textTransform: 'uppercase',
    marginTop: 10,
  },
  dpList: {
    backgroundColor: ElenzaTheme.colors.card,
    borderRadius: 20,
    borderColor: ElenzaTheme.colors.borderLight,
    borderWidth: 1,
    padding: 16,
    marginBottom: 20,
  },
  dpRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: 10,
    borderBottomWidth: 1,
    borderColor: 'rgba(255,255,255,0.02)',
  },
  dpIdText: {
    fontFamily: 'Inter',
    fontSize: 9,
    fontWeight: 'bold',
    color: ElenzaTheme.colors.bronze,
    width: 50,
  },
  dpNameText: {
    fontFamily: 'Inter',
    fontSize: 11,
    color: 'rgba(255,255,255,0.7)',
    flex: 1,
  },
  dpValText: {
    fontFamily: 'Space Grotesk',
    fontSize: 11,
    fontWeight: 'bold',
    color: '#fff',
  },
  terminal: {
    backgroundColor: '#000',
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.08)',
    borderRadius: 16,
    height: 160,
    padding: 12,
    marginBottom: 30,
  },
  terminalScroll: {
    flex: 1,
  },
  terminalText: {
    fontFamily: 'monospace',
    fontSize: 9,
    color: '#00ff66',
    lineHeight: 15,
    marginBottom: 4,
  },
});
