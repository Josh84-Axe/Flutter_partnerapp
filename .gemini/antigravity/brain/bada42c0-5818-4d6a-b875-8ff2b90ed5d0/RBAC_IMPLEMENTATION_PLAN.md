# RBAC Enforcement Implementation Plan

## Overview
Add role-based access control checks across the UI to hide/disable features based on user permissions.

## Screens Requiring RBAC

### High Priority (Critical Operations)

#### 1. Internet Plan Management
**Screen:** `internet_plan_screen.dart`
- **Create Plan Button:** Requires `create_plans` permission
- **Edit Plan Button:** Requires `edit_plans` permission  
- **Delete Plan Button:** Requires `delete_plans` permission

#### 2. User Management
**Screen:** `users_screen.dart`
- **Create User Button:** Requires `create_users` permission
- **Edit User Button:** Requires `edit_users` permission
- **Delete User Button:** Requires `delete_users` permission
- **View Users List:** Requires `view_users` permission

#### 3. Payout Requests
**Screen:** `payout_request_screen.dart`
- **Request Payout Button:** Owner only (or specific payout permission)
- **View Payout History:** Requires `view_transactions` permission

#### 4. Role Management
**Screen:** `role_permission_screen.dart`
- **Create/Edit Roles:** Requires `manage_roles` permission (owner only)

### Medium Priority

#### 5. Router Management
**Screen:** `routers_screen.dart`
- **Assign Router:** Requires `assign_routers` permission
- **Manage Router:** Requires `manage_routers` permission

#### 6. Hotspot Profile Management
**Screen:** `user_profile_screen.dart`
- **Create Profile:** Requires `create_plans` permission (similar to plans)
- **Edit Profile:** Requires `edit_plans` permission
- **Delete Profile:** Requires `delete_plans` permission

#### 7. Configuration Screens
**Screens:** `data_limit_config_screen.dart`, `shared_user_config_screen.dart`, etc.
- **Modify Configuration:** Owner only

## Implementation Pattern

### 1. Check Permission Before Action
```dart
void _onCreatePlan() {
  final user = context.read<AppState>().currentUser;
  if (user == null) return;
  
  if (!Permissions.canCreatePlans(user.role, user.permissions)) {
    PermissionDeniedDialog.show(
      context,
      requiredPermission: PermissionConstants.createPlans,
    );
    return;
  }
  
  // Proceed with action
  Navigator.pushNamed(context, '/create-plan');
}
```

### 2. Hide/Disable UI Elements
```dart
if (Permissions.canCreatePlans(user.role, user.permissions))
  FloatingActionButton(
    onPressed: _onCreatePlan,
    child: Icon(Icons.add),
  ),
```

### 3. Conditional Menu Items
```dart
PopupMenuItem(
  enabled: Permissions.canDeletePlans(user.role, user.permissions),
  child: Text('Delete'),
  onTap: () => _deletePlan(plan.id),
),
```

## Required Permission Helper Methods

Add to `lib/utils/permissions.dart`:

```dart
// Plan permissions
static bool canCreatePlans(String role, List<String>? permissions) {
  if (role == roleOwner) return true;
  return permissions?.contains(PermissionConstants.createPlans) ?? false;
}

static bool canEditPlans(String role, List<String>? permissions) {
  if (role == roleOwner) return true;
  return permissions?.contains(PermissionConstants.editPlans) ?? false;
}

static bool canDeletePlans(String role, List<String>? permissions) {
  if (role == roleOwner) return true;
  return permissions?.contains(PermissionConstants.deletePlans) ?? false;
}

// User permissions
static bool canCreateUsers(String role, List<String>? permissions) {
  if (role == roleOwner) return true;
  return permissions?.contains(PermissionConstants.createUsers) ?? false;
}

static bool canEditUsers(String role, List<String>? permissions) {
  if (role == roleOwner) return true;
  return permissions?.contains(PermissionConstants.editUsers) ?? false;
}

static bool canDeleteUsers(String role, List<String>? permissions) {
  if (role == roleOwner) return true;
  return permissions?.contains(PermissionConstants.deleteUsers) ?? false;
}

// Router permissions
static bool canManageRouters(String role, List<String>? permissions) {
  if (role == roleOwner) return true;
  return permissions?.contains(PermissionConstants.manageRouters) ?? false;
}

// Role permissions
static bool canManageRoles(String role, List<String>? permissions) {
  return role == roleOwner; // Only owners can manage roles
}

// Payout permissions
static bool canRequestPayout(String role) {
  return role == roleOwner; // Only owners can request payouts
}
```

## Implementation Steps

1. **Extend Permissions class** with all required helper methods
2. **Update InternetPlanScreen** - Add checks for create/edit/delete buttons
3. **Update UsersScreen** - Add checks for user management actions
4. **Update PayoutRequestScreen** - Add owner-only check
5. **Update RolePermissionScreen** - Add owner-only check
6. **Update RoutersScreen** - Add router management checks
7. **Update Configuration Screens** - Add owner-only checks
8. **Test RBAC** - Verify permissions work correctly

## Testing Plan

1. Test as owner - all features accessible
2. Test as worker with limited permissions - features hidden/disabled
3. Test permission denied dialog appears
4. Test navigation blocked for unauthorized screens
5. Verify API calls still fail gracefully if bypassed

## Success Criteria

- ✅ Unauthorized users cannot see restricted buttons/features
- ✅ Permission denied dialog shows when attempting unauthorized actions
- ✅ Owner role has access to all features
- ✅ Worker role respects assigned permissions
- ✅ No console errors or crashes when permissions missing
