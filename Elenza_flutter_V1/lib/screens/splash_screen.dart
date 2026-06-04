import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../state/tuya_state.dart';
import 'auth_screen.dart';
import 'dashboard_screen.dart';
import 'pairing_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _checkExistingSession();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkExistingSession() async {
    final tuyaState = Provider.of<TuyaState>(context, listen: false);
    final hasSession = await tuyaState.checkSession();
    if (hasSession && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ElenzaTheme.matteBlack,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              // Logo
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_animationController.value * 0.03),
                    child: child,
                  );
                },
                child: ClipOval(
                  child: Container(
                    color: Colors.black, // Background color for the logo if it's transparent or weirdly cropped
                    child: Image.asset(
                      'assets/Logo.jpeg',
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => Icon(
                        Icons.coffee_maker_outlined, 
                        size: 140, 
                        color: ElenzaTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              Text(
                'Elenza',
                style: const TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'IoT Smart Ecosystem',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: ElenzaTheme.bronzeAccent,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Intelligent. Connected. Personal.',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: ElenzaTheme.textSecondary,
                ),
              ),
              
              const Spacer(flex: 3),
              
              // Login Button (Orange Fill)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ElenzaTheme.bronzeAccent,
                    foregroundColor: ElenzaTheme.matteBlack,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const AuthScreen(initialIsLogin: true)),
                    );
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Sign Up / Register Button (Outlined)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ElenzaTheme.bronzeAccent,
                    side: const BorderSide(color: ElenzaTheme.bronzeAccent, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const AuthScreen(initialIsLogin: false)),
                    );
                  },
                  child: const Text(
                    'Sign Up / Register',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Continue as Guest Link
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const DashboardScreen()),
                  );
                },
                child: const Text(
                  'Continue as Guest',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: ElenzaTheme.textSecondary,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
