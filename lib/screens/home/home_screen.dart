import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../widgets/app_buttons.dart';
import '../scanner/scanner_screen.dart';
import '../my_medicines/my_medicines_screen.dart';
import '../safety/safety_result_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageObjectProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.appName),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Chip(
                label: Text(language.nativeName),
                backgroundColor: Colors.white,
                labelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome 👋', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(
                'Scan a medicine strip to verify it and learn how to use it safely.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),

              // Primary action - big, unmissable.
              Card(
                color: AppColors.primary,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ScannerScreen()),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 42),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Scan Medicine',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Camera or upload an image',
                                style: TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 18),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),
              Text('More options', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 14),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.15,
                  children: [
                    HomeActionTile(
                      label: 'My Medicines',
                      icon: Icons.medication_liquid_rounded,
                      color: AppColors.secondary,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MyMedicinesScreen()),
                      ),
                    ),
                    HomeActionTile(
                      label: 'Check Interactions',
                      icon: Icons.health_and_safety_outlined,
                      color: AppColors.cautionYellow,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SafetyResultScreen()),
                      ),
                    ),
                    HomeActionTile(
                      label: 'Voice Assistance',
                      icon: Icons.record_voice_over_rounded,
                      color: AppColors.primary,
                      onTap: () {
                        final voice = ref.read(voiceServiceProvider);
                        final lang = ref.read(languageProvider);
                        voice.speak(
                          'Welcome to Swasthya Seva. Tap Scan Medicine to check a medicine strip.',
                          languageCode: lang,
                        );
                      },
                    ),
                    HomeActionTile(
                      label: 'Scan Again',
                      icon: Icons.camera_alt_rounded,
                      color: AppColors.textSecondary,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ScannerScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
