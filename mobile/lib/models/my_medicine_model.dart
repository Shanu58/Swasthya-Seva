import 'medicine_model.dart';

/// A row in the user's "My Medicines" list, as returned by
/// GET /users/{id}/medicines (or the guest-session equivalent).
class MyMedicine {
  final String id;
  final String medicineId;
  final String brandName;
  final String genericName;
  final DateTime? expiryDate;
  final ExpiryStatus expiryStatus;
  final DateTime addedOn;

  const MyMedicine({
    required this.id,
    required this.medicineId,
    required this.brandName,
    required this.genericName,
    required this.expiryDate,
    required this.expiryStatus,
    required this.addedOn,
  });

  factory MyMedicine.fromJson(Map<String, dynamic> json) {
    return MyMedicine(
      id: json['id']?.toString() ?? '',
      medicineId: json['medicine_id']?.toString() ?? '',
      brandName: json['brand_name'] ?? 'Unknown',
      genericName: json['generic_name'] ?? '-',
      expiryDate: DateTime.tryParse(json['expiry_date'] ?? ''),
      expiryStatus: expiryStatusFromString(json['expiry_status']),
      addedOn: DateTime.tryParse(json['added_on'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'medicine_id': medicineId,
        'brand_name': brandName,
        'generic_name': genericName,
        'expiry_date': expiryDate?.toIso8601String().split('T').first,
        'expiry_status': expiryStatus.name,
        'added_on': addedOn.toIso8601String(),
      };
}
