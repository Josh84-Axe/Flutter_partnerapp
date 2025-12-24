# Task List - Users Screen Improvements & Router Visibility

## Current Task: Users Screen Improvements

### Planning Phase ✅
- [x] Audit current users screen implementation
- [x] Test API endpoints to understand response structure
- [x] Document API limitations (no acquisition_type field)
- [x] Create revised implementation plan

### Implementation Phase
- [x] Update Customer Repository
  - [x] Add `getCustomerDataUsage()` method
  - [x] Update `fetchPaginatedCustomers()` to use paginate-list endpoint
- [x] Update User Model
  - [x] Add `blocked` field
  - [x] Add `isConnected` field (computed from active sessions)
  - [x] Add `lastConnection` field
  - [x] Add `totalSessions` field
- [x] Update Users Screen
  - [x] Fix search to support name AND phone
  - [x] Replace mock status with real status
  - [x] Update status badges (Blocked, Connected, Active)
  - [x] Add "View Details" to ellipsis menu
  - [x] Improve block/unblock UI
- [x] **Automatic Updates Failure (Android)**
  - [x] Diagnose build namespace error with `r_upgrade`
  - [x] Replace `r_upgrade` with `Dio` + `package_installer` / `open_file` implementation
  - [x] Add required permissions (`REQUEST_INSTALL_PACKAGES`)
  - [x] Fix continuous update loop (reset `version.json` temporarily)

- [x] **Transaction History Rendering Bug (Android)**
  - [x] Analyze `transaction_history_screen.dart` performance
  - [x] Refactor list merging/sorting out of `build()` method to prevent crash/jank

- [x] **Dark Theme Issues**
  - [x] Fix `InternetPlanScreen` white/blur background (Updated `TiknetThemes` `surfaceContainer`)

- [x] **System Feedback Improvements**
  - [x] Audit code for raw `e.toString()` usage
  - [x] Replace with `ErrorMessageHelper` in `UsersScreen`, `HotspotUsersManagementScreen`, `CreateEditUserProfileScreen`
- [x] Create User Details Screen
  - [x] Display user info
  - [x] Display data usage stats
  - [x] Display recent transactions
  - [x] Add route to main.dart
- [x] Update AppState
  - [x] Add `getCustomerDataUsage()` method
  - [x] Add `getCustomerTransactions()` method
  - [x] Add `getActiveSessions()` method
  - [x] Add `toggleUserBlock()` method
- [x] Localization Implementation 🌍
  - [x] **Phase 1: Transactions & Users**
    - [x] Update `wallet_overview_screen.dart`
    - [x] Update `transaction_payment_history_screen.dart`
    - [x] Update `users_screen.dart`
    - [x] Update `transaction_details_screen.dart`
    - [x] Update JSON files (en/fr)
  - [x] **Phase 2: Router Management**
    - [x] Update `router_settings_screen.dart`
    - [x] Update `router_health_screen.dart`
    - [x] Update JSON files
  - [x] **Phase 3: Security & Subscription**
    - [x] Update Security screens
    - [x] Update Subscription screens
    - [x] Update JSON files
  - [x] **Phase 4: Profile & Global Polish**
  - [x] Localize Partner Profile
  - [x] Localize Settings
  - [x] Localize Help & Support
  - [x] Localize Internet Plan Screen (Audit & Fix)
  - [x] Global audit for hardcoded strings (SnackBars, Toasts)
  - [x] Fix "Duplicate object key" warnings in `fr.json` <!-- New Item -->
- [x] **Data Export & Reporting Screen Localization**
  - [x] Audit for hardcoded strings
  - [x] **Role Management Refactor** <!-- New Item -->
    - [x] Remove hardcoded role strings from `Permissions`
    - [x] Implement dynamic role colors in `AssignRoleScreen`
    - [x] Clean up `UsersScreen` role filtering logic
    - [x] Update `UserModel` to use API data explicitly
  - [x] Add keys to `en.json` / `fr.json`
  - [x] Integrate `purchased-plans` API on user details
- [x] Integrate `data-usage` API on user details
- [x] Integrate `transactions` API on user details (Split Assigned vs Wallet)
- [x] Screen Refactoring: `UserDetailsScreen` to support new data and layout
- [x] Filter displayed plans (Active/Upcoming only)
  - [x] **Dark Theme Fix** <!-- New Item -->
    - [x] Fix typography color (white on dark) in `TiknetThemes`
    - [x] Fix `SettingsScreen` theme selector widget
- [x] **Assign Role Screen Localization**
  - [x] Audit for hardcoded strings ("No Role")
  - [x] Add keys
  - [x] Implement `tr()` calls
- [x] **Assign Role Screen Localization**
  - [x] Audit for hardcoded strings ("No Role")
  - [x] Add keys
  - [x] Implement `tr()` calls
- [x] **Automatic OTA Updates (Android)** <!-- New Item -->
  - [x] Implement `UpdateService` and `UpdateConfig`
  - [x] Integrate `r_upgrade` package (replaced `ota_update` to fix build error)
  - [x] Set up `version.json` via GitHub Raw URL
  - [x] Add update check to `DashboardScreen`
  - [x] **Fix Build Failure (Android Gradle Plugin mismatch)** <!-- New Item -->
    - [x] Removed `r_upgrade` (incompatible) and implemented custom Dio+OpenFile update logic.
- [ ] **Data Export & Reporting Screen Testing** <!-- Pending User Verification -->

### Router Visibility Fix ✅
- [x] Investigate why admin couldn't see routers
- [x] Fix role check logic (recognize 'Administrator')
- [x] Verify API returns routers
- [x] Push fix (commit `df8d783`)

### Deferred (Backend Enhancement Needed)
- [ ] Gateway/Assigned labels (waiting for `acquisition_type` field)

### Verification Phase
- [ ] Test search by name
- [ ] Test search by phone
- [ ] Test status indicators
- [ ] Test view details
- [ ] Test block/unblock
- [ ] Test remove user
- [ ] Update walkthrough

## Completed Tasks

### Error Messages & User Feedback ✅
- [x] Created ErrorMessageHelper utility
- [x] Updated registration screen with success/error alerts
- [x] Added user-friendly error messages
- [x] Added localization (EN/FR)

### API Endpoint Fixes ✅
- [x] Updated transaction endpoints
- [x] Updated password change endpoint

### Guest Mode Fixes ✅
- [x] Fixed transaction date format
- [x] Added error handling

### Production Readiness: Placeholders & Logic ✅
- [x] **Help & Support**: Updated contact details.
- [x] **Auth Service**: Confirmed real API usage (via `AuthRepository`).
- [x] **User Management**:
  - [x] Implemented `blockCustomer` / `unblockCustomer` in `AppState`.
  - [x] Added Block/Unblock button in `HotspotUsersManagementScreen`.
- [x] **Data Usage**:
  - [x] Implemented `getAggregateActiveDataUsage` in `AppState`.
  - [x] Integrated `DataUsageCard` in `DashboardScreen` with real aggregated data.

### Notification Fixes ✅
- [x] User-specific notification storage
- [x] Cross-platform badge updates

### Production Readiness: Fixes Round 2 (Feedback) 🛠️
- [x] **Router Assignment & Health**
  - [x] Update `RouterRepository` to use `/partner/routers/{slug}/resources/` for health stats.
  - [x] Investigate and fix Router Health screen visibility for workers. (Standardized on Email)
  - [x] Verify `visibleRouters` logic in `AppState`.
- [x] **Error Handling Polish**
  - [x] Fix raw system messages on `LoginScreen`.
  - [x] Handle 403 Forbidden errors gracefully in `ErrorMessageHelper`.
- [x] **Dark Theme Polish**
  - [x] Re-audit `InternetPlanScreen` for hardcoded colors in Dark Mode.

### Production Readiness: Fixes Round 3 (Feedback) 🛠️
- [x] **Router Assignment Visibility**
  - [x] Deep dive into `visibleRouters` logic and Role permissions.
  - [x] Specific check: why is worker not seeing assigned router? (Implemented strict local storage save & case-insensitivity)
  - [x] Verify `UsersScreen` passes Email (not ID) to `RouterAssignScreen`.
- [x] **Internet Plan Dark Mode**
  - [x] Investigate why `InternetPlanScreen` doesn't react to theme changes. (Added `surfaceContainerHighest`)
- [x] **Data Usage Widget**
  - [x] Resize widget (make smaller).
  - [x] Ensure real aggregate data is used (wired `getAggregateTotalDataLimit`).
- [x] **Router Health 404**
  - [x] Debug URL construction `/partner/routers/{slug}/resources/`.
  - [x] Check if `id` is being passed instead of `slug` (Fixed to prefer `slug`).

### Production Readiness: Fixes Round 4 (Feedback) 🛠️
- [x] **Router Assignment Logic**
  - [x] Abandon client-side filtering (Reverted to "Show All" per user suggestion).
- [x] **Localization (Underscores)**
  - [x] Fix missing keys and clean up duplicated JSON blocks in `en.json` / `fr.json`.
- [x] **Internet Plan Dark Mode**
  - [x] Fix `InternetPlanScreen` (First Page) theme integration with deeper contrast.
- [x] **Raw System Message**
  - [x] Hardened `ErrorMessageHelper` to catch generic technical strings.
- [x] **Compact Data Usage**
  - [x] Redesign `DataUsageCard` to a slim linear format.
  - [x] Update Dashboard layout to a 2x2 grid (reduces width by 50%).
- [x] **Active Sessions Refactor**
  - [x] Support "Online Users" vs "Assigned Users" tabs.
  - [x] Use `/partner/purchased-plans/` and `/partner/assigned-plans/`.
  - [x] Cross-reference with `/partner/sessions/active/`.
  - [x] Implement session disconnection via `/partner/sessions/disconnect/`.
  - [x] Verified build and pushed changes.

- [x] **Production Deployment Setup**
  - [x] Consolidate workflows into `ci-dev.yml` and `ci-prod.yml`.
  - [x] Implement Web + Android builds in both.
  - [x] Create/Push `main` branch from `fix/token-storage-windows`.
  - [x] Verify both deployments (triggered via git push).

- [x] **Refine Active Sessions & Dashboard**
  - [x] Update "Active Sessions" tabs to show user details (`customer_name`) matched with session data.
  - [x] Remove "Active Session" widget from Dashboard.
  - [x] Make "Data Usage" card full-width below quick actions.
  - [x] Verify web build.
  
- [x] **Refine Active Sessions & Dashboard**
  - [x] Update "Active Sessions" tabs to show user details (`customer_name`) matched with session data.
  - [x] Remove "Active Session" widget from Dashboard.
  - [x] Make "Data Usage" card full-width below quick actions.
  - [x] Verify web build.

- [x] **Project Documentation**
  - [x] Create `USER_MANUAL.md` (Process flows) - *Detailed in docs/*
  - [x] Create `TEST_SCENARIOS.md` (QA validation steps) - *Detailed in docs/*
  - [x] Create `TEST_SCENARIOS.md` (QA validation steps) - *Detailed in docs/*
  - [x] Create `TESTER_FEEDBACK_FORM.md` (Execution Log & Sign-off) - *Detailed in docs/*

- [x] **Bug Fix: Active Sessions Matching**
  - [x] Fix matching logic to handle generated usernames (e.g. `user_123` vs `User`).
  - [x] Inject router details (DNS/IP) into session objects for display.

- [x] **Refactor: Real Data Usage Aggregation**
  - [x] Implement aggregate usage calculation in `loadActiveSessions` (summing bytes_in/out).
  - [x] Connect `loadDashboardData` to trigger session loading.
  - [x] Deprecate inefficient per-user API polling.

- [x] **Superadmin Dashboard Specifications**
  - [x] Audit codebase (Models/Repos) for upstream requirements.
  - [x] Create `docs/SUPERADMIN_DASHBOARD_SPECS.md` detailing functional requirements.

- [x] **Codebase Optimization Audit**
  - [x] Identify state management bottlenecks (`AppState` monolithic structure).
  - [x] Identify caching gaps (`CacheService` unused).
  - [x] Create `OPTIMIZATION_PLAN.md` with Safety & Migration Strategy.

- [ ] **Optimization Phase 2: Billing Migration**
  - [x] Implement Wallet/Transaction logic in `BillingProvider`.
  - [x] Consolidate usage in `WalletOverviewScreen` to `BillingProvider`.
  - [x] Consolidate usage in `PayoutHistoryScreen` and `TransactionHistoryScreen`.
  - [x] Consolidate usage in `PayoutRequestScreen`.
  - [x] Verify Payouts/History functionality.


- ✅ **Web**: Compiles successfully
- ✅ **Mobile (Android/iOS)**: Should build successfully
- ⚠️ **Wasm**: Expected warnings about dart:html (not critical)

## New Bugs to Fix 🐛

### Partner Profile Bug
- [x] Investigate `saveChanges` button failure
- [x] Implement/Fix `/partner/profile/update/` integration
- [ ] Test update functionality

### Transaction History Bug (Android)
- [ ] Investigate "All" tab rendering issue on Android
- [ ] Check for platform-specific layout constraints
- [ ] Fix data rendering for Android
- [ ] Verify Web still works
