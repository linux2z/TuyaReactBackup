import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../state/tuya_state.dart';
import '../state/telemetry_state.dart';
import 'splash_screen.dart';
class ConsoleTab extends StatelessWidget {
  final Function(int)? onNavigateToTab;

  const ConsoleTab({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    final tuyaState = Provider.of<TuyaState>(context);
    final telemetryState = Provider.of<TelemetryState>(context);
    
    // In Elenza Pro, we assume the machine is Modena R as per the design mock
    final String modelName = tuyaState.activeDevice != null ? 'Modena R' : 'Modena R';

    return Scaffold(
      backgroundColor: ElenzaTheme.matteBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        centerTitle: true,
        title: const Column(
          children: [
            Text(
              'E L E N Z A',
              style: TextStyle(
                fontFamily: 'Space Grotesk',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
                color: Colors.white,
              ),
            ),
            Text(
              'IoT Smart Ecosystem',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                color: ElenzaTheme.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: ElenzaTheme.graphiteDark,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: ElenzaTheme.matteBlack),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset('assets/Logo.jpeg', height: 40),
                  const SizedBox(height: 16),
                  const Text('ELENZA', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.white),
              title: const Text('Home', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),

            ListTile(
              leading: const Icon(Icons.bluetooth_connected, color: Colors.white),
              title: const Text('Device Pairing', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/pairing');
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner, color: Colors.white),
              title: const Text('Scan Coffee Bag', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/qr_scanner');
              },
            ),
            ListTile(
              leading: const Icon(Icons.science, color: Colors.white),
              title: const Text('Brew Lab', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                if (onNavigateToTab != null) onNavigateToTab!(2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt, color: Colors.white),
              title: const Text('Recipes', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                if (onNavigateToTab != null) onNavigateToTab!(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.build, color: Colors.white),
              title: const Text('Maintenance', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title: const Text('Settings', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                if (onNavigateToTab != null) onNavigateToTab!(4);
              },
            ),
            const Divider(color: ElenzaTheme.graphiteLight),
            ListTile(
              leading: const Icon(Icons.logout, color: ElenzaTheme.errorRed),
              title: const Text('Logout', style: TextStyle(color: ElenzaTheme.errorRed)),
              onTap: () async {
                Navigator.pop(context); // Close drawer
                await tuyaState.logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const SplashScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Status Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Machine Status',
                    style: TextStyle(color: ElenzaTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: tuyaState.activeDevice != null ? const Color(0xFF00E676) : ElenzaTheme.errorRed, // Bright green
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tuyaState.activeDevice != null ? 'Online' : 'Offline',
                        style: TextStyle(
                          color: tuyaState.activeDevice != null ? const Color(0xFF00E676) : ElenzaTheme.errorRed,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Hero Card
              Container(
                width: double.infinity,
                height: 280,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  image: const DecorationImage(
                    image: AssetImage('assets/machine.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ELENZA PRO',
                      style: TextStyle(
                        fontFamily: 'Space Grotesk',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      modelName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),

              // Metrics Grid
              Row(
                children: [
                  Expanded(
                    child: _buildMetricBox(
                      icon: Icons.thermostat,
                      iconColor: const Color(0xFFE53935),
                      label: 'Boiler',
                      value: telemetryState.boilerTemp.toInt().toString(),
                      unit: '°C',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricBox(
                      icon: Icons.coffee,
                      iconColor: const Color(0xFF8D6E63), // Brown
                      label: 'Beans',
                      value: telemetryState.beanHopper.toInt().toString(),
                      unit: '%',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricBox(
                      icon: Icons.shield,
                      iconColor: const Color(0xFF4FC3F7), // Light Blue
                      label: 'Health',
                      value: '100', // Static as per mock, or could be computed
                      unit: '%',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildWaterTankBox(telemetryState.waterTank.toInt().toString()),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricBox(
                      icon: null,
                      label: 'Filter Life',
                      value: telemetryState.filterLife.toInt().toString(),
                      unit: '%',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildReadyBox(),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Intelligence Recommendation Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF161616),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb, color: Color(0xFFFFD54F), size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Barista Intelligence Recommendation',
                          style: TextStyle(
                            color: Color(0xFFFFD54F),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: ElenzaTheme.textSecondary,
                          height: 1.5,
                        ),
                        children: [
                          TextSpan(text: 'Your brewing timeline indicates an 8:00 AM coffee routine. We recommend pre-heating the group head at 7:55 AM for a calibrated '),
                          TextSpan(
                            text: 'Double Espresso',
                            style: TextStyle(color: Color(0xFFFFD54F), fontWeight: FontWeight.w600),
                          ),
                          TextSpan(text: ' shot today.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricBox({
    IconData? icon,
    Color? iconColor,
    required String label,
    required String value,
    required String unit,
  }) {
    return Container(
      height: 100, // Fixed height to 100 to avoid overflow and bounding issues
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Icon(icon, color: iconColor, size: 22)
          else
            const SizedBox(height: 22),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: ElenzaTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 3.0, left: 1.0),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 12,
                    color: unit == '°C' ? const Color(0xFFFFD54F) : ElenzaTheme.textSecondary, // In the image, the C has a hint of orange/yellow sometimes
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaterTankBox(String value) {
    return Container(
      height: 100, // Matching height of 100
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                const Text(
                  'Water Tank',
                  style: TextStyle(
                    fontSize: 11,
                    color: ElenzaTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontFamily: 'Space Grotesk',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 3.0, left: 1.0),
                      child: Text(
                        '%',
                        style: TextStyle(
                          fontSize: 12,
                          color: ElenzaTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 3,
            height: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF), // Cyan
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadyBox() {
    return Container(
      height: 100, // Matching height of 100
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bolt, color: Color(0xFFFFD54F), size: 28),
          const SizedBox(height: 8),
          const Text(
            'Ready',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF00E5FF), // Cyan text
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
