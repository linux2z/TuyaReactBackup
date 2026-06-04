import React from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { ElenzaTheme } from 'src/theme/ElenzaTheme';

export function MachineSettingsScreen({ navigation }: any) {
  const settingsMenu = [
    { title: 'Maintenance Center', icon: '🧼', route: 'Maintenance', desc: 'Backflush, descale, and clean group head' },
    { title: 'Device Management', icon: '📱', route: 'DeviceDetails', desc: 'Tuya device ID, product signature, RSSI values' },
    { title: 'OTA Firmware Updates', icon: '📡', route: 'OtaUpdates', desc: 'Check and apply hardware flash updates' },
    { title: 'Notifications Center', icon: '🔔', route: 'Notifications', desc: 'Hardware alerts, water levels, cleaning prompts' },
    { title: 'Advanced DP Telemetry', icon: '🔌', route: 'AdvancedTelemetry', desc: 'Direct Data-Point logger and controller' },
    { title: 'Barista User Profile', icon: '👤', route: 'UserProfile', desc: 'Tuya account session status, cloud cluster' },
  ];

  return (
    <View style={styles.container}>
      {/* Top Header */}
      <View style={styles.header}>
        <View style={styles.headerTitleContainer}>
          <Text style={ElenzaTheme.typography.brandSubtitle}>SYSTEM HARDWARE DECK</Text>
          <Text style={styles.brandTitle}>SYSTEM SETTINGS</Text>
        </View>
      </View>

      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        <Text style={styles.sectionTitle}>HARDWARE CONTROLS</Text>

        <View style={styles.menu}>
          {settingsMenu.map((item) => (
            <TouchableOpacity 
              key={item.title} 
              style={styles.menuItem}
              onPress={() => navigation.navigate(item.route)}
            >
              <View style={styles.menuLeft}>
                <View style={styles.iconCircle}>
                  <Text style={styles.icon}>{item.icon}</Text>
                </View>
                <View style={styles.textContainer}>
                  <Text style={styles.menuTitle}>{item.title}</Text>
                  <Text style={styles.menuDesc}>{item.desc}</Text>
                </View>
              </View>
              <Text style={styles.arrow}>→</Text>
            </TouchableOpacity>
          ))}
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
    paddingHorizontal: 24,
    paddingTop: 50,
    paddingBottom: 16,
    borderBottomWidth: 1,
    borderColor: ElenzaTheme.colors.borderLight,
    backgroundColor: 'rgba(5, 5, 5, 0.85)',
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
  scrollContent: {
    padding: 20,
    paddingBottom: 110,
  },
  sectionTitle: {
    fontFamily: 'Inter',
    fontSize: 10,
    fontWeight: 'bold',
    color: ElenzaTheme.colors.textMuted,
    letterSpacing: 1.5,
    marginBottom: 20,
    textTransform: 'uppercase',
  },
  menu: {
    width: '100%',
  },
  menuItem: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    backgroundColor: ElenzaTheme.colors.card,
    borderColor: ElenzaTheme.colors.borderLight,
    borderWidth: 1,
    padding: 16,
    borderRadius: 20,
    marginBottom: 16,
  },
  menuLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
    marginRight: 10,
  },
  iconCircle: {
    width: 40,
    height: 40,
    borderRadius: 12,
    backgroundColor: ElenzaTheme.colors.graphite,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 16,
  },
  icon: {
    fontSize: 18,
  },
  textContainer: {
    flex: 1,
  },
  menuTitle: {
    fontFamily: 'Inter',
    fontSize: 13,
    fontWeight: 'bold',
    color: '#fff',
  },
  menuDesc: {
    fontFamily: 'Inter',
    fontSize: 10,
    color: ElenzaTheme.colors.textMuted,
    marginTop: 4,
  },
  arrow: {
    color: ElenzaTheme.colors.bronze,
    fontSize: 16,
    fontWeight: 'bold',
  },
});
