# Cleanup and Fix Plan

## Goal
Remove all mock data, ensure data persists across app restarts, and fix broken CRUD operations.

## User Review Required
> [!IMPORTANT]
> Removing mock data might break the app if the backend API is not fully functional or reachable. I will assume the API at `https://api.tiknetafrica.com/v1` is the source of truth.

## Proposed Changes

### 1. Remove Mock Data
- **Search**: `grep` for "mock", "dummy", "fake", "test data".
- **Files**: Likely in `lib/services`, `lib/providers`, or `lib/models`.
- **Action**: Remove hardcoded lists/objects and ensure data is fetched from `TiknetApiClient`.

### 2. Fix Data Persistence
# Cleanup and Fix Plan

## Goal
Remove all mock data, ensure data persists across app restarts, and fix broken CRUD operations.

## User Review Required
> [!IMPORTANT]
> Removing mock data might break the app if the backend API is not fully functional or reachable. I will assume the API at `https://api.tiknetafrica.com/v1` is the source of truth.

## Proposed Changes

### 1. Remove Mock Data
- **Search**: `grep` for "mock", "dummy", "fake", "test data".
- **Files**: Likely in `lib/services`, `lib/providers`, or `lib/models`.
- **Action**: Remove hardcoded lists/objects and ensure data is fetched from `TiknetApiClient`.

### 2. Fix Data Persistence
- **Analysis**: Check `AppState` or `AuthProvider` for initialization logic.
- **Issue**: Likely missing `await SharedPreferences.getInstance()` or not reading stored tokens/state on app startup.
- **Fix**: Ensure `initState` or provider constructors load data from storage before rendering the main UI.

### 3. Fix CRUD Actions
- **Analysis**: Check `TiknetApiClient` and repository layers.
- **Issue**: Potential mismatch in JSON parsing, wrong HTTP methods, or missing headers#### [MODIFY] [app_state.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/providers/app_state.dart)

### Hardcoded Data Removal
#### [MODIFY] [data_limit_config_screen.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/screens/config/data_limit_config_screen.dart)
- Removed hardcoded `_configs` list.
- Integrated `AppState.fetchDataLimits`, `createDataLimit`, `updateDataLimit`, `deleteDataLimit`.

#### [MODIFY] [subscription_management_screen.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/screens/subscription_management_screen.dart)
- Removed hardcoded `SubscriptionModel` instantiation.
- Integrated `AppState.partnerProfileData` to display real subscription info if available.
- Added fallback UI for missing subscription data.

#### [MODIFY] [plan_config_repository.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/repositories/plan_config_repository.dart)
- Updated `fetchDataLimits` path to `/partner/data-limit/list/`.
- Added `updateDataLimit` method.

#### [MODIFY] [app_state.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/providers/app_state.dart)
- Added `_dataLimits` state and management methods.
- Added `_partnerProfileData` and updated `loadProfiles` to fetch from `PartnerRepository`.

## Verification Plan
- **Persistence**: Login, close app, reopen. User should still be logged in.
- **CRUD**: Create a new item (if applicable), edit it, delete it. Verify changes reflect on backend.
