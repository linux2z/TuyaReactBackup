import 'package:flutter/material.dart';
import '../theme.dart';
import 'console_tab.dart';
import 'brew_lab_tab.dart';
import 'extraction_tab.dart';
import 'recipes_tab.dart';
import 'settings_tab.dart';
import 'community_tab.dart';
import 'package:provider/provider.dart';
import '../state/tuya_state.dart';
import '../state/telemetry_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    // Reorder tabs to match the 2.png layout exactly
    _tabs = [
      ConsoleTab(
        onNavigateToTab: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      RecipesTab(
        onCustomizeTriggered: () {
          setState(() {
            _currentIndex = 2; // BrewLabTab
          });
        },
        onBackPressed: () {
          setState(() {
            _currentIndex = 0; // ConsoleTab
          });
        },
      ),
      BrewLabTab(
        onBrewTriggered: () {
          final tuyaState = Provider.of<TuyaState>(context, listen: false);
          final telemetryState = Provider.of<TelemetryState>(context, listen: false);
          if (tuyaState.activeDevice != null) {
            telemetryState.triggerBrewSession(tuyaState.activeDevice!.devId, 93.0, 36.0);
          }
          setState(() {
            _currentIndex = 5; // ExtractionTab
          });
        },
        onBackPressed: () {
          setState(() {
            _currentIndex = 0; // ConsoleTab
          });
        },
      ),
      const CommunityTab(),
      const SettingsTab(), // 'More' mapped to settings
      ExtractionTab(
        onBackPressed: () {
          setState(() {
            _currentIndex = 2; // Back to BrewLabTab
          });
        },
      ), // Hidden 6th tab
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ElenzaTheme.matteBlack,
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: ElenzaTheme.graphiteDark,
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex > 4 ? 2 : _currentIndex, // If ExtractionTab, highlight Brew Lab
          selectedItemColor: ElenzaTheme.bronzeAccent,
          unselectedItemColor: ElenzaTheme.textSecondary,
          selectedLabelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w600),
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.coffee),
              label: 'Recipes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Brew Lab',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Community',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }
}
