import React, { useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ScrollView, ActivityIndicator } from 'react-native';
import { ElenzaTheme } from 'src/theme/ElenzaTheme';

export function MaintenanceScreen({ navigation }: any) {
  const [cleaning, setCleaning] = useState(false);
  const [cleaningProgress, setCleaningProgress] = useState(0);
  const [activeCycle, setActiveCycle] = useState<string | null>(null);

  const startClean = (name: string) => {
    setActiveCycle(name);
    setCleaning(true);
    setCleaningProgress(0);

    let progress = 0;
    const interval = setInterval(() => {
      progress += 10;
      setCleaningProgress(progress);
      if (progress >= 100) {
        clearInterval(interval);
        setCleaning(false);
        setActiveCycle(null);
        alert(`${name} cycle completed. Group head is clean and recalibrated!`);
      }
    }, 800);
  };

  return (
    <ScrollView contentContainerStyle={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backBtn} onPress={() => navigation.goBack()}>
          <Text style={styles.backArrow}>←</Text>
        </TouchableOpacity>
        <Text style={ElenzaTheme.typography.brandSubtitle}>THERMODYNAMIC REHABILITATION</Text>
        <Text style={styles.brandTitle}>MAINTENANCE CENTER</Text>
      </View>

      {!cleaning ? (
        <View style={styles.main}>
          <Text style={styles.desc}>
            Run regular diagnostic cycles to maintain absolute temperature consistency, group head flow calibration, and scale-free boiler pipelines.
          </Text>

          {/* Group head backflush */}
          <View style={styles.card}>
            <Text style={styles.cardTitle}>Backflush Group Head</Text>
            <Text style={styles.cardDesc}>
              Deploys standard high pressure cycles to clean residual espresso oils. Requires standard blind basket and cleaning tablet.
            </Text>
            <TouchableOpacity style={styles.cycleBtn} onPress={() => startClean('Backflush')}>
              <Text style={styles.cycleBtnText}>START BACKFLUSH CYCLE</Text>
            </TouchableOpacity>
          </View>

          {/* Boiler descaling */}
          <View style={styles.card}>
            <Text style={styles.cardTitle}>Descale Pipeline Boiler</Text>
            <Text style={styles.cardDesc}>
              Flushes mineral accumulations out of the thermodynamic copper tubes. Requires descaling agent in water tank reservoir.
            </Text>
            <TouchableOpacity style={styles.cycleBtn} onPress={() => startClean('Descaling')}>
              <Text style={styles.cycleBtnText}>START DESCALING CYCLE</Text>
            </TouchableOpacity>
          </View>
        </View>
      ) : (
        <View style={styles.progressContainer}>
          <View style={styles.outerRing}>
            <ActivityIndicator size="large" color={ElenzaTheme.colors.bronze} />
            <Text style={styles.progressVal}>{cleaningProgress}%</Text>
            <Text style={styles.progressSub}>Complete</Text>
          </View>

          <Text style={styles.statusTitle}>Executing {activeCycle} Cycle</Text>
          <Text style={styles.statusSub}>
            Modulating high-pressure pump waves and boiling flow gates to purge lines...
          </Text>
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
  desc: {
    fontFamily: 'Inter',
    fontSize: 12,
    lineHeight: 18,
    color: ElenzaTheme.colors.textSecondary,
    textAlign: 'center',
    marginBottom: 40,
    paddingHorizontal: 10,
  },
  main: {
    width: '100%',
  },
  card: {
    backgroundColor: ElenzaTheme.colors.card,
    borderColor: ElenzaTheme.colors.borderLight,
    borderWidth: 1,
    borderRadius: 24,
    padding: 20,
    marginBottom: 20,
  },
  cardTitle: {
    fontFamily: 'Space Grotesk',
    fontSize: 14,
    fontWeight: 'bold',
    color: '#fff',
    marginBottom: 8,
  },
  cardDesc: {
    fontFamily: 'Inter',
    fontSize: 11,
    lineHeight: 18,
    color: ElenzaTheme.colors.textSecondary,
    marginBottom: 20,
  },
  cycleBtn: {
    borderColor: ElenzaTheme.colors.bronze,
    borderWidth: 1,
    paddingVertical: 14,
    borderRadius: 14,
    alignItems: 'center',
  },
  cycleBtnText: {
    fontFamily: 'Space Grotesk',
    fontSize: 9,
    fontWeight: 'bold',
    color: ElenzaTheme.colors.bronze,
    letterSpacing: 1.0,
  },
  progressContainer: {
    alignItems: 'center',
  },
  outerRing: {
    width: 160,
    height: 160,
    borderRadius: 80,
    borderWidth: 4,
    borderColor: ElenzaTheme.colors.bronze,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 40,
    backgroundColor: 'rgba(255,255,255,0.01)',
  },
  progressVal: {
    fontFamily: 'Space Grotesk',
    fontSize: 26,
    fontWeight: 'bold',
    color: '#fff',
    marginTop: 10,
  },
  progressSub: {
    fontFamily: 'Inter',
    fontSize: 8,
    color: ElenzaTheme.colors.textMuted,
    letterSpacing: 0.5,
    textTransform: 'uppercase',
  },
  statusTitle: {
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: 'bold',
    color: '#fff',
    marginBottom: 8,
  },
  statusSub: {
    fontFamily: 'Inter',
    fontSize: 11,
    lineHeight: 18,
    color: ElenzaTheme.colors.textSecondary,
    textAlign: 'center',
    paddingHorizontal: 20,
  },
});
