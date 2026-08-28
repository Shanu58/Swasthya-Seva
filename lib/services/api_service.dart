import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../models/medicine_model.dart';
import '../models/medicine_detail_model.dart';
import '../models/my_medicine_model.dart';
import '../models/safety_result_model.dart';
import 'mock_data_service.dart';

/// Single entry point the UI layer uses to talk to "the backend".
///
/// Every public method here matches an endpoint in the API contract.
/// When [AppConstants.useMockData] is true it delegates to
/// [MockDataService] so the app is fully demoable before the FastAPI
/// backend is reachable; when false, it makes real HTTP calls. Screens
/// never need to know which mode is active.
class ApiService {
  final MockDataService _mock = MockDataService();
  final http.Client _client = http.Client();

  Uri _uri(String path) => Uri.parse('${AppConstants.apiBaseUrl}$path');

  /// POST /medicines/identify (multipart image upload)
  /// -> runs OCR + RapidFuzz matching + verification + expiry check on
  ///    the backend, returns the Medicine identification contract.
  Future<Medicine> identifyMedicine(File imageFile) async {
    if (AppConstants.useMockData) return _mock.mockIdentify();

    final request = http.MultipartRequest('POST', _uri('/medicines/identify'))
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    final streamed = await request.send().timeout(AppConstants.apiTimeout);
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      return Medicine.fromJson(jsonDecode(response.body));
    }
    throw ApiException('Failed to identify medicine (${response.statusCode})');
  }

  /// GET /medicines/{id}
  Future<MedicineDetail> getMedicineDetail(String medicineId) async {
    if (AppConstants.useMockData) return _mock.mockDetail(medicineId);

    final response =
        await _client.get(_uri('/medicines/$medicineId')).timeout(AppConstants.apiTimeout);

    if (response.statusCode == 200) {
      return MedicineDetail.fromJson(jsonDecode(response.body));
    }
    throw ApiException('Failed to load medicine details (${response.statusCode})');
  }

  /// GET /users/me/medicines (or guest-session equivalent)
  Future<List<MyMedicine>> getMyMedicines() async {
    if (AppConstants.useMockData) return _mock.mockMyMedicines();

    final response =
        await _client.get(_uri('/users/me/medicines')).timeout(AppConstants.apiTimeout);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => MyMedicine.fromJson(e)).toList();
    }
    throw ApiException('Failed to load saved medicines (${response.statusCode})');
  }

  /// POST /users/me/medicines
  Future<void> addToMyMedicines(Medicine medicine) async {
    if (AppConstants.useMockData) return _mock.mockAddMedicine(medicine);

    final response = await _client
        .post(
          _uri('/users/me/medicines'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'medicine_id': medicine.medicineId}),
        )
        .timeout(AppConstants.apiTimeout);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ApiException('Failed to save medicine (${response.statusCode})');
    }
  }

  /// POST /safety/check
  /// Runs duplicate-ingredient / interaction checks against the user's
  /// saved medicines on the backend. Flutter only ever displays the
  /// result - it never computes interactions itself.
  Future<SafetyResult> checkInteractions() async {
    if (AppConstants.useMockData) return _mock.mockSafetyCheck();

    final response =
        await _client.post(_uri('/safety/check')).timeout(AppConstants.apiTimeout);

    if (response.statusCode == 200) {
      return SafetyResult.fromJson(jsonDecode(response.body));
    }
    throw ApiException('Failed to run safety check (${response.statusCode})');
  }

  void dispose() => _client.close();
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}
