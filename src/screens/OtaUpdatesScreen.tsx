import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ScrollView, ActivityIndicator, NativeModules, NativeEventEmitter } from 'react-native';
import { useTuyaStore } from 'src/state/tuyaStore';
import { ElenzaTheme } from 'src/theme/ElenzaTheme';

const { TuyaOta } = NativeModules;
const otaEmitter = TuyaOta ? new NativeEventEmitter(TuyaOta) : null;

export function OtaUpdatesScreen({ navigation }: any) {
  const activeDevice = useTuyaStore((state) => state.activeDevice);
  const [checking, setChecking] = useState(false);
  const [upgrading, setUpgrading] = useState(false);
  const [progress, setProgress] = useState(0);
  const [otaInfo, setOtaInfo] = useState<{ current: string; next: string; desc: string; hasUpgrade: boolean } | null>(null);

  useEffect(() => {
    let progressListener: any = null;

    if (otaEmitter) {
      progressListener = otaEmitter.addListener('onOtaProgress', (event) => {
        if (event) {
          setProgress(event.progress || 0);
          if (event.status === 'success') {
            setUpgrading(false);
            alert('Hardware firmware upgraded successfully! Machine rebooting.');
            setOtaInfo(null);
          }
        }
      });
    }

    // Trigger initial check
    handleCheck();

    return () => {
      progressListener?.remove();
    };
  }, []);

  const handleCheck = async () => {
    if (!activeDevice) return;
    setChecking(true);
    try {
      if (TuyaOta) {
        const infoList = await TuyaOta.checkFirmwareUpdate(activeDevice.devId);
        if (infoList && infoList.length > 0) {
          const mainFirmware = infoList[0];
          setOtaInfo({
            current: mainFirmware.currentVersion,
            next: mainFirmware.newVersion,
            desc: mainFirmware.upgradeDescription || 'Calibrated thermodynamic wave improvements and micro-alignment stability loops.',
            hasUpgrade: mainFirmware.hasUpgrade,
          });
        } else {
          setOtaInfo({
            current: '1.4.2',
            next: '1.4.2',
            desc: 'System is fully aligned with Tuya repositories.',
            hasUpgrade: false,
          });
        }
      } else {
        // Fallback Mock
        setTimeout(() => {
          setOtaInfo({
            current: '1.4.2',
            next: '1.5.0',
            desc: 'Calibrated boiler thermodynamic wave enhancements, burr coupling gap micro-adjustments, and Matter protocol additions.',
            hasUpgrade: true,
          });
          setChecking(false);
        }, 1200);
      }
    } catch (e) {
      console.log('OTA check fail', e);
    } finally {
      setChecking(false);
    }
  };

  const handleUpgrade = async () => {
    if (!activeDevice) return;
    setUpgrading(true);
    setProgress(0);

    try {
      if (TuyaOta) {
        await TuyaOta.startFirmwareUpgrade(activeDevice.devId);
      } else {
        // Mock Progress
        let p = 0;
        const interval = setInterval(() => {
          p += 10;
          setProgress(p);
          if (p >= 100) {
            clearInterval(interval);
            setUpgrading(false);
            alert('Ecosystem updated. Booting new firmware kernel.');
            setOtaInfo({
              current: '1.5.0',
              next: '1.5.0',
              desc: 'System is fully aligned with Tuya repositories.',
              hasUpgrade: false,
            });
          }
        }, 600);
      }
    } catch (e) {
      setUpgrading(false);
      alert('Firmware deployment rejected: Check Wi-Fi transponder strength');
    }
  };

  return (
    <ScrollView contentContainerStyle={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backBtn} onPress={() => navigation.goBack()}>
          <Text style={styles.backArrow}>←</Text>
        </TouchableOpacity>
        <Text style={ElenzaTheme.typography.brandSubtitle}>HARDWARE TRANSPONDER UPDATES</Text>
        <Text style={styles.brandTitle}>OTA FIRMWARE</Text>
      </View>

      {checking && (
        <View style={styles.loadingBox}>
          <ActivityIndicator color={ElenzaTheme.colors.bronze} size="large" />
          <Text style={styles.loadingText}>Connecting Tuya Update Clusters...</Text>
        </View>
      )}

      {!checking && otaInfo && (
        <View style={styles.main}>
          <View style={styles.card}>
            <Text style={styles.cardTitle}>FIRMWARE BUILD COMPARATOR</Text>
            
            <View style={styles.versionRow}>
              <View style={styles.versionCol}>
                <Text style={styles.verLabel}>Current Version</Text>
                <Text style={styles.verVal}>{otaInfo.current}</Text>
              </View>
              <Text style={styles.arrowIcon}>→</Text>
              <View style={styles.versionCol}>
                <Text style={styles.verLabel}>Target Version</Text>
                <Text style={[styles.verVal, otaInfo.hasUpgrade && { color: ElenzaTheme.colors.bronze }]}>{otaInfo.next}</Text>
              </View>
            </View>

            <View style={styles.divider} />

            <Text style={styles.descLabel}>Calibrated Release Notes</Text>
            <Text style={styles.descVal}>{otaInfo.desc}</Text>
          </View>

          {otaInfo.hasUpgrade ? (
            !upgrading ? (
              <TouchableOpacity style={styles.actionBtn} onPress={handleUpgrade}>
                <Text style={styles.actionText}>INITIATE FIRMWARE FLASH</Text>
              </TouchableOpacity>
            ) : (
              <View style={styles.progressContainer}>
                <View style={styles.barTrack}>
                  <View style={[styles.barFill, { width: `${progress}%` }]} />
                </View>
                <Text style={styles.progressText}>Flashing Transponder Kernel: {progress}% Complete</Text>
              </View>
            )
          ) : (
            <View style={styles.verifiedBox}>
              <Text style={styles.checkIcon}>✔</Text>
              <Text style={styles.verifiedText}>System kernel fully synchronized with cloud servers</Text>
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
    marginBottom: 40,
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
  loadingBox: {
    alignItems: 'center',
  },
  loadingText: {
    fontFamily: 'Inter',
    fontSize: 11,
    color: ElenzaTheme.colors.textSecondary,
    marginTop: 20,
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  main: {
    width: '100%',
  },
  card: {
    backgroundColor: ElenzaTheme.colors.surface,
    borderColor: ElenzaTheme.colors.borderLight,
    borderWidth: 1,
    borderRadius: 30,
    padding: 24,
    marginBottom: 30,
  },
  cardTitle: {
    fontFamily: 'Inter',
    fontSize: 8,
    fontWeight: 'bold',
    color: ElenzaTheme.colors.textMuted,
    letterSpacing: 1.5,
    marginBottom: 24,
  },
  versionRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-around',
    marginBottom: 24,
  },
  versionCol: {
    alignItems: 'center',
  },
  verLabel: {
    fontFamily: 'Inter',
    fontSize: 9,
    color: ElenzaTheme.colors.textSecondary,
    textTransform: 'uppercase',
  },
  verVal: {
    fontFamily: 'Space Grotesk',
    fontSize: 24,
    fontWeight: 'bold',
    color: '#fff',
    marginTop: 6,
  },
  arrowIcon: {
    color: 'rgba(255,255,255,0.2)',
    fontSize: 24,
  },
  divider: {
    height: 1,
    backgroundColor: 'rgba(255,255,255,0.03)',
    marginBottom: 20,
  },
  descLabel: {
    fontFamily: 'Inter',
    fontSize: 9,
    color: ElenzaTheme.colors.textMuted,
    textTransform: 'uppercase',
    letterSpacing: 0.5,
    marginBottom: 8,
  },
  descVal: {
    fontFamily: 'Inter',
    fontSize: 12,
    lineHeight: 20,
    color: 'rgba(255,255,255,0.7)',
  },
  actionBtn: {
    backgroundColor: ElenzaTheme.colors.bronze,
    paddingVertical: 18,
    borderRadius: 20,
    alignItems: 'center',
    justifyContent: 'center',
  },
  actionText: {
    fontFamily: 'Space Grotesk',
    fontSize: 11,
    fontWeight: 'bold',
    color: '#000',
    letterSpacing: 1.0,
  },
  progressContainer: {
    alignItems: 'center',
  },
  barTrack: {
    width: '100%',
    height: 6,
    backgroundColor: 'rgba(255,255,255,0.05)',
    borderRadius: 3,
    overflow: 'hidden',
    marginBottom: 16,
  },
  barFill: {
    height: '100%',
    backgroundColor: ElenzaTheme.colors.bronze,
    borderRadius: 3,
  },
  progressText: {
    fontFamily: 'Inter',
    fontSize: 10,
    color: ElenzaTheme.colors.textSecondary,
    textTransform: 'uppercase',
  },
  verifiedBox: {
    alignItems: 'center',
    paddingVertical: 16,
  },
  checkIcon: {
    fontSize: 32,
    color: ElenzaTheme.colors.green,
    marginBottom: 12,
  },
  verifiedText: {
    fontFamily: 'Inter',
    fontSize: 12,
    color: ElenzaTheme.colors.green,
    textAlign: 'center',
    fontWeight: 'bold',
  },
});
