import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ScrollView } from 'react-native';
import { useTuyaStore } from 'src/state/tuyaStore';
import { ElenzaTheme } from 'src/theme/ElenzaTheme';

export function RegionSelectionScreen({ navigation }: any) {
  const activeRegion = useTuyaStore((state) => state.region);
  const setRegion = useTuyaStore((state) => state.setRegion);

  const regions = [
    { code: '1', name: 'USA/Americas' },
    { code: '39', name: 'Europe/Middle East' },
    { code: '86', name: 'China Datacenter' },
    { code: '91', name: 'Asia Pacific/India' },
  ];

  const handleSelect = (r: { code: string; name: string }) => {
    setRegion(r);
    navigation.goBack();
  };

  return (
    <ScrollView contentContainerStyle={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backBtn} onPress={() => navigation.goBack()}>
          <Text style={styles.backArrow}>←</Text>
        </TouchableOpacity>
        <Text style={ElenzaTheme.typography.brandSubtitle}>CLOUD ROUTING SCHEME</Text>
        <Text style={styles.brandTitle}>DATACENTER</Text>
      </View>

      <Text style={styles.explanation}>
        Select the appropriate Tuya cloud gateway. Ensuring alignment with your physical geolocation yields minimal ping latency and fast MQTT telemetry updates.
      </Text>

      <View style={styles.list}>
        {regions.map((r) => {
          const isActive = activeRegion?.code === r.code;
          return (
            <TouchableOpacity 
              key={r.code} 
              style={[styles.item, isActive && styles.activeItem]}
              onPress={() => handleSelect(r)}
            >
              <View>
                <Text style={[styles.name, isActive && styles.activeText]}>{r.name}</Text>
                <Text style={styles.details}>Routing Gateway Code: {r.code}</Text>
              </View>
              {isActive && (
                <View style={styles.indicator}>
                  <Text style={styles.check}>✔</Text>
                </View>
              )}
            </TouchableOpacity>
          );
        })}
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
  explanation: {
    fontFamily: 'Inter',
    fontSize: 12,
    lineHeight: 18,
    color: ElenzaTheme.colors.textSecondary,
    textAlign: 'center',
    marginBottom: 40,
    paddingHorizontal: 10,
  },
  list: {
    width: '100%',
  },
  item: {
    backgroundColor: ElenzaTheme.colors.card,
    borderWidth: 1,
    borderColor: ElenzaTheme.colors.borderLight,
    padding: 20,
    borderRadius: 20,
    marginBottom: 16,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'between',
  },
  activeItem: {
    borderColor: ElenzaTheme.colors.bronze,
    backgroundColor: ElenzaTheme.colors.surface,
  },
  name: {
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: 'bold',
    color: 'rgba(255,255,255,0.7)',
  },
  activeText: {
    color: '#fff',
  },
  details: {
    fontFamily: 'Inter',
    fontSize: 10,
    color: ElenzaTheme.colors.textMuted,
    marginTop: 4,
  },
  indicator: {
    width: 24,
    height: 24,
    borderRadius: 12,
    backgroundColor: ElenzaTheme.colors.bronze,
    alignItems: 'center',
    justifyContent: 'center',
    position: 'absolute',
    right: 20,
  },
  check: {
    color: '#000',
    fontSize: 12,
    fontWeight: 'bold',
  },
});
