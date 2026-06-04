import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'state/tuya_state.dart';
import 'state/telemetry_state.dart';
import 'state/recipe_state.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TuyaState()),
        ChangeNotifierProvider(create: (_) => TelemetryState()),
        ChangeNotifierProvider(create: (_) => RecipeState()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ELENZA Pro IoT Console',
      debugShowCheckedModeBanner: false,
      theme: ElenzaTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
