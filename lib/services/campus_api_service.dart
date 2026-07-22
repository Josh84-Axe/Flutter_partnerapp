import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api/api_config.dart';
import '../locator.dart';
import 'api/token_storage.dart';
import '../models/campus_models.dart';

class CampusApiService {
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<Map<String, String>> _getHeaders() async {
    final tokenStorage = locator<TokenStorage>();
    final token = await tokenStorage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<StudentProfile> fetchStudentProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/campus/student/profile/'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return StudentProfile.fromJson(body['data']);
    } else {
      throw Exception('Failed to fetch student profile');
    }
  }

  static Future<List<CampusSchedule>> fetchSchedules() async {
    final response = await http.get(
      Uri.parse('$baseUrl/campus/schedules/'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final List<dynamic> list = body['data'] ?? [];
      return list.map((json) => CampusSchedule.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch campus schedules');
    }
  }

  static Future<Map<String, dynamic>> verifyStudent(String matricule, String email, int campusId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/campus/verify-student/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'matricule': matricule,
        'email': email,
        'campus_id': campusId,
      }),
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return body['data'] as Map<String, dynamic>;
    } else {
      final body = json.decode(response.body);
      throw Exception(body['message'] ?? 'Failed to verify student');
    }
  }

  static Future<Map<String, dynamic>> buyPass(int passId, String paymentMethod, String phoneNumber) async {
    final response = await http.post(
      Uri.parse('$baseUrl/campus/buy-pass/'),
      headers: await _getHeaders(),
      body: json.encode({
        'pass_id': passId,
        'payment_method': paymentMethod,
        'phone_number': phoneNumber,
      }),
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return body['data'] as Map<String, dynamic>;
    } else {
      final body = json.decode(response.body);
      throw Exception(body['message'] ?? 'Failed to purchase pass');
    }
  }
}
