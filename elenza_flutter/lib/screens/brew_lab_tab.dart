import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../state/tuya_state.dart';
import '../state/recipe_state.dart';
import '../state/telemetry_state.dart';
import 'grinder_control_screen.dart';

class BrewLabTab extends StatelessWidget {
  final VoidCallback? onBrewTriggered;

  const BrewLabTab({super.key, this.onBrewTriggered});

  @override
  Widget build(BuildContext context) {
    final tuyaState = Provider.of<TuyaState>(context);
    final recipeState = Provider.of<RecipeState>(context);
    final telemetryState = Provider.of<TelemetryState>(context);

    final activeDevice = tuyaState.activeDevice;
    final selectedRecipe = recipeState.selectedRecipe;
    final grindSize = recipeState.grindSize;
    final grindWeight = recipeState.grindWeight;
    final targetYield = recipeState.targetYield;
    final targetTemp = recipeState.targetTemp;
    final preinfusionSeconds = recipeState.preinfusionSeconds;

    void handleBrew() {
      if (activeDevice == null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: ElenzaTheme.graphiteDark,
            title: const Text('Ecosystem Alert', style: TextStyle(color: ElenzaTheme.bronzeAccent)),
            content: const Text('No active ELENZA machine bonded. Please pair a device first.', style: TextStyle(color: Colors.white)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK', style: TextStyle(color: ElenzaTheme.bronzeAccent)),
              ),
            ],
          ),
        );
        return;
      }

      // Trigger telemetry session
      telemetryState.triggerBrewSession(activeDevice.devId, targetTemp, targetYield);

      // Trigger tab jump callback
      if (onBrewTriggered != null) {
        onBrewTriggered!();
      }
    }

    return Scaffold(
      backgroundColor: ElenzaTheme.matteBlack,
      appBar: AppBar(
        title: Column(
          children: const [
            Text(
              'THERMODYNAMIC LABORATORY',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Color(0xA8FFFFFF),
                letterSpacing: 2.0,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'BREW LAB',
              style: TextStyle(
                fontFamily: 'Space Grotesk',
                fontSize: 16,
                letterSpacing: 6,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 1200),
        child: Column(
          children: [
            // Selected Recipe Deck Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: ElenzaTheme.graphiteDark,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: ElenzaTheme.graphiteLight, width: 1.0),
              ),
              child: Column(
                children: [
                  const Text(
                    'Active Calibration Profile',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 8,
                      color: ElenzaTheme.textMuted,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    selectedRecipe.name,
                    style: const TextStyle(
                      fontFamily: 'Space Grotesk',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      selectedRecipe.rating.toInt(),
                      (index) => const Icon(
                        Icons.star,
                        color: ElenzaTheme.bronzeAccent,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Sliders Container
            Container(
              decoration: BoxDecoration(
                color: ElenzaTheme.graphiteDark,
                border: Border.all(color: ElenzaTheme.graphiteLight, width: 1.0),
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BREWING INDICES',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: ElenzaTheme.textMuted,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Grinder Link
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const GrinderControlScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
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
                                'GRINDER COUPLER INDEX',
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
                                'Burr Calibration: Size $grindSize',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: ElenzaTheme.bronzeAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Icon(Icons.arrow_forward, color: ElenzaTheme.bronzeAccent),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Beans Weight Slider
                  _buildIndexSlider(
                    label: 'Beans Weight',
                    value: '${grindWeight.toStringAsFixed(1)}g',
                    min: 10.0,
                    max: 25.0,
                    step: 0.5,
                    currentVal: grindWeight,
                    onChanged: (newVal) => recipeState.updateGrindWeight(newVal),
                  ),

                  // Target Yield Volume
                  _buildIndexSlider(
                    label: 'Target Yield Volume',
                    value: '${targetYield.toInt()}ml',
                    min: 20.0,
                    max: 250.0,
                    step: 5.0,
                    currentVal: targetYield,
                    onChanged: (newVal) => recipeState.updateTargetYield(newVal),
                  ),

                  // Target Temp
                  _buildIndexSlider(
                    label: 'Extraction Temperature',
                    value: '${targetTemp.toInt()}°C',
                    min: 85.0,
                    max: 98.0,
                    step: 1.0,
                    currentVal: targetTemp,
                    onChanged: (newVal) => recipeState.updateTargetTemp(newVal),
                  ),

                  // Preinfusion Delay
                  _buildIndexSlider(
                    label: 'Pre-Infusion Delay',
                    value: '${preinfusionSeconds}s',
                    min: 0.0,
                    max: 10.0,
                    step: 1.0,
                    currentVal: preinfusionSeconds.toDouble(),
                    onChanged: (newVal) => recipeState.updatePreinfusion(newVal.toInt()),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Trigger Brew Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shadowColor: ElenzaTheme.bronzeAccent,
                  elevation: 6,
                ),
                onPressed: handleBrew,
                child: const Text('TRIGGER BREW SESSION'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndexSlider({
    required String label,
    required String value,
    required double min,
    required double max,
    required double step,
    required double currentVal,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: ElenzaTheme.bronzeAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              GestureDetector(
                onTap: () => onChanged((currentVal - step).clamp(min, max)),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: ElenzaTheme.graphiteMedium,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      '-',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      FractionallySizedBox(
                        widthFactor: (currentVal - min) / (max - min),
                        child: Container(
                          color: ElenzaTheme.bronzeAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => onChanged((currentVal + step).clamp(min, max)),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: ElenzaTheme.graphiteMedium,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      '+',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
