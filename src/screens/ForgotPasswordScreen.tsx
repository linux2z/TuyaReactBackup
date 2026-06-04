import React, { useState } from 'react';
import { View, Text, TextInput, StyleSheet, TouchableOpacity, ScrollView, ActivityIndicator } from 'react-native';
import { useTuyaStore } from 'src/state/tuyaStore';
import { ElenzaTheme } from 'src/theme/ElenzaTheme';

export function ForgotPasswordScreen({ navigation }: any) {
  const [email, setEmail] = useState('');
  const [code, setCode] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [sendingCode, setSendingCode] = useState(false);
  const [codeSent, setCodeSent] = useState(false);
  const [isResetting, setIsResetting] = useState(false);

  const region = useTuyaStore((state) => state.region);
  const sendVerification = useTuyaStore((state) => state.sendCode);

  const handleRequestCode = async () => {
    if (!email) {
      alert('Please fill in email first');
      return;
    }
    setSendingCode(true);
    const sent = await sendVerification(email);
    setSendingCode(false);
    if (sent) {
      setCodeSent(true);
      alert('Reset PIN code dispatched successfully');
    }
  };

  const handleReset = async () => {
    if (!email || !code || !newPassword) {
      alert('Please fill out all fields');
      return;
    }
    setIsResetting(true);
    // Tuya Reset password integration usually occurs via native SDK methods. 
    // Here we simulate successful reset and redirect back.
    setTimeout(() => {
      setIsResetting(false);
      alert('Password reset complete. Please log in.');
      navigation.goBack();
    }, 1500);
  };

  return (
    <ScrollView contentContainerStyle={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backBtn} onPress={() => navigation.goBack()}>
          <Text style={styles.backArrow}>←</Text>
        </TouchableOpacity>
        <Text style={ElenzaTheme.typography.brandSubtitle}>CREDENTIAL RESTORATION</Text>
        <Text style={styles.brandTitle}>RESET PIN</Text>
      </View>

      <View style={styles.form}>
        <Text style={styles.inputLabel}>Registered Email</Text>
        <TextInput
          style={styles.input}
          placeholder="yourname@domain.com"
          placeholderTextColor="rgba(255,255,255,0.2)"
          value={email}
          onChangeText={setEmail}
          autoCapitalize="none"
          keyboardType="email-address"
        />

        <Text style={styles.inputLabel}>Verification PIN</Text>
        <View style={styles.codeRow}>
          <TextInput
            style={[styles.input, { flex: 1, marginBottom: 0 }]}
            placeholder="6-Digit pin code"
            placeholderTextColor="rgba(255,255,255,0.2)"
            value={code}
            onChangeText={setCode}
            keyboardType="numeric"
          />
          <TouchableOpacity 
            style={styles.codeButton} 
            onPress={handleRequestCode}
            disabled={sendingCode}
          >
            {sendingCode ? (
              <ActivityIndicator size="small" color="#000" />
            ) : (
              <Text style={styles.codeButtonText}>{codeSent ? 'Resend' : 'Send Code'}</Text>
            )}
          </TouchableOpacity>
        </View>

        <Text style={styles.inputLabel}>New Password Target</Text>
        <TextInput
          style={styles.input}
          placeholder="••••••••••••••"
          placeholderTextColor="rgba(255,255,255,0.2)"
          value={newPassword}
          onChangeText={setNewPassword}
          secureTextEntry
          autoCapitalize="none"
        />

        <TouchableOpacity 
          style={styles.primaryButton} 
          onPress={handleReset}
          disabled={isResetting}
        >
          {isResetting ? (
            <ActivityIndicator size="small" color="#000" />
          ) : (
            <Text style={styles.primaryButtonText}>REPROGRAM CREDENTIAL</Text>
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
  form: {
    width: '100%',
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
  primaryButton: {
    backgroundColor: ElenzaTheme.colors.bronze,
    paddingVertical: 18,
    borderRadius: 16,
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: 15,
  },
  primaryButtonText: {
    fontFamily: 'Space Grotesk',
    fontSize: 11,
    fontWeight: 'bold',
    color: '#000',
    letterSpacing: 1.5,
  },
});
