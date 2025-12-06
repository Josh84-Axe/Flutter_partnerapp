# Payment Method Integration

- [x] Analyze current state of Payment Method integration
- [x] Implement/Update Payment Method Models (Existing)
- [x] Implement/Update Wallet Repository (Existing)
- [x] Implement/Update Add Payout Method Screen (Existing)
- [x] Analyze current state of Payment Method integration
- [x] Implement/Update Payment Method Models (Existing)
- [x] Implement/Update Wallet Repository (Existing)
- [x] Implement/Update Add Payout Method Screen (Existing)
- [x] Fix Fee Calculation in Payout Request Screen
- [x] Verify Payout Request Flow
- [x] Verify Add Payment Method Flow
- [x] Investigate/Fix Subscription Widget Visibility
- [x] Investigate/Fix Active Session Quick Action Navigation
- [x] Verify Subscription Expiring Countdown Indicator
- [x] Investigate/Fix "Invalid Credential" Login Error on Deployment
- [x] Configure Consistent Cloudflare Deployment Link

## Internet Plan CRUD Fixes
- [x] Fix field mapping in plan creation (data_limit, validity, shared_users)
- [x] Fix unit conversion (days to minutes for validity)
- [x] Fix profile name mapping
- [x] Fix edit form pre-population
# Payment Method Integration

- [x] Analyze current state of Payment Method integration
- [x] Implement/Update Payment Method Models (Existing)
- [x] Implement/Update Wallet Repository (Existing)
- [x] Implement/Update Add Payout Method Screen (Existing)
- [x] Analyze current state of Payment Method integration
- [x] Implement/Update Payment Method Models (Existing)
- [x] Implement/Update Wallet Repository (Existing)
- [x] Implement/Update Add Payout Method Screen (Existing)
- [x] Fix Fee Calculation in Payout Request Screen
- [x] Verify Payout Request Flow
- [x] Verify Add Payment Method Flow
- [x] Investigate/Fix Subscription Widget Visibility
- [x] Investigate/Fix Active Session Quick Action Navigation
- [x] Verify Subscription Expiring Countdown Indicator
- [x] Investigate/Fix "Invalid Credential" Login Error on Deployment
- [x] Configure Consistent Cloudflare Deployment Link

## Internet Plan CRUD Fixes
- [x] Fix field mapping in plan creation (data_limit, validity, shared_users)
- [x] Fix unit conversion (days to minutes for validity)
- [x] Fix profile name mapping
- [x] Fix edit form pre-population
- [x] Fix repository consistency (use PlanRepository everywhere)
- [ ] Test plan creation
- [ ] Test plan editing
- [ ] Test plan deletion

## Codebase Audit & Fixes
- [x] Fix Hardcoded Currency Symbol in Revenue Breakdown (and other screens) `[/]`
    - [x] Update `revenue_breakdown_screen.dart` to use `CurrencyUtils`
    - [x] Fix hardcoded symbols in `subscription_management_screen.dart`
    - [x] Fix hardcoded symbols in `transaction_payment_history_screen.dart`
    - [x] Fix hardcoded symbols in `notification_router_screen.dart`
    - [x] Fix hardcoded symbols in `additional_device_config_screen.dart`
- [x] Audit and fix localization (English/French) across all screens `[/]`
    - [x] Audit `DashboardScreen` and fix hardcoded strings
    - [x] Audit `LoginScreen` and `AuthRepository` (error messages)
    - [x] Audit `CreateEditInternetPlanScreen`
    - [x] Audit `HotspotUserScreen` and `HotspotProfileModel`
    - [x] Added missing keys to `en.json` and `fr.json`
- [x] Audit core functionality (Login, Dashboard, Plans, Users, Payouts) `[/]`
    - [x] Verified `AppState.loadDashboardData` logic
    - [x] Verified `AuthRepository` error handling
    - [x] Verified `HotspotUsersManagementScreen` logic
    - [x] Verified `CreateEditInternetPlanScreen` logic
