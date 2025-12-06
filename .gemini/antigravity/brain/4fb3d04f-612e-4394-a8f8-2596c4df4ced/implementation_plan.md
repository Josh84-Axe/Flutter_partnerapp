# Implementation Plan - Fix Internet Plan CRUD

## Overview
Fix critical field mapping and data conversion issues preventing Internet Plan creation and editing from working correctly.

## Issues to Fix

### Critical Issues
1. **Field Name Mismatch**: UI sends `dataLimitGB`, `validityDays`, `deviceAllowed` but API expects `data_limit`, `validity`, `shared_users`
2. **Unit Conversion**: Validity sent in days but API expects minutes
3. **Missing Profile Name**: Only profile ID sent, need both ID and name
4. **Edit Pre-population**: Form fields don't match model field names
5. **Repository Inconsistency**: `loadPlans()` uses `WalletRepository` instead of `PlanRepository`

## Proposed Changes

### [MODIFY] [create_edit_internet_plan_screen.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/screens/create_edit_internet_plan_screen.dart)

**Fix `_savePlan()` method (lines 190-236)**:
- Change field names to match API: `data_limit`, `validity`, `shared_users`, `is_active`, `profile`, `profile_name`
- Convert validity from days to minutes (multiply by 1440)
- Add profile name lookup from hotspot profiles
- Handle both create and update with correct slug/id

**Fix `initState()` pre-population (lines 32-39)**:
- Use correct field names from `PlanModel`: `validityDays`, `dataLimitGB`, `deviceAllowed`
- Match dropdown values correctly

### [MODIFY] [app_state.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/providers/app_state.dart)

**Fix `loadPlans()` method (line 877)**:
- Change from `_walletRepository!.fetchPlans()` to `_planRepository!.fetchPlans()`
- Ensure consistency across all plan operations

### [MODIFY] [plan_model.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/models/plan_model.dart)

**Add `slug` field**:
- API uses `slug` for update/delete operations, not just `id`
- Update `toJson()` to include slug if available

## Verification Plan

### Manual Testing
1. **Create Plan**: Create a new plan with all fields populated
2. **Edit Plan**: Edit an existing plan and verify pre-population
3. **Delete Plan**: Delete a plan
4. **List Plans**: Verify plans display correctly with proper data

### Expected API Payloads

**Create/Update**:
```json
{
  "name": "Premium Plan",
  "price": 50.0,
  "data_limit": 100,
  "validity": 43200,
  "shared_users": 3,
  "is_active": true,
  "profile": "abc123",
  "profile_name": "Premium"
}
```
