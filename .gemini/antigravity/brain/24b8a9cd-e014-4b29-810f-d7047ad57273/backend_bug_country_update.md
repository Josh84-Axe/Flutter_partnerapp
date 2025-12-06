# Backend Bug Report: Partner Country Update Failure

## Issue Summary
The partner profile update endpoint returns a **500 Server Error** when attempting to update the country field.

---

## Bug Details

**Endpoint:** `PUT /partner/profile/update/`  
**Status Code:** 500 (Server Error)  
**Date Tested:** 2025-11-23  
**Tested By:** Automated test script

---

## Reproduction Steps

1. Login as partner (sientey@hotmail.com)
2. Get current profile: `GET /partner/profile/`
   - Current country: "Togo"
3. Attempt to update country: `PUT /partner/profile/update/`
   - Payload: Complete profile data with `country: "Ghana"`
4. Backend returns 500 error
5. Verify profile: Country remains "Togo"

---

## Test Results

### Request Payload
```json
{
  "first_name": "Sientey",
  "last_name": null,
  "phone": "+22892345678",
  "country": "Ghana",
  "city": "Lome",
  "addresse": "123 Test Street",
  "number_of_router": 5
}
```

### Backend Response
```
Status: 500
Body: Server Error (500)
```

### Verification
```json
{
  "statusCode": 200,
  "error": false,
  "message": "Profil récupéré avec succès.",
  "data": {
    "country": "Togo"  // ← Still unchanged
  }
}
```

---

## Impact

- **Severity:** Medium
- **Affected Feature:** Partner profile management
- **User Impact:** Partners cannot update their country setting
- **Workaround:** None available from frontend

---

## Possible Root Causes

1. **Database Constraint:** Country field may be read-only or have foreign key constraints
2. **Validation Error:** Backend may require country code (e.g., "GH") instead of country name ("Ghana")
3. **Missing Field:** Update endpoint may require additional fields not included in payload
4. **Server-Side Bug:** Exception in backend update logic

---

## Recommended Actions

### Backend Team
1. Check server logs for detailed error message
2. Verify country field is updatable in database schema
3. Check if country field expects specific format (code vs. name)
4. Add proper error handling and return meaningful error messages instead of 500
5. Consider returning validation errors (400) instead of server errors (500)

### Frontend Team
1. Document this limitation in app
2. Consider hiding country edit option until backend is fixed
3. Add error handling for 500 responses on profile update

---

## Test Script Location
`test/test_update_country.dart`

Run with: `dart test/test_update_country.dart`
