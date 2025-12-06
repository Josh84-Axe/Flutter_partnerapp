# Internet Plan Configuration & Creation Guide

## Where to Add/Configure Internet Plans

### 1. Main Entry Points (UI)

#### A. Bottom Navigation "Plans" Tab
**File**: [plans_screen.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/screens/plans_screen.dart)

- **Location**: Bottom navigation bar → "Plans" icon
- **Features**:
  - View all plans with green info chips
  - Click floating action button (+) to create new plan
  - Opens `CreateEditPlanScreen` for plan creation
  - "Assign to User" button on each card

**Navigation Path**: 
```
Home Screen → Bottom Nav "Plans" → FAB (+) → Create Plan Form
```

---

#### B. Settings "Internet Plans"
**File**: [internet_plan_screen.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/screens/internet_plan_screen.dart)

- **Location**: Settings & Preferences → Internet Plans
- **Features**:
  - Compact list view with Edit/Delete buttons
  - Click floating action button (+) to create new plan
  - Edit existing plans with green circular button
  - Delete plans with red circular button

**Navigation Path**:
```
Home Screen → Settings → Internet Plans → FAB (+) → Create Plan Form
```

**Route**: `/internet-plan`

---

### 2. Plan Creation/Edit Form

**File**: [plans_screen.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/screens/plans_screen.dart#L253-L633)

**Class**: `CreateEditPlanScreen`

**Form Fields**:
1. **Plan Name** - Text input
2. **Price** - Number input with currency
3. **Data Limit** - Dropdown (from API: `/partner/data-limit/list/`)
4. **Validity** - Dropdown (from API: `/partner/validity/list/`)
5. **Device Allowed** - Dropdown (from API: `/partner/shared-users/list/`)
6. **Hotspot User Profile** - Dropdown (from API: `/partner/hotspot-profiles/`)

**Actions**:
- **Create Plan** - Saves new plan to backend
- **Update Plan** - Updates existing plan
- **Delete Plan** - Removes plan (edit mode only)

---

### 3. Pre-Configuration Screens

Before creating plans, you need to configure these options:

#### A. Data Limit Configuration
**File**: `lib/screens/config/data_limit_config_screen.dart`
- **Route**: `/data-limit-config`
- **API**: `/partner/data-limit/list/`, `/partner/data-limit/create/`
- **Purpose**: Define available data limits (e.g., 1GB, 5GB, 10GB)

#### B. Validity Configuration
**File**: `lib/screens/config/plan_validity_config_screen.dart`
- **Route**: `/validity-config`
- **API**: `/partner/validity/list/`, `/partner/validity/create/`
- **Purpose**: Define validity periods (e.g., 1 day, 7 days, 30 days)

#### C. Shared Users Configuration
**File**: `lib/screens/config/shared_user_config_screen.dart`
- **Route**: `/shared-users-config`
- **API**: `/partner/shared-users/list/`, `/partner/shared-users/create/`
- **Purpose**: Define device limits (e.g., 1 device, 5 devices, 10 devices)

#### D. Rate Limit Configuration
**File**: `lib/screens/config/rate_limit_config_screen.dart`
- **Route**: `/rate-limit-config`
- **API**: `/partner/rate-limit/list/`, `/partner/rate-limit/create/`
- **Purpose**: Define speed limits (e.g., 10 Mbps, 50 Mbps, 100 Mbps)

---

### 4. Backend Integration

#### Plan Repository
**File**: [plan_repository.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/repositories/plan_repository.dart)

**Methods**:
- `createPlan(Map<String, dynamic> planData)` - POST `/partner/plans/create/`
- `updatePlan(String id, Map<String, dynamic> planData)` - PUT `/partner/plans/{id}/update/`
- `deletePlan(String id)` - DELETE `/partner/plans/{id}/delete/`
- `fetchPlans()` - GET `/partner/plans/`

#### App State
**File**: [app_state.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/providers/app_state.dart)

**Methods**:
- `createPlan(Map<String, dynamic> planData)` - Line 1069
- `updatePlan(String id, Map<String, dynamic> planData)` - Manages plan updates
- `deletePlan(String id)` - Manages plan deletion
- `loadPlans()` - Fetches all plans from API

---

### 5. API Endpoints Summary

| Action | Endpoint | Method |
|--------|----------|--------|
| **List Plans** | `/partner/plans/` | GET |
| **Create Plan** | `/partner/plans/create/` | POST |
| **Update Plan** | `/partner/plans/{id}/update/` | PUT |
| **Delete Plan** | `/partner/plans/{id}/delete/` | DELETE |
| **Get Data Limits** | `/partner/data-limit/list/` | GET |
| **Get Validity Options** | `/partner/validity/list/` | GET |
| **Get Device Limits** | `/partner/shared-users/list/` | GET |
| **Get Hotspot Profiles** | `/partner/hotspot-profiles/` | GET |

---

### 6. Permissions Required

**File**: [permissions.dart](file:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/utils/permissions.dart)

- **Create Plans**: `canCreatePlans(role, permissions)` - Checks for `create_plans` permission
- **Edit Plans**: `canEditPlans(role, permissions)` - Checks for `edit_plans` permission
- **Delete Plans**: `canDeletePlans(role, permissions)` - Checks for `delete_plans` permission

---

## Quick Start: Creating Your First Plan

### Step 1: Configure Pre-requisites
1. Navigate to **Settings → Data Limit Configuration**
2. Add data limit options (e.g., 5GB, 10GB, 20GB)
3. Navigate to **Settings → Validity Configuration**
4. Add validity options (e.g., 7 days, 30 days)
5. Navigate to **Settings → Shared Users Configuration**
6. Add device limit options (e.g., 1 device, 5 devices)

### Step 2: Create a Plan
1. Go to **Bottom Nav → Plans** OR **Settings → Internet Plans**
2. Click the **floating action button (+)**
3. Fill in the form:
   - Plan Name: "Basic Plan"
   - Price: 10.00
   - Data Limit: Select from dropdown
   - Validity: Select from dropdown
   - Device Allowed: Select from dropdown
   - Hotspot Profile: Select or leave as "Basic"
4. Click **"Create Plan"**

### Step 3: Verify
- The plan should appear in the plans list
- You can now assign it to users via the "Assign to User" button

---

## Troubleshooting

### Dropdowns Show "Unknown"
- **Cause**: Pre-configurations not set up
- **Fix**: Configure Data Limit, Validity, and Shared Users first

### "No Options Configured" in Dropdowns
- **Cause**: API not returning configuration data
- **Fix**: Check API endpoints and ensure data exists in backend

### Permission Denied
- **Cause**: User role doesn't have required permissions
- **Fix**: Ensure user has `create_plans`, `edit_plans`, or `delete_plans` permissions
