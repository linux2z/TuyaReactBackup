import React, { useState } from 'react';
import { View, Text, TextInput, StyleSheet, TouchableOpacity, ScrollView, ActivityIndicator } from 'react-native';
import { useTuyaStore } from 'src/state/tuyaStore';
import { ElenzaTheme } from 'src/theme/ElenzaTheme';

export function LoginRegisterScreen({ navigation }: any) {
  const [isLogin, setIsLogin] = useState(true);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [code, setCode] = useState('');
  const [codeSent, setCodeSent] = useState(false);
  const [sendingCode, setSendingCode] = useState(false);

  const region = useTuyaStore((state) => state.region);
  const authLogin = useTuyaStore((state) => state.login);
  const authRegister = useTuyaStore((state) => state.register);
  const sendVerification = useTuyaStore((state) => state.sendCode);
  const error = useTuyaStore((state) => state.error);
  const isLoading = useTuyaStore((state) => state.isLoading);

  const handleAction = async () => {
    if (isLogin) {
      const success = await authLogin(email, password);
      if (success) {
        navigation.replace('AppMain');
      }
    } else {
      const success = await authRegister(email, password, code);
      if (success) {
        setIsLogin(true);
        alert('Account created successfully! Please log in.');
      }
    }
  };

  const requestVerificationCode = async () => {
    if (!email) {
      alert('Please input a valid email address');
      return;
    }
    setSendingCode(true);
    const sent = await sendVerification(email);
    setSendingCode(false);
    if (sent) {
      setCodeSent(true);
      alert('Verification code dispatched to your inbox');
    }
  };

  return (
    <ScrollView contentContainerStyle={styles.container}>
      <View style={styles.header}>
        <Text style={ElenzaTheme.typography.brandSubtitle}>CALIBRATED CONTROL PANEL</Text>
        <Text style={styles.brandTitle}>E L E N Z A</Text>
      </View>

      <View style={styles.tabContainer}>
        <TouchableOpacity 
          style={[styles.tab, isLogin && styles.activeTab]} 
          onPress={() => setIsLogin(true)}
        >
          <Text style={[styles.tabText, isLogin && styles.activeTabText]}>Login</Text>
        </TouchableOpacity>
        <TouchableOpacity 
          style={[styles.tab, !isLogin && styles.activeTab]} 
          onPress={() => setIsLogin(false)}
        >
          <Text style={[styles.tabText, !isLogin && styles.activeTabText]}>Register</Text>
        </TouchableOpacity>
      </View>

      <View style={styles.formContainer}>
        <TouchableOpacity 
          style={styles.regionSelector} 
          onPress={() => navigation.navigate('RegionSelect')}
        >
          <Text style={styles.regionLabel}>Cloud Cluster Region</Text>
          <Text style={styles.regionValue}>{region?.name || 'USA/Americas'} (Code: {region?.code || '1'})</Text>
        </TouchableOpacity>

        {error && (
          <View style={styles.errorContainer}>
            <Text style={styles.errorText}>{error}</Text>
          </View>
        )}

        <Text style={styles.inputLabel}>Tuya Secure Username / Email</Text>
        <TextInput 
          style={styles.input}
          placeholder="yourname@domain.com"
          placeholderTextColor="rgba(255,255,255,0.2)"
          value={email}
          onChangeText={setEmail}
          autoCapitalize="none"
          keyboardType="email-address"
        />

        <Text style={styles.inputLabel}>Tuya Password</Text>
        <TextInput 
          style={styles.input}
          placeholder="••••••••••••••"
          placeholderTextColor="rgba(255,255,255,0.2)"
          value={password}
          onChangeText={setPassword}
          secureTextEntry
          autoCapitalize="none"
        />

        {!isLogin && (
          <View style={{ width: '100%' }}>
            <Text style={styles.inputLabel}>Tuya Verification Code</Text>
            <View style={styles.codeRow}>
              <TextInput 
                style={[styles.input, { flex: 1, marginBottom: 0 }]}
                placeholder="6-Digit Pin"
                placeholderTextColor="rgba(255,255,255,0.2)"
                value={code}
                onChangeText={setCode}
                keyboardType="numeric"
              />
              <TouchableOpacity 
                style={styles.codeButton} 
                onPress={requestVerificationCode}
                disabled={sendingCode}
              >
                {sendingCode ? (
                  <ActivityIndicator size="small" color="#000" />
                ) : (
                  <Text style={styles.codeButtonText}>{codeSent ? 'Resend' : 'Send Code'}</Text>
                )}
              </TouchableOpacity>
            </View>
          </View>
        )}

        <TouchableOpacity 
          style={styles.forgotBtn} 
          onPress={() => navigation.navigate('ForgotPassword')}
        >
          <Text style={styles.forgotText}>Forgot password credential?</Text>
        </TouchableOpacity>

        <TouchableOpacity 
          style={styles.primaryButton} 
          onPress={handleAction}
          disabled={isLoading}
        >
          {isLoading ? (
            <ActivityIndicator size="small" color="#000" />
          ) : (
            <Text style={styles.primaryButtonText}>
              {isLogin ? 'AUTHENTICATE SESSION' : 'ESTABLISH TUYA ID'}
            </Text>
          )}
        </TouchableOpacity>
      </View>
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
  brandTitle: {
    ...ElenzaTheme.typography.brandTitle,
    fontSize: 22,
    marginTop: 8,
    letterSpacing: 6,
  },
  tabContainer: {
    flexDirection: 'row',
    backgroundColor: ElenzaTheme.colors.surface,
    borderRadius: 16,
    padding: 4,
    marginBottom: 30,
    borderWidth: 1,
    borderColor: ElenzaTheme.colors.borderLight,
  },
  tab: {
    flex: 1,
    paddingVertical: 12,
    alignItems: 'center',
    borderRadius: 12,
  },
  activeTab: {
    backgroundColor: ElenzaTheme.colors.card,
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.05)',
  },
  tabText: {
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: '600',
    color: 'rgba(255, 255, 255, 0.4)',
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  activeTabText: {
    color: ElenzaTheme.colors.white,
  },
  formContainer: {
    width: '100%',
  },
  regionSelector: {
    backgroundColor: ElenzaTheme.colors.card,
    borderWidth: 1,
    borderColor: ElenzaTheme.colors.borderLight,
    padding: 16,
    borderRadius: 16,
    marginBottom: 20,
  },
  regionLabel: {
    fontFamily: 'Inter',
    fontSize: 8,
    fontWeight: 'bold',
    color: ElenzaTheme.colors.textMuted,
    textTransform: 'uppercase',
    letterSpacing: 1.0,
    marginBottom: 4,
  },
  regionValue: {
    fontFamily: 'Inter',
    fontSize: 12,
    color: ElenzaTheme.colors.bronze,
    fontWeight: '600',
  },
  errorContainer: {
    backgroundColor: 'rgba(223, 0, 0, 0.1)',
    borderWidth: 1,
    borderColor: 'rgba(223, 0, 0, 0.2)',
    padding: 14,
    borderRadius: 14,
    marginBottom: 20,
  },
  errorText: {
    fontFamily: 'Inter',
    fontSize: 11,
    color: '#ff4d4d',
    textAlign: 'center',
    fontWeight: '500',
  },
  inputLabel: {
    fontFamily: 'Inter',
    fontSize: 8,
    fontWeight: 'bold',
    color: ElenzaTheme.colors.textSecondary,
    textTransform: 'uppercase',
    letterSpacing: 1.0,
    marginBottom: 8,
    marginLeft: 4,
  },
  input: {
    backgroundColor: ElenzaTheme.colors.card,
    borderWidth: 1,
    borderColor: ElenzaTheme.colors.borderLight,
    padding: 16,
    borderRadius: 16,
    color: ElenzaTheme.colors.white,
    fontFamily: 'Inter',
    fontSize: 13,
    marginBottom: 20,
  },
  codeRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 20,
  },
  codeButton: {
    backgroundColor: ElenzaTheme.colors.bronze,
    paddingHorizontal: 20,
    height: 52,
    borderRadius: 16,
    justifyContent: 'center',
    alignItems: 'center',
    marginLeft: 10,
  },
  codeButtonText: {
    fontFamily: 'Inter',
    fontSize: 10,
    fontWeight: 'bold',
    color: '#000',
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  forgotBtn: {
    alignSelf: 'flex-end',
    marginBottom: 30,
  },
  forgotText: {
    fontFamily: 'Inter',
    fontSize: 10,
    color: ElenzaTheme.colors.textSecondary,
  },
  primaryButton: {
    backgroundColor: ElenzaTheme.colors.bronze,
    paddingVertical: 18,
    borderRadius: 16,
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: ElenzaTheme.colors.bronze,
    shadowOffset: { width: 0, height: 6 },
    shadowOpacity: 0.2,
    shadowRadius: 10,
    elevation: 3,
  },
  primaryButtonText: {
    fontFamily: 'Space Grotesk',
    fontSize: 11,
    fontWeight: 'bold',
    color: '#000',
    letterSpacing: 1.5,
  },
});
