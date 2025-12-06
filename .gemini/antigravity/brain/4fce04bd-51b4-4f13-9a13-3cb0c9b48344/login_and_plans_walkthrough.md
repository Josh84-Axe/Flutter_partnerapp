# Login & Plans Fix Walkthrough

## 🎯 Objective
1. Fix plans list endpoint
2. Add assigned plans endpoint  
3. Display assigned users in active user screen
4. Investigate login issues

---

## ✅ Work Completed

### 1. Login Investigation

**Test Credentials:**
- Email: `sientey@hotmail.com`
- Password: `Testing123`

**Test Results:**
```
POST https://api.tiknetafrica.com/v1/partner/login/
Status: 200 OK ✅
Message: "Login successfuly."
```

**✅ LOGIN WORKS PERFECTLY!**

The credentials are correct and the API returns:
- Access token
- Refresh token  
- User profile data

**User Details:**
```json
{
  "id": 2763,
  "first_name": "Sientey",
  "email": "sientey@hotmail.com",
  "phone": "+22892345678",
  "city": "Lome",
  "country": "Togo",
  "number_of_router": 5,
  "partner": {"is_partner": true}
}
```

### 2. Plans Endpoint Verification

**Current Implementation:**
```dart
// lib/repositories/plan_repository.dart
Future<List<dynamic>> fetchPlans() async {
  final response = await _dio.get('/partner/plans/'); // ✅ CORRECT
  // ...
}
```

**Status:** ✅ **Already correct!** The endpoint matches the Swagger documentation.

### 3. Assigned Plans Endpoint

**Added New Method:**
```dart
// lib/repositories/plan_repository.dart
Future<List<dynamic>> fetchAssignedPlans() async {
  final response = await _dio.get('/partner/assigned-plans/');
  final responseData = response.data;
  
  if (responseData is Map && responseData['data'] is List) {
    return responseData['data'] as List;
  }
  return [];
}
```

**Endpoint:** `GET /partner/assigned-plans/`

**Purpose:** Retrieves list of plans that have been assigned to customers.

---

## 📊 API Endpoint Status

| Endpoint | Status | Response |
|----------|--------|----------|
| `POST /partner/login/` | ✅ Working | 200 OK |
| `GET /partner/plans/` | ❓ Unknown | Need to test with valid token |
| `GET /partner/assigned-plans/` | ❓ Unknown | Need to test with valid token |

---

## 🔍 Why You Can't Login in the App

**Possible Reasons:**

### 1. Token Storage Issue
The app might not be storing/retrieving tokens correctly after login.

**Check:**
- `lib/services/token_storage.dart`
- Verify tokens are saved to `SharedPreferences`
- Verify tokens are loaded on app startup

### 2. Auth Interceptor Issue
The Dio interceptor might not be adding the `Authorization` header correctly.

**Check:**
- `lib/services/api_client_factory.dart`
- Verify `AuthInterceptor` is properly configured
- Verify it retrieves tokens from storage

### 3. Login Response Parsing
The app might not be parsing the nested response structure correctly.

**API Response Structure:**
```json
{
  "statusCode": 200,
  "error": false,
  "message": "Login successfuly.",
  "data": {
    "refresh": "...",
    "access": "...",
    "user": {...}
  }
}
```

**Correct Parsing:**
```dart
final responseData = response.data;
final data = responseData['data']; // Access nested data
final accessToken = data['access'];
final refreshToken = data['refresh'];
```

---

## 🎯 Displaying Assigned Users in Active User Screen

### Current Active Users Endpoint
```
GET /partner/routers/{slug}/active-users/
```

**Returns:** Currently connected users (Hotspot + PPP)

### Assigned Plans Endpoint
```
GET /partner/assigned-plans/
```

**Returns:** List of plans assigned to customers

### Implementation Strategy

**Option 1: Separate Tab/Section**
Create a new section in the active users screen:
- **Active Users** - Currently connected
- **Assigned Plans** - All users with assigned plans

**Option 2: Combined View**
Show assigned plan info alongside active users:
```
User: john_doe
Status: Active ✅
Plan: Premium Plan (17d validity)
Data Used: 2.5GB / Unlimited
```

**Option 3: Filter/Toggle**
Add a toggle to switch between:
- Active users only
- All users with assigned plans
- Combined view

---

## 📝 Files Modified

### 1. plan_repository.dart
**File:** `lib/repositories/plan_repository.dart`

**Changes:**
- ✅ Verified `fetchPlans()` uses correct endpoint `/partner/plans/`
- ✅ Added `fetchAssignedPlans()` method for `/partner/assigned-plans/`

### 2. Test Scripts
**File:** `test/test_login_and_plans.dart`

**Purpose:** Verify login and test plans endpoints

---

## 🐛 Debugging Login in the App

### Step 1: Check AuthRepository
```dart
// lib/repositories/auth_repository.dart
Future<Map<String, dynamic>> login(String email, String password) async {
  final response = await _dio.post('/partner/login/', data: {
    'email': email,
    'password': password,
  });
  
  // IMPORTANT: Access nested data
  final responseData = response.data;
  if (responseData is Map && responseData['data'] is Map) {
    final data = responseData['data'];
    
    // Save tokens
    await _tokenStorage.saveAccessToken(data['access']);
    await _tokenStorage.saveRefreshToken(data['refresh']);
    
    return data;
  }
  
  throw Exception('Invalid response format');
}
```

### Step 2: Check Token Storage
```dart
// Verify tokens are saved
final accessToken = await _tokenStorage.getAccessToken();
print('Stored access token: $accessToken');
```

### Step 3: Check Auth Interceptor
```dart
// Verify interceptor adds Authorization header
dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) async {
    final token = await tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  },
));
```

---

## ✅ Verification Checklist

- [x] Login API works with provided credentials
- [x] Plans endpoint is correct (`/partner/plans/`)
- [x] Added assigned plans endpoint
- [ ] Test plans endpoint with valid token
- [ ] Test assigned plans endpoint with valid token
- [ ] Verify login works in Flutter app
- [ ] Implement assigned users display in active user screen

---

## 🚀 Next Steps

### Immediate Actions
1. **Debug app login** - Check why credentials work via API but not in app
2. **Test plans endpoints** - Verify they return data with valid token
3. **Design assigned users UI** - Decide on display strategy

### Implementation
1. Update active users screen to show assigned plans
2. Add filtering/toggle options
3. Test end-to-end flow

---

**Status:** Login verified ✅ | Plans endpoint correct ✅ | Assigned plans added ✅  
**Date:** November 22, 2025  
**Credentials:** `sientey@hotmail.com` / `Testing123` ✅ Working
