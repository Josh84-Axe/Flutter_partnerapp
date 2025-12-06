# Payout Request Tracking Implementation

## Overview
Implemented server-side tracking for payout requests by capturing withdrawal IDs from the API and displaying them in the UI.

## Changes Made

### 1. AppState Updates ([app_state.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/providers/app_state.dart))

#### Added Withdrawal ID Storage
```dart
String? _lastWithdrawalId; // Store last withdrawal ID for tracking
String? get lastWithdrawalId => _lastWithdrawalId; // Getter for withdrawal tracking ID
```

#### Modified `requestPayout` Method
```dart
Future<void> requestPayout(double amount, String method) async {
  _setLoading(true);
  try {
    if (_walletRepository == null) _initializeRepositories();
    final response = await _walletRepository!.createWithdrawal({
      'amount': amount,
      'payment_method': method,
    });
    
    // Store the withdrawal ID from the API response for tracking
    if (response != null && response['data'] != null && response['data']['id'] != null) {
      _lastWithdrawalId = response['data']['id'].toString();
    } else if (response != null && response['id'] != null) {
      _lastWithdrawalId = response['id'].toString();
    }
    
    await loadTransactions();
    await loadWalletBalance();
    _setLoading(false);
  } catch (e) {
    _setError(e.toString());
    _setLoading(false);
    rethrow;
  }
}
```

**Key Features:**
- Captures withdrawal ID from API response
- Handles both nested (`response['data']['id']`) and flat (`response['id']`) response formats
- Stores ID in `_lastWithdrawalId` for UI access

### 2. PayoutSubmittedScreen Updates ([payout_submitted_screen.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/screens/payout_submitted_screen.dart))

#### Added Provider Import
```dart
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
```

#### Updated Tracking Reference
```dart
// Get the server-generated tracking reference from AppState
final trackingRef = context.read<AppState>().lastWithdrawalId ?? 'TXN${DateTime.now().millisecondsSinceEpoch}';
```

**Before:** Generated local timestamp-based reference  
**After:** Uses server-generated withdrawal ID from API, with fallback to timestamp

## API Integration

### Endpoint
`POST /partner/wallet/withdrawls/create/`

### Expected Response Format
```json
{
  "statusCode": 201,
  "error": false,
  "message": "Withdrawal request created",
  "data": {
    "id": "wdr_20251124_001",
    "amount": "150.00",
    "payment_method": "mobile_money",
    "status": "pending",
    "created_at": "2025-11-24T14:33:14Z"
  }
}
```

### Supported Response Formats
The implementation handles both:
1. **Nested format:** `response['data']['id']`
2. **Flat format:** `response['id']`

## User Flow

1. **User initiates payout** → `PayoutRequestScreen`
2. **Calls** `AppState.requestPayout(amount, method)`
3. **API creates withdrawal** → Returns withdrawal ID
4. **AppState stores ID** in `_lastWithdrawalId`
5. **Navigation** to `PayoutSubmittedScreen`
6. **Screen displays** server-generated tracking reference
7. **User can copy** tracking reference for their records

## Benefits

✅ **Accurate Tracking:** Uses actual server-generated IDs instead of client-side timestamps  
✅ **API Consistency:** Tracking reference matches backend records  
✅ **User Confidence:** Professional tracking IDs (e.g., `wdr_20251124_001`)  
✅ **Fallback Safety:** Still works if API doesn't return ID  
✅ **Copy Functionality:** Users can copy and save the reference

## Testing Recommendations

1. **Successful Payout:**
   - Initiate a payout request
   - Verify tracking reference matches API response ID
   - Confirm ID can be copied to clipboard

2. **API Response Variations:**
   - Test with nested `data.id` format
   - Test with flat `id` format
   - Test with missing ID (fallback to timestamp)

3. **Error Handling:**
   - Verify fallback works when API fails
   - Check that local timestamp is generated correctly

## Next Steps

Consider implementing:
- **Withdrawal History Screen:** Display all past withdrawal requests with their IDs
- **Status Tracking:** Poll API for withdrawal status updates
- **Transaction Details:** Link tracking ID to detailed transaction view
- **Push Notifications:** Notify users when withdrawal status changes
