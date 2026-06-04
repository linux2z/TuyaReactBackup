import React from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { ElenzaTheme } from 'src/theme/ElenzaTheme';

export function NotificationsScreen({ navigation }: any) {
  const alerts = [
    { id: '1', type: 'warning', title: 'Low Water Level Threshold', desc: 'Water tank level has dropped below 15%. Fill boiler tank with purified water before brewing.', time: '10 mins ago' },
    { id: '2', type: 'success', title: 'Firmware Flash Verified', desc: 'Ecosystem was successfully upgraded to transponder build version v1.4.2.', time: '2 hours ago' },
    { id: '3', type: 'info', title: 'Descaling Cycle Recommendation', desc: 'System has processed 150 shots. We recommend scheduling a backflush and group head wash.', time: 'Yesterday' },
    { id: '4', type: 'success', title: 'Burr Alignment Diagnostic', desc: 'Grinder burr micro-spacing gap successfully calibrated at 180μm.', time: '3 days ago' },
  ];

  return (
    <ScrollView contentContainerStyle={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backBtn} onPress={() => navigation.goBack()}>
          <Text style={styles.backArrow}>←</Text>
        </TouchableOpacity>
        <Text style={ElenzaTheme.typography.brandSubtitle}>SYSTEM HARDWARE ALERTS</Text>
        <Text style={styles.brandTitle}>NOTIFICATIONS</Text>
      </View>

      <Text style={styles.sectionTitle}>ALERT LOGS</Text>

      <View style={styles.list}>
        {alerts.map((alert) => (
          <View key={alert.id} style={styles.item}>
            <View style={styles.itemHeader}>
              <View style={styles.titleRow}>
                <View 
                  style={[
                    styles.indicator, 
                    alert.type === 'success' && { backgroundColor: ElenzaTheme.colors.green },
                    alert.type === 'warning' && { backgroundColor: '#ff4d4d' },
                    alert.type === 'info' && { backgroundColor: ElenzaTheme.colors.cyan }
                  ]} 
                />
                <Text style={styles.titleText}>{alert.title}</Text>
              </View>
              <Text style={styles.timeText}>{alert.time}</Text>
            </View>
            <Text style={styles.descText}>{alert.desc}</Text>
          </View>
        ))}
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
  sectionTitle: {
    fontFamily: 'Inter',
    fontSize: 10,
    fontWeight: 'bold',
    color: ElenzaTheme.colors.textMuted,
    letterSpacing: 1.5,
    marginBottom: 20,
    textTransform: 'uppercase',
  },
  list: {
    width: '100%',
  },
  item: {
    backgroundColor: ElenzaTheme.colors.card,
    borderColor: ElenzaTheme.colors.borderLight,
    borderWidth: 1,
    padding: 20,
    borderRadius: 20,
    marginBottom: 16,
  },
  itemHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
  },
  titleRow: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
    marginRight: 10,
  },
  indicator: {
    width: 6,
    height: 6,
    borderRadius: 3,
    marginRight: 10,
  },
  titleText: {
    fontFamily: 'Inter',
    fontSize: 13,
    fontWeight: 'bold',
    color: '#fff',
  },
  timeText: {
    fontFamily: 'Inter',
    fontSize: 9,
    color: ElenzaTheme.colors.textMuted,
  },
  descText: {
    fontFamily: 'Inter',
    fontSize: 11,
    lineHeight: 18,
    color: 'rgba(255,255,255,0.6)',
  },
});
