import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../../core/theme/app_theme.dart';
import '../../models/medicine_model.dart';
import '../../widgets/app_buttons.dart';
import '../../widgets/verified_badge.dart';
import '../scanner/scanner_screen.dart';
import 'medicine_info_screen.dart';

class IdentificationScreen extends StatelessWidget {
  final Medicine medicine;
  const IdentificationScreen({super.key, required this.medicine});

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return intl.DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final status = medicine.overallStatus;

    return Scaffold(
      appBar: AppBar(title: const Text('Identification Result')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: VerifiedBadge(status: status, fontSize: 16)),
                      const SizedBox(height: 20),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(medicine.brandName,
                                  style: Theme.of(context).textTheme.headlineMedium),
                              const SizedBox(height: 4),
                              Text('Generic: ${medicine.genericName}',
                                  style: Theme.of(context).textTheme.bodyLarge),
                              const Divider(height: 28),
                              _InfoRow(
                                label: 'Manufacturer',
                                value: medicine.manufacturer,
                                trailing: Icon(
                                  medicine.manufacturerVerified
                                      ? Icons.check_circle_rounded
                                      : Icons.error_outline_rounded,
                                  color: medicine.manufacturerVerified
                                      ? AppColors.safeGreen
                                      : AppColors.dangerRed,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _InfoRow(
                                label: 'Expiry Date',
                                value: _formatDate(medicine.expiryDate),
                                trailing: Icon(
                                  medicine.expiryStatus == ExpiryStatus.safe
                                      ? Icons.check_circle_rounded
                                      : Icons.error_outline_rounded,
                                  color: medicine.expiryStatus == ExpiryStatus.safe
                                      ? AppColors.safeGreen
                                      : AppColors.dangerRed,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _InfoRow(
                                label: 'Match Confidence',
                                value: '${(medicine.matchConfidence * 100).toStringAsFixed(0)}%',
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (status == VerificationStatus.unverified) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.dangerRed.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: AppColors.dangerRed),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'We could not fully verify this medicine against the registered dataset. Please purchase only from licensed pharmacies.',
                                  style: TextStyle(color: AppColors.dangerRed),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              PrimaryActionButton(
                label: 'Confirm',
                icon: Icons.arrow_forward_rounded,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => MedicineInfoScreen(medicine: medicine)),
                ),
              ),
              const SizedBox(height: 10),
              SecondaryActionButton(
                label: 'Scan Again',
                icon: Icons.refresh_rounded,
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const ScannerScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;

  const _InfoRow({required this.label, required this.value, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
