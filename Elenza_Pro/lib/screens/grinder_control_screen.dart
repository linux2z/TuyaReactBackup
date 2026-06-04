import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../state/recipe_state.dart';

class GrinderControlScreen extends StatefulWidget {
  const GrinderControlScreen({super.key});

  @override
  State<GrinderControlScreen> createState() => _GrinderControlScreenState();
}

class _GrinderControlScreenState extends State<GrinderControlScreen> {
  bool _grindBySync = true;
  double _targetFlowRate = 2.2;
  double _currentFlowRate = 2.1;

  @override
  Widget build(BuildContext context) {
    final recipeState = Provider.of<RecipeState>(context);
    final grindSize = recipeState.grindSize;

    return Scaffold(
      backgroundColor: ElenzaTheme.matteBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Grinder Sync',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Connection Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: ElenzaTheme.graphiteDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ElenzaTheme.bronzeAccent.withOpacity(0.5), width: 1.5),
                    ),
                    child: const Icon(Icons.coffee_maker, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Grinder Control',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Elenza Smart Grinder',
                          style: TextStyle(
                            fontSize: 13,
                            color: ElenzaTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'Connected',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D32), // Darker green
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Sync Toggle (NOT IN A CARD)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Grind by Sync',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Switch(
                    value: _grindBySync,
                    onChanged: (val) {
                      setState(() {
                        _grindBySync = val;
                      });
                    },
                    activeColor: Colors.white,
                    activeTrackColor: ElenzaTheme.bronzeAccent,
                    inactiveTrackColor: Colors.white24,
                    inactiveThumbColor: Colors.white54,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Flow Rate Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ElenzaTheme.graphiteDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Target Flow Rate
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Target Flow Rate',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${_targetFlowRate.toStringAsFixed(1)} ml/s',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: ElenzaTheme.bronzeAccent,
                      inactiveTrackColor: Colors.black26,
                      thumbColor: ElenzaTheme.bronzeAccent,
                      overlayColor: ElenzaTheme.bronzeAccent.withOpacity(0.2),
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                    ),
                    child: Slider(
                      value: _targetFlowRate,
                      min: 0.5,
                      max: 5.0,
                      onChanged: (val) {
                        setState(() {
                          _targetFlowRate = val;
                        });
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('0.5', style: TextStyle(color: ElenzaTheme.textSecondary, fontSize: 12)),
                      Text('5.0', style: TextStyle(color: ElenzaTheme.textSecondary, fontSize: 12)),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Current Flow Rate
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Flow Rate',
                        style: TextStyle(
                          fontSize: 14,
                          color: ElenzaTheme.textSecondary,
                        ),
                      ),
                      Text(
                        '${_currentFlowRate.toStringAsFixed(1)} ml/s',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF29B6F6), // Light blue
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Grinder Setting Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ElenzaTheme.graphiteDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Grinder Setting',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          _buildAdjustButton(Icons.remove, () {
                            recipeState.updateGrindSize((grindSize - 1).clamp(1, 40));
                          }),
                          const SizedBox(width: 12),
                          _buildAdjustButton(Icons.add, () {
                            recipeState.updateGrindSize((grindSize + 1).clamp(1, 40));
                          }),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: ElenzaTheme.bronzeAccent,
                      inactiveTrackColor: Colors.black26,
                      thumbColor: ElenzaTheme.bronzeAccent,
                      overlayColor: ElenzaTheme.bronzeAccent.withOpacity(0.2),
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                    ),
                    child: Slider(
                      value: grindSize.toDouble(),
                      min: 1,
                      max: 40,
                      onChanged: (val) {
                        recipeState.updateGrindSize(val.toInt());
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('1', style: TextStyle(color: ElenzaTheme.textSecondary, fontSize: 12)),
                      Text('40', style: TextStyle(color: ElenzaTheme.textSecondary, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Grind Size',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          const Text(
                            'Fine',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.qr_code_scanner, color: ElenzaTheme.textSecondary, size: 20),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ElenzaTheme.graphiteDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb, color: ElenzaTheme.bronzeAccent, size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Flow rate too low?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Activate Grind by Sync. The app automatically adjusts the grinder setting.',
                          style: TextStyle(
                            fontSize: 13,
                            color: ElenzaTheme.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdjustButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: ElenzaTheme.graphiteLight, width: 2),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
