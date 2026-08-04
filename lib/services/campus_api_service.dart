import '../locator.dart';
import 'package:dio/dio.dart';
import '../models/campus_models.dart';

class CampusApiService {
  static Future<StudentProfile> fetchStudentProfile() async {
    final response = await locator<Dio>().get('/student/profile/');

    if (response.statusCode == 200) {
      final body = response.data;
      return StudentProfile.fromJson(body['data']);
    } else {
      throw Exception('Failed to fetch student profile');
    }
  }

  static Future<List<CampusSchedule>> fetchSchedules() async {
    final response = await locator<Dio>().get('/schedules/');

    if (response.statusCode == 200) {
      final body = response.data;
      final List<dynamic> list = body['data'] ?? [];
      return list.map((json) => CampusSchedule.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch campus schedules');
    }
  }

  static Future<Map<String, dynamic>> verifyStudent(String matricule, String email, int campusId) async {
    final response = await locator<Dio>().post('/verify-student/', data: {
      'matricule': matricule,
      'email': email,
      'campus_id': campusId,
    });

    if (response.statusCode == 200) {
      final body = response.data;
      return body['data'] as Map<String, dynamic>;
    } else {
      final body = response.data;
      throw Exception(body['message'] ?? 'Failed to verify student');
    }
  }

  static Future<Map<String, dynamic>> buyPass(int passId, String paymentMethod, String phoneNumber) async {
    final response = await locator<Dio>().post('/buy-pass/', data: {
        'pass_id': passId,
        'payment_method': paymentMethod,
        'phone_number': phoneNumber,
      });

    if (response.statusCode == 200) {
      final body = response.data;
      return body['data'] as Map<String, dynamic>;
    } else {
      final body = response.data;
      throw Exception(body['message'] ?? 'Failed to purchase pass');
    }
  }

  static Future<List<DataPass>> fetchPasses() async {
    final response = await locator<Dio>().get('/passes/');

    if (response.statusCode == 200) {
      final body = response.data;
      final List<dynamic> list = body['data'] ?? [];
      return list.map((json) => DataPass.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch data passes');
    }
  }

  static Future<List<WifiZone>> fetchWifiZones() async {
    final response = await locator<Dio>().get('/zones/');

    if (response.statusCode == 200) {
      final body = response.data;
      final List<dynamic> list = body['data'] ?? [];
      return list.map((json) => WifiZone.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch wifi zones');
    }
  }

  static Future<bool> submitSupportTicket(String issueType, String description) async {
    final response = await locator<Dio>().post('/tickets/', data: {
        'issue_type': issueType,
        'description': description,
      });

    if (response.statusCode == 201) {
      return true;
    } else {
      final body = response.data;
      throw Exception(body['message'] ?? 'Failed to submit ticket');
    }
  }
}
