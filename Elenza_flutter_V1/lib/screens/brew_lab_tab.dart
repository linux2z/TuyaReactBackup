import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../state/tuya_state.dart';
import '../state/recipe_state.dart';
import 'grinder_control_screen.dart';

class BrewLabTab extends StatelessWidget {
  final VoidCallback? onBrewTriggered;
  final VoidCallback? onBackPressed;

  const BrewLabTab({super.key, this.onBrewTriggered, this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    final recipeState = Provider.of<RecipeState>(context);
    final tuyaState = Provider.of<TuyaState>(context);
    final activeDeviceName = tuyaState.activeDevice?.name ?? 'No Device Selected';

    return Scaffold(
      backgroundColor: ElenzaTheme.matteBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Brew Control',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            
            // Pressure Profile
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pressure Profile',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activeDeviceName,
                      style: TextStyle(
                        fontSize: 12,
                        color: ElenzaTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Elenza Pro Calibration feature coming soon'),
                        backgroundColor: ElenzaTheme.bronzeAccent,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ElenzaTheme.bronzeAccent,
                    side: const BorderSide(color: ElenzaTheme.bronzeAccent),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Edit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('bar', style: TextStyle(fontSize: 12, color: ElenzaTheme.textSecondary)),
            const SizedBox(height: 8),
            
            // Fake Graph Area
            Container(
              height: 180,
              width: double.infinity,
              padding: const EdgeInsets.only(top: 8, bottom: 20, left: 0, right: 0),
              child: CustomPaint(
                painter: _PressureProfilePainter(),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Parameters Row
            Row(
              children: [
                _buildParameterCard(
                  'Brew Temp.',
                  '${recipeState.targetTemp.toInt()}°C',
                  'Boiler',
                ),
                const SizedBox(width: 12),
                _buildParameterCard(
                  'Pre-Infusion',
                  '${recipeState.preinfusionSeconds.toStringAsFixed(1)}s',
                  '',
                ),
                const SizedBox(width: 12),
                _buildParameterCard(
                  'Flow Focus (AI)',
                  'Balanced',
                  'Recommended',
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Recipes List Title
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: ElenzaTheme.graphiteDark,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.coffee_maker, color: ElenzaTheme.bronzeAccent, size: 20),
                      const SizedBox(width: 16),
                      const Text(
                        'Recipes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Manage all',
                        style: TextStyle(
                          fontSize: 14,
                          color: ElenzaTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right, color: ElenzaTheme.textSecondary, size: 20),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: ElenzaTheme.graphiteLight, height: 1),
            
            // Auto Flush
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              color: ElenzaTheme.graphiteDark,
              child: Row(
                children: [
                  Icon(Icons.access_time, color: ElenzaTheme.textSecondary, size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Auto Flush',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Flush machine for 4 seconds before brewing.',
                          style: TextStyle(
                            fontSize: 12,
                            color: ElenzaTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: true,
                    onChanged: (val) {},
                    activeColor: Colors.white,
                    activeTrackColor: ElenzaTheme.bronzeAccent,
                  ),
                ],
              ),
            ),
            const Divider(color: ElenzaTheme.graphiteLight, height: 1),
            
            // Timer
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: ElenzaTheme.graphiteDark,
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer_outlined, color: ElenzaTheme.bronzeAccent, size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Timer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Daily schedule',
                          style: TextStyle(
                            fontSize: 12,
                            color: ElenzaTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        'On',
                        style: TextStyle(
                          fontSize: 14,
                          color: ElenzaTheme.infoBlue,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right, color: ElenzaTheme.infoBlue, size: 20),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Grinder Sync Option
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: ElenzaTheme.graphiteDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const GrinderControlScreen()),
                  );
                },
                child: Row(
                  children: [
                    Icon(Icons.sync, color: ElenzaTheme.bronzeAccent, size: 24),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Grinder Sync',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: ElenzaTheme.textSecondary, size: 20),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Start Extraction Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onBrewTriggered,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ElenzaTheme.bronzeAccent,
                  foregroundColor: ElenzaTheme.matteBlack,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Start Extraction',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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



  Widget _buildParameterCard(String title, String value, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ElenzaTheme.graphiteDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: ElenzaTheme.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: ElenzaTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PressureProfilePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ElenzaTheme.bronzeAccent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    
    final points = [
      const Offset(0.05, 0.9),
      const Offset(0.15, 0.7),
      const Offset(0.25, 0.6),
      const Offset(0.35, 0.5),
      const Offset(0.45, 0.3),
      const Offset(0.55, 0.2),
      const Offset(0.65, 0.5),
      const Offset(0.75, 0.6),
      const Offset(0.85, 0.7),
      const Offset(0.95, 0.8),
    ];
    
    path.moveTo(points[0].dx * size.width, points[0].dy * size.height);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx * size.width, points[i].dy * size.height);
    }
    
    // Draw fill gradient
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          ElenzaTheme.bronzeAccent.withOpacity(0.3),
          ElenzaTheme.bronzeAccent.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx * size.width, size.height)
      ..lineTo(points.first.dx * size.width, size.height)
      ..close();
      
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
    
    // Draw dots
    final dotPaint = Paint()
      ..color = ElenzaTheme.bronzeAccent
      ..style = PaintingStyle.fill;
      
    for (final p in points) {
      canvas.drawCircle(Offset(p.dx * size.width, p.dy * size.height), 3, dotPaint);
    }
    
    // Draw axes lines and text
    final gridPaint = Paint()
      ..color = ElenzaTheme.graphiteLight
      ..strokeWidth = 1;
      
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), gridPaint); // X axis
    canvas.drawLine(const Offset(0, 0), Offset(0, size.height), gridPaint); // Y axis
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
