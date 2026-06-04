import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';

// Import stores & styles
import { useTuyaStore } from 'src/state/tuyaStore';
import { ElenzaTheme } from 'src/theme/ElenzaTheme';

// Import Screens
import { SplashScreen } from 'src/screens/SplashScreen';
import { StartupDiagnosticsScreen } from 'src/screens/StartupDiagnosticsScreen';
import { LoginRegisterScreen } from 'src/screens/LoginRegisterScreen';
import { ForgotPasswordScreen } from 'src/screens/ForgotPasswordScreen';
import { RegionSelectionScreen } from 'src/screens/RegionSelectionScreen';
import { DevicePairingScreen } from 'src/screens/DevicePairingScreen';
import { HomeDashboard } from 'src/screens/HomeDashboard';
import { BrewLabScreen } from 'src/screens/BrewLabScreen';
import { LiveExtractionScreen } from 'src/screens/LiveExtractionScreen';
import { RecipesScreen } from 'src/screens/RecipesScreen';
import { GrinderControlScreen } from 'src/screens/GrinderControlScreen';
import { StatisticsScreen } from 'src/screens/StatisticsScreen';
import { MachineSettingsScreen } from 'src/screens/MachineSettingsScreen';
import { DeviceManagementScreen } from 'src/screens/DeviceManagementScreen';
import { OtaUpdatesScreen } from 'src/screens/OtaUpdatesScreen';
import { NotificationsScreen } from 'src/screens/NotificationsScreen';
import { MaintenanceScreen } from 'src/screens/MaintenanceScreen';
import { AdvancedTelemetryScreen } from 'src/screens/AdvancedTelemetryScreen';
import { UserProfileScreen } from 'src/screens/UserProfileScreen';

export type RootStackParamList = {
  Splash: undefined;
  Diagnostics: undefined;
  Auth: undefined;
  ForgotPassword: undefined;
  RegionSelect: undefined;
  AppMain: undefined;
  DevicePairing: undefined;
  LiveExtraction: undefined;
  GrinderControl: undefined;
  DeviceDetails: undefined;
  Maintenance: undefined;
  OtaUpdates: undefined;
  Notifications: undefined;
  AdvancedTelemetry: undefined;
  UserProfile: undefined;
};

export type TabParamList = {
  Elenza: undefined;
  Recipes: undefined;
  BrewLab: undefined;
  Stats: undefined;
  System: undefined;
};

const Stack = createNativeStackNavigator<RootStackParamList>();
const Tab = createBottomTabNavigator<TabParamList>();

// Custom premium bottom tab design replicating the webapp footer
function BottomTabNavigator() {
  return (
    <Tab.Navigator
      screenOptions={{
        headerShown: false,
        tabBarStyle: styles.tabBar,
        tabBarActiveTintColor: ElenzaTheme.colors.bronze,
        tabBarInactiveTintColor: 'rgba(255, 255, 255, 0.4)',
        tabBarLabelStyle: styles.tabBarLabel,
      }}
    >
      <Tab.Screen
        name="Elenza"
        component={HomeDashboard}
        options={{
          tabBarIcon: ({ color }) => <Text style={{ color, fontSize: 16 }}>☕</Text>,
        }}
      />
      <Tab.Screen
        name="Recipes"
        component={RecipesScreen}
        options={{
          tabBarIcon: ({ color }) => <Text style={{ color, fontSize: 16 }}>💖</Text>,
        }}
      />
      <Tab.Screen
        name="BrewLab"
        component={BrewLabScreen}
        options={{
          tabBarLabel: 'Brew Lab',
          tabBarIcon: ({ color }) => (
            <View style={styles.floatingBrewLab}>
              <Text style={{ color: '#fff', fontSize: 18 }}>⚡</Text>
            </View>
          ),
        }}
      />
      <Tab.Screen
        name="Stats"
        component={StatisticsScreen}
        options={{
          tabBarIcon: ({ color }) => <Text style={{ color, fontSize: 16 }}>📊</Text>,
        }}
      />
      <Tab.Screen
        name="System"
        component={MachineSettingsScreen}
        options={{
          tabBarIcon: ({ color }) => <Text style={{ color, fontSize: 16 }}>⚙️</Text>,
        }}
      />
    </Tab.Navigator>
  );
}

export function AppNavigator() {
  const user = useTuyaStore((state) => state.user);

  return (
    <NavigationContainer>
      <Stack.Navigator screenOptions={{ headerShown: false }}>
        <Stack.Screen name="Splash" component={SplashScreen} />
        <Stack.Screen name="Diagnostics" component={StartupDiagnosticsScreen} />
        <Stack.Screen name="Auth" component={LoginRegisterScreen} />
        <Stack.Screen name="ForgotPassword" component={ForgotPasswordScreen} />
        <Stack.Screen name="RegionSelect" component={RegionSelectionScreen} />
        
        {/* Protected App Route */}
        <Stack.Screen name="AppMain" component={BottomTabNavigator} />
        
        {/* Modal Overlay / Console screens */}
        <Stack.Screen name="DevicePairing" component={DevicePairingScreen} />
        <Stack.Screen name="LiveExtraction" component={LiveExtractionScreen} />
        <Stack.Screen name="GrinderControl" component={GrinderControlScreen} />
        <Stack.Screen name="DeviceDetails" component={DeviceManagementScreen} />
        <Stack.Screen name="Maintenance" component={MaintenanceScreen} />
        <Stack.Screen name="OtaUpdates" component={OtaUpdatesScreen} />
        <Stack.Screen name="Notifications" component={NotificationsScreen} />
        <Stack.Screen name="AdvancedTelemetry" component={AdvancedTelemetryScreen} />
        <Stack.Screen name="UserProfile" component={UserProfileScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}

const styles = StyleSheet.create({
  tabBar: {
    position: 'absolute',
    bottom: 24,
    left: 20,
    right: 20,
    backgroundColor: 'rgba(18, 18, 18, 0.95)',
    borderRadius: 32,
    height: 75,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.08)',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 10 },
    shadowOpacity: 0.5,
    shadowRadius: 15,
    elevation: 5,
    paddingBottom: 8,
    paddingTop: 8,
  },
  tabBarLabel: {
    fontFamily: 'Inter',
    fontSize: 9,
    fontWeight: 'bold',
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  floatingBrewLab: {
    width: 48,
    height: 48,
    borderRadius: 24,
    backgroundColor: '#2a2a2a',
    borderColor: 'rgba(255, 255, 255, 0.1)',
    borderWidth: 1,
    alignItems: 'center',
    justifyContent: 'center',
    top: -12,
    shadowColor: '#c5a368',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.2,
    shadowRadius: 6,
    elevation: 3,
  },
});
