import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ScrollView } from 'react-native';
import { useTuyaStore } from 'src/state/tuyaStore';
import { ElenzaTheme } from 'src/theme/ElenzaTheme';

export function DeviceManagementScreen({ navigation }: any) {
  const activeDevice = useTuyaStore((state) => state.activeDevice);
  const setActiveDevice = useTuyaStore((state) => state.setActiveDevice);

  const handleUnbind = () => {
    // Unbind and clear device state
    setActiveDevice(null);
    alert('Device unbound successfully from Tuya account context');
    navigation.goBack();
  };

  return (
    <ScrollView contentContainerStyle={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backBtn} onPress={() => navigation.goBack()}>
          <Text style={styles.backArrow}>←</Text>
        </TouchableOpacity>
        <Text style={ElenzaTheme.typography.brandSubtitle}>TUYA DEVICE SIGNATURE</Text>
        <Text style={styles.brandTitle}>HARDWARE DETAILS</Text>
      </View>

      <View style={styles.card}>
        <Text style={styles.title}>ACTIVE SIGNATURE</Text>

        <View style={styles.row}>
          <Text style={styles.label}>Device Name</Text>
          <Text style={styles.val}>{activeDevice?.name || 'No machine linked'}</Text>
        </View>

        <View style={styles.row}>
          <Text style={styles.label}>Device Identifier (Id)</Text>
          <Text style={styles.val}>{activeDevice?.devId || 'dev_elenza_pro_calibrator'}</Text>
        </View>

        <View style={styles.row}>
          <Text style={styles.label}>Product Type ID</Text>
          <Text style={styles.val}>{activeDevice?.productId || 'zt36shl6ah0sffsj'}</Text>
        </View>

        <View style={styles.row}>
          <Text style={styles.label}>Firmware Build</Text>
          <Text style={styles.val}>v1.4.2-Production</Text>
        </View>

        <View style={styles.row}>
          <Text style={styles.label}>Cloud RSSI</Text>
          <Text style={styles.val}>-42 dBm (Excellent)</Text>
        </View>

        <View style={styles.row}>
          <Text style={styles.label}>Network Protocol</Text>
          <Text style={styles.val}>MQTT over TLS 1.3</Text>
        </View>
      </View>

      <TouchableOpacity style={styles.unbindBtn} onPress={handleUnbind}>
        <Text style={styles.unbindText}>UNBIND & REMOVE DEVICE</Text>
      </TouchableOpacity>
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
  card: {
    backgroundColor: ElenzaTheme.colors.surface,
    borderColor: ElenzaTheme.colors.borderLight,
    borderWidth: 1,
    borderRadius: 30,
    padding: 24,
    marginBottom: 40,
  },
  title: {
    fontFamily: 'Inter',
    fontSize: 8,
    fontWeight: 'bold',
    color: ElenzaTheme.colors.textMuted,
    letterSpacing: 1.5,
    marginBottom: 24,
  },
  row: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: 14,
    borderBottomWidth: 1,
    borderColor: 'rgba(255,255,255,0.02)',
  },
  label: {
    fontFamily: 'Inter',
    fontSize: 11,
    color: 'rgba(255,255,255,0.5)',
  },
  val: {
    fontFamily: 'Inter',
    fontSize: 11,
    fontWeight: 'bold',
    color: '#fff',
  },
  unbindBtn: {
    borderColor: '#ff4d4d',
    borderWidth: 1,
    paddingVertical: 18,
    borderRadius: 20,
    alignItems: 'center',
    justifyContent: 'center',
  },
  unbindText: {
    fontFamily: 'Space Grotesk',
    fontSize: 10,
    fontWeight: 'bold',
    color: '#ff4d4d',
    letterSpacing: 1.0,
  },
});
