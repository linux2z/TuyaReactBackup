import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../state/tuya_state.dart';
import '../state/telemetry_state.dart';
import 'user_profile_screen.dart';
import 'notifications_screen.dart';
import 'pairing_screen.dart';

class ConsoleTab extends StatefulWidget {
  const ConsoleTab({super.key});

  @override
  State<ConsoleTab> createState() => _ConsoleTabState();
}

class _ConsoleTabState extends State<ConsoleTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tuyaState = Provider.of<TuyaState>(context, listen: false);
      if (tuyaState.activeDevice != null) {
        Provider.of<TelemetryState>(context, listen: false)
            .startTelemetry(tuyaState.activeDevice!.devId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tuyaState = Provider.of<TuyaState>(context);
    final telemetryState = Provider.of<TelemetryState>(context);

    final activeDevice = tuyaState.activeDevice;
    final waterTank = telemetryState.waterTank;
    final boilerTemp = telemetryState.boilerTemp;
    final machineState = telemetryState.machineState;
    final filterLife = telemetryState.filterLife;

    final isOnline = activeDevice != null && machineState != 'Offline';

    return Scaffold(
      backgroundColor: ElenzaTheme.matteBlack,
      drawer: _buildDrawer(context, tuyaState),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Elenza',
          style: TextStyle(
            fontFamily: 'Space Grotesk',
            fontSize: 28,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white, size: 28),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Modena V2',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isOnline ? 'Ready' : 'Offline',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isOnline ? ElenzaTheme.successGreen : ElenzaTheme.errorRed,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.cell_tower,
                  color: isOnline ? ElenzaTheme.successGreen : ElenzaTheme.errorRed,
                  size: 28,
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Metrics Grid (6 cards)
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
              children: [
                _buildGridCard(Icons.thermostat, 'Boiler', '${boilerTemp.toInt()}°C'),
                _buildGridCard(Icons.settings_applications, 'Brew Temp', '${boilerTemp.toInt()}°C'),
                _buildGridCard(Icons.speed, 'Pressure', '9.2 bar'),
                _buildGridCard(Icons.electric_bolt, 'Flow Rate', '2.1 ml/s'),
                _buildGridCard(Icons.water_drop, 'Water Tank', '${waterTank.toInt()}%'),
                _buildGridCard(Icons.filter_alt, 'Filter', '${filterLife.toInt()}%'),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Barista Intelligence Recommendation
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ElenzaTheme.graphiteDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: ElenzaTheme.bronzeAccent, size: 24),
                      const SizedBox(width: 12),
                      const Text(
                        'Barista Recommendation',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: ElenzaTheme.bronzeAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your brewing timeline indicates an 8:00 AM coffee routine. We recommend pre-heating the group head at 7:55 AM for a calibrated Double Espresso shot today.',
                    style: TextStyle(
                      fontSize: 14,
                      color: ElenzaTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(IconData icon, String label, String value) {
    return Container(
      decoration: BoxDecoration(
        color: ElenzaTheme.graphiteDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: ElenzaTheme.textSecondary, size: 28),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: ElenzaTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, TuyaState tuyaState) {
    return Drawer(
      backgroundColor: ElenzaTheme.graphiteDark,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: ElenzaTheme.matteBlack),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'ELENZA PRO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tuyaState.user?.email ?? 'Not logged in',
                  style: const TextStyle(
                    color: ElenzaTheme.bronzeAccent,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.white),
            title: const Text('Home', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.coffee_maker, color: Colors.white),
            title: const Text('Select Model', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const PairingScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.bluetooth_connected, color: Colors.white),
            title: const Text('Device Pairing', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const PairingScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.white),
            title: const Text('Settings', style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.pop(context),
          ),

          ListTile(
            leading: const Icon(Icons.person_outline, color: Colors.white),
            title: const Text('User Profile', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const UserProfileScreen()),
              );
            },
          ),
          const Divider(color: ElenzaTheme.graphiteLight),
          ListTile(
            leading: const Icon(Icons.logout, color: ElenzaTheme.errorRed),
            title: const Text('Logout', style: TextStyle(color: ElenzaTheme.errorRed)),
            onTap: () async {
              Navigator.pop(context);
              await tuyaState.logout();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/');
              }
            },
          ),
        ],
      ),
    );
  }
}
