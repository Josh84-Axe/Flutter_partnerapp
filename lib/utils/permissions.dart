class Permissions {
  static const String roleOwner = 'owner';
  static const String roleWorker = 'worker';
  
  static bool canCreateWorkers(String role) => role == roleOwner;
  
  static bool canAssignRouters(String role) => role == roleOwner;
  
  static bool canCreatePlans(String role, List<String>? permissions) {
    if (role == roleOwner) return true;
    return permissions?.contains('create_plans') ?? false;
  }
  
  static bool canViewUsers(String role, List<String>? permissions) {
    if (role == roleOwner) return true;
    return permissions?.contains('view_users') ?? false;
  }
  
  static bool canViewTransactions(String role, List<String>? permissions) {
    if (role == roleOwner) return true;
    return permissions?.contains('view_transactions') ?? false;
  }
  
  static bool canViewRouters(String role, List<String>? permissions) {
    if (role == roleOwner) return true;
    return permissions?.contains('view_routers') ?? false;
  }
}
