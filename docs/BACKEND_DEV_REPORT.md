# Backend Development Report - API Endpoint Status

**Date:** November 14, 2025  
**Prepared by:** Devin AI (Flutter Team)  
**For:** Backend Development Team  
**Purpose:** Clarify endpoint implementation status and responsibilities

---

## Executive Summary

After comprehensive testing of 71 API endpoints under `/partner/`, we identified:
- **27 endpoints working correctly** (38%)
- **5 endpoints partially working** (7%) - Need parameter documentation or minor backend fixes
- **39 endpoints not implemented** (55%) - Need backend development

This report focuses on the **5 partial** and **21 critical not-implemented** endpoints that require backend team attention.

---

## Part 1: Partially Implemented Endpoints (5 Total)

These endpoints exist on the backend and respond to requests, but require either:
- Better parameter documentation
- Minor backend fixes
- Flutter-side parameter adjustments

### 1. POST `/partner/payment-methods/create/`
**Status:** ⚠️ PARTIAL - Validation Error  
**Priority:** HIGH  
**Responsibility:** Backend Team (Documentation)

**Current Behavior:**
```bash
curl -X POST https://api.tiknetafrica.com/v1/partner/payment-methods/create/ \
  -H 'Authorization: Bearer $TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{"type":"card","details":"Test Card"}'
```

**Response:**
```json
{
    "statusCode": 400,
    "error": true,
    "message": "Validation error.",
    "data": {
        "name": ["This field is required."],
        "numbers": ["This field is required."]
    },
    "exception": ""
}
```

**Issue:** Backend expects `name` and `numbers` fields, but API documentation doesn't specify this.

**Required Action (Backend Team):**
- [ ] Update API documentation to specify required fields: `name` (string), `numbers` (string)
- [ ] Provide example request showing correct field structure
- [ ] Clarify what `numbers` field should contain (card number? phone number?)

**Flutter Team Action:**
- [ ] Once backend provides documentation, update Flutter PaymentMethodRepository to use correct fields

---

### 2. POST `/partner/collaborators/create/`
**Status:** ⚠️ PARTIAL - Validation Error  
**Priority:** HIGH  
**Responsibility:** Backend Team (Documentation)

**Current Behavior:**
```bash
curl -X POST https://api.tiknetafrica.com/v1/partner/collaborators/create/ \
  -H 'Authorization: Bearer $TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{"email":"collab@example.com","role":"admin"}'
```

**Response:**
```json
{
    "first_name": ["This field is required."]
}
```

**Issue:** Backend requires `first_name` field, but API documentation doesn't specify this.

**Required Action (Backend Team):**
- [ ] Update API documentation to specify all required fields: `first_name`, `email`, `role`
- [ ] Provide example request showing correct field structure
- [ ] Document available role values (admin, viewer, manager, etc.)

**Flutter Team Action:**
- [x] Flutter CollaboratorRepository already includes `first_name` field - no changes needed

---

### 3. POST `/partner/roles/create/`
**Status:** ⚠️ PARTIAL - Validation Error  
**Priority:** MEDIUM  
**Responsibility:** Backend Team (Documentation)

**Current Behavior:**
```bash
curl -X POST https://api.tiknetafrica.com/v1/partner/roles/create/ \
  -H 'Authorization: Bearer $TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{"name":"manager","permissions":["view_customers","manage_plans"]}'
```

**Response:**
```json
{
    "statusCode": 400,
    "error": true,
    "message": "Validation error.",
    "data": {
        "permissions": ["Incorrect type. Expected pk value, received str."]
    },
    "exception": ""
}
```

**Issue:** Backend expects `permissions` as array of IDs (integers), not strings.

**Required Action (Backend Team):**
- [ ] Update API documentation to specify `permissions` field expects array of permission IDs (integers)
- [ ] Provide GET `/partner/permissions/list/` endpoint to retrieve available permission IDs
- [ ] Provide example request showing correct format: `{"name":"manager","permissions":[1,2,3]}`

**Flutter Team Action:**
- [ ] Once backend provides permissions list endpoint, update Flutter to fetch and use permission IDs

---

### 4. POST `/partner/additional-devices/create/`
**Status:** ⚠️ PARTIAL - Validation Error  
**Priority:** MEDIUM  
**Responsibility:** Backend Team (Documentation)

**Current Behavior:**
```bash
curl -X POST https://api.tiknetafrica.com/v1/partner/additional-devices/create/ \
  -H 'Authorization: Bearer $TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{"mac_address":"AA:BB:CC:DD:EE:FF","customer":"testuser"}'
```

**Response:**
```json
{
    "statusCode": 400,
    "error": true,
    "message": "Validation error.",
    "data": {
        "value": ["This field is required."],
        "price": ["This field is required."]
    },
    "exception": ""
}
```

**Issue:** Backend expects `value` and `price` fields, but API documentation doesn't specify this.

**Required Action (Backend Team):**
- [ ] Update API documentation to specify all required fields: `value`, `price`, `mac_address`, `customer`
- [ ] Clarify what `value` field represents (device type? device name?)
- [ ] Provide example request showing correct field structure

**Flutter Team Action:**
- [ ] Once backend provides documentation, update Flutter AdditionalDeviceRepository to use correct fields

---

### 5. POST `/partner/refresh/token/`
**Status:** ⚠️ PARTIAL - Invalid Token  
**Priority:** HIGH  
**Responsibility:** Flutter Team (Already Implemented Correctly)

**Current Behavior:**
```bash
curl -X POST https://api.tiknetafrica.com/v1/partner/refresh/token/ \
  -H 'Content-Type: application/json' \
  -d '{"refresh":"test_refresh_token"}'
```

**Response:**
```json
{
    "detail": "Token is invalid or expired",
    "code": "token_not_valid"
}
```

**Issue:** Test token is invalid (expected behavior).

**Required Action:**
- [x] **NO ACTION NEEDED** - Endpoint works correctly. Flutter AuthRepository already implements token refresh properly.

---

## Part 2: Not Implemented Endpoints (21 Critical)

These endpoints are documented in Swagger but return no response or 404 when called. Backend team needs to implement them.

### Category 1: Session Management (2 endpoints)

#### 1. GET `/partner/sessions/list/`
**Priority:** HIGH  
**Purpose:** List all active sessions for the partner account  
**Expected Response:** Array of session objects with device info, IP address, last active time  
**Flutter Status:** ❌ Not implemented (waiting for backend)

**Required Action (Backend Team):**
- [ ] Implement endpoint to return list of active sessions
- [ ] Include session details: device type, IP address, location, last active timestamp
- [ ] Support pagination if session list can be large

---

#### 2. DELETE `/partner/sessions/{id}/delete/`
**Priority:** HIGH  
**Purpose:** Delete/logout a specific session  
**Expected Response:** Success message confirming session deletion  
**Flutter Status:** ❌ Not implemented (waiting for backend)

**Required Action (Backend Team):**
- [ ] Implement endpoint to delete specific session by ID
- [ ] Invalidate session token on deletion
- [ ] Return appropriate error if session doesn't exist or doesn't belong to partner

---

### Category 2: Password Management (4 endpoints)

#### 3. POST `/partner/password-reset/`
**Priority:** HIGH  
**Purpose:** Request password reset (send OTP to email)  
**Expected Response:** Success message confirming OTP sent  
**Flutter Status:** ✅ Implemented (waiting for backend)

**Required Action (Backend Team):**
- [ ] Implement endpoint to send password reset OTP to email
- [ ] Generate and store OTP with expiration time
- [ ] Send email with OTP code

---

#### 4. POST `/partner/password-reset-confirm/`
**Priority:** HIGH  
**Purpose:** Confirm password reset with OTP and new password  
**Expected Response:** Success message confirming password changed  
**Flutter Status:** ✅ Implemented (waiting for backend)

**Required Action (Backend Team):**
- [ ] Implement endpoint to verify OTP and update password
- [ ] Validate OTP hasn't expired
- [ ] Hash and store new password
- [ ] Invalidate OTP after successful reset

---

#### 5. POST `/partner/password-change/`
**Priority:** HIGH  
**Purpose:** Change password for authenticated user  
**Expected Response:** Success message confirming password changed  
**Flutter Status:** ✅ Implemented (waiting for backend)

**Required Action (Backend Team):**
- [ ] Implement endpoint to change password (requires old password verification)
- [ ] Verify old password is correct
- [ ] Hash and store new password
- [ ] Optionally invalidate all other sessions

---

#### 6. POST `/partner/resend-password-reset-otp/`
**Priority:** MEDIUM  
**Purpose:** Resend password reset OTP  
**Expected Response:** Success message confirming OTP resent  
**Flutter Status:** ❌ Not implemented (waiting for backend)

**Required Action (Backend Team):**
- [ ] Implement endpoint to resend password reset OTP
- [ ] Invalidate previous OTP
- [ ] Generate and send new OTP

---

### Category 3: Payment Methods (3 endpoints)

#### 7. GET `/partner/payment-methods/list/`
**Priority:** HIGH  
**Purpose:** List all payment methods for partner  
**Expected Response:** Array of payment method objects  
**Flutter Status:** ❌ Not implemented (waiting for backend)

**Required Action (Backend Team):**
- [ ] Implement endpoint to return list of payment methods
- [ ] Include payment method details: name, numbers (masked), type, is_default
- [ ] Support pagination if needed

---

#### 8. PUT `/partner/payment-methods/{id}/update/`
**Priority:** MEDIUM  
**Purpose:** Update payment method details  
**Expected Response:** Updated payment method object  
**Flutter Status:** ❌ Not implemented (waiting for backend)

**Required Action (Backend Team):**
- [ ] Implement endpoint to update payment method
- [ ] Validate payment method belongs to partner
- [ ] Return updated payment method object

---

#### 9. DELETE `/partner/payment-methods/{id}/delete/`
**Priority:** MEDIUM  
**Purpose:** Delete payment method  
**Expected Response:** Success message confirming deletion  
**Flutter Status:** ❌ Not implemented (waiting for backend)

**Required Action (Backend Team):**
- [ ] Implement endpoint to delete payment method
- [ ] Validate payment method belongs to partner
- [ ] Prevent deletion of default payment method (or reassign default)

---

### Category 4: Collaborators Management (3 endpoints)

#### 10. GET `/partner/collaborators/list/`
**Priority:** HIGH  
**Purpose:** List all collaborators for partner account  
**Expected Response:** Array of collaborator objects  
**Flutter Status:** ✅ Implemented (waiting for backend)

**Required Action (Backend Team):**
- [ ] Implement endpoint to return list of collaborators
- [ ] Include collaborator details: first_name, last_name, email, role, status
- [ ] Support pagination if needed

---

#### 11. PUT `/partner/collaborators/{id}/update/`
**Priority:** MEDIUM  
**Purpose:** Update collaborator details (role, permissions)  
**Expected Response:** Updated collaborator object  
**Flutter Status:** ✅ Implemented (waiting for backend)

**Required Action (Backend Team):**
- [ ] Implement endpoint to update collaborator
- [ ] Validate collaborator belongs to partner
- [ ] Return updated collaborator object

---

#### 12. POST `/partner/collaborators/{id}/resend-invitation/`
**Priority:** MEDIUM  
**Purpose:** Resend invitation email to collaborator  
**Expected Response:** Success message confirming invitation resent  
**Flutter Status:** ❌ Not implemented (waiting for backend)

**Required Action (Backend Team):**
- [ ] Implement endpoint to resend collaborator invitation
- [ ] Generate new invitation token
- [ ] Send invitation email

---

### Category 5: Plan Configuration Resources (5 endpoints)

#### 13. GET `/partner/plan-config/validity-units/`
**Priority:** MEDIUM  
**Purpose:** Get available validity units for plans (minutes, hours, days, weeks, months)  
**Expected Response:** Array of validity unit options  
**Flutter Status:** ❌ Not implemented (waiting for backend)

**Required Action (Backend Team):**
- [ ] Implement endpoint to return validity unit options
- [ ] Return array of objects: `[{"value":"minutes","label":"Minutes"},{"value":"hours","label":"Hours"},...]`

---

#### 14. GET `/partner/plan-config/data-limits/`
**Priority:** MEDIUM  
**Purpose:** Get available data limit options for plans  
**Expected Response:** Array of data limit options  
**Flutter Status:** ❌ Not implemented (waiting for backend)

**Required Action (Backend Team):**
- [ ] Implement endpoint to return data limit options
- [ ] Return array of objects with value and label

---

#### 15. GET `/partner/plan-config/shared-users/`
**Priority:** MEDIUM  
**Purpose:** Get available shared user options for plans  
**Expected Response:** Array of shared user options  
**Flutter Status:** ❌ Not implemented (waiting for backend)

**Required Action (Backend Team):**
- [ ] Implement endpoint to return shared user options
- [ ] Return array of objects with value and label

---

#### 16. GET `/partner/plan-config/speed-limits/`
**Priority:** MEDIUM  
**Purpose:** Get available speed limit options for plans  
**Expected Response:** Array of speed limit options  
**Flutter Status:** ❌ Not implemented (waiting for backend)

**Required Action (Backend Team):**
- [ ] Implement endpoint to return speed limit options
- [ ] Return array of objects with value and label

---

#### 17. GET `/partner/plan-config/rate-limits/`
**Priority:** MEDIUM  
**Purpose:** Get available rate limit options for plans  
**Expected Response:** Array of rate limit options  
**Flutter Status:** ❌ Not implemented (waiting for backend)

**Required Action (Backend Team):**
- [ ] Implement endpoint to return rate limit options
- [ ] Return array of objects with value and label

---

### Category 6: Additional Devices (3 endpoints)

#### 18. GET `/partner/additional-devices/list/`
**Priority:** MEDIUM  
**Purpose:** List all additional devices for partner  
**Expected Response:** Array of additional device objects  
**Flutter Status:** ✅ Implemented (waiting for backend)

**Required Action (Backend Team):**
- [ ] Implement endpoint to return list of additional devices
- [ ] Include device details: mac_address, value, price, customer, status
- [ ] Support pagination if needed

---

#### 19. PUT `/partner/additional-devices/{id}/update/`
**Priority:** MEDIUM  
**Purpose:** Update additional device details  
**Expected Response:** Updated device object  
**Flutter Status:** ✅ Implemented (waiting for backend)

**Required Action (Backend Team):**
- [ ] Implement endpoint to update additional device
- [ ] Validate device belongs to partner
- [ ] Return updated device object

---

#### 20. GET `/partner/additional-devices/{id}/details/`
**Priority:** MEDIUM  
**Purpose:** Get details of specific additional device  
**Expected Response:** Device object with full details  
**Flutter Status:** ❌ Not implemented (waiting for backend)

**Required Action (Backend Team):**
- [ ] Implement endpoint to return device details
- [ ] Include all device information
- [ ] Return 404 if device doesn't exist or doesn't belong to partner

---

### Category 7: Permissions (1 endpoint)

#### 21. GET `/partner/permissions/list/`
**Priority:** MEDIUM  
**Purpose:** List all available permissions for role creation  
**Expected Response:** Array of permission objects with ID and name  
**Flutter Status:** ❌ Not implemented (waiting for backend)

**Required Action (Backend Team):**
- [ ] Implement endpoint to return list of available permissions
- [ ] Return array of objects: `[{"id":1,"name":"view_customers","description":"View customer list"},...]`
- [ ] This is required for POST `/partner/roles/create/` to work properly

---

## Part 3: Lower Priority Not Implemented Endpoints (18 Total)

These endpoints are documented but not critical for core functionality:

### Analytics & Reporting (5 endpoints)
- GET `/partner/analytics/revenue/` - Revenue analytics
- GET `/partner/analytics/customers/` - Customer analytics
- GET `/partner/analytics/plans/` - Plan analytics
- GET `/partner/analytics/routers/` - Router analytics
- GET `/partner/reports/monthly/` - Monthly reports

### Transaction Management (5 endpoints)
- GET `/partner/transactions/filter/` - Filter transactions
- GET `/partner/transactions/{id}/details/` - Transaction details
- POST `/partner/transactions/export/` - Export transactions
- GET `/partner/wallet/history/` - Wallet transaction history
- POST `/partner/wallet/withdraw/` - Withdraw from wallet

### Role Management (3 endpoints)
- GET `/partner/roles/list/` - List roles
- PUT `/partner/roles/{id}/update/` - Update role
- DELETE `/partner/roles/{id}/delete/` - Delete role

### Notifications & Settings (5 endpoints)
- GET `/partner/notifications/list/` - List notifications
- PUT `/partner/notifications/{id}/mark-read/` - Mark notification as read
- GET `/partner/settings/` - Get partner settings
- PUT `/partner/settings/update/` - Update partner settings
- GET `/partner/support/tickets/` - List support tickets

---

## Summary & Recommendations

### Immediate Actions Required (Backend Team)

**High Priority (7 endpoints):**
1. Implement session management endpoints (2)
2. Implement password management endpoints (4)
3. Provide documentation for partial endpoints (1 - payment methods create)

**Medium Priority (14 endpoints):**
1. Implement collaborators management endpoints (3)
2. Implement plan configuration resource endpoints (5)
3. Implement additional devices endpoints (3)
4. Implement payment methods endpoints (2)
5. Implement permissions list endpoint (1)

### Immediate Actions Required (Flutter Team)

**High Priority:**
1. ✅ Already fixed: `verifyEmailOtp` now uses `code` field instead of `otp`
2. Wait for backend documentation on partial endpoints before updating repositories

**Medium Priority:**
1. Once backend implements missing endpoints, add corresponding Flutter repository methods

### Timeline Recommendation

**Phase 1 (Week 1-2):** Implement 7 high priority endpoints
- Session management (2)
- Password management (4)
- Document partial endpoints (1)

**Phase 2 (Week 3-4):** Implement 14 medium priority endpoints
- Collaborators management (3)
- Plan configuration resources (5)
- Additional devices (3)
- Payment methods (2)
- Permissions list (1)

**Phase 3 (Week 5-6):** Implement 18 lower priority endpoints
- Analytics & reporting (5)
- Transaction management (5)
- Role management (3)
- Notifications & settings (5)

---

## Contact & Questions

**Flutter Team Lead:** Devin AI  
**Backend Team Lead:** [To be filled]  
**Project Manager:** [To be filled]

For questions or clarifications on this report, please contact the Flutter team.

---

**Report Generated:** November 14, 2025  
**Next Review:** After Phase 1 completion (2 weeks)
