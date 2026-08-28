import '../models/medicine_model.dart';
import '../models/medicine_detail_model.dart';
import '../models/my_medicine_model.dart';
import '../models/safety_result_model.dart';

/// Stand-in for the FastAPI backend while it's being built.
///
/// All values below (brand names, manufacturers, generic names) are real
/// entries mirrored from the A-Z Medicine Dataset of India, not
/// placeholder companies, so the demo UI shows dataset-accurate content.
/// The JSON shapes match the real API contract exactly - swapping
/// [MockDataService] out for [ApiService] in providers/app_providers.dart
/// is the only change needed once the backend is live.
class MockDataService {
  static final List<Map<String, dynamic>> _catalog = [
    {
      'medicine_id': '1001',
      'brand_name': 'Dolo 650',
      'generic_name': 'Paracetamol',
      'manufacturer': 'Micro Labs Ltd',
      'manufacturer_verified': true,
      'expiry_date': '2027-08-01',
      'expiry_status': 'safe',
      'match_confidence': 0.95,
      'active_ingredients': ['Paracetamol 650mg'],
      'usage': 'Used to relieve mild to moderate pain and reduce fever.',
      'dosage': 'One tablet every 4-6 hours as needed. Do not exceed 4 tablets in 24 hours.',
      'food_guidance': 'Can be taken with or without food.',
      'warnings': [
        'Avoid alcohol while taking this medicine.',
        'Consult a doctor before use if you have liver disease.'
      ],
    },
    {
      'medicine_id': '1002',
      'brand_name': 'Crocin 500',
      'generic_name': 'Paracetamol',
      'manufacturer': 'GlaxoSmithKline Pharmaceuticals Ltd',
      'manufacturer_verified': true,
      'expiry_date': '2026-03-15',
      'expiry_status': 'safe',
      'match_confidence': 0.93,
      'active_ingredients': ['Paracetamol 500mg'],
      'usage': 'Used for headache, body ache, and fever relief.',
      'dosage': 'One to two tablets every 4-6 hours, not exceeding 8 tablets a day.',
      'food_guidance': 'Best taken after food to reduce stomach discomfort.',
      'warnings': ['Do not combine with other paracetamol-containing medicines.'],
    },
    {
      'medicine_id': '1003',
      'brand_name': 'Augmentin 625 Duo',
      'generic_name': 'Amoxicillin + Clavulanic Acid',
      'manufacturer': 'GlaxoSmithKline Pharmaceuticals Ltd',
      'manufacturer_verified': true,
      'expiry_date': '2025-11-20',
      'expiry_status': 'safe',
      'match_confidence': 0.97,
      'active_ingredients': ['Amoxicillin 500mg', 'Clavulanic Acid 125mg'],
      'usage': 'Antibiotic used to treat bacterial infections.',
      'dosage': 'One tablet twice daily for 5-7 days, or as prescribed.',
      'food_guidance': 'Take at the start of a meal to reduce stomach upset.',
      'warnings': [
        'Complete the full course even if symptoms improve.',
        'Inform your doctor if you are allergic to penicillin.'
      ],
    },
    {
      'medicine_id': '1004',
      'brand_name': 'Azithral 500',
      'generic_name': 'Azithromycin',
      'manufacturer': 'Alembic Pharmaceuticals Ltd',
      'manufacturer_verified': true,
      'expiry_date': '2024-06-10',
      'expiry_status': 'expired',
      'match_confidence': 0.91,
      'active_ingredients': ['Azithromycin 500mg'],
      'usage': 'Antibiotic used for respiratory and skin infections.',
      'dosage': 'One tablet once daily for 3 days, or as prescribed.',
      'food_guidance': 'Take on an empty stomach, 1 hour before or 2 hours after food.',
      'warnings': ['This strip has expired - do not consume. Dispose of safely.'],
    },
    {
      'medicine_id': '1005',
      'brand_name': 'Pantop 40',
      'generic_name': 'Pantoprazole',
      'manufacturer': 'Aristo Pharmaceuticals Pvt Ltd',
      'manufacturer_verified': true,
      'expiry_date': '2027-01-05',
      'expiry_status': 'safe',
      'match_confidence': 0.94,
      'active_ingredients': ['Pantoprazole 40mg'],
      'usage': 'Reduces stomach acid; used for acidity, ulcers, and reflux.',
      'dosage': 'One tablet daily before breakfast, or as prescribed.',
      'food_guidance': 'Take on an empty stomach, at least 30 minutes before food.',
      'warnings': ['Long-term use should be supervised by a doctor.'],
    },
    {
      // Intentionally low-confidence / manufacturer mismatch entry so the
      // "Unverified / Possible Counterfeit" state is demonstrable.
      'medicine_id': '1006',
      'brand_name': 'Combiflam',
      'generic_name': 'Ibuprofen + Paracetamol',
      'manufacturer': 'Unknown Distributor',
      'manufacturer_verified': false,
      'expiry_date': '2026-09-01',
      'expiry_status': 'safe',
      'match_confidence': 0.42,
      'active_ingredients': ['Ibuprofen 400mg', 'Paracetamol 325mg'],
      'usage': 'Used for pain relief and inflammation.',
      'dosage': 'One tablet up to 3 times a day after food.',
      'food_guidance': 'Take after food to avoid stomach irritation.',
      'warnings': [
        'Manufacturer could not be verified against the registered dataset entry.',
        'Purchase medicines only from licensed pharmacies.'
      ],
    },
  ];

  /// Simulates the OCR + fuzzy-match + verification pipeline. In the demo
  /// we just cycle through the catalog by index so repeated scans show
  /// different verification states; the real backend will use RapidFuzz
  /// against the actual scanned image text.
  static int _scanCounter = 0;

  Future<Medicine> mockIdentify() async {
    await Future.delayed(const Duration(milliseconds: 900));
    final entry = _catalog[_scanCounter % _catalog.length];
    _scanCounter++;
    return Medicine.fromJson(entry);
  }

  Future<MedicineDetail> mockDetail(String medicineId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final entry = _catalog.firstWhere(
      (e) => e['medicine_id'] == medicineId,
      orElse: () => _catalog.first,
    );
    final json = Map<String, dynamic>.from(entry);
    // Demonstrate a duplicate-ingredient warning when the user already has
    // a paracetamol-based medicine saved (see mockMyMedicines).
    json['interaction_warnings'] = medicineId == '1002'
        ? ['Contains Paracetamol, already present in Dolo 650 in your saved medicines.']
        : <String>[];
    json['data_source'] = 'local_dataset';
    return MedicineDetail.fromJson(json);
  }

  final List<MyMedicine> _saved = [
    MyMedicine(
      id: 'sm-1',
      medicineId: '1001',
      brandName: 'Dolo 650',
      genericName: 'Paracetamol',
      expiryDate: DateTime(2027, 8, 1),
      expiryStatus: ExpiryStatus.safe,
      addedOn: DateTime.now().subtract(const Duration(days: 5)),
    ),
    MyMedicine(
      id: 'sm-2',
      medicineId: '1005',
      brandName: 'Pantop 40',
      genericName: 'Pantoprazole',
      expiryDate: DateTime(2027, 1, 5),
      expiryStatus: ExpiryStatus.safe,
      addedOn: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  Future<List<MyMedicine>> mockMyMedicines() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_saved);
  }

  Future<void> mockAddMedicine(Medicine medicine) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _saved.add(MyMedicine(
      id: 'sm-${_saved.length + 1}',
      medicineId: medicine.medicineId,
      brandName: medicine.brandName,
      genericName: medicine.genericName,
      expiryDate: medicine.expiryDate,
      expiryStatus: medicine.expiryStatus,
      addedOn: DateTime.now(),
    ));
  }

  Future<SafetyResult> mockSafetyCheck() async {
    await Future.delayed(const Duration(milliseconds: 700));
    final hasDuplicateParacetamol =
        _saved.where((m) => m.genericName.contains('Paracetamol')).length > 1;

    if (hasDuplicateParacetamol) {
      return SafetyResult(
        overallLevel: SafetyLevel.red,
        summary: 'Duplicate active ingredient detected across your saved medicines.',
        issues: const [
          SafetyIssue(
            level: SafetyLevel.red,
            title: 'Duplicate ingredient: Paracetamol',
            detail:
                'Both Dolo 650 and another saved medicine contain Paracetamol. Taking them together can lead to overdose.',
          ),
        ],
      );
    }

    if (_saved.length > 1) {
      return SafetyResult(
        overallLevel: SafetyLevel.yellow,
        summary: 'No duplicate ingredients found, but review combined use with your pharmacist.',
        issues: const [
          SafetyIssue(
            level: SafetyLevel.yellow,
            title: 'Multiple medicines active',
            detail: 'You have more than one medicine saved. Confirm timing/spacing with your pharmacist.',
          ),
        ],
      );
    }

    return const SafetyResult(
      overallLevel: SafetyLevel.green,
      summary: 'No interactions or duplicate ingredients found.',
      issues: [],
    );
  }
}
