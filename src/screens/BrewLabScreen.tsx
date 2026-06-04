import React from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, Alert } from 'react-native';
import { useRecipeStore } from 'src/state/recipeStore';
import { useTuyaStore } from 'src/state/tuyaStore';
import { useTelemetryStore } from 'src/state/telemetryStore';
import { ElenzaTheme } from 'src/theme/ElenzaTheme';

export function BrewLabScreen({ navigation }: any) {
  const activeDevice = useTuyaStore((state) => state.activeDevice);

  // Zustand states
  const selectedRecipe = useRecipeStore((state) => state.selectedRecipe);
  const grindSize = useRecipeStore((state) => state.grindSize);
  const grindWeight = useRecipeStore((state) => state.grindWeight);
  const targetYield = useRecipeStore((state) => state.targetYield);
  const targetTemp = useRecipeStore((state) => state.targetTemp);
  const preinfusionSeconds = useRecipeStore((state) => state.preinfusionSeconds);

  // Zustand triggers
  const updateGrindSize = useRecipeStore((state) => state.updateGrindSize);
  const updateGrindWeight = useRecipeStore((state) => state.updateGrindWeight);
  const updateTargetYield = useRecipeStore((state) => state.updateTargetYield);
  const updateTargetTemp = useRecipeStore((state) => state.updateTargetTemp);
  const updatePreinfusion = useRecipeStore((state) => state.updatePreinfusion);

  const triggerBrewSession = useTelemetryStore((state) => state.triggerBrewSession);

  const handleBrew = async () => {
    if (!activeDevice) {
      Alert.alert('Ecosystem Alert', 'No active ELENZA machine bonded. Please pair a device first.');
      return;
    }

    // Trigger thermodynamic session
    triggerBrewSession(activeDevice.devId, targetTemp, targetYield);
    
    // Jump instantly to Live Extraction
    navigation.navigate('LiveExtraction');
  };

  return (
    <View style={styles.container}>
      {/* Top Header */}
      <View style={styles.header}>
        <View style={styles.headerTitleContainer}>
          <Text style={ElenzaTheme.typography.brandSubtitle}>THERMODYNAMIC LABORATORY</Text>
          <Text style={styles.brandTitle}>BREW LAB</Text>
        </View>
      </View>

      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        
        {/* Selected Recipe Deck */}
        <View style={styles.recipeCard}>
          <Text style={styles.recipeCardSubtitle}>Active Calibration Profile</Text>
          <Text style={styles.recipeCardName}>{selectedRecipe.name}</Text>
          <View style={styles.ratingRow}>
            {Array.from({ length: selectedRecipe.rating }).map((_, i) => (
              <Text key={i} style={styles.star}>★</Text>
            ))}
          </View>
        </View>

        {/* Sliders Container */}
        <View style={styles.controlsCard}>
          <Text style={styles.controlsTitle}>BREWING INDICES</Text>

          {/* Grinder Control Trigger link */}
          <TouchableOpacity 
            style={styles.grinderLink} 
            onPress={() => navigation.navigate('GrinderControl')}
          >
            <View>
              <Text style={styles.grinderLinkLabel}>GRINDER COUPLER INDEX</Text>
              <Text style={styles.grinderLinkValue}>Burr Calibration: Size {grindSize}</Text>
            </View>
            <Text style={styles.grinderLinkArrow}>→</Text>
          </TouchableOpacity>

          {/* Grind Weight */}
          <View style={styles.sliderGroup}>
            <View style={styles.sliderHeader}>
              <Text style={styles.sliderLabel}>Beans Weight</Text>
              <Text style={styles.sliderVal}>{grindWeight.toFixed(1)}g</Text>
            </View>
            <View style={styles.customTrack}>
              {/* React Native Slider simplified mock buttons */}
              <TouchableOpacity style={styles.adjBtn} onPress={() => updateGrindWeight(Math.max(10, grindWeight - 0.5))}>
                <Text style={styles.adjText}>-</Text>
              </TouchableOpacity>
              <View style={styles.barContainer}>
                <View style={[styles.barLevel, { width: `${((grindWeight - 10) / 15) * 100}%` }]} />
              </View>
              <TouchableOpacity style={styles.adjBtn} onPress={() => updateGrindWeight(Math.min(25, grindWeight + 0.5))}>
                <Text style={styles.adjText}>+</Text>
              </TouchableOpacity>
            </View>
          </View>

          {/* Target Yield */}
          <View style={styles.sliderGroup}>
            <View style={styles.sliderHeader}>
              <Text style={styles.sliderLabel}>Target Yield Volume</Text>
              <Text style={styles.sliderVal}>{targetYield}ml</Text>
            </View>
            <View style={styles.customTrack}>
              <TouchableOpacity style={styles.adjBtn} onPress={() => updateTargetYield(Math.max(20, targetYield - 5))}>
                <Text style={styles.adjText}>-</Text>
              </TouchableOpacity>
              <View style={styles.barContainer}>
                <View style={[styles.barLevel, { width: `${((targetYield - 20) / 230) * 100}%` }]} />
              </View>
              <TouchableOpacity style={styles.adjBtn} onPress={() => updateTargetYield(Math.min(250, targetYield + 5))}>
                <Text style={styles.adjText}>+</Text>
              </TouchableOpacity>
            </View>
          </View>

          {/* Target Temperature */}
          <View style={styles.sliderGroup}>
            <View style={styles.sliderHeader}>
              <Text style={styles.sliderLabel}>Extraction Temperature</Text>
              <Text style={styles.sliderVal}>{targetTemp}°C</Text>
            </View>
            <View style={styles.customTrack}>
              <TouchableOpacity style={styles.adjBtn} onPress={() => updateTargetTemp(Math.max(85, targetTemp - 1))}>
                <Text style={styles.adjText}>-</Text>
              </TouchableOpacity>
              <View style={styles.barContainer}>
                <View style={[styles.barLevel, { width: `${((targetTemp - 85) / 13) * 100}%` }]} />
              </View>
              <TouchableOpacity style={styles.adjBtn} onPress={() => updateTargetTemp(Math.min(98, targetTemp + 1))}>
                <Text style={styles.adjText}>+</Text>
              </TouchableOpacity>
            </View>
          </View>

          {/* Preinfusion seconds */}
          <View style={styles.sliderGroup}>
            <View style={styles.sliderHeader}>
              <Text style={styles.sliderLabel}>Pre-Infusion Delay</Text>
              <Text style={styles.sliderVal}>{preinfusionSeconds}s</Text>
            </View>
            <View style={styles.customTrack}>
              <TouchableOpacity style={styles.adjBtn} onPress={() => updatePreinfusion(Math.max(0, preinfusionSeconds - 1))}>
                <Text style={styles.adjText}>-</Text>
              </TouchableOpacity>
              <View style={styles.barContainer}>
                <View style={[styles.barLevel, { width: `${(preinfusionSeconds / 10) * 100}%` }]} />
              </View>
              <TouchableOpacity style={styles.adjBtn} onPress={() => updatePreinfusion(Math.min(10, preinfusionSeconds + 1))}>
                <Text style={styles.adjText}>+</Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>

        {/* Trigger Brew CTA */}
        <TouchableOpacity style={styles.brewBtn} onPress={handleBrew}>
          <Text style={styles.brewBtnText}>TRIGGER BREW SESSION</Text>
        </TouchableOpacity>

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
  recipeCard: {
    backgroundColor: ElenzaTheme.colors.surface,
    borderColor: ElenzaTheme.colors.borderLight,
    borderWidth: 1,
    borderRadius: 24,
    padding: 24,
    marginBottom: 20,
    alignItems: 'center',
  },
  recipeCardSubtitle: {
    fontFamily: 'Inter',
    fontSize: 8,
    color: ElenzaTheme.colors.textMuted,
    textTransform: 'uppercase',
    letterSpacing: 1.0,
    marginBottom: 6,
  },
  recipeCardName: {
    fontFamily: 'Space Grotesk',
    fontSize: 20,
    fontWeight: 'bold',
    color: '#fff',
  },
  ratingRow: {
    flexDirection: 'row',
    marginTop: 8,
  },
  star: {
    color: ElenzaTheme.colors.bronze,
    fontSize: 12,
    marginHorizontal: 1,
  },
  controlsCard: {
    backgroundColor: ElenzaTheme.colors.card,
    borderColor: ElenzaTheme.colors.borderLight,
    borderWidth: 1,
    borderRadius: 24,
    padding: 20,
    marginBottom: 20,
  },
  controlsTitle: {
    fontFamily: 'Inter',
    fontSize: 8,
    fontWeight: 'bold',
    color: ElenzaTheme.colors.textMuted,
    letterSpacing: 1.5,
    marginBottom: 20,
  },
  grinderLink: {
    backgroundColor: 'rgba(0, 0, 0, 0.3)',
    borderWidth: 1,
    borderColor: ElenzaTheme.colors.borderLight,
    padding: 16,
    borderRadius: 16,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 24,
  },
  grinderLinkLabel: {
    fontFamily: 'Inter',
    fontSize: 8,
    fontWeight: 'bold',
    color: ElenzaTheme.colors.textMuted,
    letterSpacing: 1.0,
    textTransform: 'uppercase',
  },
  grinderLinkValue: {
    fontFamily: 'Inter',
    fontSize: 12,
    color: ElenzaTheme.colors.bronze,
    fontWeight: 'bold',
    marginTop: 4,
  },
  grinderLinkArrow: {
    color: ElenzaTheme.colors.bronze,
    fontSize: 16,
    fontWeight: 'bold',
  },
  sliderGroup: {
    marginBottom: 24,
  },
  sliderHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 10,
  },
  sliderLabel: {
    fontFamily: 'Inter',
    fontSize: 11,
    fontWeight: '500',
    color: 'rgba(255,255,255,0.7)',
  },
  sliderVal: {
    fontFamily: 'Space Grotesk',
    fontSize: 12,
    fontWeight: 'bold',
    color: ElenzaTheme.colors.bronze,
  },
  customTrack: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  adjBtn: {
    width: 36,
    height: 36,
    borderRadius: 10,
    backgroundColor: ElenzaTheme.colors.graphite,
    alignItems: 'center',
    justifyContent: 'center',
  },
  adjText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
  },
  barContainer: {
    flex: 1,
    height: 6,
    backgroundColor: 'rgba(255,255,255,0.05)',
    borderRadius: 3,
    marginHorizontal: 12,
    overflow: 'hidden',
  },
  barLevel: {
    height: '100%',
    backgroundColor: ElenzaTheme.colors.bronze,
    borderRadius: 3,
  },
  brewBtn: {
    backgroundColor: ElenzaTheme.colors.bronze,
    paddingVertical: 18,
    borderRadius: 20,
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: ElenzaTheme.colors.bronze,
    shadowOffset: { width: 0, height: 6 },
    shadowOpacity: 0.2,
    shadowRadius: 12,
    elevation: 3,
  },
  brewBtnText: {
    fontFamily: 'Space Grotesk',
    fontSize: 12,
    fontWeight: 'bold',
    color: '#000',
    letterSpacing: 1.5,
  },
});
