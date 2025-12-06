# Walkthrough - Refactor Subscription & Router Management

## Goal
Refactor the application to use real API endpoints for subscription management, router operations, and static configuration lists, eliminating hardcoded mock data.

## Changes

### Subscription & Router Management
- **`SubscriptionManagementScreen`**: Fixed duplicate class definition and integrated `AppState` for subscription data.
- **`PartnerRepository`**: Added `purchaseSubscription` method.
- **`RouterRepository`**: Updated endpoints for fetching, adding, deleting, and updating routers. Added `rebootRouter`, `restartHotspot`, `getRouterResources`, and `fetchActiveUsers`.
- **`SessionRepository`**: Updated `fetchActiveSessions` endpoint.
- **`AppState`**: Added methods to manage subscriptions, routers, and session data.

### Static Configuration Lists
- **`AppState`**: Added `_rateLimits`, `_validityPeriods`, `_idleTimeouts`, `_sharedUsers` and methods to fetch them.
- **`CreateEditInternetPlanScreen`**: Refactored to use `AppState` for configuration dropdowns.
- **`CreateEditUserProfileScreen`**: Refactored to use `AppState` for configuration dropdowns.
- **`PlansScreen`**: Refactored to use `AppState` for configuration data.
- **`HotspotConfigurationService`**: Removed static lists.

### Hotspot Users & Email Verification
- **`AppState`**: Added `_hotspotUsers` list and methods (`loadHotspotUsers`, `createHotspotUser`, `updateHotspotUser`, `deleteHotspotUser`). Added `confirmRegistration` and `resendVerifyEmailOtp`.
- **`HotspotUsersManagementScreen`**: Refactored to use `AppState` for user management.
- **`EmailVerificationScreen`**: Refactored to use `AppState` for email verification.

## Verification Results

### Build Verification
- **Command**: `flutter build windows`
- **Result**: **SUCCESS**
- **Notes**:
    - Resolved duplicate class definition in `SubscriptionManagementScreen`.
    - Resolved syntax errors in `DataLimitConfigScreen` (duplicate class, leftover code).
    - Resolved missing getters/setters in `AppState` (`currentUser`, `isLoading`, `walletBalance`, `transactions`, `error`, `_selectedLanguage`, `_subscription`, `_partnerProfileData`, `_profiles`).
    - Resolved duplicate arguments in `CreateEditUserProfileScreen`.

### Manual Verification Required
- **Subscription**: Verify that subscription details load correctly and "Purchase Plan" works.
- **Routers**: Verify router list loads, and add/delete/update/reboot actions work.
- **Configuration**: Verify dropdowns in "Create Plan" and "Create Profile" are populated from the API.
- **Hotspot Users**: Verify creating, listing, and deleting hotspot users.
- **Email Verification**: Verify the email verification flow.

## Next Steps
- Run the application and perform manual verification of the features.
