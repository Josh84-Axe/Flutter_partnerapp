# Implementation Task List

## Phase 1: Configuration Fetchers ✅
- [x] Add `_validityPeriods` and `_dataLimits` fields to AppState
- [x] Add getters for `validityPeriods` and `dataLimits`
- [x] Implement `fetchValidityPeriods()` method
- [x] Implement `fetchDataLimits()` method
- [x] Update CreateEditInternetPlanScreen to use API data
- [x] Test configuration fetchers

## Phase 2: CRUD Delete Operations ✅
- [x] Implement `deletePlan()` method in AppState
- [x] Implement `updateHotspotUser()` method in AppState
- [x] Confirm `deleteHotspotProfile()` exists
- [x] Test delete operations

## Phase 3: RBAC Enforcement (In Progress)
- [x] Extend Permissions class with all permission methods
- [x] Implement RBAC in InternetPlanScreen (demo)
- [x] Implement RBAC in UsersScreen
- [ ] Implement RBAC in PayoutRequestScreen
- [ ] Implement RBAC in RolePermissionScreen
- [ ] Implement RBAC in RoutersScreen
- [ ] Implement RBAC in Configuration Screens
- [ ] Test RBAC with different user roles

## Phase 4: Email Verification Flow Testing
- [ ] Test password reset flow end-to-end
- [ ] Test OTP validation screen
- [ ] Test email verification flow
- [ ] Verify navigation and error handling

## Phase 5: Polish & Documentation
- [ ] Update implementation_plan.md
- [ ] Add code comments to new methods
- [ ] Run final flutter analyze
- [ ] Create final walkthrough document

## Phase 6: Refactoring Hardcoded Data (Current Focus)
- [ ] Refactor Currency Utils (Remove hardcoded maps)
- [ ] Refactor Currency Helper (Remove hardcoded maps)
- [ ] Update Metric Cards (Dynamic currency)
- [ ] Remove Mock Data Generation (Auth Service)
- [ ] Remove Mock Data Toggles (App State)
- [ ] Refactor Static Country Lists
- [ ] Refactor Static Payment Methods
- [ ] Refactor Static Report Types
- [ ] Verify Real API Integration
