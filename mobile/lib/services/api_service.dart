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
    final request = http.MultipartRequest('POST', _uri('/medicines/identify'))
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    final streamed = await request.send().timeout(AppConstants.apiTimeout);
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 200) return Medicine.fromJson(jsonDecode(response.body));
    throw ApiException('Failed to identify medicine (${response.statusCode})');
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
    final response = await _client.get(_uri('/users/')).timeout(AppConstants.apiTimeout);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((user) => AppUser.fromJson(user as Map<String, dynamic>)).toList();
    }
    throw ApiException('Failed to load users (${response.statusCode})');
  }

  Future<AppUser> createUser({required String name, required String email}) async {
    final response = await _client.post(
      _uri('/users/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email}),
    ).timeout(AppConstants.apiTimeout);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return AppUser.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw ApiException('Failed to create user (${response.statusCode})');
  }

  Future<AppUser?> findUserByEmail(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    final users = await getUsers();
    for (final user in users) {
      if (user.email.trim().toLowerCase() == normalizedEmail) return user;
    }
    return null;
  }

  void dispose() => _client.close();
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}
