import 'medicine_model.dart';

/// Extended detail returned by GET /medicines/{id}, layered on top of the
/// identification result. Usage/dosage/side-effect fields come from the
/// companion usage CSV joined on medicine name, or from the OpenFDA
/// fallback when a local row is missing (see project brief) - the source
/// is a backend concern, the Flutter layer just displays whatever comes
/// back in this shape.
class MedicineDetail {
  final Medicine medicine;
  final List<String> activeIngredients;
  final String usage;
  final String dosage;
  final String foodGuidance;
  final List<String> warnings;

  /// Duplicate-ingredient / interaction warnings against the user's saved
  /// medicines. This is ONLY ever populated by the backend's safety
  /// engine - Flutter never computes interactions itself.
  final List<String> interactionWarnings;

  final String dataSource; // e.g. "local_dataset" or "openfda_fallback"

  const MedicineDetail({
    required this.medicine,
    required this.activeIngredients,
    required this.usage,
    required this.dosage,
    required this.foodGuidance,
    required this.warnings,
    required this.interactionWarnings,
    required this.dataSource,
  });

  factory MedicineDetail.fromJson(Map<String, dynamic> json) {
    return MedicineDetail(
      medicine: Medicine.fromJson(json),
      activeIngredients: List<String>.from(json['active_ingredients'] ?? const []),
      usage: json['usage'] ?? 'Not available',
      dosage: json['dosage'] ?? 'Consult your doctor or pharmacist',
      foodGuidance: json['food_guidance'] ?? 'No specific guidance provided',
      warnings: List<String>.from(json['warnings'] ?? const []),
      interactionWarnings: List<String>.from(json['interaction_warnings'] ?? const []),
      dataSource: json['data_source'] ?? 'local_dataset',
    );
  }

  /// A plain-text summary suitable for handing to [VoiceService.speak].
  /// Kept here (not in the widget) so the "what gets read aloud" logic is
  /// testable and reusable outside the widget tree.
  String get spokenSummary {
    final b = StringBuffer();
    b.writeln('${medicine.brandName}, generic name ${medicine.genericName}.');
    b.writeln('Manufactured by ${medicine.manufacturer}.');
    b.writeln('Usage: $usage.');
    b.writeln('Dosage: $dosage.');
    if (foodGuidance.isNotEmpty) b.writeln('Food guidance: $foodGuidance.');
    if (warnings.isNotEmpty) b.writeln('Warnings: ${warnings.join(". ")}.');
    return b.toString();
  }
}
