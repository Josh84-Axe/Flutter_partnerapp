# Screen-Repository Wiring Plan

**Date:** November 13, 2025  
**Status:** Analysis Complete - Ready for Implementation

## Existing Screens Analysis (69 screens found)

### ✅ Screens That Exist and Need Repository Wiring

#### 1. **Users/Customers Management**
- **Screen:** `lib/screens/users_screen.dart`
- **Current:** Uses `appState.loadUsers()` (mock data)
- **Wire to:** `CustomerRepository.fetchCustomers()` (paginated)
- **Additional methods needed:**
  - Block/unblock customer
  - View customer details
  - View customer data usage
  - View customer transactions

- **Screen:** `lib/screens/user_details_screen.dart`
- **Wire to:** 
  - `CustomerRepository.getCustomerDataUsage()`
  - `CustomerRepository.getCustomerTransactions()`

#### 2. **Hotspot Profiles Management**
- **Screen:** `lib/screens/hotspot_user_screen.dart`
- **Current:** Uses `appState.hotspotProfiles` (mock data)
- **Wire to:** `HotspotRepository.fetchProfiles()`

- **Screen:** `lib/screens/profiles_screen.dart`
- **Current:** Uses `appState.loadProfiles()` (mock data)
- **Wire to:** `HotspotRepository.fetchProfiles()`

- **Screen:** `lib/screens/create_edit_user_profile_screen.dart`
- **Current:** Saves to mock data
- **Wire to:** 
  - `HotspotRepository.createProfile()` (create)
  - `HotspotRepository.updateProfile()` (edit)
  - `HotspotRepository.deleteProfile()` (delete)

#### 3. **Internet Plans Management**
- **Screen:** `lib/screens/internet_plan_screen.dart`
- **Current:** Uses mock data
- **Wire to:** `PlanRepository.fetchPlans()`

- **Screen:** `lib/screens/plans_screen.dart`
- **Current:** Uses mock data
- **Wire to:** `PlanRepository.fetchPlans()`

- **Screen:** `lib/screens/create_edit_internet_plan_screen.dart`
- **Current:** Uses `appState.createPlan()` (mock)
- **Wire to:**
  - `PlanRepository.createPlan()` (create)
  - `PlanRepository.updatePlan()` (edit)
  - `PlanRepository.deletePlan()` (delete)

#### 4. **Router Management**
- **Screen:** `lib/screens/add_router_screen.dart`
- **Wire to:** `RouterRepository.addRouter()`

- **Screen:** `lib/screens/router_details_screen.dart`
- **Wire to:** 
  - `RouterRepository.fetchRouterDetails()`
  - `RouterRepository.fetchActiveUsers()`
  - `RouterRepository.fetchRouterResources()`

- **Screen:** `lib/screens/router_settings_screen.dart`
- **Wire to:** 
  - `RouterRepository.updateRouter()`
  - `RouterRepository.rebootRouter()`
  - `RouterRepository.restartHotspot()`

#### 5. **Wallet & Transactions**
- **Screen:** `lib/screens/wallet_overview_screen.dart`
- **Current:** Uses mock data
- **Wire to:** 
  - `WalletRepository.fetchBalance()`
  - `WalletRepository.fetchTransactions()`

- **Screen:** `lib/screens/transactions_screen.dart`
- **Current:** Uses mock data
- **Wire to:** 
  - `TransactionRepository.fetchTransactions()`
  - `TransactionRepository.fetchAdditionalDeviceTransactions()`
  - `TransactionRepository.fetchAssignedPlanTransactions()`

- **Screen:** `lib/screens/payout_request_screen.dart`
- **Wire to:** `WalletRepository.createWithdrawal()`

#### 6. **Dashboard**
- **Screen:** `lib/screens/dashboard_screen.dart`
- **Current:** Uses `appState.fetchDashboard()` (may already be wired)
- **Verify:** Check if using `PartnerRepository.fetchDashboard()`

#### 7. **Authentication**
- **Screen:** `lib/screens/registration_screen.dart`
- **Current:** Uses `AuthRepository.register()` (already wired)
- **Add:** Email verification flow after registration

- **Screen:** `lib/screens/otp_validation_screen.dart`
- **Wire to:** `AuthRepository.confirmRegistration()`

- **Screen:** `lib/screens/forgot_password_screen.dart`
- **Wire to:** `PasswordRepository.requestPasswordResetOtp()`

- **Screen:** `lib/screens/set_new_password_screen.dart`
- **Wire to:** `PasswordRepository.resetPassword()`

#### 8. **Configuration Screens**
- **Screen:** `lib/screens/config/rate_limit_config_screen.dart`
- **Wire to:** `PlanConfigRepository` (rate limit methods)

- **Screen:** `lib/screens/config/data_limit_config_screen.dart`
- **Wire to:** `PlanConfigRepository` (data limit methods)

- **Screen:** `lib/screens/config/shared_user_config_screen.dart`
- **Wire to:** `PlanConfigRepository` (shared users methods)

- **Screen:** `lib/screens/config/plan_validity_config_screen.dart`
- **Wire to:** `PlanConfigRepository` (validity methods)

- **Screen:** `lib/screens/config/idle_time_config_screen.dart`
- **Wire to:** `PlanConfigRepository` (idle timeout methods)

- **Screen:** `lib/screens/config/additional_device_config_screen.dart`
- **Wire to:** `AdditionalDeviceRepository`

#### 9. **Security & Password**
- **Screen:** `lib/screens/security/password_and_2fa_screen.dart`
- **Wire to:** `PasswordRepository.changePassword()`

#### 10. **Roles & Permissions**
- **Screen:** `lib/screens/assign_role_screen.dart`
- **Wire to:** `CollaboratorRepository.assignRole()`

- **Screen:** `lib/screens/create_role_screen.dart`
- **Wire to:** `CollaboratorRepository.createRole()`

- **Screen:** `lib/screens/role_permission_screen.dart`
- **Wire to:** `CollaboratorRepository.fetchRoles()`

- **Screen:** `lib/screens/user_role_screen.dart`
- **Wire to:** `CollaboratorRepository.fetchCollaborators()`

### ❌ Missing Screens (Need to Create)

#### Critical Missing Screens:
1. **Email Verification Screen** - After registration, verify email with OTP
2. **Session Management Screen** - View active sessions, disconnect sessions
3. **Payment Methods Screen** - Manage payment methods (list, create, edit, delete)
4. **Hotspot Users Screen** - Create and manage hotspot users (different from profiles)
5. **Plan Assignment Screen** - Assign plans to customers
6. **Assigned Plans List Screen** - View all assigned plans
7. **Collaborators Management Screen** - Manage team members

## Implementation Priority

### Phase 1: Critical Flows (High Priority)
1. ✅ Wire `users_screen.dart` to `CustomerRepository`
2. ✅ Wire `hotspot_user_screen.dart` to `HotspotRepository`
3. ✅ Wire `create_edit_user_profile_screen.dart` to `HotspotRepository`
4. ✅ Wire `create_edit_internet_plan_screen.dart` to `PlanRepository`
5. ✅ Wire `add_router_screen.dart` to `RouterRepository`
6. ✅ Create Email Verification Screen
7. ✅ Create Hotspot Users Management Screen
8. ✅ Create Plan Assignment Screen

### Phase 2: Important Features (Medium Priority)
1. Wire `wallet_overview_screen.dart` to `WalletRepository`
2. Wire `transactions_screen.dart` to `TransactionRepository`
3. Wire `router_details_screen.dart` to `RouterRepository`
4. Wire configuration screens to `PlanConfigRepository`
5. Create Session Management Screen
6. Create Payment Methods Screen

### Phase 3: Additional Features (Lower Priority)
1. Wire role/permission screens to `CollaboratorRepository`
2. Wire password screens to `PasswordRepository`
3. Create Collaborators Management Screen
4. Create Assigned Plans List Screen

## Next Steps

1. Start with Phase 1 - Wire critical screens to repositories
2. Test each wiring to ensure API calls work correctly
3. Create missing critical screens using Stitch (Material 3 + French/English localization)
4. Build and test APK
5. Move to Phase 2 and Phase 3

## Notes

- All screens need to handle loading states
- All screens need to handle error states
- All screens need to show appropriate messages for empty states
- All API calls should use the nested response structure: `{statusCode, error, message, data, exception}`
- French and English localization must be maintained for all new/modified screens
