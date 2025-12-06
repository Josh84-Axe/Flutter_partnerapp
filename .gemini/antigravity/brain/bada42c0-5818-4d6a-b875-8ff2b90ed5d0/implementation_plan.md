# Refactoring & Real API Integration Plan

## Goal
Remove all hardcoded currency symbols, mock data, and static data lists. Enable full real API integration for partner account data.

## User Review Required
> [!IMPORTANT]
> This refactoring will disable all mock data generation. Ensure the backend API is fully functional and accessible from the testing environment.

## Proposed Changes

### 1. Currency Refactoring
#### [MODIFY] [currency_utils.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/utils/currency_utils.dart)
- Remove hardcoded country-to-currency maps.
- Implement `getCurrencySymbol(String currencyCode)` to use standard formatting or fetch from API.

#### [MODIFY] [currency_helper.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/utils/currency_helper.dart)
- Remove hardcoded maps.
- Update methods to rely on dynamic data.

#### [MODIFY] [metric_card.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/widgets/metric_card.dart)
- Remove hardcoded `$` fallback.
- Accept currency symbol as a parameter or fetch from `AppState`.

### 2. Remove Mock Data
#### [MODIFY] [auth_service.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/services/auth_service.dart)
- Remove `mock_jwt_token` generation.
- Ensure `login` and `register` methods only return real API responses.

#### [MODIFY] [app_state.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/providers/app_state.dart)
- Remove `_useMockData` flag and toggling logic.
- Remove "FORCE REMOTE API" comments and ensure default path is always API.

#### [MODIFY] [api_config.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/services/api/api_config.dart)
- Remove `useMockData` constant.

### 3. Remove Static Data Lists
#### [MODIFY] [registration_screen.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/screens/registration_screen.dart)
- Replace `_countries` list with API call to fetch available countries.

#### [MODIFY] [partner_profile_screen.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/screens/partner_profile_screen.dart)
- Replace `_paymentMethods` with API call.

#### [MODIFY] [reporting_screen.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/screens/reporting_screen.dart)
- Fetch report types from backend.

### 4. Real API Integration
#### [MODIFY] [partner_repository.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/repositories/partner_repository.dart)
- Verify `getPartnerProfile` uses correct endpoint.

#### [MODIFY] [auth_repository.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/repositories/auth_repository.dart)
- Ensure login flow correctly parses and stores real tokens.

## Verification Plan

### Automated Tests
- Run `flutter test` to ensure no tests rely on removed mock data constants.

### Manual Verification
1. **Login:** Use `sientey@hotmail.com` / `Testing123`. Verify successful login.
2. **Dashboard:** Verify currency symbols match the partner's profile (not default `$`).
3. **Profile:** Verify payment methods load from API.
4. **Registration:** Verify country list loads from API (if endpoint available, otherwise use a package).
