import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import 'console_tab.dart';
import 'brew_lab_tab.dart';
import 'extraction_tab.dart';
import 'recipes_tab.dart';
import 'settings_tab.dart';

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
    // Reorder tabs to match the new UI layout:
    // 0: Elenza (Console)
    // 1: Recipes
    // 2: Brew Lab (Center FAB)
    // 3: Stats (Extraction)
    // 4: System (Settings)
    _tabs = [
      const ConsoleTab(),
      RecipesTab(onCustomizeTriggered: () {
        setState(() {
          _currentIndex = 2; // BrewLabTab
        });
      }),
      BrewLabTab(onBrewTriggered: () {
        setState(() {
          _currentIndex = 3; // ExtractionTab
        });
      }),
      const ExtractionTab(),
      const SettingsTab(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ElenzaTheme.matteBlack,
      extendBody: false, // Prevent body from flowing under the floating nav bar
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: _buildFloatingNavBar(),
    );
  }

  Widget _buildFloatingNavBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // The Pill Shape Background
            Container(
              height: 75,
              decoration: BoxDecoration(
                color: ElenzaTheme.graphiteDark.withOpacity(0.95),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: ElenzaTheme.graphiteLight, width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(0, 'ELENZA', Icons.coffee_outlined),
                  _buildNavItem(1, 'RECIPES', Icons.favorite_border),
                  const SizedBox(width: 70), // Empty space for the center FAB
                  _buildNavItem(3, 'STATS', Icons.bar_chart),
                  _buildNavItem(4, 'SYSTEM', Icons.settings_outlined),
                ],
              ),
            ),
            
            // The Center FAB (Brew Lab)
            Positioned(
              bottom: 25,
              child: GestureDetector(
                onTap: () => setState(() => _currentIndex = 2),
                child: Container(
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ElenzaTheme.graphiteDark,
                    border: Border.all(color: ElenzaTheme.graphiteLight, width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.show_chart_rounded, // Waveform-like icon
                      color: _currentIndex == 2 ? ElenzaTheme.bronzeAccent : Colors.white54,
                      size: 36,
                    ),
                  ),
                ),
              ),
            ),
            // Center Text Label
            Positioned(
              bottom: 12,
              child: Text(
                'BREW LAB',
                style: TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: _currentIndex == 2 ? ElenzaTheme.bronzeAccent : Colors.white54,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? ElenzaTheme.bronzeAccent : Colors.white54;
    
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 65,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Glowing Top Indicator
            Container(
              height: 4,
              width: 32,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: isSelected ? ElenzaTheme.bronzeAccent : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: ElenzaTheme.bronzeAccent.withOpacity(0.8),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ] : null,
              ),
            ),
            const Spacer(),
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Space Grotesk',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: color,
              ),
            ),
            const SizedBox(height: 14), // Bottom padding
          ],
        ),
      ),
    );
  }
}
