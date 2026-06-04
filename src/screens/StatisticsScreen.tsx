import React from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { useTelemetryStore } from 'src/state/telemetryStore';
import { ElenzaTheme } from 'src/theme/ElenzaTheme';

export function StatisticsScreen({ navigation }: any) {
  const logs = useTelemetryStore((state) => state.logs);
  const weeklyIndex = useTelemetryStore((state) => state.weeklyIndex);

  const days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

  return (
    <View style={styles.container}>
      {/* Top Header */}
      <View style={styles.header}>
        <View style={styles.headerTitleContainer}>
          <Text style={ElenzaTheme.typography.brandSubtitle}>SYSTEM METRICS PLATFORM</Text>
          <Text style={styles.brandTitle}>STATISTICS</Text>
        </View>
      </View>

      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        
        {/* Weekly Index Column Graph */}
        <View style={styles.luxuryCard}>
          <View style={styles.weeklyHeader}>
            <View>
              <Text style={styles.weeklyLabel}>Weekly Index</Text>
              <Text style={styles.weeklyCups}>28 Shots Extracted</Text>
            </View>
            <View style={styles.trendPill}>
              <Text style={styles.trendText}>+15% VS LAST WEEK</Text>
            </View>
          </View>

          {/* Render custom bar chart columns */}
          <View style={styles.chartRow}>
            {weeklyIndex.map((val, idx) => {
              const day = days[idx];
              const isFriday = day === 'Fr'; // Friday highlight matching reference
              return (
                <View key={day} style={styles.chartCol}>
                  <View style={[styles.barTrack, isFriday && styles.activeBarTrack]}>
                    <View 
                      style={[
                        styles.barFill, 
                        { height: `${val}%` },
                        isFriday && styles.activeBarFill
                      ]} 
                    />
                  </View>
                  <Text style={[styles.dayText, isFriday && styles.activeDayText]}>{day}</Text>
                </View>
              );
            })}
          </View>
        </View>

        {/* Quick Stats Grid */}
        <View style={styles.gridRow}>
          <View style={[styles.luxuryCard, styles.gridItem]}>
            <Text style={styles.itemIcon}>💧</Text>
            <View>
              <Text style={styles.itemLabel}>Water Index</Text>
              <Text style={styles.itemVal}>8.4 Liters</Text>
            </View>
          </View>

          <View style={[styles.luxuryCard, styles.gridItem]}>
            <Text style={styles.itemIcon}>🛡️</Text>
            <View>
              <Text style={styles.itemLabel}>Energy Rating</Text>
              <Text style={styles.itemVal}>A+++ Grade</Text>
            </View>
          </View>
        </View>

        {/* Activity log */}
        <View style={styles.luxuryCard}>
          <Text style={styles.logsTitle}>ELENZA ACTIVITY HISTORY</Text>
          <View style={styles.logsList}>
            {logs.map((log) => (
              <View key={log.id} style={styles.logItem}>
                <View style={styles.logLeft}>
                  <View style={[styles.bullet, { backgroundColor: log.type === 'success' ? ElenzaTheme.colors.green : ElenzaTheme.colors.cyan }]} />
                  <Text style={styles.logText}>{log.title}</Text>
                </View>
                <Text style={styles.logTime}>{log.time}</Text>
              </View>
            ))}
          </View>
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
  luxuryCard: {
    backgroundColor: ElenzaTheme.colors.card,
    borderColor: ElenzaTheme.colors.borderLight,
    borderWidth: 1,
    borderRadius: 24,
    padding: 20,
    marginBottom: 16,
  },
  weeklyHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 24,
  },
  weeklyLabel: {
    fontFamily: 'Inter',
    fontSize: 8,
    fontWeight: 'bold',
    color: ElenzaTheme.colors.textMuted,
    textTransform: 'uppercase',
    letterSpacing: 1.0,
  },
  weeklyCups: {
    fontFamily: 'Space Grotesk',
    fontSize: 18,
    fontWeight: 'bold',
    color: '#fff',
    marginTop: 4,
  },
  trendPill: {
    backgroundColor: 'rgba(0, 223, 129, 0.1)',
    borderColor: 'rgba(0, 223, 129, 0.2)',
    borderWidth: 1,
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 20,
  },
  trendText: {
    fontFamily: 'Inter',
    fontSize: 8,
    fontWeight: 'bold',
    color: ElenzaTheme.colors.green,
  },
  chartRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-end',
    height: 140,
    paddingHorizontal: 8,
  },
  chartCol: {
    alignItems: 'center',
    flex: 1,
  },
  barTrack: {
    width: 8,
    height: 100,
    backgroundColor: 'rgba(255,255,255,0.05)',
    borderRadius: 10,
    justifyContent: 'flex-end',
    overflow: 'hidden',
  },
  activeBarTrack: {
    backgroundColor: 'rgba(197, 163, 104, 0.1)',
  },
  barFill: {
    width: '100%',
    backgroundColor: 'rgba(255, 255, 255, 0.15)',
    borderRadius: 10,
  },
  activeBarFill: {
    backgroundColor: ElenzaTheme.colors.bronze,
  },
  dayText: {
    fontFamily: 'Inter',
    fontSize: 10,
    color: ElenzaTheme.colors.textMuted,
    marginTop: 8,
  },
  activeDayText: {
    color: ElenzaTheme.colors.bronze,
    fontWeight: 'bold',
  },
  gridRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  gridItem: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    marginHorizontal: 4,
    padding: 16,
  },
  itemIcon: {
    fontSize: 18,
    marginRight: 12,
  },
  itemLabel: {
    fontFamily: 'Inter',
    fontSize: 8,
    fontWeight: 'bold',
    color: ElenzaTheme.colors.textMuted,
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  itemVal: {
    fontFamily: 'Space Grotesk',
    fontSize: 13,
    fontWeight: 'bold',
    color: '#fff',
    marginTop: 2,
  },
  logsTitle: {
    fontFamily: 'Inter',
    fontSize: 8,
    fontWeight: 'bold',
    color: ElenzaTheme.colors.textMuted,
    letterSpacing: 1.0,
    marginBottom: 16,
    textTransform: 'uppercase',
  },
  logsList: {
    width: '100%',
  },
  logItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 10,
    borderBottomWidth: 1,
    borderColor: 'rgba(255,255,255,0.02)',
  },
  logLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
    marginRight: 10,
  },
  bullet: {
    width: 6,
    height: 6,
    borderRadius: 3,
    marginRight: 10,
  },
  logText: {
    fontFamily: 'Inter',
    fontSize: 11,
    color: 'rgba(255,255,255,0.7)',
  },
  logTime: {
    fontFamily: 'Inter',
    fontSize: 9,
    color: ElenzaTheme.colors.textMuted,
  },
});
