import React, { useEffect } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, Image, Alert } from 'react-native';
import { useTuyaStore } from 'src/state/tuyaStore';
import { useTelemetryStore } from 'src/state/telemetryStore';
import { ElenzaTheme } from 'src/theme/ElenzaTheme';

export function HomeDashboard({ navigation }: any) {
  const activeDevice = useTuyaStore((state) => state.activeDevice);
  const devices = useTuyaStore((state) => state.devices);
  const user = useTuyaStore((state) => state.user);

  const waterTank = useTelemetryStore((state) => state.waterTank);
  const beanHopper = useTelemetryStore((state) => state.beanHopper);
  const filterLife = useTelemetryStore((state) => state.filterLife);
  const boilerTemp = useTelemetryStore((state) => state.boilerTemp);
  const machineState = useTelemetryStore((state) => state.machineState);
  const logs = useTelemetryStore((state) => state.logs);
  
  const startTelemetry = useTelemetryStore((state) => state.startTelemetry);
  const stopTelemetry = useTelemetryStore((state) => state.stopTelemetry);
  const triggerPreheat = useTelemetryStore((state) => state.triggerPreheat);

  useEffect(() => {
    if (activeDevice) {
      startTelemetry(activeDevice.devId);
    }
    return () => {
      if (activeDevice) {
        stopTelemetry(activeDevice.devId);
      }
    };
  }, [activeDevice]);

  const handlePreheat = () => {
    if (!activeDevice) {
      Alert.alert('Ecosystem Alert', 'No active ELENZA machine bonded. Please pair a device first.');
      return;
    }
    triggerPreheat(activeDevice.devId);
  };

  return (
    <View style={styles.container}>
      {/* Top Header */}
      <View style={styles.header}>
        <TouchableOpacity onPress={() => navigation.navigate('UserProfile')}>
          <Text style={styles.headerIcon}>👤</Text>
        </TouchableOpacity>
        <View style={styles.headerTitleContainer}>
          <Text style={ElenzaTheme.typography.brandSubtitle}>IoT Smart Ecosystem</Text>
          <Text style={styles.brandTitle}>E L E N Z A</Text>
        </View>
        <TouchableOpacity style={styles.notifBtn} onPress={() => navigation.navigate('Notifications')}>
          <Text style={styles.headerIcon}>🔔</Text>
          <View style={styles.notifBadge} />
        </TouchableOpacity>
      </View>

      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        
        {/* Hero Machine Card */}
        <View style={styles.heroCard}>
          <View style={styles.heroHeader}>
            <View>
              <Text style={styles.heroSubTitle}>Elenza Pro Platform</Text>
              <Text style={styles.heroPID}>PID: {activeDevice?.devId || 'Awaiting Link'}</Text>
            </View>
            {activeDevice ? (
              <View style={styles.onlinePill}>
                <View style={styles.onlineLed} />
                <Text style={styles.onlineText}>{machineState === 'Offline' ? 'Offline' : 'Online'}</Text>
              </View>
            ) : (
              <TouchableOpacity 
                style={styles.pairBtn} 
                onPress={() => navigation.navigate('DevicePairing')}
              >
                <Text style={styles.pairBtnText}>Pair Machine</Text>
              </TouchableOpacity>
            )}
          </View>

          {/* Machine image container */}
          <View style={styles.imageContainer}>
            <View style={styles.imageOverlay} />
            <Image 
              source={{ uri: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCRJcImNKATjXcIG0YI4Lc36ZWiA0VtrFrp3cJzXZ8LGO0IKCQFwEvTnpaXaBNSkJDBIIrpLiCMetb_yKbfkmuwFVJtp2WCOLGegJ9cM10IljL8oGUtSdrl8_NGhD_mT063jab8eS_xkRMA6PX7bfcZOAtTTjiaj075hMSqyVKCjMdSFGkf_drEG-DqBopn7xA8kfwjnR5e4x7KSgv5Mu4ACi2vMaddeTFPTZNk5T6nddy88iZeDHsm042zc8I_bqlFkGmn2Zns8wqm' }}
              style={styles.machineImage}
              resizeMode="cover"
            />
          </View>
        </View>

        {/* Triple Quick Metrics Card */}
        <View style={styles.tripleMetricGrid}>
          <View style={styles.metricCard}>
            <Text style={styles.metricIcon}>🛡️</Text>
            <Text style={ElenzaTheme.typography.metricLabel}>Health</Text>
            <Text style={ElenzaTheme.typography.metricValue}>100<Text style={styles.metricPercent}>%</Text></Text>
          </View>

          <View style={styles.metricCard}>
            <Text style={styles.metricIcon}>🫘</Text>
            <Text style={ElenzaTheme.typography.metricLabel}>Beans</Text>
            <Text style={ElenzaTheme.typography.metricValue}>{beanHopper}<Text style={styles.metricPercent}>%</Text></Text>
          </View>

          <View style={styles.metricCard}>
            <Text style={styles.metricIcon}>🌡️</Text>
            <Text style={ElenzaTheme.typography.metricLabel}>Boiler</Text>
            <Text style={styles.metricValue}>{boilerTemp}°C</Text>
          </View>
        </View>

        {/* Vertical Resource Gauges */}
        <View style={styles.tripleMetricGrid}>
          {/* Water Tank */}
          <View style={[styles.metricCard, styles.gaugeCard]}>
            <View>
              <Text style={styles.gaugeTitle}>Water Tank</Text>
              <Text style={styles.gaugeValue}>{waterTank}%</Text>
            </View>
            <View style={styles.verticalTrack}>
              <View style={[styles.verticalLevel, { height: `${waterTank}%`, backgroundColor: ElenzaTheme.colors.cyan }]} />
            </View>
          </View>

          {/* Filter Life */}
          <View style={[styles.metricCard, styles.gaugeCard]}>
            <View>
              <Text style={styles.gaugeTitle}>Filter Life</Text>
              <Text style={styles.gaugeValue}>{filterLife}%</Text>
            </View>
            <View style={styles.verticalTrack}>
              <View style={[styles.verticalLevel, { height: `${filterLife}%`, backgroundColor: ElenzaTheme.colors.green }]} />
            </View>
          </View>

          {/* Machine Calibration Status */}
          <View style={[styles.metricCard, { justifyContent: 'center' }]}>
            <Text style={styles.metricIcon}>⚡</Text>
            <Text style={ElenzaTheme.typography.metricLabel}>Status</Text>
            <Text style={[styles.metricValue, { fontSize: 13, color: ElenzaTheme.colors.cyan, textTransform: 'uppercase', letterSpacing: 0.5, marginTop: 8 }]}>
              {machineState}
            </Text>
          </View>
        </View>

        {/* Barista Intelligence Recommendation */}
        <View style={styles.intelligenceCard}>
          <View style={styles.bronzeVerticalLine} />
          <View style={styles.intelligenceHeader}>
            <Text style={styles.intelligenceHeaderIcon}>💡</Text>
            <Text style={styles.intelligenceTitle}>Barista Intelligence Recommendation</Text>
          </View>
          <Text style={styles.intelligenceBody}>
            Your brewing timeline indicates an 8:00 AM coffee routine. We recommend pre-heating the group head at 7:55 AM for a calibrated <Text style={styles.highlightText}>Double Espresso</Text> shot today.
          </Text>
        </View>

        {/* Brewing logs */}
        <View style={styles.logsCard}>
          <Text style={styles.logsTitle}>LATEST BREWING LOGS</Text>
          <View style={styles.logsList}>
            {logs.slice(0, 3).map((log) => (
              <View key={log.id} style={styles.logItem}>
                <View style={[styles.logIndicator, { borderColor: log.type === 'success' ? ElenzaTheme.colors.green : ElenzaTheme.colors.cyan }]}>
                  <Text style={[styles.logCheck, { color: log.type === 'success' ? ElenzaTheme.colors.green : ElenzaTheme.colors.cyan }]}>✓</Text>
                </View>
                <View style={{ flex: 1 }}>
                  <Text style={styles.logText}>{log.title}</Text>
                  <Text style={styles.logTime}>{log.time}</Text>
                </View>
              </View>
            ))}
          </View>
        </View>

        {/* Bottom Preheat CTA */}
        <View style={styles.preheatCTA}>
          <View>
            <Text style={styles.ctaTitle}>Quick Pre-Heat</Text>
            <Text style={styles.ctaSub}>Stabilize Thermodynamic boilers</Text>
          </View>
          <TouchableOpacity 
            style={[styles.preheatBtn, machineState === 'Preheating' && styles.preheatBtnActive]} 
            onPress={handlePreheat}
            disabled={machineState === 'Preheating'}
          >
            <Text style={styles.preheatBtnText}>
              {machineState === 'Preheating' ? 'HEATING...' : 'PREHEAT NOW'}
            </Text>
          </TouchableOpacity>
        </View>

      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: ElenzaTheme.colors.background,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 24,
    paddingTop: 50,
    paddingBottom: 16,
    borderBottomWidth: 1,
    borderColor: ElenzaTheme.colors.borderLight,
    backgroundColor: 'rgba(5, 5, 5, 0.85)',
  },
  headerIcon: {
    fontSize: 20,
    color: '#fff',
  },
  headerTitleContainer: {
    alignItems: 'center',
  },
  brandTitle: {
    fontFamily: 'Space Grotesk',
    fontSize: 16,
    letterSpacing: 6,
    color: '#fff',
    fontWeight: 'bold',
  },
  notifBtn: {
    position: 'relative',
  },
  notifBadge: {
    position: 'absolute',
    top: 0,
    right: 0,
    width: 6,
    height: 6,
    borderRadius: 3,
    backgroundColor: ElenzaTheme.colors.bronze,
  },
  scrollContent: {
    padding: 20,
    paddingBottom: 110,
  },
  heroCard: {
    backgroundColor: ElenzaTheme.colors.surface,
    borderColor: ElenzaTheme.colors.borderLight,
    borderWidth: 1,
    borderRadius: 30,
    padding: 20,
    marginBottom: 20,
    overflow: 'hidden',
  },
  heroHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 20,
  },
  heroSubTitle: {
    fontFamily: 'Space Grotesk',
    fontSize: 12,
    fontWeight: 'bold',
    color: ElenzaTheme.colors.bronze,
    textTransform: 'uppercase',
    letterSpacing: 1.0,
  },
  heroPID: {
    fontFamily: 'Inter',
    fontSize: 8,
    color: ElenzaTheme.colors.textMuted,
    marginTop: 2,
  },
  onlinePill: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(0, 0, 0, 0.4)',
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: ElenzaTheme.colors.borderLight,
  },
  onlineLed: {
    width: 6,
    height: 6,
    borderRadius: 3,
    backgroundColor: ElenzaTheme.colors.green,
    marginRight: 6,
    shadowColor: ElenzaTheme.colors.green,
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.8,
    shadowRadius: 4,
  },
  onlineText: {
    fontFamily: 'Inter',
    fontSize: 8,
    fontWeight: 'bold',
    color: ElenzaTheme.colors.green,
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  pairBtn: {
    backgroundColor: ElenzaTheme.colors.bronze,
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 12,
  },
  pairBtnText: {
    fontFamily: 'Inter',
    fontSize: 9,
    fontWeight: 'bold',
    color: '#000',
    textTransform: 'uppercase',
  },
  imageContainer: {
    width: '100%',
    height: 200,
    borderRadius: 20,
    overflow: 'hidden',
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.05)',
  },
  imageOverlay: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: 'rgba(0, 0, 0, 0.25)',
    zIndex: 1,
  },
  machineImage: {
    width: '100%',
    height: '100%',
  },
  tripleMetricGrid: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 16,
  },
  metricCard: {
    flex: 1,
    backgroundColor: ElenzaTheme.colors.card,
    borderColor: ElenzaTheme.colors.borderLight,
    borderWidth: 1,
    borderRadius: 20,
    padding: 16,
    marginHorizontal: 4,
    alignItems: 'center',
  },
  metricIcon: {
    fontSize: 16,
    marginBottom: 8,
  },
  metricPercent: {
    fontSize: 10,
    color: 'rgba(255, 255, 255, 0.4)',
  },
  gaugeCard: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  gaugeTitle: {
    fontFamily: 'Inter',
    fontSize: 8,
    fontWeight: 'bold',
    color: 'rgba(255, 255, 255, 0.4)',
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  gaugeValue: {
    fontFamily: 'Space Grotesk',
    fontSize: 20,
    fontWeight: 'bold',
    color: '#fff',
    marginTop: 4,
  },
  verticalTrack: {
    width: 6,
    height: 48,
    backgroundColor: 'rgba(255,255,255,0.05)',
    borderRadius: 3,
    overflow: 'hidden',
    justifyContent: 'flex-end',
  },
  verticalLevel: {
    width: '100%',
    borderRadius: 3,
  },
  intelligenceCard: {
    backgroundColor: ElenzaTheme.colors.card,
    borderColor: ElenzaTheme.colors.borderLight,
    borderWidth: 1,
    borderRadius: 24,
    padding: 20,
    position: 'relative',
    overflow: 'hidden',
    marginBottom: 20,
  },
  bronzeVerticalLine: {
    position: 'absolute',
    left: 0,
    top: 0,
    bottom: 0,
    width: 4,
    backgroundColor: ElenzaTheme.colors.bronze,
  },
  intelligenceHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 10,
  },
  intelligenceHeaderIcon: {
    fontSize: 14,
    marginRight: 8,
  },
  intelligenceTitle: {
    fontFamily: 'Inter',
    fontSize: 9,
    fontWeight: 'bold',
    color: ElenzaTheme.colors.bronze,
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  intelligenceBody: {
    fontFamily: 'Inter',
    fontSize: 11,
    lineHeight: 18,
    color: 'rgba(255, 255, 255, 0.6)',
  },
  highlightText: {
    color: ElenzaTheme.colors.bronze,
    fontWeight: 'bold',
  },
  logsCard: {
    backgroundColor: ElenzaTheme.colors.card,
    borderColor: ElenzaTheme.colors.borderLight,
    borderWidth: 1,
    borderRadius: 24,
    padding: 20,
    marginBottom: 20,
  },
  logsTitle: {
    fontFamily: 'Inter',
    fontSize: 8,
    fontWeight: 'bold',
    color: ElenzaTheme.colors.textMuted,
    letterSpacing: 1.5,
    marginBottom: 16,
  },
  logsList: {
    width: '100%',
  },
  logItem: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 16,
  },
  logIndicator: {
    width: 20,
    height: 20,
    borderRadius: 10,
    borderWidth: 1,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 12,
  },
  logCheck: {
    fontSize: 10,
    fontWeight: 'bold',
  },
  logText: {
    fontFamily: 'Inter',
    fontSize: 11,
    color: 'rgba(255, 255, 255, 0.8)',
    fontWeight: '500',
  },
  logTime: {
    fontFamily: 'Inter',
    fontSize: 8,
    color: ElenzaTheme.colors.textMuted,
    marginTop: 2,
  },
  preheatCTA: {
    backgroundColor: ElenzaTheme.colors.card,
    borderColor: ElenzaTheme.colors.borderLight,
    borderWidth: 1,
    borderRadius: 24,
    padding: 16,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  ctaTitle: {
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: 'bold',
    color: '#fff',
  },
  ctaSub: {
    fontFamily: 'Inter',
    fontSize: 9,
    color: ElenzaTheme.colors.textMuted,
    marginTop: 2,
  },
  preheatBtn: {
    backgroundColor: ElenzaTheme.colors.bronze,
    paddingHorizontal: 20,
    paddingVertical: 12,
    borderRadius: 14,
  },
  preheatBtnActive: {
    backgroundColor: '#2a2a2a',
    borderColor: ElenzaTheme.colors.borderMedium,
    borderWidth: 1,
  },
  preheatBtnText: {
    fontFamily: 'Space Grotesk',
    fontSize: 10,
    fontWeight: 'bold',
    color: '#000',
    letterSpacing: 1.0,
  },
});
