import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Severity levels for the interaction/duplicate-ingredient check.
/// GREEN = no issue, YELLOW = caution/interaction, RED = duplicate
/// ingredient or major warning. This mapping is decided entirely by the
/// backend's safety engine; the enum here just needs to round-trip it.
enum SafetyLevel { green, yellow, red }

SafetyLevel safetyLevelFromString(String value) {
  switch (value) {
    case 'red':
      return SafetyLevel.red;
    case 'yellow':
      return SafetyLevel.yellow;
    default:
      return SafetyLevel.green;
  }
}

extension SafetyLevelDisplay on SafetyLevel {
  Color get color {
    switch (this) {
      case SafetyLevel.green:
        return AppColors.safeGreen;
      case SafetyLevel.yellow:
        return AppColors.cautionYellow;
      case SafetyLevel.red:
        return AppColors.dangerRed;
    }
  }

  IconData get icon {
    switch (this) {
      case SafetyLevel.green:
        return Icons.check_circle;
      case SafetyLevel.yellow:
        return Icons.warning_rounded;
      case SafetyLevel.red:
        return Icons.dangerous_rounded;
    }
  }
}

/// A single flagged issue within the overall safety result, e.g.
/// "Duplicate ingredient: Paracetamol found in both Dolo 650 and Crocin 500".
class SafetyIssue {
  final SafetyLevel level;
  final String title;
  final String detail;

  const SafetyIssue({
    required this.level,
    required this.title,
    required this.detail,
  });

  factory SafetyIssue.fromJson(Map<String, dynamic> json) {
    return SafetyIssue(
      level: safetyLevelFromString(json['level'] ?? 'green'),
      title: json['title'] ?? '',
      detail: json['detail'] ?? '',
    );
  }
}

/// Mirrors the response of POST /safety/check, run against the medicines
/// the user has saved (plus, optionally, a newly-scanned one).
class SafetyResult {
  final SafetyLevel overallLevel;
  final String summary;
  final List<SafetyIssue> issues;

  const SafetyResult({
    required this.overallLevel,
    required this.summary,
    required this.issues,
  });

  factory SafetyResult.fromJson(Map<String, dynamic> json) {
    return SafetyResult(
      overallLevel: safetyLevelFromString(json['overall_level'] ?? 'green'),
      summary: json['summary'] ?? '',
      issues: (json['issues'] as List<dynamic>? ?? const [])
          .map((e) => SafetyIssue.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
