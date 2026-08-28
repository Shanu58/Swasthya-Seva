import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/medicine_model.dart';
import '../../providers/app_providers.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/section_card.dart';
import '../../widgets/verified_badge.dart';
import '../safety/safety_result_screen.dart';

class MedicineInfoScreen extends ConsumerStatefulWidget {
  final Medicine medicine;
  const MedicineInfoScreen({super.key, required this.medicine});

  @override
  ConsumerState<MedicineInfoScreen> createState() => _MedicineInfoScreenState();
}

class _MedicineInfoScreenState extends ConsumerState<MedicineInfoScreen> {
  bool _isAdding = false;
  bool _added = false;
  bool _isSpeaking = false;
  StreamSubscription<bool>? _speakingSub;

  @override
  void initState() {
    super.initState();
    // Subscribed once so the Listen/Stop button reflects the actual TTS
    // engine state (handles natural completion, not just manual Stop).
    final voice = ref.read(voiceServiceProvider);
    _speakingSub = voice.isSpeakingStream.listen((speaking) {
      if (mounted) setState(() => _isSpeaking = speaking);
    });
  }

  @override
  void dispose() {
    _speakingSub?.cancel();
    super.dispose();
  }

  Future<void> _toggleListen(String text) async {
    final voice = ref.read(voiceServiceProvider);
    final lang = ref.read(languageProvider);

    if (_isSpeaking) {
      await voice.stop();
      return;
    }
    await voice.speak(text, languageCode: lang);
  }

  Future<void> _addToMyMedicines() async {
    setState(() => _isAdding = true);
    try {
      final api = ref.read(apiServiceProvider);
      await api.addToMyMedicines(widget.medicine);
      ref.invalidate(myMedicinesProvider);
      if (!mounted) return;
      setState(() {
        _isAdding = false;
        _added = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to My Medicines')),
      );
    } catch (e) {
      setState(() => _isAdding = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save this medicine. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(medicineDetailProvider(widget.medicine.medicineId));

    return Scaffold(
      appBar: AppBar(title: const Text('Medicine Information')),
      body: SafeArea(
        child: detailAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Could not load medicine details.\n$err', textAlign: TextAlign.center),
            ),
          ),
          data: (detail) {
            final status = detail.medicine.overallStatus;
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(detail.medicine.brandName,
                                    style: Theme.of(context).textTheme.headlineMedium),
                                Text('Generic: ${detail.medicine.genericName}',
                                    style: Theme.of(context).textTheme.bodyLarge),
                              ],
                            ),
                          ),
                          VerifiedBadge(status: status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Manufacturer: ${detail.medicine.manufacturer}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 20),

                      SectionCard(
                        title: 'Active Ingredients',
                        icon: Icons.science_outlined,
                        child: BulletList(items: detail.activeIngredients),
                      ),
                      const SizedBox(height: 14),

                      SectionCard(
                        title: 'Usage',
                        icon: Icons.info_outline_rounded,
                        child: Text(detail.usage, style: Theme.of(context).textTheme.bodyLarge),
                      ),
                      const SizedBox(height: 14),

                      SectionCard(
                        title: 'Dosage / How to Take',
                        icon: Icons.medication_outlined,
                        child: Text(detail.dosage, style: Theme.of(context).textTheme.bodyLarge),
                      ),
                      const SizedBox(height: 14),

                      SectionCard(
                        title: 'Food Guidance',
                        icon: Icons.restaurant_outlined,
                        child: Text(detail.foodGuidance, style: Theme.of(context).textTheme.bodyLarge),
                      ),
                      const SizedBox(height: 14),

                      SectionCard(
                        title: 'Warnings',
                        icon: Icons.warning_amber_rounded,
                        accentColor: AppColors.cautionYellow,
                        child: BulletList(items: detail.warnings, dotColor: AppColors.cautionYellow),
                      ),

                      if (detail.interactionWarnings.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        SectionCard(
                          title: 'Interaction / Duplicate Ingredient Warning',
                          icon: Icons.dangerous_rounded,
                          accentColor: AppColors.dangerRed,
                          child: BulletList(
                            items: detail.interactionWarnings,
                            dotColor: AppColors.dangerRed,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const SafetyResultScreen()),
                            ),
                            icon: const Icon(Icons.health_and_safety_outlined),
                            label: const Text('View full safety check'),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: SecondaryActionButton(
                          label: _isSpeaking ? 'Stop' : 'Listen',
                          icon: _isSpeaking ? Icons.stop_circle_outlined : Icons.volume_up_rounded,
                          onPressed: () => _toggleListen(detail.spokenSummary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PrimaryActionButton(
                          label: _added ? 'Added ✓' : 'Add to My Medicines',
                          icon: _added ? Icons.check_rounded : Icons.add_rounded,
                          isLoading: _isAdding,
                          onPressed: _added ? null : _addToMyMedicines,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
