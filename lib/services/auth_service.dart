import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _tokenKey = 'jwt_token';
  static const String _userKey = 'current_user';

  Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (email.isNotEmpty && password.isNotEmpty) {
      final token = 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}';
      final user = UserModel(
        id: 'partner_001',
        name: 'John Partner',
        email: email,
        role: 'partner',
        phone: '+1234567890',
        isActive: true,
        createdAt: DateTime.now(),
      );

      await _saveToken(token);
      await _saveUser(user);

      return {'success': true, 'token': token, 'user': user.toJson()};
    }

    throw Exception('Invalid credentials');
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    final token = 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}';
    final user = UserModel(
      id: 'partner_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      role: 'partner',
      isActive: true,
      createdAt: DateTime.now(),
    );

    await _saveToken(token);
    await _saveUser(user);

    return {'success': true, 'token': token, 'user': user.toJson()};
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> _saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<List<UserModel>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      UserModel(
        id: 'user_001',
        name: 'Alice Johnson',
        email: 'alice@example.com',
        role: 'user',
        phone: '+1234567891',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      UserModel(
        id: 'user_002',
        name: 'Bob Smith',
        email: 'bob@example.com',
        role: 'user',
        phone: '+1234567892',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      UserModel(
        id: 'user_003',
        name: 'Carol White',
        email: 'carol@example.com',
        role: 'worker',
        phone: '+1234567893',
        isActive: false,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
  }

  Future<UserModel> createUser(Map<String, dynamic> userData) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: userData['name'],
      email: userData['email'],
      role: userData['role'] ?? 'user',
      phone: userData['phone'],
      isActive: true,
      createdAt: DateTime.now(),
    );
  }

  Future<UserModel> updateUser(String id, Map<String, dynamic> userData) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return UserModel(
      id: id,
      name: userData['name'],
      email: userData['email'],
      role: userData['role'] ?? 'user',
      phone: userData['phone'],
      isActive: userData['isActive'] ?? true,
      createdAt: DateTime.parse(userData['createdAt']),
    );
  }

  Future<void> deleteUser(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
