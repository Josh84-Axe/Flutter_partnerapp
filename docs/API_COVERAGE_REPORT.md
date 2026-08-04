# API Coverage Report - Flutter Partner App

**Date:** November 13, 2025  
**Base URL:** `https://api.tiknetafrica.com/v1`  
**Testing Method:** Direct API calls with admin credentials

---

## Executive Summary

Comprehensive API testing revealed that most core endpoints are working correctly. Key findings:

✅ **Working:** Login, Dashboard, Profile, Wallet Balance, Plans, Transactions  
⚠️ **Partially Working:** Registration (wrong endpoint path and field names)  
❌ **Missing:** Dedicated routers list endpoint, dedicated customers endpoint, router creation endpoint

---

## Detailed Endpoint Testing Results

### 1. Authentication Endpoints

#### ✅ POST `/v1/partner/login/`
- **Status:** WORKING
- **Auth Required:** No
- **Request:**
  ```json
  {
    "email": "test@example.com",
    "password": "test_password"
  }
  ```
- **Response:** 200 OK
  ```json
  {
    "statusCode": 200,
    "error": false,
    "message": "Authentification réussie.",
    "data": {
      "refresh": "eyJhbGci...",
      "access": "eyJhbGci...",
      "user": {
        "id": 2712,
        "first_name": null,
        "last_name": null,
        "email": "admin@tiknetafrica.com",
        "phone": null,
        "date_joined": "2025-08-09T23:59:24Z",
        "city": null,
        "address": null,
        "country": null,
        "number_of_router": 1,
        "role": {...},
        "partner": {"is_partner": true}
      }
    },
    "exception": ""
  }
  ```
- **Notes:** Returns nested structure with tokens in `data.access` and `data.refresh`

#### ⚠️ POST `/v1/partner/register/` (CORRECT ENDPOINT)
- **Status:** PARTIALLY WORKING - Wrong endpoint in app code
- **Auth Required:** No
- **App Currently Uses:** `/v1/partner/register-init/` ❌ (returns 404)
- **Correct Endpoint:** `/v1/partner/register/` ✅
- **Request:**
  ```json
  {
    "first_name": "Devin Test",
    "email": "devintest1763051236@example.com",
    "password": "TestPass123!",
    "password2": "TestPass123!",
    "phone": "+22812345678",
    "entreprise_name": "Devin Test Business",  // NOT "business_name"
    "addresse": "123 Test Street",
    "city": "Lome",
    "country": "TG",  // ISO code, NOT full name
    "number_of_router": 5
  }
  ```
- **Response:** 200 OK
  ```json
  {
    "statusCode": 200,
    "error": false,
    "message": "A verification code has been sent to your email address.",
    "data": {
      "email": "devintest1763051236@example.com"
    },
    "exception": ""
  }
  ```
- **Critical Issues Found:**
  1. App uses wrong endpoint: `/partner/register-init/` instead of `/partner/register/`
  2. App uses wrong field name: `business_name` instead of `entreprise_name`
  3. App sends full country name instead of ISO code (e.g., "United States" instead of "US" or "TG")
  4. Registration requires email verification (no tokens returned immediately)

---

### 2. Partner Profile Endpoints

#### ✅ GET `/v1/partner/profile/`
- **Status:** WORKING
- **Auth Required:** Yes (Bearer token)
- **Response:** 200 OK
  ```json
  {
    "statusCode": 200,
    "error": false,
    "message": "Profil récupéré avec succès.",
    "data": {
      "id": 2712,
      "first_name": null,
      "last_name": null,
      "phone": null,
      "date": "2025-08-09T23:59:24Z",
      "user": 2712,
      "roles": {"name": "super_admin"},
      "partner": {"id": 2712, "name": ""},
      "country": null,
      "state": null,
      "city": null,
      "addresse": null,
      "number_of_router": 1
    },
    "exception": ""
  }
  ```
- **Notes:** Returns partner profile data successfully

#### ✅ GET `/v1/partner/dashboard/`
- **Status:** WORKING
- **Auth Required:** Yes (Bearer token)
- **Response:** 200 OK (7.8KB)
  ```json
  {
    "statusCode": 200,
    "error": false,
    "message": "Dashboard data retrieved.",
    "data": {
      "last_customers": [...],  // Array of 10 customers
      "transactions": [...],     // Array of 8 transactions
      "total_hotspot_users": 12,
      "success_transactions_total_amount": 90.0
    },
    "exception": ""
  }
  ```
- **Notes:** 
  - Returns customer list in `data.last_customers` (10 customers)
  - Returns recent transactions in `data.transactions` (8 transactions)
  - Includes total users and revenue metrics
  - **This endpoint provides customer list data, so dedicated `/partner/users/` endpoint may not be needed**

---

### 3. Wallet & Transaction Endpoints

#### ✅ GET `/v1/partner/wallet/balance/`
- **Status:** WORKING
- **Auth Required:** Yes (Bearer token)
- **Response:** 200 OK
  ```json
  {
    "statusCode": 200,
    "error": false,
    "message": "Wallet balance retrieved successfully.",
    "data": {
      "partner": "Admin",
      "wallet_balance": "470.00",
      "last_updated": "2025-11-11 23:36:06"
    },
    "exception": ""
  }
  ```
- **Notes:** Returns wallet balance with nested data structure

#### ✅ GET `/v1/partner/wallet/transactions/`
- **Status:** WORKING
- **Auth Required:** Yes (Bearer token)
- **Response:** 200 OK (4KB)
  ```json
  {
    "statusCode": 200,
    "error": false,
    "message": "...",
    "data": {
      "count": 12,
      "next": null,
      "previous": null,
      "totals": {
        "total_amount": "575.00",
        "total_revenue": "505.00",
        "total_payout": "70.00",
        "total_pending": "10.00",
        "total_success": "555.00",
        "total_failed": "10.00"
      },
      "paginate_data": [...]  // Array of 12 transactions
    },
    "exception": ""
  }
  ```
- **Notes:** 
  - Returns paginated transaction list with totals
  - Includes revenue and payout transactions
  - Supports filtering (search, status, type, period, date range)

---

### 4. Plans Endpoints

#### ✅ GET `/v1/partner/plans/`
- **Status:** WORKING
- **Auth Required:** Yes (Bearer token)
- **Response:** 200 OK (5.7KB)
  ```json
  {
    "statusCode": 200,
    "error": false,
    "message": "...",
    "data": [
      {
        "id": 37,
        "slug": "30-minutes",
        "profile": 22,
        "profile_name": "30 Minutes",
        "name": "30 Minutes",
        "price": "10.00",
        "price_display": "10 GHS",
        "validity": 7,
        "formatted_validity": "30 Minutes",
        "data_limit": null,
        "shared_users": 6,
        "description": "",
        "is_active": true,
        "is_for_roaming": false,
        "is_for_promo": true,
        "created_at": "2025-08-10T00:24:28.860572Z",
        "routers": [...]  // Array of routers for this plan
      },
      ...
    ],
    "exception": ""
  }
  ```
- **Notes:** 
  - Returns 8 active plans
  - Each plan includes associated routers array
  - **Routers are embedded in plans response (no dedicated `/partner/routers/` endpoint)**

---

### 5. Router Endpoints

#### ❌ GET `/v1/partner/routers/`
- **Status:** NOT FOUND (404)
- **Auth Required:** Yes (Bearer token)
- **Response:** 404 Not Found
- **Notes:** 
  - Dedicated routers list endpoint doesn't exist
  - App currently extracts routers from `/partner/plans/` response (workaround implemented)
  - Dashboard also provides router data in transactions

#### ❌ POST `/v1/partner/routers/add/`
- **Status:** NOT FOUND (404)
- **Auth Required:** Yes (Bearer token)
- **Request Tested:**
  ```json
  {
    "name": "Test Router",
    "ref": "TEST123",
    "ip_address": "10.0.0.100",
    "username": "admin",
    "password": "test123",
    "secret": "secret123",
    "dns_name": "test.example.com",
    "api_port": 8728,
    "coa_port": 3799
  }
  ```
- **Response:** 404 Not Found
- **Notes:** Router creation endpoint doesn't exist in production API

---

### 6. Customer/User Endpoints

#### ❌ GET `/v1/partner/users/`
- **Status:** NOT FOUND (404)
- **Auth Required:** Yes (Bearer token)
- **Response:** 404 Not Found
- **Notes:** 
  - Dedicated users/customers list endpoint doesn't exist
  - Customer data is available via `/partner/dashboard/` in `data.last_customers`

#### ❌ GET `/v1/partner/customers/`
- **Status:** NOT FOUND (404)
- **Auth Required:** Yes (Bearer token)
- **Response:** 404 Not Found
- **Notes:** Alternative endpoint also doesn't exist

---

## Summary of Issues

### Critical Issues (Must Fix)

1. **Registration Endpoint Wrong**
   - Current: `/partner/register-init/` ❌
   - Correct: `/partner/register/` ✅
   - File: `lib/repositories/auth_repository.dart:100`

2. **Registration Field Name Wrong**
   - Current: `business_name` ❌
   - Correct: `entreprise_name` ✅
   - File: `lib/repositories/auth_repository.dart:107`

3. **Country Format Wrong**
   - Current: Full name (e.g., "United States") ❌
   - Correct: ISO code (e.g., "US", "TG", "GH") ✅
   - Files: `lib/screens/registration_screen.dart`, `lib/providers/app_state.dart`

4. **Registration Returns No Tokens**
   - Registration requires email verification
   - No tokens returned immediately
   - App should show "Check your email" message instead of attempting login
   - File: `lib/repositories/auth_repository.dart:146` (returns true even without tokens)

### Missing Endpoints (Workarounds Implemented)

1. **No Dedicated Routers List Endpoint**
   - Missing: `/partner/routers/`
   - Workaround: Extract routers from `/partner/plans/` response ✅
   - File: `lib/repositories/router_repository.dart:12-46`

2. **No Router Creation Endpoint**
   - Missing: `/partner/routers/add/`
   - Impact: Cannot add new routers from mobile app
   - Recommendation: Add this endpoint to backend or disable router creation in app

3. **No Dedicated Customers List Endpoint**
   - Missing: `/partner/users/` and `/partner/customers/`
   - Workaround: Use `/partner/dashboard/` which returns `last_customers` ✅
   - Impact: Only shows last 10 customers, no pagination or filtering

---

## Recommendations

### Immediate Actions (High Priority)

1. **Fix Registration Integration**
   - Update endpoint from `/partner/register-init/` to `/partner/register/`
   - Change `business_name` to `entreprise_name`
   - Implement country ISO code mapping (full name → ISO code)
   - Update UI to show email verification message instead of auto-login

2. **Add Country ISO Code Mapping**
   - Create utility to convert country names to ISO codes
   - Support all countries in the API (TG, GH, CI, NG, etc.)
   - Update registration screen dropdown to use ISO codes

3. **Improve Registration Flow**
   - Show "Check your email for verification code" message after registration
   - Don't attempt to fetch profile immediately after registration
   - Add email verification screen if needed

### Backend Recommendations (For API Team)

1. **Add Dedicated Routers Endpoint**
   - Implement `GET /v1/partner/routers/` for listing all routers
   - Implement `POST /v1/partner/routers/add/` for router creation
   - Include pagination and filtering

2. **Add Dedicated Customers Endpoint**
   - Implement `GET /v1/partner/customers/` with pagination
   - Support filtering by status, date range, search
   - Include customer details and subscription info

3. **Standardize Response Structure**
   - All endpoints use consistent nested structure: `{statusCode, error, message, data, exception}`
   - This is good! Keep this pattern.

### Testing Recommendations

1. **Add Integration Tests**
   - Test all API endpoints with real credentials
   - Verify response structure matches expectations
   - Test error handling (401, 404, 400, etc.)

2. **Add E2E Tests**
   - Test complete registration flow
   - Test login → dashboard → transactions flow
   - Test router management flow

---

## API Endpoint Reference

### Working Endpoints ✅

| Method | Endpoint | Auth | Purpose | Status |
|--------|----------|------|---------|--------|
| POST | `/v1/partner/login/` | No | Partner login | ✅ Working |
| POST | `/v1/partner/register/` | No | Partner registration | ✅ Working |
| GET | `/v1/partner/profile/` | Yes | Get partner profile | ✅ Working |
| GET | `/v1/partner/dashboard/` | Yes | Get dashboard data | ✅ Working |
| GET | `/v1/partner/wallet/balance/` | Yes | Get wallet balance | ✅ Working |
| GET | `/v1/partner/wallet/transactions/` | Yes | Get transactions | ✅ Working |
| GET | `/v1/partner/plans/` | Yes | Get available plans | ✅ Working |

### Missing Endpoints ❌

| Method | Endpoint | Purpose | Impact |
|--------|----------|---------|--------|
| GET | `/v1/partner/routers/` | List routers | Medium (workaround exists) |
| POST | `/v1/partner/routers/add/` | Create router | High (feature unavailable) |
| GET | `/v1/partner/users/` | List customers | Medium (workaround exists) |
| GET | `/v1/partner/customers/` | List customers (alt) | Medium (workaround exists) |

### Wrong in App Code ⚠️

| Current (Wrong) | Correct | File |
|----------------|---------|------|
| `/partner/register-init/` | `/partner/register/` | `auth_repository.dart:100` |
| `business_name` | `entreprise_name` | `auth_repository.dart:107` |
| Full country name | ISO code (TG, GH, etc.) | `registration_screen.dart` |

---

## Testing Credentials

- **Email:** [Contact admin for test credentials]
- **Password:** [Contact admin for test credentials]
- **User ID:** 2712
- **Role:** super_admin
- **Wallet Balance:** 470.00 GHS

---

## Next Steps

1. ✅ Fix registration endpoint path
2. ✅ Fix registration field names
3. ✅ Add country ISO code mapping
4. ✅ Update registration flow UI
5. ✅ Test registration end-to-end
6. ✅ Build and deploy updated APK
7. ⏳ Request backend team to add missing endpoints
