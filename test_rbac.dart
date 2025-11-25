import 'lib/utils/permissions.dart';
import 'lib/utils/permission_mapping.dart';

void main() {
  // Simulate a worker role with a limited set of permissions
  const role = Permissions.roleWorker;
  final permissions = [
    PermissionConstants.viewPlans,
    PermissionConstants.editPlans,
    PermissionConstants.viewUsers,
    PermissionConstants.viewRouters,
    // Note: No create/edit/delete for plans, users, routers, etc.
  ];

  print('--- RBAC Simulation for role: $role ---');
  print('Permissions list: ${permissions.join(', ')}');

  // Plans
  print('Can create plans: ${Permissions.canCreatePlans(role, permissions)}');
  print('Can view plans:   ${Permissions.canViewPlans(role, permissions)}');
  print('Can edit plans:   ${Permissions.canEditPlans(role, permissions)}');
  print('Can delete plans: ${Permissions.canDeletePlans(role, permissions)}');

  // Users
  print('Can create users: ${Permissions.canCreateUsers(role, permissions)}');
  print('Can view users:   ${Permissions.canViewUsers(role, permissions)}');
  print('Can edit users:   ${Permissions.canEditUsers(role, permissions)}');
  print('Can delete users: ${Permissions.canDeleteUsers(role, permissions)}');

  // Routers
  print('Can manage routers: ${Permissions.canManageRouters(role, permissions)}');
  print('Can view routers:   ${Permissions.canViewRouters(role, permissions)}');

  // Roles & payouts (owner only)
  print('Can manage roles: ${Permissions.canManageRoles(role, permissions)}');
  print('Can request payout: ${Permissions.canRequestPayout(role)}');
}
