# Manual UI Verification Checklist

## Overview

This checklist will help you verify that the subscription management and internet plan improvements are working correctly. The automated browser testing had difficulties interacting with the Flutter web app, so please perform these manual checks.

## Prerequisites

- App URL: https://fix-token-storage-windows.wifi-4u-partner.pages.dev
- Test Credentials: `sientey@hotmail.com` / `Testing123`
- Browser: Chrome/Edge (recommended for Flutter web)
- Browser Console: Open Developer Tools (F12) to view debug logs

## Part 1: Subscription Management Verification

### 1.1 Dashboard Subscription Widget

**Steps:**
1. Log in to the app
2. Navigate to Dashboard
3. Locate the "Subscription Plan" card (should be near the top)

**Expected Results:**
- ✅ Shows your actual plan name (not "Free Plan" or mock data)
- ✅ Shows correct renewal date
- ✅ Shows countdown timer (days/hours/minutes left)
- ✅ Active/Inactive status badge

**Check Console Logs:**
```
📦 [AppState] Subscription data received: {...}
✅ [AppState] Subscription loaded: [Plan Name]
```

**Screenshot Location:** Dashboard with subscription widget visible

---

### 1.2 Subscription Management Screen

**Steps:**
1. Navigate to Settings → Subscription Management
2. Wait for data to load

**Expected Results:**

**Current Plan Section:**
- ✅ Shows your active subscription tier
- ✅ Shows monthly fee in correct currency
- ✅ Shows renewal date
- ✅ Shows plan features (if available)
- ✅ Active/Inactive status badge

**Available Plans Section:**
- ✅ Shows list of available subscription plans from API
- ✅ NOT showing hardcoded plans (Basic, Standard, Premium, Enterprise)
- ✅ Each plan shows name, price, description, features
- ✅ "Popular" badge on popular plans
- ✅ "Current" badge on your active plan
- ✅ "Upgrade" button on other plans

**Check Console Logs:**
```
📋 [AppState] Loading available subscription plans
✅ [AppState] Loaded X subscription plans
📦 [SubscriptionRepository] Fetching subscription plans
✅ [SubscriptionRepository] Response: {...}
```

**If No Plans Show:**
- Check console for errors
- Verify API endpoint `/partner/subscription-plans/list/` is accessible
- Check if response has `data` or `results` field

**Screenshot Location:** Subscription Management screen showing both sections

---

### 1.3 Subscription Purchase Flow

**Steps:**
1. On Subscription Management screen
2. Click "Upgrade" on a different plan
3. Confirm the purchase dialog

**Expected Results:**
- ✅ Confirmation dialog appears
- ✅ After confirmation, shows success/error message
- ✅ Dashboard updates with new subscription

**Check Console Logs:**
```
💳 [AppState] Purchasing subscription plan: [plan-id]
✅ [AppState] Subscription purchase successful
```

**Screenshot Location:** Purchase confirmation dialog

---

## Part 2: Internet Plan CRUD Verification

### 2.1 Configuration Loading

**Steps:**
1. Navigate to Internet Plans
2. Click "New Plan" or edit existing plan
3. Check all dropdown fields

**Expected Results:**

**Validity Dropdown:**
- ✅ Shows options loaded from API
- ✅ NOT showing "No options configured"
- ✅ Options display correctly (e.g., "30 Days", "60 Days")

**Data Limit Dropdown:**
- ✅ Shows options loaded from API
- ✅ Options display correctly (e.g., "10 GB", "50 GB", "Unlimited")

**Additional Devices Dropdown:**
- ✅ Shows options loaded from API
- ✅ Options display correctly (e.g., "1 Device", "2 Devices")

**Hotspot Profile Dropdown:**
- ✅ Shows profiles loaded from API
- ✅ Profile names display correctly

**Check Console Logs:**
```
🔄 [AppState] Loading validity periods...
✅ [AppState] Validity periods loaded: X items
   Sample: {id: 1, name: "30 Days", value: 30, ...}

🔄 [AppState] Loading data limits...
✅ [AppState] Data limits loaded: X items
   Sample: {id: 1, name: "10 GB", value: 10, ...}

🔄 [AppState] Loading shared users...
✅ [AppState] Shared users loaded: X items
   Sample: {id: 1, name: "1 Device", value: 1, ...}
```

**If Dropdowns Are Empty:**
- Check console for configuration loading errors
- Verify API endpoints are accessible:
  - `/partner/validity/list/`
  - `/partner/data-limit/list/`
  - `/partner/shared-users/list/`
- Check if responses have `data.results` or `results` field
- Note the exact structure of the API response

**Screenshot Location:** Create Plan screen with all dropdowns expanded

---

### 2.2 Plan Creation

**Steps:**
1. Click "New Plan"
2. Fill in all fields:
   - Plan Name: "Test Plan"
   - Price: 10.00
   - Validity: Select any option
   - Data Limit: Select any option
   - Additional Devices: Select any option
   - Hotspot Profile: Select any option
3. Click "Create"

**Expected Results:**
- ✅ All fields validate before submission
- ✅ Shows error if any dropdown is not selected
- ✅ Success message appears after creation
- ✅ Plan appears in the plans list
- ✅ No errors in console

**Check Console Logs:**
```
🔍 [CreatePlan] Extracting value from validity: {...}
   Extracted from Map: 30
🔍 [CreatePlan] Extracting value from data_limit: {...}
   Extracted from Map: 10
📦 [CreatePlan] Prepared plan data:
   Name: Test Plan
   Price: 10.0
   Data Limit: 10 GB
   Validity: 43200 minutes (30 days)
   Shared Users: 1
   Profile: [profile-id]
   Profile Name: Basic
➕ [CreatePlan] Creating new plan
📦 [PlanRepository] Plan data: {name: Test Plan, price: 10.0, ...}
✅ [CreatePlan] Plan created successfully
```

**If Creation Fails:**
- Check console for error messages
- Verify the exact error from API
- Check if data transformation is correct
- Note which field is causing the issue

**Screenshot Location:** 
1. Filled create plan form
2. Success message
3. New plan in plans list

---

### 2.3 Plan Update

**Steps:**
1. Click edit on an existing plan
2. Change the name to "Updated Test Plan"
3. Click "Update"

**Expected Results:**
- ✅ Form pre-fills with existing data
- ✅ Dropdowns show current selections
- ✅ Success message after update
- ✅ Plan name updates in list

**Check Console Logs:**
```
🔄 [CreatePlan] Updating plan: [plan-id]
✅ [CreatePlan] Plan updated successfully
```

**Screenshot Location:** Updated plan in list

---

### 2.4 Plan Deletion

**Steps:**
1. Click delete on a test plan
2. Confirm deletion

**Expected Results:**
- ✅ Confirmation dialog appears
- ✅ Plan removed from list
- ✅ Success message

**Screenshot Location:** Plans list after deletion

---

## Part 3: Error Scenarios

### 3.1 Network Errors

**Test:**
1. Open DevTools → Network tab
2. Set throttling to "Offline"
3. Try to create a plan

**Expected Results:**
- ✅ Shows user-friendly error message
- ✅ Error details in console
- ✅ App doesn't crash

---

### 3.2 Validation Errors

**Test:**
1. Try to create a plan without filling all fields
2. Leave dropdowns unselected

**Expected Results:**
- ✅ Shows specific error for each missing field
- ✅ "Please select a validity period"
- ✅ "Please select a data limit"
- ✅ "Please select additional devices"

**Screenshot Location:** Validation error messages

---

## Part 4: API Response Analysis

### 4.1 Check Actual API Responses

**Steps:**
1. Open DevTools → Network tab
2. Filter by "XHR" or "Fetch"
3. Navigate to Subscription Management
4. Check these requests:

**Subscription Check:**
- URL: `/partner/subscription-plans/check/`
- Method: GET
- Response structure: Document the actual response

**Subscription Plans List:**
- URL: `/partner/subscription-plans/list/`
- Method: GET
- Response structure: Document the actual response

**Validity Periods:**
- URL: `/partner/validity/list/`
- Method: GET
- Response structure: Document the actual response

**Data Limits:**
- URL: `/partner/data-limit/list/`
- Method: GET
- Response structure: Document the actual response

**Shared Users:**
- URL: `/partner/shared-users/list/`
- Method: GET
- Response structure: Document the actual response

**For Each Response, Note:**
- Status code (200, 404, 500, etc.)
- Response structure (nested in `data`? `results`? direct array?)
- Field names (`value`, `days`, `gb`, `count`, etc.)
- Sample data

---

## Troubleshooting Guide

### Issue: Subscription Widget Shows "Free Plan"

**Possible Causes:**
1. API endpoint not returning data
2. Response structure doesn't match expected format
3. Subscription not loaded during login

**Debug Steps:**
1. Check console for subscription loading logs
2. Check Network tab for `/partner/subscription-plans/check/` request
3. Verify response has `plan` object with `name` field

---

### Issue: Available Plans Not Showing

**Possible Causes:**
1. API endpoint returns empty array
2. Response structure mismatch
3. No plans configured in backend

**Debug Steps:**
1. Check console for "Loaded X subscription plans"
2. Check Network tab for `/partner/subscription-plans/list/` request
3. Verify response structure matches expected format

---

### Issue: Dropdowns Empty in Plan Creation

**Possible Causes:**
1. Configuration APIs not returning data
2. Response structure mismatch
3. Data extraction failing

**Debug Steps:**
1. Check console for configuration loading logs
2. Look for "Sample: {...}" logs showing actual data
3. Check if extraction logs show "Could not extract value"
4. Verify API response field names match extraction logic

---

### Issue: Plan Creation Fails

**Possible Causes:**
1. Missing required fields
2. Data transformation error
3. API validation error

**Debug Steps:**
1. Check console for "Prepared plan data" log
2. Verify all values are correct (validity in minutes, etc.)
3. Check API error response for validation messages
4. Compare with working web admin request

---

## Reporting Results

Please provide:

1. **Screenshots** of:
   - Dashboard subscription widget
   - Subscription Management screen
   - Create Plan screen with dropdowns
   - Any error messages

2. **Console Logs** showing:
   - Configuration loading
   - Plan creation attempt
   - Any errors

3. **Network Tab** showing:
   - API request URLs
   - Response status codes
   - Response data structure

4. **Specific Issues** encountered:
   - Which features work ✅
   - Which features don't work ❌
   - Error messages received
   - Unexpected behavior

This information will help identify exactly where the issue is and how to fix it.
