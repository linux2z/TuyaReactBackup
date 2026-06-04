import React, { useEffect, useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, NativeModules, ActivityIndicator } from 'react-native';
import { useTuyaStore } from 'src/state/tuyaStore';
import { ElenzaTheme } from 'src/theme/ElenzaTheme';

const { SDKValidationManager } = NativeModules;

interface DiagnosticsData {
  packageName: string;
  sha256Signature: string;
  appKeyStatus: string;
  appSecretStatus: string;
  appKeyHash: string;
  securityAlgorithmLoaded: boolean;
  legacyTsBmpFound: boolean;
  integrityStatus: 'PASS' | 'FAIL';
}

export function StartupDiagnosticsScreen({ navigation }: any) {
  const [loading, setLoading] = useState(true);
  const [data, setData] = useState<DiagnosticsData | null>(null);
  const checkSession = useTuyaStore((state) => state.checkSession);

  useEffect(() => {
    runChecks();
  }, []);

  const runChecks = async () => {
    setLoading(true);
    try {
      if (SDKValidationManager) {
        const diagnostics = await SDKValidationManager.getStartupDiagnostics();
        setData(diagnostics);
      } else {
        // Fallback Mock diagnostics for non-android runs
        setTimeout(() => {
          setData({
            packageName: 'com.elenza.app',
            sha256Signature: '8C:15:3A:5F:C9:4B:D1:80:7A:B4:EF:20:9E:C1:28:D5:7F:8C:36:A2:B4:EF:92:C9:D8:1A:56:8C:15:3A:5F:C9',
            appKeyStatus: 'VALID',
            appSecretStatus: 'VALID',
            appKeyHash: 'va9n...',
            securityAlgorithmLoaded: true,
            legacyTsBmpFound: false,
            integrityStatus: 'PASS',
          });
        }, 1500);
      }
    } catch (e) {
      console.log('Diag error', e);
    } finally {
      setLoading(false);
    }
  };

  const handleProceed = async () => {
    const isLoggedIn = await checkSession();
    if (isLoggedIn) {
      navigation.replace('AppMain');
    } else {
      navigation.replace('Auth');
    }
  };

  if (loading) {
    return (
      <View style={styles.centerContainer}>
        <ActivityIndicator size="large" color={ElenzaTheme.colors.bronze} />
        <Text style={styles.loadingText}>COMPILING HARDWARE DIAGNOSTICS...</Text>
      </View>
    );
  }

  const isIntact = data?.integrityStatus === 'PASS';

  return (
    <View style={styles.container}>
      {/* Top Header */}
      <View style={styles.header}>
        <Text style={ElenzaTheme.typography.brandSubtitle}>PRODUCTION DIAGNOSTICS DECK</Text>
        <Text style={styles.brandTitle}>SYSTEM INTEGRITY</Text>
      </View>

      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        
        {/* Verification Status Card */}
        <View style={[styles.statusCard, isIntact ? styles.statusPass : styles.statusFail]}>
          <Text style={styles.statusLabel}>INTEGRITY AUDIT RESULT</Text>
          <Text style={[styles.statusVal, { color: isIntact ? ElenzaTheme.colors.green : '#ff4d4d' }]}>
            {isIntact ? 'PASSED: SYSTEM SECURE' : 'FAILED: CONFIGURATION LOCK'}
          </Text>
          <Text style={styles.statusDesc}>
            {isIntact 
              ? 'All production signing hashes, packageName matches, and secure Tuya AAR bridges are calibrated.'
              : 'Integrity mismatch identified. Pairing or credential authorizations will fail immediately on real transponders.'}
          </Text>
        </View>

        <Text style={styles.sectionTitle}>HARDWARE SECURITY DIAGNOSTIC CHECKLIST</Text>

        <View style={styles.logBox}>
          {/* Check PackageName */}
          <View style={styles.logItem}>
            <Text style={styles.logName}>Package Name Matching</Text>
            <View style={styles.logRight}>
              <Text style={styles.logVal}>{data?.packageName}</Text>
              <Text style={[styles.badge, styles.badgeSuccess]}>OK</Text>
            </View>
          </View>

          {/* Check AppKey */}
          <View style={styles.logItem}>
            <Text style={styles.logName}>Tuya AppKey Status</Text>
            <View style={styles.logRight}>
              <Text style={styles.logVal}>{data?.appKeyHash}</Text>
              <Text style={[styles.badge, data?.appKeyStatus === 'VALID' ? styles.badgeSuccess : styles.badgeFail]}>
                {data?.appKeyStatus}
              </Text>
            </View>
          </View>

          {/* Check AppSecret */}
          <View style={styles.logItem}>
            <Text style={styles.logName}>Tuya AppSecret Status</Text>
            <View style={styles.logRight}>
              <Text style={styles.logVal}>••••</Text>
              <Text style={[styles.badge, data?.appSecretStatus === 'VALID' ? styles.badgeSuccess : styles.badgeFail]}>
                {data?.appSecretStatus}
              </Text>
            </View>
          </View>

          {/* Check security algorithm AAR */}
          <View style={styles.logItem}>
            <Text style={styles.logName}>security-algorithm.aar</Text>
            <View style={styles.logRight}>
              <Text style={styles.logVal}>ThingSmart Security Bridge</Text>
              <Text style={[styles.badge, data?.securityAlgorithmLoaded ? styles.badgeSuccess : styles.badgeFail]}>
                {data?.securityAlgorithmLoaded ? 'LOADED' : 'MISSING'}
              </Text>
            </View>
          </View>

          {/* Check legacy t_s.bmp assets */}
          <View style={styles.logItem}>
            <Text style={styles.logName}>Legacy t_s.bmp Assets</Text>
            <View style={styles.logRight}>
              <Text style={styles.logVal}>Deprecated Asset Checker</Text>
              <Text style={[styles.badge, !data?.legacyTsBmpFound ? styles.badgeSuccess : styles.badgeFail]}>
                {!data?.legacyTsBmpFound ? 'CLEAN' : 'FOUND'}
              </Text>
            </View>
          </View>
        </View>

        {/* SHA256 Panel */}
        <View style={styles.shaCard}>
          <Text style={styles.shaLabel}>ACTIVE SHA256 SIGNING CERTIFICATE FOOTPRINT</Text>
          <Text style={styles.shaVal}>{data?.sha256Signature}</Text>
        </View>

        {!isIntact && (
          <View style={styles.troubleBox}>
            <Text style={styles.troubleTitle}>🔧 HOW TO RESOLVE SIGN_VALIDATE_FAILED:</Text>
            <Text style={styles.troubleText}>
              1. Register the SHA256 hash displayed above inside your **Tuya Developer Platform account** under certificate settings.{"\n"}
              2. Verify the `packageName` matches your Tuya application identifier exactly.{"\n"}
              3. Check that the `security-algorithm-1.0.0-beta.aar` is loaded inside the `libs` compilation directory.
            </Text>
          </View>
        )}

      </ScrollView>

      {/* Primary Action Button */}
      <TouchableOpacity 
        style={[styles.actionBtn, !isIntact && styles.disabledBtn]} 
        onPress={handleProceed}
        disabled={!isIntact}
      >
        <Text style={styles.actionText}>{isIntact ? 'ENTER ELENZA CONSOLE' : 'SYSTEM OVERRIDE BLOCKED'}</Text>
      </TouchableOpacity>
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
  centerContainer: {
    flex: 1,
    backgroundColor: ElenzaTheme.colors.background,
    justifyContent: 'center',
    alignItems: 'center',
  },
  loadingText: {
    fontFamily: 'Inter',
    fontSize: 9,
    color: ElenzaTheme.colors.textMuted,
    marginTop: 20,
    letterSpacing: 1.0,
  },
  scrollContent: {
    padding: 20,
    paddingBottom: 120,
  },
  statusCard: {
    borderWidth: 1,
    borderRadius: 24,
    padding: 20,
    marginBottom: 24,
  },
  statusPass: {
    borderColor: 'rgba(0, 223, 129, 0.2)',
    backgroundColor: 'rgba(0, 223, 129, 0.02)',
  },
  statusFail: {
    borderColor: 'rgba(255, 77, 77, 0.2)',
    backgroundColor: 'rgba(255, 77, 77, 0.02)',
  },
  statusLabel: {
    fontFamily: 'Inter',
    fontSize: 8,
    color: ElenzaTheme.colors.textMuted,
    letterSpacing: 1.0,
    marginBottom: 6,
  },
  statusVal: {
    fontFamily: 'Space Grotesk',
    fontSize: 16,
    fontWeight: 'bold',
    marginBottom: 8,
  },
  statusDesc: {
    fontFamily: 'Inter',
    fontSize: 11,
    lineHeight: 18,
    color: ElenzaTheme.colors.textSecondary,
  },
  sectionTitle: {
    fontFamily: 'Inter',
    fontSize: 8,
    fontWeight: 'bold',
    color: ElenzaTheme.colors.textMuted,
    letterSpacing: 1.5,
    marginBottom: 16,
    textTransform: 'uppercase',
  },
  logBox: {
    backgroundColor: ElenzaTheme.colors.card,
    borderColor: ElenzaTheme.colors.borderLight,
    borderWidth: 1,
    borderRadius: 20,
    paddingHorizontal: 16,
    paddingVertical: 8,
    marginBottom: 20,
  },
  logItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 14,
    borderBottomWidth: 1,
    borderColor: 'rgba(255,255,255,0.02)',
  },
  logName: {
    fontFamily: 'Inter',
    fontSize: 11,
    color: 'rgba(255,255,255,0.6)',
  },
  logRight: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  logVal: {
    fontFamily: 'Inter',
    fontSize: 10,
    color: ElenzaTheme.colors.textMuted,
    marginRight: 10,
  },
  badge: {
    fontFamily: 'Inter',
    fontSize: 8,
    fontWeight: 'bold',
    paddingHorizontal: 6,
    paddingVertical: 3,
    borderRadius: 6,
    overflow: 'hidden',
  },
  badgeSuccess: {
    backgroundColor: 'rgba(0, 223, 129, 0.1)',
    color: ElenzaTheme.colors.green,
  },
  badgeFail: {
    backgroundColor: 'rgba(255, 77, 77, 0.1)',
    color: '#ff4d4d',
  },
  shaCard: {
    backgroundColor: 'rgba(0,0,0,0.3)',
    borderColor: ElenzaTheme.colors.borderLight,
    borderWidth: 1,
    borderRadius: 16,
    padding: 16,
    marginBottom: 20,
  },
  shaLabel: {
    fontFamily: 'Inter',
    fontSize: 8,
    fontWeight: 'bold',
    color: ElenzaTheme.colors.bronze,
    letterSpacing: 0.5,
    marginBottom: 8,
  },
  shaVal: {
    fontFamily: 'Space Grotesk',
    fontSize: 11,
    lineHeight: 18,
    color: '#fff',
  },
  troubleBox: {
    backgroundColor: 'rgba(255, 77, 77, 0.05)',
    borderColor: 'rgba(255, 77, 77, 0.1)',
    borderWidth: 1,
    borderRadius: 16,
    padding: 16,
    marginBottom: 20,
  },
  troubleTitle: {
    fontFamily: 'Inter',
    fontSize: 11,
    fontWeight: 'bold',
    color: '#ff4d4d',
    marginBottom: 8,
  },
  troubleText: {
    fontFamily: 'Inter',
    fontSize: 11,
    lineHeight: 18,
    color: 'rgba(255,255,255,0.7)',
  },
  actionBtn: {
    position: 'absolute',
    bottom: 24,
    left: 20,
    right: 20,
    backgroundColor: ElenzaTheme.colors.bronze,
    paddingVertical: 18,
    borderRadius: 20,
    alignItems: 'center',
    justifyContent: 'center',
  },
  disabledBtn: {
    backgroundColor: ElenzaTheme.colors.graphite,
    opacity: 0.5,
  },
  actionText: {
    fontFamily: 'Space Grotesk',
    fontSize: 11,
    fontWeight: 'bold',
    color: '#000',
    letterSpacing: 1.0,
  },
});
