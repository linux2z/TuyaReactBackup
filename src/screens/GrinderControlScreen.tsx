import React, { useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ScrollView, ActivityIndicator } from 'react-native';
import { useRecipeStore } from 'src/state/recipeStore';
import { ElenzaTheme } from 'src/theme/ElenzaTheme';

export function GrinderControlScreen({ navigation }: any) {
  const grindSize = useRecipeStore((state) => state.grindSize);
  const updateGrindSize = useRecipeStore((state) => state.updateGrindSize);
  const [calibrating, setCalibrating] = useState(false);

  const getGrindDescription = (size: number) => {
    if (size <= 5) return 'Super-Fine Turkish (Micro dust)';
    if (size <= 10) return 'Classic Espresso Calibration (Calibrated)';
    if (size <= 15) return 'Medium-Fine Moka Pot / AeroPress';
    if (size <= 20) return 'Medium Drip / V60 Filter';
    if (size <= 25) return 'Coarse Chemex / Pour Over';
    return 'Super-Coarse French Press (Grit size)';
  };

  const handleCalibrate = () => {
    setCalibrating(true);
    setTimeout(() => {
      setCalibrating(false);
      alert('Burr micro-alignment calibration sequence successful');
    }, 2000);
  };

  return (
    <ScrollView contentContainerStyle={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backBtn} onPress={() => navigation.goBack()}>
          <Text style={styles.backArrow}>←</Text>
        </TouchableOpacity>
        <Text style={ElenzaTheme.typography.brandSubtitle}>BURR SPACING CALIBRATOR</Text>
        <Text style={styles.brandTitle}>GRINDER CONTROL</Text>
      </View>

      {/* Visual Burr Spacing Indicator */}
      <View style={styles.visualizerCard}>
        <Text style={styles.visualTitle}>BURR COUPLER GAP RATIO</Text>
        
        <View style={styles.burrRing}>
          <View style={[styles.innerBurr, { transform: [{ rotate: `${grindSize * 12}deg` }] }]} />
          <Text style={styles.gapText}>{grindSize * 15} μm</Text>
        </View>

        <Text style={styles.visualDesc}>{getGrindDescription(grindSize)}</Text>
      </View>

      {/* Slider gap */}
      <View style={styles.controlBox}>
        <View style={styles.row}>
          <Text style={styles.lbl}>Alignment Step Size</Text>
          <Text style={styles.val}>{grindSize} / 30</Text>
        </View>

        <View style={styles.adjustRow}>
          <TouchableOpacity 
            style={styles.adjBtn} 
            onPress={() => updateGrindSize(Math.max(1, grindSize - 1))}
          >
            <Text style={styles.adjIcon}>-</Text>
          </TouchableOpacity>

          <View style={styles.progressTrack}>
            <View style={[styles.progressVal, { width: `${(grindSize / 30) * 100}%` }]} />
          </View>

          <TouchableOpacity 
            style={styles.adjBtn} 
            onPress={() => updateGrindSize(Math.min(30, grindSize + 1))}
          >
            <Text style={styles.adjIcon}>+</Text>
          </TouchableOpacity>
        </View>
      </View>

      {/* Calibrate CTA */}
      <TouchableOpacity 
        style={styles.actionBtn} 
        onPress={handleCalibrate}
        disabled={calibrating}
      >
        {calibrating ? (
          <ActivityIndicator color="#000" />
        ) : (
          <Text style={styles.actionText}>INITIATE MICRO-ALIGNMENT LOOP</Text>
        )}
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
  visualizerCard: {
    backgroundColor: ElenzaTheme.colors.surface,
    borderColor: ElenzaTheme.colors.borderLight,
    borderWidth: 1,
    borderRadius: 30,
    padding: 24,
    alignItems: 'center',
    marginBottom: 24,
  },
  visualTitle: {
    fontFamily: 'Inter',
    fontSize: 8,
    fontWeight: 'bold',
    color: ElenzaTheme.colors.textMuted,
    letterSpacing: 1.5,
    marginBottom: 30,
  },
  burrRing: {
    width: 160,
    height: 160,
    borderRadius: 80,
    borderWidth: 8,
    borderColor: ElenzaTheme.colors.bronze,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'rgba(255,255,255,0.01)',
    position: 'relative',
    marginBottom: 30,
  },
  innerBurr: {
    position: 'absolute',
    width: 100,
    height: 100,
    borderRadius: 50,
    borderWidth: 6,
    borderColor: 'rgba(255, 255, 255, 0.1)',
    borderStyle: 'dashed',
  },
  gapText: {
    fontFamily: 'Space Grotesk',
    fontSize: 22,
    fontWeight: 'bold',
    color: '#fff',
  },
  visualDesc: {
    fontFamily: 'Inter',
    fontSize: 12,
    color: ElenzaTheme.colors.bronze,
    fontWeight: 'bold',
  },
  controlBox: {
    backgroundColor: ElenzaTheme.colors.card,
    borderColor: ElenzaTheme.colors.borderLight,
    borderWidth: 1,
    padding: 20,
    borderRadius: 24,
    marginBottom: 30,
  },
  row: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 16,
  },
  lbl: {
    fontFamily: 'Inter',
    fontSize: 11,
    color: 'rgba(255,255,255,0.5)',
  },
  val: {
    fontFamily: 'Space Grotesk',
    fontSize: 12,
    fontWeight: 'bold',
    color: ElenzaTheme.colors.bronze,
  },
  adjustRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  adjBtn: {
    width: 40,
    height: 40,
    backgroundColor: ElenzaTheme.colors.graphite,
    borderRadius: 12,
    alignItems: 'center',
    justifyContent: 'center',
  },
  adjIcon: {
    color: '#fff',
    fontSize: 20,
    fontWeight: 'bold',
  },
  progressTrack: {
    flex: 1,
    height: 6,
    backgroundColor: 'rgba(255,255,255,0.05)',
    borderRadius: 3,
    marginHorizontal: 16,
    overflow: 'hidden',
  },
  progressVal: {
    height: '100%',
    backgroundColor: ElenzaTheme.colors.bronze,
    borderRadius: 3,
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
});
