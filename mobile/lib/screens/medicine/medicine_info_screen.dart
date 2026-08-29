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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Medicine Information')),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text('Could not load medicine details.\n$err', textAlign: TextAlign.center),
          ),
        ),
        data: (detail) {
          final status = detail.medicine.overallStatus;
          return Stack(
            children: [
              Positioned(
                top: -110,
                right: -70,
                child: _Glow(color: AppColors.primary.withOpacity(isDark ? 0.15 : 0.08)),
              ),
              Positioned(
                top: 240,
                left: -100,
                child: _Glow(color: AppColors.secondary.withOpacity(isDark ? 0.10 : 0.06)),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(26),
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [AppColors.primaryDark, AppColors.darkSurface]
                                    : [AppColors.primary, AppColors.primaryDark],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.25),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.16),
                                        borderRadius: BorderRadius.circular(17),
                                      ),
                                      child: const Icon(Icons.medication_rounded, color: Colors.white, size: 28),
                                    ),
                                    const Spacer(),
                                    VerifiedBadge(status: status),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  detail.medicine.brandName,
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  detail.medicine.genericName,
                                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.business_rounded, size: 18, color: Colors.white70),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          detail.medicine.manufacturer,
                                          style: const TextStyle(color: Colors.white70),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          _QuickInfoStrip(
                            items: [
                              _QuickInfo('Verified', Icons.verified_rounded, AppColors.safeGreen),
                              _QuickInfo('${detail.activeIngredients.length} ingredients', Icons.science_rounded, AppColors.secondary),
                              _QuickInfo('Safety info', Icons.health_and_safety_rounded, AppColors.primary),
                            ],
                          ),
                          const SizedBox(height: 18),

                          SectionCard(
                            title: 'Active Ingredients',
                            icon: Icons.science_outlined,
                            child: BulletList(items: detail.activeIngredients),
                          ),
                          const SizedBox(height: 14),
                          SectionCard(
                            title: 'What it is used for',
                            icon: Icons.info_outline_rounded,
                            child: Text(detail.usage, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.45)),
                          ),
                          const SizedBox(height: 14),
                          SectionCard(
                            title: 'How to take it',
                            icon: Icons.medication_outlined,
                            accentColor: AppColors.secondary,
                            child: Text(detail.dosage, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.45)),
                          ),
                          const SizedBox(height: 14),
                          SectionCard(
                            title: 'Food & drink guidance',
                            icon: Icons.restaurant_outlined,
                            accentColor: AppColors.safeGreen,
                            child: Text(detail.foodGuidance, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.45)),
                          ),
                          const SizedBox(height: 14),
                          SectionCard(
                            title: 'Important warnings',
                            icon: Icons.warning_amber_rounded,
                            accentColor: AppColors.cautionYellow,
                            child: BulletList(items: detail.warnings, dotColor: AppColors.cautionYellow),
                          ),
                          if (detail.interactionWarnings.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            SectionCard(
                              title: 'Interaction warnings',
                              icon: Icons.dangerous_rounded,
                              accentColor: AppColors.dangerRed,
                              child: BulletList(items: detail.interactionWarnings, dotColor: AppColors.dangerRed),
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const SafetyResultScreen()),
                              ),
                              icon: const Icon(Icons.health_and_safety_outlined),
                              label: const Text('View full safety check'),
                            ),
                          ],
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.96),
                        border: Border(top: BorderSide(color: AppColors.primary.withOpacity(0.10))),
                      ),
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
                              label: _added ? 'Added' : 'Add to My Medicines',
                              icon: _added ? Icons.check_rounded : Icons.add_rounded,
                              isLoading: _isAdding,
                              onPressed: _added ? null : _addToMyMedicines,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color;
  const _Glow({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: 240,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _QuickInfo {
  final String label;
  final IconData icon;
  final Color color;
  const _QuickInfo(this.label, this.icon, this.color);
}

class _QuickInfoStrip extends StatelessWidget {
  final List<_QuickInfo> items;
  const _QuickInfoStrip({required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items
          .map((item) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: item == items.last ? 0 : 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: item.color.withOpacity(0.14)),
                    ),
                    child: Column(
                      children: [
                        Icon(item.icon, size: 19, color: item.color),
                        const SizedBox(height: 5),
                        Text(
                          item.label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: item.color,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}
