import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../state/tuya_state.dart';

class RegionScreen extends StatelessWidget {
  const RegionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tuyaState = Provider.of<TuyaState>(context);
    final activeRegion = tuyaState.region;

    final regions = [
      TuyaRegion(code: '1', name: 'USA/Americas'),
      TuyaRegion(code: '39', name: 'Europe/Middle East'),
      TuyaRegion(code: '86', name: 'China Datacenter'),
      TuyaRegion(code: '91', name: 'Asia Pacific/India'),
    ];

    return Scaffold(
      backgroundColor: ElenzaTheme.matteBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Text(
                      'CLOUD ROUTING SCHEME',
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
                      'DATACENTER',
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
              const Text(
                'Select the appropriate Tuya cloud gateway. Ensuring alignment with your physical geolocation yields minimal ping latency and fast MQTT telemetry updates.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  height: 1.6,
                  color: ElenzaTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: regions.length,
                itemBuilder: (context, index) {
                  final r = regions[index];
                  final isActive = activeRegion.code == r.code;

                  return GestureDetector(
                    onTap: () {
                      tuyaState.setRegion(r);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: ElenzaTheme.graphiteDark,
                        border: Border.all(
                          color: isActive ? ElenzaTheme.bronzeAccent : ElenzaTheme.graphiteLight,
                          width: isActive ? 1.5 : 1.0,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.name,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Routing Gateway Code: ${r.code}',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10,
                                  color: ElenzaTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                          if (isActive)
                            Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: ElenzaTheme.bronzeAccent,
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.black,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
