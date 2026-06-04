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
  bool _calibrating = false;

  String _getGrindDescription(int size) {
    if (size <= 5) return 'Super-Fine Turkish (Micro dust)';
    if (size <= 10) return 'Classic Espresso Calibration (Calibrated)';
    if (size <= 15) return 'Medium-Fine Moka Pot / AeroPress';
    if (size <= 20) return 'Medium Drip / V60 Filter';
    if (size <= 25) return 'Coarse Chemex / Pour Over';
    return 'Super-Coarse French Press (Grit size)';
  }

  void _handleCalibrate() {
    setState(() {
      _calibrating = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _calibrating = false;
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: ElenzaTheme.graphiteDark,
            title: const Text('Calibration Successful', style: TextStyle(color: ElenzaTheme.bronzeAccent)),
            content: const Text('Burr micro-alignment calibration sequence successful.', style: TextStyle(color: Colors.white)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK', style: TextStyle(color: ElenzaTheme.bronzeAccent)),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final recipeState = Provider.of<RecipeState>(context);
    final grindSize = recipeState.grindSize;

    return Scaffold(
      backgroundColor: ElenzaTheme.matteBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 10),
              Center(
                child: Column(
                  children: [
                    Text(
                      'BURR SPACING CALIBRATOR',
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
                      'GRINDER CONTROL',
                      style: TextStyle(
                        fontFamily: 'Space Grotesk',
                        fontSize: 22,
                        letterSpacing: 4,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Visual Burr Spacing Indicator Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: ElenzaTheme.graphiteDark,
                  border: Border.all(color: ElenzaTheme.graphiteLight, width: 1.0),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  children: [
                    const Text(
                      'BURR COUPLER GAP RATIO',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: ElenzaTheme.textMuted,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Burr Ring
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: ElenzaTheme.bronzeAccent, width: 8.0),
                        color: Colors.white.withOpacity(0.01),
                      ),
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Rotate inner burr representation
                            Transform.rotate(
                              angle: (grindSize * 12) * 3.14159 / 180,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                    width: 6,
                                    style: BorderStyle.solid, // Dash simulation in flutter
                                  ),
                                ),
                                child: CircularProgressIndicator(
                                  value: 0.8,
                                  strokeWidth: 2,
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.05)),
                                ),
                              ),
                            ),
                            Text(
                              '${grindSize * 15} μm',
                              style: const TextStyle(
                                fontFamily: 'Space Grotesk',
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                    Text(
                      _getGrindDescription(grindSize),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: ElenzaTheme.bronzeAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Control Box Card
              Container(
                decoration: BoxDecoration(
                  color: ElenzaTheme.graphiteDark,
                  border: Border.all(color: ElenzaTheme.graphiteLight, width: 1.0),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Alignment Step Size',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: Colors.white60, // changed to white60 to be compile-safe and clean
                          ),
                        ),
                        Text(
                          '$grindSize / 30',
                          style: const TextStyle(
                            fontFamily: 'Space Grotesk',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: ElenzaTheme.bronzeAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => recipeState.updateGrindSize(
                            (grindSize - 1).clamp(1, 30),
                          ),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: ElenzaTheme.graphiteMedium,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                '-',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              children: [
                                FractionallySizedBox(
                                  widthFactor: grindSize / 30.0,
                                  child: Container(
                                    color: ElenzaTheme.bronzeAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => recipeState.updateGrindSize(
                            (grindSize + 1).clamp(1, 30),
                          ),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: ElenzaTheme.graphiteMedium,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                '+',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
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
              ),

              const SizedBox(height: 30),

              // Calibrate CTA
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  onPressed: _calibrating ? null : _handleCalibrate,
                  child: _calibrating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        )
                      : const Text('INITIATE MICRO-ALIGNMENT LOOP'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
