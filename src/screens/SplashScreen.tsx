import React, { useEffect } from 'react';
import { View, Text, StyleSheet, ActivityIndicator } from 'react-native';
import { useTuyaStore } from 'src/state/tuyaStore';
import { ElenzaTheme } from 'src/theme/ElenzaTheme';

export function SplashScreen({ navigation }: any) {
  const checkSession = useTuyaStore((state) => state.checkSession);

  useEffect(() => {
    setTimeout(() => {
      navigation.replace('Diagnostics');
    }, 2500);
  }, []);

  return (
    <View style={styles.container}>
      <View style={styles.logoContainer}>
        <Text style={ElenzaTheme.typography.brandSubtitle}>IoT Smart Ecosystem</Text>
        <Text style={styles.title}>E L E N Z A</Text>
      </View>

      <View style={styles.indicatorContainer}>
        <ActivityIndicator size="small" color={ElenzaTheme.colors.bronze} />
        <Text style={styles.loadingText}>Calibrating Thermodynamic Engine...</Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: ElenzaTheme.colors.background,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 30,
  },
  logoContainer: {
    alignItems: 'center',
    marginBottom: 60,
  },
  title: {
    ...ElenzaTheme.typography.brandTitle,
    fontSize: 26,
    letterSpacing: 8.0,
    marginTop: 12,
  },
  indicatorContainer: {
    position: 'absolute',
    bottom: 80,
    alignItems: 'center',
  },
  loadingText: {
    fontFamily: 'Inter',
    fontSize: 10,
    color: 'rgba(255, 255, 255, 0.3)',
    marginTop: 15,
    letterSpacing: 1.0,
    textTransform: 'uppercase',
  },
});
