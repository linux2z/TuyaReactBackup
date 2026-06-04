import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../state/tuya_state.dart';
import 'region_screen.dart';
import 'forgot_password_screen.dart';
import 'dashboard_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();

  bool _sendingCode = false;
  bool _codeSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleAction() async {
    final tuyaState = Provider.of<TuyaState>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final code = _codeController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email and password cannot be empty')),
      );
      return;
    }

    if (!_isLogin && code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter verification code')),
      );
      return;
    }

    if (_isLogin) {
      final success = await tuyaState.login(email, password);
      if (success) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tuyaState.error ?? 'Authentication failed')),
        );
      }
    } else {
      final success = await tuyaState.register(email, password, code);
      if (success) {
        setState(() {
          _isLogin = true;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully! Please log in.')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tuyaState.error ?? 'Registration failed')),
        );
      }
    }
  }

  Future<void> _requestVerificationCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please input a valid email address')),
      );
      return;
    }

    setState(() {
      _sendingCode = true;
    });

    final tuyaState = Provider.of<TuyaState>(context, listen: false);
    final sent = await tuyaState.sendCode(email);

    setState(() {
      _sendingCode = false;
    });

    if (sent) {
      setState(() {
        _codeSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification code dispatched to your inbox')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tuyaState.error ?? 'Failed to send code')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tuyaState = Provider.of<TuyaState>(context);
    final region = tuyaState.region;
    final isLoading = tuyaState.isLoading;

    return Scaffold(
      backgroundColor: ElenzaTheme.matteBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Text(
                      'CALIBRATED CONTROL PANEL',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: ElenzaTheme.bronzeAccent.withOpacity(0.8),
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'E L E N Z A',
                      style: TextStyle(
                        fontFamily: 'Space Grotesk',
                        fontSize: 22,
                        letterSpacing: 6,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Tab Container
              Container(
                decoration: BoxDecoration(
                  color: ElenzaTheme.graphiteDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ElenzaTheme.graphiteLight, width: 1.0),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isLogin = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isLogin ? ElenzaTheme.graphiteMedium : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: _isLogin
                                ? Border.all(color: Colors.white.withOpacity(0.05))
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'LOGIN',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _isLogin ? Colors.white : Colors.white.withOpacity(0.4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isLogin = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_isLogin ? ElenzaTheme.graphiteMedium : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: !_isLogin
                                ? Border.all(color: Colors.white.withOpacity(0.05))
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'REGISTER',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: !_isLogin ? Colors.white : Colors.white.withOpacity(0.4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Region Selector Card
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const RegionScreen()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ElenzaTheme.graphiteDark,
                    border: Border.all(color: ElenzaTheme.graphiteLight, width: 1.0),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CLOUD CLUSTER REGION',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: ElenzaTheme.textMuted,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${region.name} (Code: ${region.code})',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: ElenzaTheme.bronzeAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.chevron_right, color: ElenzaTheme.bronzeAccent),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'TUYA SECURE USERNAME / EMAIL',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: ElenzaTheme.textSecondary,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'yourname@domain.com',
                ),
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 20),

              const Text(
                'TUYA PASSWORD',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: ElenzaTheme.textSecondary,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  hintText: '••••••••••••••',
                ),
                obscureText: true,
                style: const TextStyle(color: Colors.white),
              ),

              if (!_isLogin) ...[
                const SizedBox(height: 20),
                const Text(
                  'TUYA VERIFICATION CODE',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: ElenzaTheme.textSecondary,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _codeController,
                        decoration: const InputDecoration(
                          hintText: '6-Digit Pin',
                        ),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _sendingCode ? null : _requestVerificationCode,
                        child: _sendingCode
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                ),
                              )
                            : Text(_codeSent ? 'RESEND' : 'SEND CODE'),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 15),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                    );
                  },
                  child: const Text('Forgot password credential?'),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  onPressed: isLoading ? null : _handleAction,
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        )
                      : Text(
                          _isLogin ? 'AUTHENTICATE SESSION' : 'ESTABLISH TUYA ID',
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
