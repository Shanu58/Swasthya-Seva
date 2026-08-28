/// Overall verification status derived from the backend's verification
/// logic (name match + manufacturer match + expiry check). The Flutter
/// app never computes this itself - it only renders whatever the backend
/// (or, for the demo, [MockDataService]) returns.
enum VerificationStatus { verified, unverified, expired }

enum ExpiryStatus { safe, expired, unknown }

ExpiryStatus expiryStatusFromString(String? value) {
  switch (value) {
    case 'safe':
      return ExpiryStatus.safe;
    case 'expired':
      return ExpiryStatus.expired;
    default:
      return ExpiryStatus.unknown;
  }
}

/// Mirrors the JSON returned by the medicine identification endpoint:
/// {
///   "medicine_id": "123",
///   "brand_name": "Dolo 650",
///   "generic_name": "Paracetamol",
///   "manufacturer": "Micro Labs Ltd",
///   "manufacturer_verified": true,
///   "expiry_date": "2027-08-01",
///   "expiry_status": "safe",
///   "match_confidence": 0.95
/// }
class Medicine {
  final String medicineId;
  final String brandName;
  final String genericName;
  final String manufacturer;
  final bool manufacturerVerified;
  final DateTime? expiryDate;
  final ExpiryStatus expiryStatus;
  final double matchConfidence;

  const Medicine({
    required this.medicineId,
    required this.brandName,
    required this.genericName,
    required this.manufacturer,
    required this.manufacturerVerified,
    required this.expiryDate,
    required this.expiryStatus,
    required this.matchConfidence,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      medicineId: json['medicine_id']?.toString() ?? '',
      brandName: json['brand_name'] ?? 'Unknown',
      genericName: json['generic_name'] ?? '-',
      manufacturer: json['manufacturer'] ?? 'Unknown',
      manufacturerVerified: json['manufacturer_verified'] ?? false,
      expiryDate: DateTime.tryParse(json['expiry_date'] ?? ''),
      expiryStatus: expiryStatusFromString(json['expiry_status']),
      matchConfidence: (json['match_confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'medicine_id': medicineId,
        'brand_name': brandName,
        'generic_name': genericName,
        'manufacturer': manufacturer,
        'manufacturer_verified': manufacturerVerified,
        'expiry_date': expiryDate?.toIso8601String().split('T').first,
        'expiry_status': expiryStatus.name,
        'match_confidence': matchConfidence,
      };

  /// Whether the medicine name itself was found in the dataset at all.
  /// Per the verification logic, low/zero confidence effectively means
  /// "not found" -> Unverified / Possible Counterfeit.
  bool get nameMatched => matchConfidence > 0;

  /// The single badge shown on the Identification + Info screens,
  /// derived purely from fields the backend already computed.
  VerificationStatus get overallStatus {
    if (expiryStatus == ExpiryStatus.expired) return VerificationStatus.expired;
    if (nameMatched && manufacturerVerified) return VerificationStatus.verified;
    return VerificationStatus.unverified;
  }
}
