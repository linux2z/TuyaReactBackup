import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../state/tuya_state.dart';

class PairingScreen extends StatefulWidget {
  const PairingScreen({super.key});

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Selected Data
  String _selectedModel = '';
  Map<String, dynamic>? _selectedBleDevice;
  
  // Form Controllers
  final _nameController = TextEditingController();
  final _locationController = TextEditingController(text: 'Home');
  final _timezoneController = TextEditingController(text: '(GMT+01:00) Berlin');

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _locationController.dispose();
    _timezoneController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentStep++);
      
      // Trigger BLE scan if entering connect step
      if (_currentStep == 2) {
        Provider.of<TuyaState>(context, listen: false).startBleScan();
      }
    } else {
      // Done -> pop to root (which is Splash or Dashboard)
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ElenzaTheme.matteBlack,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    if (_currentStep > 0) {
                      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      setState(() => _currentStep--);
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                ),
                Expanded(
                  child: Text(
                    _getStepTitle(),
                    style: const TextStyle(
                      fontFamily: 'Space Grotesk',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 48), // Balance for arrow
              ],
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildModelSelection(),
                  _buildMachineDetails(),
                  _buildBleConnection(),
                  _buildRegistrationForm(),
                  _buildCompletion(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0: return 'Select Model';
      case 1: return _selectedModel;
      case 2: return 'Connect';
      case 3: return 'Register Machine';
      case 4: return 'Setup Complete';
      default: return '';
    }
  }

  Widget _buildModelSelection() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Choose your ELENZA model', style: TextStyle(color: ElenzaTheme.textSecondary, fontSize: 14)),
          const SizedBox(height: 24),
          _buildModelCard('Nina V2', 'Compact. Elegant. Intelligent.', imagePath: 'assets/nina_v2.png'),
          const SizedBox(height: 16),
          _buildModelCard('Modena V2', 'Powerful. Versatile. Reliable.', imagePath: 'assets/modena_v2.png'),
          const SizedBox(height: 16),
          _buildModelCard('Modena R', 'Professional. Robust. High-performance.', imagePath: 'assets/modena_v2.png'), // Fallback to modena_v2 for R
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedModel.isNotEmpty ? _nextStep : null,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelCard(String title, String subtitle, {String? imagePath}) {
    final isSelected = _selectedModel == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedModel = title),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ElenzaTheme.graphiteDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? ElenzaTheme.bronzeAccent : ElenzaTheme.graphiteLight,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            if (imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imagePath,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.coffee_maker, size: 40, color: isSelected ? ElenzaTheme.bronzeAccent : Colors.white54),
                ),
              )
            else
              Icon(Icons.coffee_maker, size: 40, color: isSelected ? ElenzaTheme.bronzeAccent : Colors.white54),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: ElenzaTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? ElenzaTheme.bronzeAccent : Colors.white24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMachineDetails() {
    String imagePath = 'assets/modena_v2.png';
    if (_selectedModel == 'Nina V2') {
      imagePath = 'assets/nina_v2.png';
    }
    
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Machine Image
          Center(
            child: Image.asset(
              imagePath,
              height: 220,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 40),
          // Features List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                _buildFeatureItem('Dual Boiler System'),
                const SizedBox(height: 20),
                _buildFeatureItem('Thermodynamic Stabilization'),
                const SizedBox(height: 20),
                _buildFeatureItem('Integrated Scale'),
                const SizedBox(height: 20),
                _buildFeatureItem('Grinder Sync Compatible'),
                const SizedBox(height: 20),
                _buildFeatureItem('Touch Display'),
              ],
            ),
          ),
          // Bottom Button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ElenzaTheme.bronzeAccent,
                  foregroundColor: ElenzaTheme.matteBlack,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Choose this model',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ElenzaTheme.bronzeAccent, width: 1.5),
          ),
          child: const Center(
            child: Icon(Icons.add, color: ElenzaTheme.bronzeAccent, size: 16),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBleConnection() {
    final tuyaState = Provider.of<TuyaState>(context);
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Text('Establish a connection to your machine', style: TextStyle(color: ElenzaTheme.textSecondary, fontSize: 14)),
          const SizedBox(height: 40),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ElenzaTheme.bronzeAccent, width: 2),
            ),
            child: const Center(
              child: Icon(Icons.bluetooth, size: 60, color: ElenzaTheme.infoBlue),
            ),
          ),
          const SizedBox(height: 30),
          Text(tuyaState.pairingStatus, style: const TextStyle(color: ElenzaTheme.textSecondary, fontSize: 14)),
          const SizedBox(height: 30),
          
          if (tuyaState.discoveredBleDevices.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: tuyaState.discoveredBleDevices.length,
                itemBuilder: (context, index) {
                  final device = tuyaState.discoveredBleDevices[index];
                  return ListTile(
                    tileColor: ElenzaTheme.graphiteDark,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    leading: const Icon(Icons.coffee_maker, color: Colors.white),
                    title: Text(device['name'] ?? 'ELENZA Device', style: const TextStyle(color: Colors.white)),
                    subtitle: Text('MAC: ${device['mac']}', style: const TextStyle(color: ElenzaTheme.textSecondary)),
                    trailing: const Icon(Icons.signal_cellular_alt, color: ElenzaTheme.successGreen),
                    onTap: () {
                      setState(() => _selectedBleDevice = device);
                      _nextStep();
                    },
                  );
                },
              ),
            )
          else
            const Expanded(child: Center(child: CircularProgressIndicator(color: ElenzaTheme.bronzeAccent))),
        ],
      ),
    );
  }

  Widget _buildRegistrationForm() {
    final tuyaState = Provider.of<TuyaState>(context);
    
    // Auto-fill name if selected
    if (_nameController.text.isEmpty && _selectedModel.isNotEmpty) {
      _nameController.text = 'My $_selectedModel';
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Give your machine a name', style: TextStyle(color: ElenzaTheme.textSecondary, fontSize: 14)),
          const SizedBox(height: 30),
          
          _buildFormLabel('Machine Name'),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(hintText: 'e.g. Kitchen Espresso'),
          ),
          const SizedBox(height: 20),
          
          _buildFormLabel('Location (optional)'),
          TextField(
            controller: _locationController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(hintText: 'Home'),
          ),
          const SizedBox(height: 20),
          
          _buildFormLabel('Timezone'),
          TextField(
            controller: _timezoneController,
            style: const TextStyle(color: Colors.white),
          ),
          
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_selectedBleDevice != null) {
                  tuyaState.startBlePairing(
                    _selectedBleDevice!['mac'], 
                    _selectedBleDevice!['productId'] ?? '', 
                    _selectedBleDevice!['uuid'] ?? ''
                  );
                }
                _nextStep();
              },
              child: const Text('Register'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: ElenzaTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildCompletion() {
    final tuyaState = Provider.of<TuyaState>(context);
    final isDone = !tuyaState.isPairingInProgress && tuyaState.activeDevice != null;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone ? ElenzaTheme.successGreen.withOpacity(0.1) : ElenzaTheme.graphiteDark,
            ),
            child: Center(
              child: isDone
                  ? const Icon(Icons.check, size: 50, color: ElenzaTheme.successGreen)
                  : const CircularProgressIndicator(color: ElenzaTheme.bronzeAccent),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            isDone ? 'Setup Complete!' : 'Pairing with ${_nameController.text}...',
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            isDone ? 'Your ${_nameController.text} is now connected and ready.' : tuyaState.pairingStatus,
            textAlign: TextAlign.center,
            style: const TextStyle(color: ElenzaTheme.textSecondary, fontSize: 14),
          ),
          if (isDone) ...[
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextStep, // Finishes flow
                child: const Text('Go to Dashboard'),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
