# Task: Refactor Subscription & Router Management

- [x] Refactor `SubscriptionManagementScreen` (Fix duplicate class) <!-- id: 0 -->
- [x] Implement `purchaseSubscription` in `PartnerRepository` (Endpoint: `/partner/purchase-subscription-plan/`) <!-- id: 1 -->
- [x] Update `RouterRepository` endpoints <!-- id: 5 -->
    - [x] `fetchRouters` -> `/partner/routers/list/`
    - [x] `addRouter` -> `/partner/routers-add/`
    - [x] `deleteRouter` -> `/partner/routers/{id}/delete/`
    - [x] `getRouterDetails` -> `/partner/routers/{slug}/details/`
    - [x] `updateRouter` -> `/partner/routers/{slug}/update/`
    - [x] Add `rebootRouter`, `restartHotspot`, `getRouterResources`, `getActiveUsers`
- [x] Update `SessionRepository` endpoints <!-- id: 6 -->
    - [x] `fetchActiveSessions` -> `/partner/sessions/active/`
- [x] Integrate real data into Subscription UI <!-- id: 3 -->
- [x] Verify changes <!-- id: 4 -->
- [x] Refactor Static Configuration Lists <!-- id: 7 -->
    - [x] Update `AppState` to load all config lists (Rate, Validity, Idle, Shared Users) <!-- id: 8 -->
    - [x] Refactor `CreateEditInternetPlanScreen` to use `AppState` <!-- id: 9 -->
    - [x] Refactor `CreateEditUserProfileScreen` to use `AppState` <!-- id: 10 -->
    - [x] Refactor `PlansScreen` to use `AppState` <!-- id: 11 -->
    - [x] Remove `HotspotConfigurationService` static lists <!-- id: 12 -->

- [x] Connect Hotspot Users <!-- id: 13 -->
    - [x] Update `AppState` to manage Hotspot Users <!-- id: 14 -->
    - [x] Refactor `HotspotUsersManagementScreen` to use `AppState` <!-- id: 15 -->
- [x] Implement Email Verification <!-- id: 16 -->
    - [x] Update `AuthRepository` with verification methods <!-- id: 17 -->
    - [x] Refactor `EmailVerificationScreen` to use `AuthRepository` <!-- id: 18 -->

