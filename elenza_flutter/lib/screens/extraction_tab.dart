import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme.dart';
import '../state/tuya_state.dart';
import '../state/recipe_state.dart';
import '../state/telemetry_state.dart';

class ExtractionTab extends StatelessWidget {
  const ExtractionTab({super.key});

  @override
  Widget build(BuildContext context) {
    final recipeState = Provider.of<RecipeState>(context);
    final telemetryState = Provider.of<TelemetryState>(context);

    final selectedRecipe = recipeState.selectedRecipe;
    final targetYield = recipeState.targetYield;
    final targetTemp = recipeState.targetTemp;

    final pumpPressure = telemetryState.pumpPressure;
    final flowRate = telemetryState.flowRate;
    final boilerTemp = telemetryState.boilerTemp;
    final machineState = telemetryState.machineState;
    final seconds = telemetryState.extractionSeconds;
    final pressureCurve = telemetryState.pressureCurve;
    final flowCurve = telemetryState.flowCurve;

    void handleAbort() {
      // Abort or clear curve session
      telemetryState.resetCurves();
      // If we want to reset State back to Ready we can, though state machine handles it.
    }

    // Convert list to Spot coordinates
    List<FlSpot> getSpots(List<double> data, double scale) {
      if (data.isEmpty) return [const FlSpot(0, 0)];
      return data.asMap().entries.map((e) {
        return FlSpot(e.key.toDouble(), e.value * scale);
      }).toList();
    }

    return Scaffold(
      backgroundColor: ElenzaTheme.matteBlack,
      appBar: AppBar(
        title: Column(
          children: const [
            Text(
              'THERMODYNAMIC STREAM',
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
              'LIVE EXTRACTION',
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ElenzaTheme.graphiteDark, // Graphite surface
                  border: Border.all(color: ElenzaTheme.graphiteLight, width: 1.0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetaColumn('Recipe Profile', selectedRecipe.name),
                    _buildMetaColumn('Target Temperature', '${targetTemp.toInt()}°C'),
                    _buildMetaColumn('Target Yield', '${targetYield.toInt()}ml'),
                  ],
                ),
              ),

              // Live Gauges Triple Grid
              Row(
                children: [
                  _buildLiveBox(
                    label: 'Pressure',
                    value: '${pumpPressure.toStringAsFixed(1)} ',
                    unit: 'Bar',
                    color: ElenzaTheme.bronzeAccent,
                  ),
                  _buildLiveBox(
                    label: 'Boiler Temp',
                    value: '${boilerTemp.toInt()}°C',
                    unit: '',
                    color: Colors.white,
                  ),
                  _buildLiveBox(
                    label: 'Flow Speed',
                    value: '${flowRate.toStringAsFixed(1)} ',
                    unit: 'ml/s',
                    color: ElenzaTheme.hydraulicCyan,
                  ),
                ],
              ),

              // Dynamic Wave Chart Visualizer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ElenzaTheme.graphiteDark,
                  border: Border.all(color: ElenzaTheme.graphiteLight, width: 1.0),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'EXTRACTION THERMODYNAMIC CALIBRATION (28S)',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 8,
                        color: ElenzaTheme.textMuted,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // fl_chart Graph Box
                    Container(
                      height: 160,
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 10, right: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.03)),
                      ),
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: Colors.white.withOpacity(0.04),
                              strokeWidth: 1.0,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value % 5 == 0 && value <= 28) {
                                    return Text(
                                      '${value.toInt()}s',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.2),
                                        fontSize: 8,
                                        fontFamily: 'Inter',
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                                reservedSize: 18,
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          maxX: 28,
                          minY: 0,
                          maxY: 12,
                          lineBarsData: [
                            // Pump Pressure Curve (Gold)
                            LineChartBarData(
                              spots: getSpots(pressureCurve, 1.0),
                              isCurved: true,
                              color: ElenzaTheme.bronzeAccent,
                              barWidth: 2.5,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                            ),
                            // Flow Rate Curve (Cyan - scaled to show nicely together)
                            LineChartBarData(
                              spots: getSpots(flowCurve, 3.0), // Scale up so 3ml/s sits around 9 Bar height
                              isCurved: true,
                              color: ElenzaTheme.hydraulicCyan,
                              barWidth: 1.5,
                              dashArray: [4, 4],
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        Text(
                          '■ Pump Pressure (Bar)',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: ElenzaTheme.bronzeAccent,
                          ),
                        ),
                        Text(
                          '■ Flow Velocity (ml/s)',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: ElenzaTheme.hydraulicCyan,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Extraction Timer Circle
              Center(
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: ElenzaTheme.bronzeAccent, width: 3.0),
                    color: Colors.white.withOpacity(0.01),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${seconds}s',
                        style: const TextStyle(
                          fontFamily: 'Space Grotesk',
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        machineState == 'Brewing' ? 'EXTRACTION DURATION' : 'SESSION COMPLETED',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                          color: ElenzaTheme.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Abort Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: machineState == 'Brewing' ? Colors.redAccent : ElenzaTheme.bronzeAccent,
                    side: BorderSide(
                      color: machineState == 'Brewing' ? Colors.redAccent : ElenzaTheme.bronzeAccent,
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: handleAbort,
                  child: Text(
                    machineState == 'Brewing' ? 'ABORT EXTRACTION' : 'RESET CONSOLE WAVE',
                    style: TextStyle(
                      fontFamily: 'Space Grotesk',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 8,
            color: ElenzaTheme.textMuted,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildLiveBox({
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ElenzaTheme.graphiteDark,
          border: Border.all(color: ElenzaTheme.graphiteLight, width: 1.0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 8,
                color: ElenzaTheme.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                children: [
                  TextSpan(text: value),
                  if (unit.isNotEmpty)
                    TextSpan(
                      text: unit,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.normal,
                        color: Colors.white30,
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
}
