½import 'permission_mapping.dart';

class Permissions {
  static const String roleOwner = 'Administrator';
  static const String rolePartner = 'Partner';
  static const String roleWorker = 'worker';
  
  static bool isOwner(String role) {
    return role == roleOwner || role == rolePartner;
  }
  
  // Legacy methods (kept for backward compatibility)
  static bool canCreateWorkers(String role) => isOwner(role);
  
  static bool canAssignRouters(String role) => isOwner(role);
  
  static bool canCreatePlans(String role, List<String>? permissions) {
    if (isOwner(role)) return true;
    return permissions?.contains(PermissionConstants.createPlans) ?? false;
  }
  
  static bool canViewUsers(String role, List<String>? permissions) {
    if (isOwner(role)) return true;
    return permissions?.contains(PermissionConstants.viewUsers) ?? false;
  }
  
  static bool canViewTransactions(String role, List<String>? permissions) {
    if (isOwner(role)) return true;
    return permissions?.contains(PermissionConstants.viewTransactions) ?? false;
  }
  
  static bool canViewRouters(String role, List<String>? permissions) {
    if (isOwner(role)) return true;
    return permissions?.contains(PermissionConstants.viewRouters) ?? false;
  }
  
  // Plan Management Permissions
  static bool canViewPlans(String role, List<String>? permissions) {
    if (isOwner(role)) return true;
    return permissions?.contains(PermissionConstants.viewPlans) ?? false;
  }
  
  static bool canEditPlans(String role, List<String>? permissions) {
    if (isOwner(role)) return true;
    return permissions?.contains(PermissionConstants.editPlans) ?? false;
  }
  
  static bool canDeletePlans(String role, List<String>? permissions) {
    if (isOwner(role)) return true;
    return permissions?.contains(PermissionConstants.deletePlans) ?? false;
  }
  
  // User Management Permissions
  static bool canCreateUsers(String role, List<String>? permissions) {
    if (isOwner(role)) return true;
    return permissions?.contains(PermissionConstants.createUsers) ?? false;
  }
  
  static bool canEditUsers(String role, List<String>? permissions) {
    if (isOwner(role)) return true;
    return permissions?.contains(PermissionConstants.editUsers) ?? false;
  }
  
  static bool canDeleteUsers(String role, List<String>? permissions) {
    if (isOwner(role)) return true;
    return permissions?.contains(PermissionConstants.deleteUsers) ?? false;
  }
  
  // Router Management Permissions
  static bool canManageRouters(String role, List<String>? permissions) {
    if (isOwner(role)) return true;
    return permissions?.contains(PermissionConstants.manageRouters) ?? false;
  }
  
  // Role Management Permissions
  static bool canManageRoles(String role, List<String>? permissions) {
    return isOwner(role); // Only owners can manage roles
  }
  
  // Payout Permissions
  static bool canRequestPayout(String role) {
    return isOwner(role); // Only owners can request payouts
  }
  
  static bool canViewPayouts(String role, List<String>? permissions) {
    if (isOwner(role)) return true;
    return permissions?.contains(PermissionConstants.viewTransactions) ?? false;
  }
}
ˆ ˆ¸*cascade08
¸Ò Ò·*cascade08
·› ›*cascade08
¢ ¢¨*cascade08
¨Ş Şà*cascade08
àå åë*cascade08
ëÂ ÂÄ*cascade08
ÄÉ ÉÏ*cascade08
Ïƒ ƒ…*cascade08
…Š Š*cascade08
É ÉË*cascade08
ËĞ ĞÖ*cascade08
Ö‘	 ‘	“	*cascade08
“	˜	 ˜		*cascade08
	ô
 ô
ö
*cascade08
ö
û
 û
*cascade08
³ ³µ*cascade08
µº ºÀ*cascade08
Àô ôö*cascade08
öû û*cascade08
Ù ÙÛ*cascade08
Ûà àæ*cascade08
æš šœ*cascade08
œ¡ ¡§*cascade08
§Û Ûİ*cascade08
İâ âè*cascade08
èÄ ÄÆ*cascade08
ÆË ËÑ*cascade08
Ñ® ®°*cascade08
°µ µ»*cascade08
»º º¼*cascade08
¼Á ÁÇ*cascade08
ÇÆ ÆÈ*cascade08
ÈÍ ÍÓ*cascade08
Ó½ "(1f73c1cc83dbe3cf3d5e6c924bf686fa08a569f22cfile:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/utils/permissions.dart:Hfile:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp