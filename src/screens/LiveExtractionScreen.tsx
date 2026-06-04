import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity, Dimensions } from 'react-native';
import Svg, { Path, Grid, Line } from 'react-native-svg';
import { useTelemetryStore } from 'src/state/telemetryStore';
import { useRecipeStore } from 'src/state/recipeStore';
import { ElenzaTheme } from 'src/theme/ElenzaTheme';

const { width } = Dimensions.get('window');

export function LiveExtractionScreen({ navigation }: any) {
  const selectedRecipe = useRecipeStore((state) => state.selectedRecipe);
  const targetYield = useRecipeStore((state) => state.targetYield);
  const targetTemp = useRecipeStore((state) => state.targetTemp);

  const pumpPressure = useTelemetryStore((state) => state.pumpPressure);
  const flowRate = useTelemetryStore((state) => state.flowRate);
  const boilerTemp = useTelemetryStore((state) => state.boilerTemp);
  const machineState = useTelemetryStore((state) => state.machineState);
  const seconds = useTelemetryStore((state) => state.extractionSeconds);
  const pressureCurve = useTelemetryStore((state) => state.pressureCurve);
  const flowCurve = useTelemetryStore((state) => state.flowCurve);

  // Generate SVG path from telemetry points
  const generatePath = (data: number[], maxVal: number, height: number) => {
    if (data.length === 0) return 'M 0 0';
    const xStep = (width - 80) / 28; // Max 28 seconds standard extraction
    let path = `M 0 ${height}`;
    
    data.forEach((val, index) => {
      const x = index * xStep;
      // Invert Y because SVG 0,0 is top-left
      const y = height - (val / maxVal) * height;
      path += ` L ${x} ${y}`;
    });
    return path;
  };

  const handleAbort = () => {
    // Abort logic triggers telemetry store cleanups
    useTelemetryStore.setState({ machineState: 'Ready', pumpPressure: 0, flowRate: 0 });
    navigation.goBack();
  };

  return (
    <View style={styles.container}>
      {/* Top Header */}
      <View style={styles.header}>
        <Text style={ElenzaTheme.typography.brandSubtitle}>THERMODYNAMIC STREAM</Text>
        <Text style={styles.brandTitle}>LIVE EXTRACTION</Text>
      </View>

      <View style={styles.consoleContent}>
        {/* Active Stats Console */}
        <View style={styles.metaRow}>
          <View style={styles.metaCol}>
            <Text style={styles.metaLabel}>Recipe Profile</Text>
            <Text style={styles.metaVal}>{selectedRecipe.name}</Text>
          </View>
          <View style={styles.metaCol}>
            <Text style={styles.metaLabel}>Target Temperature</Text>
            <Text style={styles.metaVal}>{targetTemp}°C</Text>
          </View>
          <View style={styles.metaCol}>
            <Text style={styles.metaLabel}>Target Yield</Text>
            <Text style={styles.metaVal}>{targetYield}ml</Text>
          </View>
        </View>

        {/* Live Gauges Triple Grid */}
        <View style={styles.liveGrid}>
          <View style={styles.liveBox}>
            <Text style={styles.liveLabel}>Pressure</Text>
            <Text style={[styles.liveVal, { color: ElenzaTheme.colors.bronze }]}>{pumpPressure.toFixed(1)} <Text style={styles.liveUnit}>Bar</Text></Text>
          </View>
          <View style={styles.liveBox}>
            <Text style={styles.liveLabel}>Boiler Temp</Text>
            <Text style={[styles.liveVal, { color: ElenzaTheme.colors.white }]}>{boilerTemp}°C</Text>
          </View>
          <View style={styles.liveBox}>
            <Text style={styles.liveLabel}>Flow Speed</Text>
            <Text style={[styles.liveVal, { color: ElenzaTheme.colors.cyan }]}>{flowRate.toFixed(1)} <Text style={styles.liveUnit}>ml/s</Text></Text>
          </View>
        </View>

        {/* Dynamic Wave Chart Visualizer */}
        <View style={styles.chartContainer}>
          <Text style={styles.chartTitle}>EXTRACTION THERMODYNAMIC CALIBRATION (28S)</Text>
          
          <View style={styles.graphBox}>
            <Svg width={width - 80} height={180}>
              {/* Grid Background lines */}
              <Line x1="0" y1="45" x2={width - 80} y2="45" stroke="rgba(255,255,255,0.04)" strokeWidth="1" />
              <Line x1="0" y1="90" x2={width - 80} y2="90" stroke="rgba(255,255,255,0.04)" strokeWidth="1" />
              <Line x1="0" y1="135" x2={width - 80} y2="135" stroke="rgba(255,255,255,0.04)" strokeWidth="1" />
              
              {/* Pump Pressure Curve (Gold) */}
              <Path 
                d={generatePath(pressureCurve, 12, 180)} 
                fill="none" 
                stroke={ElenzaTheme.colors.bronze} 
                strokeWidth="2.5" 
              />
              
              {/* Flow Rate Curve (Cyan) */}
              <Path 
                d={generatePath(flowCurve, 4, 180)} 
                fill="none" 
                stroke={ElenzaTheme.colors.cyan} 
                strokeWidth="1.5" 
                strokeDasharray="4, 4"
              />
            </Svg>
          </View>
          <View style={styles.chartFooter}>
            <Text style={styles.legendText}>■ Pump Pressure (Bar)</Text>
            <Text style={[styles.legendText, { color: ElenzaTheme.colors.cyan }]}>■ Flow Velocity (ml/s)</Text>
          </View>
        </View>

        {/* Extraction Timer Circle */}
        <View style={styles.timerWrapper}>
          <View style={styles.timerCircle}>
            <Text style={styles.timerSecs}>{seconds}s</Text>
            <Text style={styles.timerLabel}>{machineState === 'Brewing' ? 'EXTRACTION DURATION' : 'SESSION COMPLETED'}</Text>
          </View>
        </View>

        {/* Abort/Complete Button */}
        <TouchableOpacity 
          style={[styles.abortBtn, machineState !== 'Brewing' && styles.completeBtn]} 
          onPress={handleAbort}
        >
          <Text style={[styles.abortText, machineState !== 'Brewing' && styles.completeText]}>
            {machineState === 'Brewing' ? 'ABORT EXTRACTION' : 'RETURN TO CONSOLE'}
          </Text>
        </TouchableOpacity>
      </View>
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
    alignItems: 'center',
    backgroundColor: 'rgba(5, 5, 5, 0.85)',
  },
  brandTitle: {
    fontFamily: 'Space Grotesk',
    fontSize: 16,
    letterSpacing: 6,
    color: '#fff',
    fontWeight: 'bold',
  },
  consoleContent: {
    flex: 1,
    padding: 24,
    justifyContent: 'space-between',
  },
  metaRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    backgroundColor: ElenzaTheme.colors.surface,
    borderColor: ElenzaTheme.colors.borderLight,
    borderWidth: 1,
    padding: 16,
    borderRadius: 20,
  },
  metaCol: {
    alignItems: 'center',
  },
  metaLabel: {
    fontFamily: 'Inter',
    fontSize: 8,
    color: ElenzaTheme.colors.textMuted,
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  metaVal: {
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: 'bold',
    color: '#fff',
    marginTop: 4,
  },
  liveGrid: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginVertical: 15,
  },
  liveBox: {
    flex: 1,
    backgroundColor: ElenzaTheme.colors.card,
    borderColor: ElenzaTheme.colors.borderLight,
    borderWidth: 1,
    borderRadius: 16,
    padding: 16,
    marginHorizontal: 4,
    alignItems: 'center',
  },
  liveLabel: {
    fontFamily: 'Inter',
    fontSize: 8,
    color: ElenzaTheme.colors.textSecondary,
    textTransform: 'uppercase',
    letterSpacing: 0.5,
    marginBottom: 6,
  },
  liveVal: {
    fontFamily: 'Space Grotesk',
    fontSize: 18,
    fontWeight: 'bold',
  },
  liveUnit: {
    fontSize: 10,
    fontWeight: 'normal',
    color: 'rgba(255,255,255,0.4)',
  },
  chartContainer: {
    backgroundColor: ElenzaTheme.colors.card,
    borderColor: ElenzaTheme.colors.borderLight,
    borderWidth: 1,
    borderRadius: 24,
    padding: 16,
    marginBottom: 15,
  },
  chartTitle: {
    fontFamily: 'Inter',
    fontSize: 8,
    color: ElenzaTheme.colors.textMuted,
    fontWeight: 'bold',
    letterSpacing: 1.0,
    marginBottom: 16,
  },
  graphBox: {
    height: 180,
    width: '100%',
    backgroundColor: 'rgba(0, 0, 0, 0.4)',
    borderRadius: 16,
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.03)',
    overflow: 'hidden',
  },
  chartFooter: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    marginTop: 12,
  },
  legendText: {
    fontFamily: 'Inter',
    fontSize: 9,
    fontWeight: '500',
    color: ElenzaTheme.colors.bronze,
  },
  timerWrapper: {
    alignItems: 'center',
    marginVertical: 10,
  },
  timerCircle: {
    width: 140,
    height: 140,
    borderRadius: 70,
    borderWidth: 3,
    borderColor: ElenzaTheme.colors.bronze,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'rgba(255,255,255,0.01)',
  },
  timerSecs: {
    fontFamily: 'Space Grotesk',
    fontSize: 36,
    fontWeight: 'bold',
    color: '#fff',
  },
  timerLabel: {
    fontFamily: 'Inter',
    fontSize: 7,
    fontWeight: 'bold',
    color: ElenzaTheme.colors.textMuted,
    letterSpacing: 1.0,
    marginTop: 4,
    textTransform: 'uppercase',
  },
  abortBtn: {
    borderColor: '#ff4d4d',
    borderWidth: 1,
    paddingVertical: 18,
    borderRadius: 20,
    alignItems: 'center',
    justifyContent: 'center',
  },
  completeBtn: {
    backgroundColor: ElenzaTheme.colors.bronze,
    borderColor: 'transparent',
  },
  abortText: {
    fontFamily: 'Space Grotesk',
    fontSize: 10,
    fontWeight: 'bold',
    color: '#ff4d4d',
    letterSpacing: 1.0,
  },
  completeText: {
    color: '#000',
  },
});
