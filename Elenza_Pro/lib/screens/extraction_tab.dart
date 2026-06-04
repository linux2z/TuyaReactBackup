import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme.dart';
import '../state/tuya_state.dart';
import '../state/recipe_state.dart';
import '../state/telemetry_state.dart';

class ExtractionTab extends StatelessWidget {
  final VoidCallback? onBackPressed;

  const ExtractionTab({super.key, this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    final recipeState = Provider.of<RecipeState>(context);
    final telemetryState = Provider.of<TelemetryState>(context);

    final selectedRecipe = recipeState.selectedRecipe;
    final pumpPressure = telemetryState.pumpPressure;
    final flowRate = telemetryState.flowRate;
    final boilerTemp = telemetryState.boilerTemp;
    final seconds = telemetryState.extractionSeconds;
    final pressureCurve = telemetryState.pressureCurve;
    final flowCurve = telemetryState.flowCurve;

    void handleAbort() {
      final tuyaState = Provider.of<TuyaState>(context, listen: false);
      if (tuyaState.activeDevice != null) {
        telemetryState.stopTelemetry(tuyaState.activeDevice!.devId);
      }
      telemetryState.resetCurves();
      if (onBackPressed != null) {
        onBackPressed!();
      } else {
        Navigator.of(context).pop();
      }
    }

    List<FlSpot> getSpots(List<double> data, double scale) {
      if (data.isEmpty) return [const FlSpot(0, 0)];
      return data.asMap().entries.map((e) {
        return FlSpot(e.key.toDouble(), e.value * scale);
      }).toList();
    }

    return Scaffold(
      backgroundColor: ElenzaTheme.matteBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ElenzaTheme.textPrimary),
          onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Live Extraction',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share, color: ElenzaTheme.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Recipe Header
            // Recipe Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ElenzaTheme.graphiteDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/coffee_cup.jpeg', // A placeholder for the actual cup image
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => Container(
                        width: 56,
                        height: 56,
                        color: Colors.white.withOpacity(0.05),
                        child: const Icon(Icons.coffee, color: ElenzaTheme.bronzeAccent, size: 32),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedRecipe.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '18g Beans | Target 36ml | 93°C',
                          style: TextStyle(
                            fontSize: 12,
                            color: ElenzaTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Live Gauges
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLiveBox(
                  label: 'Pressure',
                  value: pumpPressure.toStringAsFixed(1),
                  unit: 'bar',
                  valueColor: const Color(0xFF29B6F6), // Light blue
                ),
                const SizedBox(width: 12),
                _buildLiveBox(
                  label: 'Boiler Temp.',
                  value: '${boilerTemp.toInt()}°C',
                  unit: '',
                  valueColor: Colors.white,
                  showChevron: true,
                ),
                const SizedBox(width: 12),
                _buildLiveBox(
                  label: 'Flow Rate',
                  value: flowRate.toStringAsFixed(1),
                  unit: 'ml/s',
                  valueColor: const Color(0xFF29B6F6), // Light blue
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Graph Area
            Container(
              height: 240,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ElenzaTheme.graphiteDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: ElenzaTheme.bronzeAccent, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          const Text('Pressure (bar)', style: TextStyle(fontSize: 12, color: ElenzaTheme.textSecondary)),
                        ],
                      ),
                      Row(
                        children: [
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF29B6F6), shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          const Text('Flow (ml/s)', style: TextStyle(fontSize: 12, color: ElenzaTheme.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.white.withOpacity(0.05),
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 24,
                              getTitlesWidget: (value, meta) {
                                if (value == 0 || value == 6 || value == 12) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: TextStyle(color: ElenzaTheme.textSecondary, fontSize: 10),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 24,
                              getTitlesWidget: (value, meta) {
                                if (value % 5 == 0 && value <= 30) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      '${value.toInt()}s',
                                      style: TextStyle(color: ElenzaTheme.textSecondary, fontSize: 10),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minX: 0,
                        maxX: 30,
                        minY: 0,
                        maxY: 12,
                        lineBarsData: [
                          LineChartBarData(
                            spots: getSpots(pressureCurve, 1.0),
                            isCurved: false,
                            color: ElenzaTheme.bronzeAccent,
                            barWidth: 2,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                                radius: 3,
                                color: ElenzaTheme.bronzeAccent,
                                strokeWidth: 0,
                              ),
                            ),
                          ),
                          LineChartBarData(
                            spots: getSpots(flowCurve, 3.0),
                            isCurved: false,
                            color: const Color(0xFF29B6F6),
                            barWidth: 2,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                                radius: 3,
                                color: const Color(0xFF29B6F6),
                                strokeWidth: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Timer Circle
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white12, width: 2), // Background ring
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: (seconds / 30).clamp(0.0, 1.0),
                    strokeWidth: 4,
                    color: ElenzaTheme.bronzeAccent,
                    backgroundColor: Colors.transparent,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${seconds}s',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Time Elapsed',
                        style: TextStyle(
                          fontSize: 12,
                          color: ElenzaTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Abort Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: handleAbort,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ElenzaTheme.matteBlack,
                  side: const BorderSide(color: ElenzaTheme.bronzeAccent, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'End Extraction',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ElenzaTheme.bronzeAccent,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveBox({required String label, required String value, required String unit, required Color valueColor, bool showChevron = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: ElenzaTheme.graphiteDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: ElenzaTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 12,
                  color: ElenzaTheme.textSecondary,
                ),
              ),
            ],
            if (showChevron) ...[
              const SizedBox(height: 4),
              const Icon(Icons.keyboard_arrow_down, color: Colors.white54, size: 16),
            ]
          ],
        ),
      ),
    );
  }
}
