# Session History: Fix Empty App Data on Physical Device

**Date:** November 11, 2025  
**Session:** https://app.devin.ai/sessions/f52953460f934a0eac2c02e04f5ca8b6  
**Branch:** `devin/1761668736-phase1-phase2-on-pr5`  
**PR:** https://github.com/Josh84-Axe/Flutter_partnerapp/pull/9

## Problem Statement

User reported that after installing the APK on a physical device, the app was empty and not loading any data from the backend API, despite successful API testing via curl showing the account has:
- 10 customers
- 2 routers (Tiknet, Tiknet Africa)
- 8 plans
- Wallet balance: 450.00 GHS
- 8 transactions
- 12 total hotspot users

## Root Causes Identified

### 1. CRITICAL: Missing INTERNET Permission (Primary Cause)
**File:** `android/app/src/main/AndroidManifest.xml`

The AndroidManifest was missing the `android.permission.INTERNET` permission, which prevented the app from making any network requests on physical devices. This is the most common cause of "empty app" issues on Android.

**Fix:** Added both `android.permission.INTERNET` and `android.permission.ACCESS_NETWORK_STATE` permissions to the manifest.

### 2. Repository Initialization on Cold Start
**File:** `lib/providers/app_state.dart` (line 217-223)

The `checkAuthStatus()` method was using mock `_authService.getCurrentUser()` instead of checking for saved tokens and initializing API repositories. When the app restarted with a saved token, repositories were null, so API calls couldn't be made.

**Fix:** Updated `checkAuthStatus()` to:
- Initialize repositories when `useRemoteApi` is true
- Check for saved access token using TokenStorage
- Verify token validity by fetching profile from API
- Automatically clear invalid tokens
- Load dashboard data if token is valid

### 3. Data Loading Methods Using Mock Services
**Files:** `lib/providers/app_state.dart`

Several data loading methods were still using mock services instead of API repositories:
- `loadUsers()` (line 314-320) - used `_authService.getUsers()`
- `loadPlans()` (line 350-356) - used `_paymentService.getPlans()`
- `loadTransactions()` (line 359-365) - used `_paymentService.getTransactions()`

**Fix:** Updated all methods to:
- Check `useRemoteApi` flag
- Initialize repositories if null (lazy initialization)
- Call appropriate API repository methods
- Map API response data to model objects
- Fall back to mock services only when `useRemoteApi` is false

### 4. Wallet Balance Field Name Mismatch
**File:** `lib/providers/app_state.dart` (line 368-382)

The API returns `wallet_balance` in the response, but the code was trying to read `balance`, causing the wallet balance to always show 0.00.

**Fix:** Updated `loadWalletBalance()` to read `wallet_balance` from API response and parse it correctly as a double.

### 5. Model Field Mapping Errors
**File:** `lib/providers/app_state.dart`

The PlanModel and TransactionModel mappings didn't match their actual field definitions:
- PlanModel: Used non-existent fields `duration` and `features`
- TransactionModel: Used `date` instead of `createdAt`

**Fix:** 
- Updated PlanModel mapping to use actual fields: `dataLimitGB`, `validityDays`, `speedMbps`, `isActive`, `deviceAllowed`, `userProfile`
- Updated TransactionModel mapping to use `createdAt` and added optional fields: `paymentMethod`, `gateway`, `workerId`, `accountId`
- Added explicit type casting with `<PlanModel>` and `<TransactionModel>` for type safety

### 6. Missing Repository Method
**File:** `lib/repositories/wallet_repository.dart`

The WalletRepository didn't have a `fetchPlans()` method, which was needed by `loadPlans()`.

**Fix:** Added `fetchPlans()` method to WalletRepository that calls `GET /partner/plans/` endpoint.

## Changes Made

### Files Modified:
1. `android/app/src/main/AndroidManifest.xml` - Added INTERNET permissions
2. `lib/providers/app_state.dart` - Fixed all data loading methods and repository initialization
3. `lib/repositories/wallet_repository.dart` - Added fetchPlans() method

### Commits:
1. `04b0ae4` - "fix: critical fixes for empty app data on physical device"
2. `26a7a02` - "fix: correct PlanModel and TransactionModel field mappings for API integration"

## Build Results

**APK Location:** `build/app/outputs/flutter-apk/app-release.apk`  
**APK Size:** 57.1MB  
**Build Status:** ✅ Success (no errors)  
**Download Link:** https://app.devin.ai/attachments/786fc701-d659-42b4-a9e7-37542f69341f/app-release.apk

## Testing Checklist

The following should be verified on a physical device:

- [ ] Login works with test credentials (admin@tiknetafrica.com / uN5]B}u8<A1T)
- [ ] Dashboard loads and displays account data
- [ ] Wallet balance shows 450.00 GHS (not 0.00)
- [ ] 2 routers display correctly (Tiknet, Tiknet Africa)
- [ ] 8 plans display with correct data
- [ ] 8 transactions display with correct data
- [ ] Cold start works (kill app and reopen - should auto-login with saved token)
- [ ] All screens are accessible and display data correctly
- [ ] Create actions work or are properly disabled
- [ ] Error messages are user-friendly

## Known Issues

1. **Customer List Endpoint Returns 404** - The `/partner/customers/` endpoint returns 404, so `loadUsers()` returns an empty list. This may require a backend fix to identify the correct endpoint.

2. **Router Creation Endpoint Returns 404** - The `/partner/routers/add/` endpoint returns 404. This may require a backend fix.

3. **Modified Auto-Generated File** - The file `packages/tiknet_api_client/lib/src/model/purchase_subscription.dart` was manually modified to fix a build error. This will be overwritten if code generation runs again.

## API Endpoints Used

All endpoints are relative to base URL: `https://api.tiknetafrica.com/v1`

- `POST /partner/login/` - Authentication
- `GET /partner/profile/` - Fetch partner profile
- `GET /partner/dashboard/` - Dashboard statistics
- `GET /partner/routers/` - List routers
- `GET /partner/wallet/balance/` - Wallet balance
- `GET /partner/plans/` - List plans
- `GET /partner/wallet/transactions/` - List transactions

## Next Steps

1. **User Testing** - Wait for user to test APK on physical device and confirm all data loads correctly
2. **Backend Fixes** - If customer list and router creation are needed, backend endpoints need to be fixed
3. **Error Handling** - Consider adding user-visible error messages (currently only stored in state)
4. **Offline Support** - Consider adding local caching for offline access
5. **Pull-to-Refresh** - Add pull-to-refresh functionality on all data screens

## Lessons Learned

1. **Always check AndroidManifest for INTERNET permission** - This is the #1 cause of empty data on physical devices
2. **Test on physical devices early** - Emulators may have different network permissions than physical devices
3. **Verify field names match API responses** - Use API testing results to confirm exact field names
4. **Initialize repositories on cold start** - Apps need to handle saved tokens and initialize repositories before loading data
5. **Add lazy initialization guards** - Ensure repositories are initialized before any API call
6. **Use explicit type casting** - Helps catch type errors at compile time instead of runtime

## References

- Previous Session: `SESSION_HISTORY.md`
- API Testing Results: `API_TESTING_RESULTS.md`
- API Fixes Recommendations: `API_FIXES_RECOMMENDATIONS.md`
- PR #9: https://github.com/Josh84-Axe/Flutter_partnerapp/pull/9
