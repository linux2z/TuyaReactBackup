import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ScrollView } from 'react-native';
import { useTuyaStore } from 'src/state/tuyaStore';
import { ElenzaTheme } from 'src/theme/ElenzaTheme';

export function UserProfileScreen({ navigation }: any) {
  const user = useTuyaStore((state) => state.user);
  const homeName = useTuyaStore((state) => state.homeName);
  const homeId = useTuyaStore((state) => state.homeId);
  const region = useTuyaStore((state) => state.region);
  const logout = useTuyaStore((state) => state.logout);

  const handleSignOut = async () => {
    await logout();
    // Redirect all the way back to onboarding authentication screen
    navigation.reset({
      index: 0,
      routes: [{ name: 'Auth' }],
    });
  };

  return (
    <ScrollView contentContainerStyle={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backBtn} onPress={() => navigation.goBack()}>
          <Text style={styles.backArrow}>←</Text>
        </TouchableOpacity>
        <Text style={ElenzaTheme.typography.brandSubtitle}>CALIBRATED BARISTA ACCOUNT</Text>
        <Text style={styles.brandTitle}>BARISTA PROFILE</Text>
      </View>

      <View style={styles.profileBox}>
        <View style={styles.avatarCircle}>
          <Text style={styles.avatarText}>🏆</Text>
        </View>
        <Text style={styles.profileEmail}>{user?.email || 'barista@elenza.com'}</Text>
        <Text style={styles.profileRole}>Master Coffee Designer</Text>
      </View>

      <View style={styles.card}>
        <Text style={styles.cardTitle}>TUYA SECURE LEDGER</Text>

        <View style={styles.row}>
          <Text style={styles.label}>Tuya User UID</Text>
          <Text style={styles.val}>{user?.uid || 'usr_f8h398hsh492js83'}</Text>
        </View>

        <View style={styles.row}>
          <Text style={styles.label}>Active Home Group</Text>
          <Text style={styles.val}>{homeName || 'ELENZA Laboratory'}</Text>
        </View>

        <View style={styles.row}>
          <Text style={styles.label}>Home Group ID</Text>
          <Text style={styles.val}>{homeId || '1029482937'}</Text>
        </View>

        <View style={styles.row}>
          <Text style={styles.label}>Active Server Region</Text>
          <Text style={styles.val}>{region?.name || 'USA/Americas'}</Text>
        </View>

        <View style={styles.row}>
          <Text style={styles.label}>Server Region Code</Text>
          <Text style={styles.val}>{region?.code || '1'}</Text>
        </View>
      </View>

      <TouchableOpacity style={styles.logoutBtn} onPress={handleSignOut}>
        <Text style={styles.logoutText}>TERMINATE SECTOR SESSION</Text>
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
  profileBox: {
    alignItems: 'center',
    marginBottom: 40,
  },
  avatarCircle: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: ElenzaTheme.colors.surface,
    borderColor: ElenzaTheme.colors.borderLight,
    borderWidth: 1,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 16,
  },
  avatarText: {
    fontSize: 32,
  },
  profileEmail: {
    fontFamily: 'Space Grotesk',
    fontSize: 16,
    fontWeight: 'bold',
    color: '#fff',
  },
  profileRole: {
    fontFamily: 'Inter',
    fontSize: 10,
    color: ElenzaTheme.colors.bronze,
    fontWeight: 'bold',
    textTransform: 'uppercase',
    letterSpacing: 0.5,
    marginTop: 4,
  },
  card: {
    backgroundColor: ElenzaTheme.colors.surface,
    borderColor: ElenzaTheme.colors.borderLight,
    borderWidth: 1,
    borderRadius: 30,
    padding: 24,
    marginBottom: 40,
  },
  cardTitle: {
    fontFamily: 'Inter',
    fontSize: 8,
    fontWeight: 'bold',
    color: ElenzaTheme.colors.textMuted,
    letterSpacing: 1.5,
    marginBottom: 24,
  },
  row: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: 14,
    borderBottomWidth: 1,
    borderColor: 'rgba(255,255,255,0.02)',
  },
  label: {
    fontFamily: 'Inter',
    fontSize: 11,
    color: 'rgba(255,255,255,0.5)',
  },
  val: {
    fontFamily: 'Inter',
    fontSize: 11,
    fontWeight: 'bold',
    color: '#fff',
  },
  logoutBtn: {
    borderColor: '#ff4d4d',
    borderWidth: 1,
    paddingVertical: 18,
    borderRadius: 20,
    alignItems: 'center',
    justifyContent: 'center',
  },
  logoutText: {
    fontFamily: 'Space Grotesk',
    fontSize: 10,
    fontWeight: 'bold',
    color: '#ff4d4d',
    letterSpacing: 1.0,
  },
});
