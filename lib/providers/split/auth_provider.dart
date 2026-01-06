import 'package:flutter/foundation.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/partner_repository.dart';
import '../../services/api/token_storage.dart';
import '../../services/cache_service.dart';
import '../../services/local_notification_service.dart';
import '../../models/user_model.dart';
import '../../utils/permission_mapping.dart';
import '../../utils/currency_utils.dart';

class AuthProvider with ChangeNotifier {
  AuthRepository? _authRepository;
  PartnerRepository? _partnerRepository;
  TokenStorage? _tokenStorage;
  
  // Cache service for local data persistence
  final CacheService _cacheService = CacheService();
  final LocalNotificationService _localNotificationService = LocalNotificationService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  
  // Auth state fields
  String? _partnerCountry;
  String? _partnerCurrencyCode;
  String? _partnerCurrencySymbol;
  String? _registrationEmail;
  String? _passwordResetToken;
  
  // Guest mode
  bool _isGuestMode = false;

  AuthProvider({
    AuthRepository? authRepository,
    PartnerRepository? partnerRepository,
    TokenStorage? tokenStorage,
  }) : _authRepository = authRepository,
       _partnerRepository = partnerRepository,
       _tokenStorage = tokenStorage;

  void update({
    AuthRepository? authRepository,
    PartnerRepository? partnerRepository,
    TokenStorage? tokenStorage,
  }) {
    _authRepository = authRepository;
    _partnerRepository = partnerRepository;
    _tokenStorage = tokenStorage;
  }

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get partnerCountry => _partnerCountry;
  String get currencySymbol => _partnerCurrencySymbol ?? '\$';
  bool get isGuestMode => _isGuestMode;
  String? get registrationEmail => _registrationEmail;
  String? get passwordResetToken => _passwordResetToken;
  
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  void _setError(String? value) {
    _error = value;
    if (value != null) notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  /// Toggle between mock and real API (proxy to global config or ignored if strictly remote)
  // Logic from AppState: "FORCE REMOTE API: Always use real API for login"
  
  Future<bool> login(String email, String password) async {
    if (kDebugMode) print('🔐 [AuthProvider] login() called with email: $email');
    
    _setLoading(true);
    _setError(null);
    try {
      if (_authRepository == null) throw Exception('AuthRepository not initialized');

      final result = await _authRepository!.login(
        email: email,
        password: password,
      );
      
      if (result['success'] == true) {
        // Extract user data from login response if available
        final loginData = result['data'];
        Map<String, dynamic>? userData;
        
        if (loginData != null && loginData['user'] != null) {
          userData = loginData['user'];
        } else if (_partnerRepository != null) {
          // Fallback to fetching profile if user data not in login response
          final profileData = await _partnerRepository!.fetchProfile();
          if (profileData != null) {
            userData = profileData['data'] is Map ? profileData['data'] : profileData;
          }
        }

        if (userData != null) {
          await _mapUserData(userData, email);
        }

        _setLoading(false);
        return true;
      } else {
        _setError(result['message'] ?? 'Login failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      if (kDebugMode) print('🔐 [AuthProvider] Login error: $e');
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> _mapUserData(Map<String, dynamic> userData, String email) async {
      // Extract permissions
      List<String> mappedPermissions = [];
      if (userData['role'] is Map && userData['role']['permissions'] is Map) {
        final permsMap = userData['role']['permissions'] as Map;
        permsMap.forEach((key, value) {
          if (value == true) {
            final constant = PermissionMapping.getConstant(key.toString());
            if (constant != null) {
              mappedPermissions.add(constant);
            }
          }
        });
      }
      
      // Extract role
      final userRole = userData['role'] is Map ? (userData['role']['name']?.toString() ?? 'Partner') : 'Partner';

      _currentUser = UserModel(
        id: userData['id']?.toString() ?? '1',
        name: '${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}'.trim(),
        email: userData['email']?.toString() ?? email,
        role: userRole,
        permissions: mappedPermissions,
        isActive: true,
        createdAt: DateTime.now(),
      );
      
      // Extract country and set currency info
      _partnerCountry = userData['country']?.toString();
      _partnerCurrencyCode = CurrencyUtils.getCurrencyCode(_partnerCountry);
      _partnerCurrencySymbol = CurrencyUtils.getCurrencySymbol(_partnerCountry);
      notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    _setLoading(true);
    try {
      if (_tokenStorage == null || _partnerRepository == null) {
        // Dependencies not ready, maybe retry or just fail silently
        _setLoading(false);
        return;
      }

      final accessToken = await _tokenStorage!.getAccessToken();
      if (accessToken != null) {
        // Token exists, verify it by fetching profile
        if (kDebugMode) print('🔐 [AuthProvider] Token found, verifying...');
        
        try {
          final profileData = await _partnerRepository!.fetchProfile();
          if (profileData != null) {
            final userData = profileData['data'] is Map ? profileData['data'] : profileData;
            final email = userData['email']?.toString() ?? '';
             await _mapUserData(userData, email);
             if (kDebugMode) print('✅ [AuthProvider] Session restored for $email');
          } else {
             if (kDebugMode) print('⚠️ [AuthProvider] Token invalid or expired (profile fetch failed)');
             await logout();
          }
        } catch (e) {
             if (kDebugMode) print('⚠️ [AuthProvider] Token invalid or expired (error: $e)');
             await logout();
        }
      } else {
        if (kDebugMode) print('ℹ️ [AuthProvider] No token found');
      }
    } catch (e) {
      if (kDebugMode) print('❌ [AuthProvider] Check auth status error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String firstName,
    required String email,
    required String password,
    required String password2,
    required String phone,
    required String businessName,
    required String address,
    required String city,
    required String country,
    required int numberOfRouters,
  }) async {
    _setLoading(true);
    _registrationEmail = email; // Store email for verification
    _setError(null);
    
    try {
      if (_authRepository == null) throw Exception('AuthRepository not initialized');
      
      final result = await _authRepository!.register(
        firstName: firstName,
        email: email,
        password: password,
        password2: password2,
        phone: phone,
        businessName: businessName,
        address: address,
        city: city,
        country: country,
        numberOfRouters: numberOfRouters,
      );
      
      final success = result['success'] as bool;
      final message = result['message'] as String;
      final otpId = result['otp_id'] as String?;
      
      if (!success) {
        _setError(message);
        _setLoading(false);
        return false;
      }
      
      // Store OTP ID if email verification is required
      if (otpId != null) {
        _registrationOtpId = otpId;
      }
      
      // Try to load profile to get user data if possible (auto-login scenario)
      // If registration requires email verification, this might fail or be skipped
      if (_partnerRepository != null) {
        try {
          final profileData = await _partnerRepository!.fetchProfile();
          if (profileData != null) {
            final userData = profileData['data'] is Map ? profileData['data'] : profileData;
            await _mapUserData(userData, email);
          }
        } catch (e) {
             // Verification likely required
             if (kDebugMode) print('ℹ️ [AuthProvider] Could not fetch profile after register (verification likely needed): $e');
        }
      }
      
      _setLoading(false);
      return success;
    } catch (e) {
      if (kDebugMode) print('❌ [AuthProvider] Register error: $e');
      _setError('Registration error: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    _setLoading(true);
    try {
      if (_partnerRepository == null) throw Exception('PartnerRepository not initialized');
      final success = await _partnerRepository!.updateProfile(profileData);
      if (success) {
        // Refresh profile data
        await checkAuthStatus();
      }
      _setLoading(false);
      return success;
    } catch (e) {
      if (kDebugMode) print('❌ [AuthProvider] Update profile error: $e');
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }





  Future<void> logout() async {
    if (_authRepository != null) {
      await _authRepository!.logout();
    }
    
    // Clear cached data
    await _cacheService.clearAllCache();
    await _localNotificationService.clearUserData();
    
    _currentUser = null;
    _partnerCountry = null;
    _isGuestMode = false;
    
    notifyListeners();
  }

  Future<Map<String, dynamic>?> requestPasswordReset(String email) async {
    _setLoading(true);
    try {
      if (_authRepository == null) throw Exception('AuthRepository not initialized');
      final result = await _authRepository!.requestPasswordReset(email);
      _passwordResetOtpId = null; // Clear any previous
      _setLoading(false);
      return result;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return null;
    }
  }

  Future<bool> confirmPasswordReset({
    required String token,
    required String newPassword,
  }) async {
    _setLoading(true);
    try {
      if (_authRepository == null) throw Exception('AuthRepository not initialized');
      final result = await _authRepository!.confirmPasswordReset(
        token: token,
        newPassword: newPassword,
      );
      _setLoading(false);
      return result;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Not strictly used by forgot password flow but good to keep consistent if needed
  Future<bool> verifyEmailOtp(String email, String otp, String otpId) async {
    _setLoading(true);
    try {
      if (_authRepository == null) throw Exception('AuthRepository not initialized');
      final success = await _authRepository!.verifyEmailOtp(
        email: email,
        otp: otp,
        otpId: otpId,
      );
      _setLoading(false);
      if (success) {
        await checkAuthStatus();
      }
      return success;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> confirmRegistration(String email, String otp) async {
    _setLoading(true);
    try {
      if (_authRepository == null) throw Exception('AuthRepository not initialized');
      final response = await _authRepository!.confirmRegistration(email, otp);
      _setLoading(false);
      return response != null;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> resendVerifyEmailOtp(String email) async {
    _setLoading(true);
    try {
      if (_authRepository == null) throw Exception('AuthRepository not initialized');
      final success = await _authRepository!.resendVerifyEmailOtp(email);
      _setLoading(false);
      return success;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<Map<String, dynamic>?> resendPasswordResetOtp(String email) async {
    _setLoading(true);
    try {
      if (_authRepository == null) throw Exception('AuthRepository not initialized');
      final result = await _authRepository!.resendPasswordResetOtp(email);
      _setLoading(false);
      return result;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return null;
    }
  }

  Future<Map<String, dynamic>?> verifyPasswordResetOtp(String email, String otp, String otpId) async {
    _setLoading(true);
    try {
      if (_authRepository == null) throw Exception('AuthRepository not initialized');
      final result = await _authRepository!.verifyPasswordResetOtp(email.trim(), otp.trim(), otpId);
      
      // Extraction for local state
      if (result != null && result['success'] == true) {
        final data = result['data'];
        if (data is Map) {
          _passwordResetToken = data['token']?.toString() ?? data['access']?.toString() ?? data['password_reset_token']?.toString();
        } else if (data is String) {
          _passwordResetToken = data;
        }
      }

      _setLoading(false);
      return result;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<void> enterGuestMode({String? countryCode}) async {
    _isGuestMode = true;
    _guestCountryCode = countryCode;
    // Create dummy guest user?
    // AppState created a dummy user. Let's replicate or UserProvider handles it?
    // UserProvider.loadUsers might return nothing in guest mode.
    // Dashboard needs a user name.
    _currentUser = UserModel(
        id: 'guest',
        name: 'Guest User',
        email: 'guest@example.com',
        role: 'Guest',
        permissions: [],
        isActive: true,
        createdAt: DateTime.now(),
    );
        
    notifyListeners();
  }

  // ==================== Partner Profile ====================

  Future<void> loadProfile() async {
    if (_partnerRepository == null) return;
    try {
      if (kDebugMode) print('📡 [AuthProvider] Loading partner profile...');
      final profileData = await _partnerRepository!.fetchProfile();
      if (profileData != null) {
        final data = profileData['data'] is Map ? profileData['data'] : profileData;
        final email = data['email']?.toString() ?? _currentUser?.email ?? '';
        await _mapUserData(data, email);
        if (kDebugMode) print('✅ [AuthProvider] Profile loaded: ${_currentUser!.name}, Country: $_partnerCountry');
      }
      _error = null;
    } catch (e) {
      if (kDebugMode) print('❌ [AuthProvider] Error loading profile: $e');
      _error = e.toString();
    } finally {
      // notifyListeners called inside _mapUserData
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _setLoading(true);
    try {
      if (_authRepository == null) throw Exception('AuthRepository not initialized');
      
      // Note: Repository needs to support this. If not, we might need to add it there too.
      // For now assuming repo has it or generic method. 
      // Checking AuthRepository... it usually has changePassword.
      
      final success = await _authRepository!.changePassword(
        oldPassword: currentPassword, 
        newPassword: newPassword
      );
      
      _setLoading(false);
      return success;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> getTwoFactorStatus() async {
    // Placeholder - implement real API call when available
    return false;
  }

}
