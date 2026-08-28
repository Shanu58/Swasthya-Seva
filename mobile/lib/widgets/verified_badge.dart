import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/medicine_model.dart';

class VerifiedBadge extends StatelessWidget {
  final VerificationStatus status;
  final double fontSize;

  const VerifiedBadge({super.key, required this.status, this.fontSize = 15});

  @override
  Widget build(BuildContext context) {
    late final Color color;
    late final IconData icon;
    late final String label;

    switch (status) {
      case VerificationStatus.verified:
        color = AppColors.safeGreen;
        icon = Icons.verified_rounded;
        label = 'VERIFIED';
        break;
      case VerificationStatus.expired:
        color = AppColors.dangerRed;
        icon = Icons.event_busy_rounded;
        label = 'EXPIRED';
        break;
      case VerificationStatus.unverified:
        color = AppColors.unverifiedGrey;
        icon = Icons.help_rounded;
        label = 'UNVERIFIED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color, width: 1.4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: fontSize + 3),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small pill for the separate expiry status where it needs to be shown
/// independent of overall verification (e.g. list rows in My Medicines).
class ExpiryPill extends StatelessWidget {
  final ExpiryStatus status;
  const ExpiryPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isExpired = status == ExpiryStatus.expired;
    final color = isExpired ? AppColors.dangerRed : AppColors.safeGreen;
    final label = isExpired ? 'Expired' : 'Safe';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}
