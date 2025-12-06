# Implementation Plan - API Refactoring

Refactor the codebase to match the API endpoints defined in the Swagger documentation, addressing the discrepancies found during the API audit.

## User Review Required
> [!WARNING]
> The Swagger documentation uses the spelling `withdrawls` instead of `withdrawals`. The code will be updated to match this spelling to ensure API compatibility, even though it is a typo.

## Proposed Changes

### Repositories

#### [MODIFY] [additional_device_repository.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/repositories/additional_device_repository.dart)
- Change `GET /partner/additional-devices` to `GET /partner/additional-devices/list`
- Verify `PATCH` vs `PUT` for updates if applicable.

#### [MODIFY] [collaborator_repository.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/repositories/collaborator_repository.dart)
- Change `GET /partner/collaborators` to `GET /partner/collaborators/list`

#### [MODIFY] [customer_repository.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/repositories/customer_repository.dart)
- Change `GET /partner/customers/all/list` to `GET /partner/customers/list` (or `paginate-list` depending on usage, likely `list` for all).
- Change `POST /partner/customers` to match Swagger (likely `POST /customer/register` or check if there is a partner-facing create). *Self-correction: Swagger has `POST /customer/register` but no `POST /partner/customers`. Need to verify if `POST /customer/register` is the intended replacement or if `POST /partner/customers` is missing from Swagger.*
- Change `PUT /partner/customers/{id}` to `PATCH` or `PUT` as per Swagger.

#### [MODIFY] [plan_config_repository.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/repositories/plan_config_repository.dart)
- Change `GET /partner/data-limit` to `GET /partner/data-limit/list`
- Change `GET /partner/idle-timeout` to `GET /partner/idle-timeout/list`
- Change `GET /partner/rate-limit` to `GET /partner/rate-limit/list`
- Change `GET /partner/validity` to `GET /partner/validity/list`
- Change `GET /partner/shared-users` to `GET /partner/shared-users/list`

#### [MODIFY] [hotspot_repository.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/repositories/hotspot_repository.dart)
- Change `GET /partner/hotspot/users/list` to `GET /partner/hotspot/users/paginate-list` (or check if `list` exists).
- Check `GET /partner/hotspot/profiles/list` vs `paginate-list`.

#### [MODIFY] [payment_method_repository.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/repositories/payment_method_repository.dart)
- Change `GET /partner/payment-methods` to `GET /partner/payment-methods/list`

#### [MODIFY] [partner_repository.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/repositories/partner_repository.dart)
- Change `GET /partner/roles` to `GET /partner/roles/list`
- Remove `login` method if it duplicates `AuthRepository`, or update endpoint to `/partner/login` (Swagger has `POST /partner/login` as a parameter? No, `POST /auth/login` is missing, `POST /partner/login` is in parameters? Wait, report says `PARAMETERS /partner/login`. This usually means it's a path. Let's check `AuthRepository` usage).
- Check `GET /partner/countries`, `GET /partner/currency`, `GET /partner/currency-code`. These are "Extra". Need to find their Swagger equivalents or confirm they are missing from Swagger.

#### [MODIFY] [wallet_repository.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/repositories/wallet_repository.dart)
- Change `GET /partner/withdrawals` to `GET /partner/wallet/withdrawls`
- Change `POST /partner/withdrawals/create` to `POST /partner/wallet/withdrawls/create`
- Change `GET /partner/transactions` to `GET /partner/wallet/transactions` (if that's the match).

#### [MODIFY] [transaction_repository.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/repositories/transaction_repository.dart)
- Verify `GET /partner/transactions` usage here vs `WalletRepository`.

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure no syntax errors.
- Re-run `compare_api.dart` to verify that the "Missing" list decreases and "Extra" list decreases (though some might remain if Swagger is incomplete).

### Manual Verification
- Since I cannot run the app against the real API to verify functionality (I don't have the full environment/device), I will rely on the Swagger spec as the source of truth.
