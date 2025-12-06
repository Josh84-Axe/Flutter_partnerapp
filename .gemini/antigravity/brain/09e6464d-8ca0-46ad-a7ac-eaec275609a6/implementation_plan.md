# Refactor Static Configuration Lists

## Goal
Eliminate hardcoded static lists in `HotspotConfigurationService` and replace them with dynamic data fetched from the API via `PlanConfigRepository` and stored in `AppState`.

## Proposed Changes

### `lib/providers/app_state.dart`
- Add state variables:
    - `List<Map<String, dynamic>> _rateLimits`
    - `List<Map<String, dynamic>> _validityPeriods`
    - `List<Map<String, dynamic>> _idleTimeouts`
    - `List<Map<String, dynamic>> _sharedUsers`
- Add methods to fetch and load these lists:
    - `fetchRateLimits()`
    - `fetchValidityPeriods()`
    - `fetchIdleTimeouts()`
    - `fetchSharedUsers()`
- Update `loadDashboardData` (or similar) to call these fetch methods.

### `lib/screens/create_edit_internet_plan_screen.dart`
- Replace `HotspotConfigurationService.get...` calls with `appState.validityPeriods`, `appState.dataLimits`, etc.
- Update dropdowns to display values from the API data (likely `name` or `value` fields).
- Update `_savePlan` to use the selected values directly.

### `lib/screens/create_edit_user_profile_screen.dart`
- Replace `HotspotConfigurationService` calls with `AppState` data for Rate Limits and Idle Timeouts.

### `lib/screens/plans_screen.dart`
- Replace `HotspotConfigurationService` calls with `AppState` data for filtering/display if applicable.

### `lib/services/hotspot_configuration_service.dart`
- Remove static list methods.
- Keep helper methods like `extractNumericValue` only if still strictly necessary (likely can be removed if API returns structured data).

## Verification
- Verify that dropdowns in "Create Plan" and "Create Profile" screens are populated.
- Verify that creating a plan/profile sends the correct data to the API.

# Connect Hotspot Users & Email Verification

## Goal
Connect the `HotspotUsersManagementScreen` to the API via `AppState` and `HotspotRepository`. Implement missing email verification methods in `AuthRepository` and connect `EmailVerificationScreen`.

## Proposed Changes

### `lib/providers/app_state.dart`
- Add `List<Map<String, dynamic>> _hotspotUsers`.
- Add methods:
    - `loadHotspotUsers()`: Call `_hotspotRepository.fetchUsers()`.
    - `createHotspotUser(Map<String, dynamic> userData)`: Call `_hotspotRepository.createUser()`.
    - `updateHotspotUser(String username, Map<String, dynamic> userData)`: Call `_hotspotRepository.updateUser()`.
    - `deleteHotspotUser(String username)`: Call `_hotspotRepository.deleteUser()` (if available, otherwise check repo).

### `lib/screens/hotspot_users_management_screen.dart`
- Remove mock data and TODOs.
- Use `context.watch<AppState>().hotspotUsers` to display the list.
- Use `context.read<AppState>().createHotspotUser` in the create dialog.
- Implement edit/delete functionality using `AppState` methods.

### `lib/repositories/auth_repository.dart`
- Add `confirmRegistration(String email, String code)`.
- Add `resendVerifyEmailOtp(String email)`.
- Ensure these match the backend endpoints (likely `/partner/register-confirm/` and `/partner/resend-verify-email-otp/`).

### `lib/screens/email_verification_screen.dart`
- Replace TODOs with calls to `AuthRepository` (via `AppState` or directly if `AppState` doesn't wrap them yet - preferably wrap in `AppState` for consistency).
- Update `AppState` to expose `confirmRegistration` and `resendVerifyEmailOtp` if needed, or access repository directly if `AppState` is just for global state. *Decision: Add wrapper methods to `AppState` for consistency.*

## Verification
- **Hotspot Users**: Create a user, verify it appears in the list. Edit a user, verify changes.
- **Email Verification**: Trigger verification flow (if possible without new registration) or verify the code calls the correct endpoint.
