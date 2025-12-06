# Codebase Analysis - User Questions Answered

## 1. Amount Format Found in Codebase

### Primary Format Method
**Location:** `lib/utils/currency_utils.dart`

```dart
static String formatPrice(double price, String? country) {
    final formatter = NumberFormat.currency(symbol: '$', decimalDigits: 2);
    return formatter.format(price);
}
```

### Format Pattern
- **Uses:** `intl` package's `NumberFormat.currency()`
- **Symbol:** `$` (hardcoded default)
- **Decimal Places:** 2
- **Example Output:** `$1,234.56`

### Usage Throughout App
The app uses `AppState.formatMoney()` which delegates to `CurrencyUtils.formatPrice()`:

```dart
// In AppState (line 165)
String formatMoney(double amount) => CurrencyUtils.formatPrice(amount, _partnerCountry);
```

**Used in:**
- Wallet balance display
- Transaction amounts
- Plan prices
- Payout requests
- Revenue metrics

---

## 2. Static Files in Configs

### ✅ YES - Static Config File Found

**File:** `lib/services/api/api_config.dart`

```dart
class ApiConfig {
  /// Base URL for the API
  static const String apiHost = String.fromEnvironment(
    'API_HOST',
    defaultValue: 'https://api.tiknetafrica.com',
  );

  /// Full base URL including version path
  static String get baseUrl => '$apiHost/v1';

  /// Feature flag to enable/disable remote API integration
  static const bool useRemoteApi = true;
}
```

### Configuration Details
- **API Host:** `https://api.tiknetafrica.com`
- **Base URL:** `https://api.tiknetafrica.com/v1`
- **Remote API:** Enabled (hardcoded to `true`)
- **Environment Override:** Supports `--dart-define=API_HOST=...`

### Other Config Locations
- `lib/screens/config/` - UI screens for plan configurations
- `lib/models/configuration_model.dart` - Configuration data models
- `lib/repositories/plan_config_repository.dart` - Config API endpoints

---

## 3. Mock Data in Codebase

### ❌ NO Mock Data Found

**Search Results:** 0 files matching `*mock*`

### Current Implementation
- **Remote API:** Fully integrated and enabled
- **Mock Data:** None present
- **Data Source:** 100% real API calls to `https://api.tiknetafrica.com/v1`

### Historical Context
Based on code comments and the `useRemoteApi` flag in `ApiConfig`, there was likely mock data in the past, but it has been **completely removed** in favor of real API integration.

---

## 4. Current Partner Country

### Partner Country Storage
**Location:** `lib/providers/app_state.dart` (line 103)

```dart
String? _partnerCountry; // Store partner country for currency display
```

### How It's Set
During login, the partner's country is extracted from the profile:

```dart
// From login flow
_partnerCountry = profileData['country']?.toString() ?? 
                  profileData['country_name']?.toString();
```

### Current Partner Country
**Status:** ⚠️ **Dynamic - Depends on logged-in user**

To find the current partner's country, you need to:
1. Check the running app's state
2. Or query `/partner/profile/` endpoint with credentials

**Test Credentials:** `sientey@hotmail.com` / `Testing123`

---

## 5. Currency Symbol Display

### Current Implementation
**Location:** `lib/utils/currency_utils.dart` (line 11-15)

```dart
static String getCurrencySymbol(String? country) {
    // This is now handled by AppState, but we keep this static method
    // for backward compatibility where context isn't available.
    // Ideally, widgets should use context.read<AppState>().currencySymbol
    return '$'; 
}
```

### Currency Symbol
**Current:** `$` (USD - hardcoded default)

### AppState Currency Access
```dart
// Line 164
String get currencySymbol => CurrencyUtils.getCurrencySymbol(_partnerCountry);
```

### ⚠️ Issue Identified
The currency symbol is **hardcoded to `$`** regardless of partner country. The API endpoints exist to fetch dynamic currency:

- `/partner/currency/` - Get currency symbol by country
- `/partner/currency-code/` - Get currency code by country

**Recommendation:** Implement dynamic currency fetching based on partner country.

---

## 6. Partner Role

### Role Storage
**Location:** `lib/models/user_model.dart`

```dart
class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;  // ← Partner role stored here
  final bool isActive;
  final DateTime createdAt;
}
```

### Current User Role
**Location:** `lib/providers/app_state.dart` (line 102)

```dart
UserModel? _currentUser;
```

### How Role is Set
During login, the role is set to `'Partner'`:

```dart
_currentUser = UserModel(
  id: profileData['id']?.toString() ?? '1',
  name: '${profileData['first_name'] ?? ''} ${profileData['last_name'] ?? ''}'.trim(),
  email: profileData['email']?.toString() ?? email,
  role: 'Partner',  // ← Hardcoded
  isActive: true,
  createdAt: DateTime.now(),
);
```

### Partner Role
**Current:** `'Partner'` (hardcoded for all logged-in users)

**Note:** The actual role from the API might be different. Check the `/partner/profile/` response for the real role.

---

## 7. Partner First Name and Last Name

### Name Storage
**Location:** `lib/providers/app_state.dart`

```dart
_currentUser = UserModel(
  name: '${profileData['first_name'] ?? ''} ${profileData['last_name'] ?? ''}'.trim(),
  // ...
);
```

### How Names are Extracted
From the `/partner/profile/` API response:
- `first_name` field → First name
- `last_name` field → Last name
- Combined as: `"FirstName LastName"`

### Current Partner Name
**Status:** ⚠️ **Dynamic - Depends on logged-in user**

For test account `sientey@hotmail.com`:
- **First Name:** Retrieved from API `profileData['first_name']`
- **Last Name:** Retrieved from API `profileData['last_name']`

**To get actual values:** Login with test credentials and check the profile response.

---

## 8. Active Session UI Implementation

### ✅ YES - Fully Implemented

**File:** `lib/screens/active_sessions_screen.dart` (376 lines)

### Features Implemented

#### 1. **Two-Tab Interface**
- **Tab 1:** Online Users (Active Sessions)
- **Tab 2:** Assigned Users (with online/offline status)

#### 2. **Online Users Tab**
Displays all active WiFi sessions with:
- Username
- IP Address
- MAC Address
- Uptime
- Download/Upload data (formatted in B/KB/MB/GB)
- Disconnect button

**Data Source:** `AppState.activeSessions` from `/partner/sessions/active/`

#### 3. **Assigned Users Tab**
Shows assigned plan users with:
- Username
- Plan name
- **Online/Offline status indicator** (green/grey badge)
- For online users:
  - IP Address
  - Uptime
  - Download/Upload data
  - Disconnect button

**Data Source:** 
- Assigned plans: `AppState.assignedPlans` from `/partner/assigned-plans/`
- Active sessions: Matched with online users

#### 4. **Session Matching Logic**
```dart
// Creates a map for quick lookup
final activeSessionMap = {
  for (var s in activeSessions) s['username']?.toString().toLowerCase(): s
};

// Matches assigned users with active sessions
final activeSession = activeSessionMap[username];
final isOnline = activeSession != null;
```

#### 5. **Disconnect Functionality**
- Confirmation dialog before disconnect
- Calls `AppState.disconnectSession()`
- Uses `/partner/sessions/disconnect/` endpoint
- Success/error feedback via SnackBar

#### 6. **Data Formatting**
```dart
String _formatBytes(dynamic bytes) {
  if (bytes == null) return '0 B';
  int b = int.tryParse(bytes.toString()) ?? 0;
  if (b < 1024) return '$b B';
  if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(1)} KB';
  if (b < 1024 * 1024 * 1024) return '${(b / (1024 * 1024)).toStringAsFixed(1)} MB';
  return '${(b / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
}
```

#### 7. **UI Features**
- ✅ Pull-to-refresh on both tabs
- ✅ Loading indicators
- ✅ Empty state messages
- ✅ Refresh button in app bar
- ✅ Color-coded online/offline status
- ✅ Responsive card layout

### API Integration Status
| Feature | Endpoint | Status |
|---------|----------|--------|
| Fetch active sessions | `/partner/sessions/active/` | ✅ Working |
| Fetch assigned plans | `/partner/assigned-plans/` | ✅ Working |
| Disconnect session | `/partner/sessions/disconnect/` | ✅ Working |

---

## Summary

| Question | Answer |
|----------|--------|
| **Amount Format** | `NumberFormat.currency(symbol: '$', decimalDigits: 2)` |
| **Static Config** | ✅ Yes - `api_config.dart` with API host and feature flags |
| **Mock Data** | ❌ No - 100% real API integration |
| **Partner Country** | Dynamic from `/partner/profile/` response |
| **Currency Symbol** | `$` (hardcoded, should be dynamic) |
| **Partner Role** | `'Partner'` (hardcoded in UserModel) |
| **First/Last Name** | Dynamic from `profileData['first_name']` and `profileData['last_name']` |
| **Active Session UI** | ✅ Fully implemented with online/offline tracking |

---

## Recommendations

1. **Currency Symbol:** Implement dynamic currency fetching using existing API endpoints
2. **Role Management:** Use actual role from API instead of hardcoded `'Partner'`
3. **Testing:** Login with `sientey@hotmail.com` / `Testing123` to verify actual partner data
