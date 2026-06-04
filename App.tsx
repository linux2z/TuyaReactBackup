import React from 'react';
import { StatusBar, SafeAreaView, StyleSheet } from 'react-native';
import { AppNavigator } from './src/navigation/AppNavigator';
import { ElenzaTheme } from './src/theme/ElenzaTheme';

export default function App() {
  return (
    <SafeAreaView style={styles.safeArea}>
      <StatusBar 
        barStyle="light-content" 
        backgroundColor={ElenzaTheme.colors.background} 
      />
      <AppNavigator />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: ElenzaTheme.colors.background,
  },
});
