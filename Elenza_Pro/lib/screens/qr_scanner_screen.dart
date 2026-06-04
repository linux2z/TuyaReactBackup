import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../state/telemetry_state.dart';
import '../state/recipe_state.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isScanned = false;

  void _onDetect(BarcodeCapture capture) {
    if (_isScanned) return;
    
    // For demonstration, we trigger the payload parsing immediately on any QR
    if (capture.barcodes.isNotEmpty) {
      setState(() {
        _isScanned = true;
      });
      // Pause scanner after detection
      controller.stop();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final telemetryState = Provider.of<TelemetryState>(context, listen: false);
    final recipeState = Provider.of<RecipeState>(context, listen: false);

    return Scaffold(
      backgroundColor: ElenzaTheme.matteBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Scan Coffee Bag',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          // The Live Camera Feed
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),
          
          // The Overlay mask and text
          Positioned.fill(
            child: Container(
              color: Colors.black54, // Semi-transparent mask
            ),
          ),
          
          Column(
            children: [
              const SizedBox(height: 40),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  'Scan the QR code on your coffee bag to recognize your beans.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
                ),
              ),
              const SizedBox(height: 40),
              
              // The QR Framing Box
              Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: ElenzaTheme.bronzeAccent, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: MobileScanner(
                        controller: controller, // Re-use controller to show camera un-masked here
                        onDetect: _onDetect,
                      ),
                    ),
                  ),
                ),
              ),
              
              const Spacer(),
              
              // The Results Card
              if (_isScanned)
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161616),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recognized Bean',
                        style: TextStyle(
                          color: ElenzaTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Elenza House Blend',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Brazil / Colombia\nMedium Roast',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Roasted on: 01 May 2024',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            telemetryState.addBeanProfile('Elenza House Blend', 93.0, 9.0, 2.0, 30.0);
                            telemetryState.addLog('Bean Profile Added: Elenza House Blend', type: 'success');
                            
                            // Automatically offer suggested settings into RecipeState for Brew Lab
                            recipeState.updateTargetTemp(93.0);
                            recipeState.updatePreinfusion(4);
                            recipeState.updateTargetYield(36.0);
                            
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ElenzaTheme.bronzeAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Add to My Beans',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}
