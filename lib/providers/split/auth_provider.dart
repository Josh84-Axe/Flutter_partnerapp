import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../repositories/auth_repository.dart';
import '../../services/api/token_storage.dart';
import '../../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  AuthRepository? _authRepository;
  TokenStorage? _tokenStorage;
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider({
    AuthRepository? authRepository,
    TokenStorage? tokenStorage,
  }) : _authRepository = authRepository,
       _tokenStorage = tokenStorage;

  void update({
    AuthRepository? authRepository,
    TokenStorage? tokenStorage,
  }) {
    _authRepository = authRepository;
    _tokenStorage = tokenStorage;
  }

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Placeholder for incremental migration
}
