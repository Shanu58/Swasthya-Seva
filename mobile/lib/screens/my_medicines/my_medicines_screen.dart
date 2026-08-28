import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import '../../core/theme/app_theme.dart';
import '../../models/my_medicine_model.dart';
import '../../providers/app_providers.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/verified_badge.dart';
import '../safety/safety_result_screen.dart';

class MyMedicinesScreen extends ConsumerWidget {
  const MyMedicinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicinesAsync = ref.watch(myMedicinesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Medicines')),
      body: SafeArea(
        child: medicinesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Text('Could not load your medicines.\n$err', textAlign: TextAlign.center),
          ),
          data: (medicines) {
            if (medicines.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.medication_liquid_outlined,
                          size: 56, color: AppColors.textSecondary),
                      const SizedBox(height: 12),
                      Text(
                        'No medicines saved yet.\nScan a medicine and tap "Add to My Medicines".',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: medicines.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _MedicineTile(medicine: medicines[index]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: PrimaryActionButton(
                    label: 'Check Interactions',
                    icon: Icons.health_and_safety_outlined,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SafetyResultScreen()),
                    ),
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

class _MedicineTile extends StatelessWidget {
  final MyMedicine medicine;
  const _MedicineTile({required this.medicine});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.medication_rounded, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(medicine.brandName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(medicine.genericName, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    medicine.expiryDate != null
                        ? 'Expires ${intl.DateFormat('dd MMM yyyy').format(medicine.expiryDate!)}'
                        : 'Expiry unknown',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            ExpiryPill(status: medicine.expiryStatus),
          ],
        ),
      ),
    );
  }
}
