import React, { useState, useEffect } from 'react';
import { View, Text, TextInput, StyleSheet, TouchableOpacity, ScrollView, ActivityIndicator, NativeModules, NativeEventEmitter } from 'react-native';
import { useTuyaStore } from 'src/state/tuyaStore';
import { ElenzaTheme } from 'src/theme/ElenzaTheme';

const { TuyaPairing } = NativeModules;
const pairingEmitter = TuyaPairing ? new NativeEventEmitter(TuyaPairing) : null;

export function DevicePairingScreen({ navigation }: any) {
  const [ssid, setSsid] = useState('Elenza_Espresso_HQ');
  const [password, setPassword] = useState('');
  const [pairingMode, setPairingMode] = useState<'EZ' | 'AP'>('EZ');
  const [isPairing, setIsPairing] = useState(false);
  const [progress, setProgress] = useState(0);
  const [statusText, setStatusText] = useState('Standby - Awaiting Network Credentials');
  const [errorMsg, setErrorMsg] = useState<string | null>(null);

  const homeId = useTuyaStore((state) => state.homeId);
  const mockAddDevice = useTuyaStore((state) => state.mockAddDevice);

  useEffect(() => {
    let stepListener: any = null;
    let successListener: any = null;
    let errorListener: any = null;

    if (pairingEmitter) {
      stepListener = pairingEmitter.addListener('onPairingStep', (event) => {
        if (event) {
          setProgress(event.progress || 0);
          setStatusText(`Calibrating: ${event.step || 'Binding details'}`);
        }
      });

      successListener = pairingEmitter.addListener('onPairingSuccess', (device) => {
        setIsPairing(false);
        setProgress(100);
        setStatusText('Elenza Calibrated Machine bound successfully!');
        if (device) {
          mockAddDevice({
            devId: device.devId,
            name: device.name,
            productId: device.productId,
            isOnline: true,
          });
        }
        setTimeout(() => {
          navigation.goBack();
        }, 1500);
      });

      errorListener = pairingEmitter.addListener('onPairingError', (err) => {
        setIsPairing(false);
        setProgress(0);
        setErrorMsg(err.message || 'Verification mismatch');
        setStatusText('Binding Error - Retransmission required');
      });
    }

    return () => {
      stepListener?.remove();
      successListener?.remove();
      errorListener?.remove();
      if (TuyaPairing) {
        TuyaPairing.stopPairing();
      }
    };
  }, []);

  const handlePairing = async () => {
    if (!ssid) {
      alert('Please fill in Wi-Fi SSID');
      return;
    }
    if (!homeId) {
      alert('Tuya Home ID not generated yet');
      return;
    }

    setErrorMsg(null);
    setIsPairing(true);
    setProgress(10);
    setStatusText('Requesting cloud authentication token...');

    try {
      if (TuyaPairing) {
        const token = await TuyaPairing.getPairingToken(homeId);
        setStatusText('Acquired pairing token. Launching transponder...');
        setProgress(25);
        await TuyaPairing.startEZPairing(token, ssid, password, 100);
      } else {
        // Fallback Mock Simulation
        let percent = 25;
        const mockInterval = setInterval(() => {
          percent += Math.floor(Math.random() * 15) + 5;
          if (percent >= 100) {
            clearInterval(mockInterval);
            mockAddDevice({
              devId: 'dev_elenza_pro_calibrator',
              name: 'ELENZA Pro calibrator',
              productId: 'zt36shl6ah0sffsj',
              isOnline: true,
            });
            setProgress(100);
            setStatusText('Device bound successfully!');
            setIsPairing(false);
            setTimeout(() => navigation.goBack(), 1500);
          } else {
            setProgress(percent);
            const steps = [
              'Broadcasting EZ Wave Packet...',
              'Received device handshake acknowledgment...',
              'Deploying secure Tuya keys to device...',
              'Binding ownership to cloud ledger...',
            ];
            setStatusText(steps[Math.min(Math.floor(percent / 25), 3)]);
          }
        }, 1200);
      }
    } catch (err: any) {
      setIsPairing(false);
      setProgress(0);
      setErrorMsg(err.message || 'Pairing initialization failed');
      setStatusText('Activation aborted');
    }
  };

  return (
    <ScrollView contentContainerStyle={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backBtn} onPress={() => navigation.goBack()}>
          <Text style={styles.backArrow}>←</Text>
        </TouchableOpacity>
        <Text style={ElenzaTheme.typography.brandSubtitle}>Hardware Integration</Text>
        <Text style={styles.brandTitle}>ECOSYSTEM PAIRING</Text>
      </View>

      {!isPairing ? (
        <View style={styles.form}>
          <Text style={styles.description}>
            Initialize the EZ Link transmitter. Power on the ELENZA machine and hold the Brew button for 5 seconds until the LED ring pulses yellow.
          </Text>

          <Text style={styles.inputLabel}>Wi-Fi Network Name (SSID)</Text>
          <TextInput
            style={styles.input}
            placeholder="SSID Name"
            placeholderTextColor="rgba(255,255,255,0.2)"
            value={ssid}
            onChangeText={setSsid}
            autoCapitalize="none"
          />

          <Text style={styles.inputLabel}>Wi-Fi Password</Text>
          <TextInput
            style={styles.input}
            placeholder="••••••••••••"
            placeholderTextColor="rgba(255,255,255,0.2)"
            value={password}
            onChangeText={setPassword}
            secureTextEntry
            autoCapitalize="none"
          />

          <TouchableOpacity style={styles.primaryButton} onPress={handlePairing}>
            <Text style={styles.primaryButtonText}>INITIATE COUPLING WAVE</Text>
          </TouchableOpacity>
        </View>
      ) : (
        <View style={styles.progressContainer}>
          <View style={styles.progressCircle}>
            <Text style={styles.progressVal}>{progress}%</Text>
            <Text style={styles.progressSub}>Complete</Text>
          </View>

          <Text style={styles.statusTitle}>{statusText}</Text>
          
          <ActivityIndicator size="large" color={ElenzaTheme.colors.bronze} style={{ marginTop: 30 }} />

          {errorMsg && (
            <View style={styles.errorBox}>
              <Text style={styles.errorText}>{errorMsg}</Text>
              <TouchableOpacity 
                style={styles.retryBtn} 
                onPress={() => setIsPairing(false)}
              >
                <Text style={styles.retryText}>Retry Calibration</Text>
              </TouchableOpacity>
            </View>
          )}
        </View>
      )}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flexGrow: 1,
    backgroundColor: ElenzaTheme.colors.background,
    padding: 24,
    justifyContent: 'center',
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
    fontSize: 22,
    marginTop: 8,
    letterSpacing: 4,
  },
  description: {
    fontFamily: 'Inter',
    fontSize: 12,
    lineHeight: 18,
    color: ElenzaTheme.colors.textSecondary,
    textAlign: 'center',
    marginBottom: 40,
    paddingHorizontal: 10,
  },
  form: {
    width: '100%',
  },
  inputLabel: {
    fontFamily: 'Inter',
    fontSize: 8,
    fontWeight: 'bold',
    color: ElenzaTheme.colors.textSecondary,
    textTransform: 'uppercase',
    letterSpacing: 1.0,
    marginBottom: 8,
    marginLeft: 4,
  },
  input: {
    backgroundColor: ElenzaTheme.colors.card,
    borderWidth: 1,
    borderColor: ElenzaTheme.colors.borderLight,
    padding: 16,
    borderRadius: 16,
    color: ElenzaTheme.colors.white,
    fontFamily: 'Inter',
    fontSize: 13,
    marginBottom: 20,
  },
  primaryButton: {
    backgroundColor: ElenzaTheme.colors.bronze,
    paddingVertical: 18,
    borderRadius: 16,
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: 15,
  },
  primaryButtonText: {
    fontFamily: 'Space Grotesk',
    fontSize: 11,
    fontWeight: 'bold',
    color: '#000',
    letterSpacing: 1.5,
  },
  progressContainer: {
    alignItems: 'center',
    padding: 20,
  },
  progressCircle: {
    width: 180,
    height: 180,
    borderRadius: 90,
    borderWidth: 4,
    borderColor: ElenzaTheme.colors.bronze,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 40,
    backgroundColor: 'rgba(255,255,255,0.02)',
  },
  progressVal: {
    fontFamily: 'Space Grotesk',
    fontSize: 40,
    fontWeight: 'bold',
    color: '#fff',
  },
  progressSub: {
    fontFamily: 'Inter',
    fontSize: 10,
    textTransform: 'uppercase',
    color: ElenzaTheme.colors.textMuted,
    letterSpacing: 1.0,
    marginTop: 4,
  },
  statusTitle: {
    fontFamily: 'Inter',
    fontSize: 13,
    fontWeight: '600',
    color: '#fff',
    textAlign: 'center',
    paddingHorizontal: 20,
  },
  errorBox: {
    marginTop: 40,
    width: '100%',
    alignItems: 'center',
  },
  errorText: {
    fontFamily: 'Inter',
    fontSize: 12,
    color: '#ff4d4d',
    textAlign: 'center',
    marginBottom: 20,
  },
  retryBtn: {
    borderColor: '#ff4d4d',
    borderWidth: 1,
    paddingVertical: 12,
    paddingHorizontal: 24,
    borderRadius: 12,
  },
  retryText: {
    fontFamily: 'Inter',
    fontSize: 11,
    fontWeight: 'bold',
    color: '#ff4d4d',
    textTransform: 'uppercase',
  },
});
