import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../models/medicine_model.dart';
import '../models/medicine_detail_model.dart';
import '../models/my_medicine_model.dart';
import '../models/user_model.dart';
import '../models/safety_result_model.dart';
import 'mock_data_service.dart';

class ApiService {
  final MockDataService _mock = MockDataService();
  final http.Client _client = http.Client();

  Uri _uri(String path) => Uri.parse('${AppConstants.apiBaseUrl}$path');

  Future<Medicine> identifyMedicine(File imageFile) async {
    if (AppConstants.useMockData) return _mock.mockIdentify();

    final request = http.MultipartRequest(
      'POST',
      _uri('/medicine-image-search/'),
    )..files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

    final streamed = await request.send().timeout(AppConstants.apiTimeout);
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      String detail = response.body;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['detail'] != null) {
          detail = decoded['detail'].toString();
        }
      } catch (_) {}

      throw ApiException(
        'Medicine identification failed (${response.statusCode}): $detail',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final matches = (data['matches'] as List<dynamic>? ?? const []);

    if (matches.isEmpty) {
      throw ApiException('No medicine match was found. Please try a clearer image.');
    }

    final top = matches.first as Map<String, dynamic>;
    final score = (top['score'] as num?)?.toDouble() ?? 0.0;

    return Medicine(
      medicineId: top['id']?.toString() ?? '',
      brandName: top['name']?.toString() ?? 'Unknown',
      genericName: top['matched_text']?.toString() ?? '-',
      manufacturer: 'Verified against medicine database',
      manufacturerVerified: true,
      expiryDate: null,
      expiryStatus: ExpiryStatus.unknown,
      matchConfidence: (score / 100).clamp(0.0, 1.0).toDouble(),
    );
  }

  Future<MedicineDetail> getMedicineDetail(String medicineId) async {
    if (AppConstants.useMockData) return _mock.mockDetail(medicineId);
    final response = await _client.get(_uri('/medicines/$medicineId')).timeout(AppConstants.apiTimeout);
    if (response.statusCode == 200) return MedicineDetail.fromJson(jsonDecode(response.body));
    throw ApiException('Failed to load medicine details (${response.statusCode})');
  }

  Future<List<MyMedicine>> getMyMedicines() async {
    if (AppConstants.useMockData) return _mock.mockMyMedicines();
    final response = await _client.get(_uri('/users/me/medicines')).timeout(AppConstants.apiTimeout);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => MyMedicine.fromJson(e)).toList();
    }
    throw ApiException('Failed to load saved medicines (${response.statusCode})');
  }

  Future<void> addToMyMedicines(Medicine medicine) async {
    if (AppConstants.useMockData) return _mock.mockAddMedicine(medicine);
    final response = await _client.post(
      _uri('/users/me/medicines'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'medicine_id': medicine.medicineId}),
    ).timeout(AppConstants.apiTimeout);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ApiException('Failed to save medicine (${response.statusCode})');
    }
  }

  Future<SafetyResult> checkInteractions() async {
    if (AppConstants.useMockData) return _mock.mockSafetyCheck();
    final response = await _client.post(_uri('/safety/check')).timeout(AppConstants.apiTimeout);
    if (response.statusCode == 200) return SafetyResult.fromJson(jsonDecode(response.body));
    throw ApiException('Failed to run safety check (${response.statusCode})');
  }

  Future<List<AppUser>> getUsers() async {
    if (AppConstants.useMockData) return [];
    final response = await _client.get(_uri('/users/')).timeout(AppConstants.apiTimeout);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((user) => AppUser.fromJson(user as Map<String, dynamic>)).toList();
    }
    throw ApiException('Failed to load users (${response.statusCode})');
  }

  Future<AppUser> createUser({required String name, required String email, int? age, double? heightCm, double? weightKg}) async {
    final response = await _client.post(
      _uri('/users/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'age': age, 'height_cm': heightCm, 'weight_kg': weightKg}),
    ).timeout(AppConstants.apiTimeout);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return AppUser.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw ApiException('Failed to create user (${response.statusCode})');
  }

  Future<AppUser?> findUserByEmail(String email) async {
    final users = await getUsers();
    final normalizedEmail = email.trim().toLowerCase();
    for (final user in users) {
      if (user.email.trim().toLowerCase() == normalizedEmail) return user;
    }
    return null;
  }

  Future<AppUser> getUser(int userId) async {
    final response = await _client.get(_uri('/users/$userId')).timeout(AppConstants.apiTimeout);
    if (response.statusCode == 200) return AppUser.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    throw ApiException('Failed to load user (${response.statusCode})');
  }

  void dispose() => _client.close();
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}
