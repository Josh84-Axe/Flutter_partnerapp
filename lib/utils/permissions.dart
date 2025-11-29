import 'permission_mapping.dart';

class Permissions {
  static const String roleOwner = 'Administrator';
  static const String roleWorker = 'worker';
  
  // Legacy methods (kept for backward compatibility)
  static bool canCreateWorkers(String role) => role == roleOwner;
  
  static bool canAssignRouters(String role) => role == roleOwner;
  
  static bool canCreatePlans(String role, List<String>? permissions) {
    if (role == roleOwner) return true;
    return permissions?.contains(PermissionConstants.createPlans) ?? false;
  }
  
  static bool canViewUsers(String role, List<String>? permissions) {
    if (role == roleOwner) return true;
    return permissions?.contains(PermissionConstants.viewUsers) ?? false;
  }
  
  static bool canViewTransactions(String role, List<String>? permissions) {
    if (role == roleOwner) return true;
    return permissions?.contains(PermissionConstants.viewTransactions) ?? false;
  }
  
  static bool canViewRouters(String role, List<String>? permissions) {
    if (role == roleOwner) return true;
    return permissions?.contains(PermissionConstants.viewRouters) ?? false;
  }
  
  // Plan Management Permissions
  static bool canViewPlans(String role, List<String>? permissions) {
    if (role == roleOwner) return true;
    return permissions?.contains(PermissionConstants.viewPlans) ?? false;
  }
  
  static bool canEditPlans(String role, List<String>? permissions) {
    if (role == roleOwner) return true;
    return permissions?.contains(PermissionConstants.editPlans) ?? false;
  }
  
  static bool canDeletePlans(String role, List<String>? permissions) {
    if (role == roleOwner) return true;
    return permissions?.contains(PermissionConstants.deletePlans) ?? false;
  }
  
  // User Management Permissions
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
  
  // Router Management Permissions
  static bool canManageRouters(String role, List<String>? permissions) {
    if (role == roleOwner) return true;
    return permissions?.contains(PermissionConstants.manageRouters) ?? false;
  }
  
  // Role Management Permissions
  static bool canManageRoles(String role, List<String>? permissions) {
    return role == roleOwner; // Only owners can manage roles
  }
  
  // Payout Permissions
  static bool canRequestPayout(String role) {
    return role == roleOwner; // Only owners can request payouts
  }
  
  static bool canViewPayouts(String role, List<String>? permissions) {
    if (role == roleOwner) return true;
    return permissions?.contains(PermissionConstants.viewTransactions) ?? false;
  }
}
