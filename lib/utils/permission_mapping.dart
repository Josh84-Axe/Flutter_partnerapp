class PermissionConstants {
  // Plan Management
  static const String createPlans = 'create_plans';
  static const String viewPlans = 'view_plans';
  static const String editPlans = 'edit_plans';
  static const String deletePlans = 'delete_plans';

  // User Management
  static const String viewUsers = 'view_users';
  static const String createUsers = 'create_users';
  static const String editUsers = 'edit_users';
  static const String deleteUsers = 'delete_users';

  // Router Management
  static const String viewRouters = 'view_routers';
  static const String assignRouters = 'assign_routers';
  static const String manageRouters = 'manage_routers';

  // Transaction Management
  static const String viewTransactions = 'view_transactions';
  
  // Role Management
  static const String manageRoles = 'manage_roles';
}

class PermissionMapping {
  static const Map<String, String> permissionLabels = {
    PermissionConstants.createPlans: 'Create Plans',
    PermissionConstants.viewPlans: 'View Plans',
    PermissionConstants.editPlans: 'Edit Plans',
    PermissionConstants.deletePlans: 'Delete Plans',
    PermissionConstants.viewUsers: 'View Users',
    PermissionConstants.createUsers: 'Create Users',
    PermissionConstants.editUsers: 'Edit Users',
    PermissionConstants.deleteUsers: 'Delete Users',
    PermissionConstants.viewRouters: 'View Routers',
    PermissionConstants.assignRouters: 'Assign Routers',
    PermissionConstants.manageRouters: 'Manage Routers',
    PermissionConstants.viewTransactions: 'View Transactions',
    PermissionConstants.manageRoles: 'Manage Roles',
  };

  static String getLabel(String permission) {
    return permissionLabels[permission] ?? permission;
  }
}
