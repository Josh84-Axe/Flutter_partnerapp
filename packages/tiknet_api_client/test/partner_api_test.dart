import 'package:test/test.dart';
import 'package:tiknet_api_client/tiknet_api_client.dart';


/// tests for PartnerApi
void main() {
  final instance = TiknetApiClient().getPartnerApi();

  group(PartnerApi, () {
    //Future partnerAdditionalDevicesCreateCreate() async
    test('test partnerAdditionalDevicesCreateCreate', () async {
      // TODO
    });

    //Future partnerAdditionalDevicesDeleteDelete(String id) async
    test('test partnerAdditionalDevicesDeleteDelete', () async {
      // TODO
    });

    //Future partnerAdditionalDevicesList() async
    test('test partnerAdditionalDevicesList', () async {
      // TODO
    });

    //Future partnerAdditionalDevicesPartialUpdate(String id) async
    test('test partnerAdditionalDevicesPartialUpdate', () async {
      // TODO
    });

    //Future partnerAdditionalDevicesRead(String id) async
    test('test partnerAdditionalDevicesRead', () async {
      // TODO
    });

    //Future partnerAdditionalDevicesUpdate(String id) async
    test('test partnerAdditionalDevicesUpdate', () async {
      // TODO
    });

    //Future partnerAssignPlanCreate() async
    test('test partnerAssignPlanCreate', () async {
      // TODO
    });

    //Future partnerAssignedPlansList() async
    test('test partnerAssignedPlansList', () async {
      // TODO
    });

    // Changer le mot de passe (Partner/Collaborator)
    //
    //  Cette API permet à un utilisateur connecté (partenaire ou collaborateur) de modifier son mot de passe en fournissant l'ancien mot de passe et le nouveau. 
    //
    //Future partnerChangePasswordCreate(PartnerChangePasswordCreateRequest data) async
    test('test partnerChangePasswordCreate', () async {
      // TODO
    });

    // Vérifie la validité du token et retourne les informations de l'utilisateur.
    //
    //Future partnerCheckTokenList() async
    test('test partnerCheckTokenList', () async {
      // TODO
    });

    // Assigner un rôle à un collaborateur
    //
    //  Cette API permet à un partenaire d’assigner un rôle à un collaborateur existant. Le rôle doit appartenir au même partenaire. 
    //
    //Future partnerCollaboratorsAssignRoleCreate(String username, PartnerCollaboratorsAssignRoleCreateRequest data) async
    test('test partnerCollaboratorsAssignRoleCreate', () async {
      // TODO
    });

    //Future<PartnerCollaboratorRegister> partnerCollaboratorsCreateCreate(PartnerCollaboratorRegister data) async
    test('test partnerCollaboratorsCreateCreate', () async {
      // TODO
    });

    // Supprimer un collaborateur
    //
    //  Cette API permet à un partenaire de supprimer un collaborateur existant associé à son compte. Le collaborateur sera supprimé de la base de données. 
    //
    //Future partnerCollaboratorsDeleteDelete(String username) async
    test('test partnerCollaboratorsDeleteDelete', () async {
      // TODO
    });

    //Future partnerCollaboratorsList() async
    test('test partnerCollaboratorsList', () async {
      // TODO
    });

    // Mettre à jour le rôle d’un collaborateur
    //
    //  Cette API permet à un partenaire de modifier le rôle d’un collaborateur déjà existant. Le nouveau rôle doit appartenir au même partenaire. 
    //
    //Future partnerCollaboratorsUpdateRoleUpdate(String username, PartnerCollaboratorsUpdateRoleUpdateRequest data) async
    test('test partnerCollaboratorsUpdateRoleUpdate', () async {
      // TODO
    });

    //Future partnerCustomersAllListList() async
    test('test partnerCustomersAllListList', () async {
      // TODO
    });

    //Future<PartnerBlockOrUnblockCustomer> partnerCustomersBlockOrUnblockPartialUpdate(String username, PartnerBlockOrUnblockCustomer data) async
    test('test partnerCustomersBlockOrUnblockPartialUpdate', () async {
      // TODO
    });

    //Future<PartnerBlockOrUnblockCustomer> partnerCustomersBlockOrUnblockUpdate(String username, PartnerBlockOrUnblockCustomer data) async
    test('test partnerCustomersBlockOrUnblockUpdate', () async {
      // TODO
    });

    //Future partnerCustomersListList() async
    test('test partnerCustomersListList', () async {
      // TODO
    });

    //Future partnerCustomersPaginateListList() async
    test('test partnerCustomersPaginateListList', () async {
      // TODO
    });

    // Récupère les transactions d’un client spécifique
    //
    // Cette API permet au partenaire connecté de **récupérer la liste des transactions** de type `revenue` pour un **client spécifique** (identifié par son `username`).  **Filtres disponibles :** - `search`: référence, statut, montant... - `status`: success / pending / failed - `period`: today / this_week / this_month / this_year - `start_date` et `end_date`  **Réponse :** Retourne les transactions du client, avec pagination et totaux.
    //
    //Future<List<WalletTransaction>> partnerCustomersTransactionsList(String username, { String search, String status, String period, String startDate, String endDate, String sort }) async
    test('test partnerCustomersTransactionsList', () async {
      // TODO
    });

    //Future partnerDashboardList() async
    test('test partnerDashboardList', () async {
      // TODO
    });

    //Future partnerDataLimitCreateCreate() async
    test('test partnerDataLimitCreateCreate', () async {
      // TODO
    });

    //Future partnerDataLimitDeleteDelete(String id) async
    test('test partnerDataLimitDeleteDelete', () async {
      // TODO
    });

    //Future partnerDataLimitList() async
    test('test partnerDataLimitList', () async {
      // TODO
    });

    //Future partnerDataLimitPartialUpdate(String id) async
    test('test partnerDataLimitPartialUpdate', () async {
      // TODO
    });

    //Future partnerDataLimitRead(String id) async
    test('test partnerDataLimitRead', () async {
      // TODO
    });

    //Future partnerDataLimitUpdate(String id) async
    test('test partnerDataLimitUpdate', () async {
      // TODO
    });

    //Future partnerHotspotProfilesCreateCreate() async
    test('test partnerHotspotProfilesCreateCreate', () async {
      // TODO
    });

    //Future partnerHotspotProfilesDeleteDelete(String profileSlug) async
    test('test partnerHotspotProfilesDeleteDelete', () async {
      // TODO
    });

    //Future partnerHotspotProfilesDetailList(String profileSlug) async
    test('test partnerHotspotProfilesDetailList', () async {
      // TODO
    });

    //Future partnerHotspotProfilesListList() async
    test('test partnerHotspotProfilesListList', () async {
      // TODO
    });

    //Future partnerHotspotProfilesPaginateListList() async
    test('test partnerHotspotProfilesPaginateListList', () async {
      // TODO
    });

    //Future partnerHotspotProfilesUpdateList(String profileSlug) async
    test('test partnerHotspotProfilesUpdateList', () async {
      // TODO
    });

    //Future partnerHotspotProfilesUpdateUpdate(String profileSlug) async
    test('test partnerHotspotProfilesUpdateUpdate', () async {
      // TODO
    });

    //Future partnerHotspotUsersCreateCreate() async
    test('test partnerHotspotUsersCreateCreate', () async {
      // TODO
    });

    //Future partnerHotspotUsersDeleteDelete(String id) async
    test('test partnerHotspotUsersDeleteDelete', () async {
      // TODO
    });

    //Future partnerHotspotUsersListList() async
    test('test partnerHotspotUsersListList', () async {
      // TODO
    });

    //Future partnerHotspotUsersReadList(String username) async
    test('test partnerHotspotUsersReadList', () async {
      // TODO
    });

    //Future partnerHotspotUsersUpdateUpdate(String username) async
    test('test partnerHotspotUsersUpdateUpdate', () async {
      // TODO
    });

    //Future partnerIdleTimeoutCreateCreate() async
    test('test partnerIdleTimeoutCreateCreate', () async {
      // TODO
    });

    //Future partnerIdleTimeoutDeleteDelete(String id) async
    test('test partnerIdleTimeoutDeleteDelete', () async {
      // TODO
    });

    //Future partnerIdleTimeoutList() async
    test('test partnerIdleTimeoutList', () async {
      // TODO
    });

    //Future partnerIdleTimeoutPartialUpdate(String id) async
    test('test partnerIdleTimeoutPartialUpdate', () async {
      // TODO
    });

    //Future partnerIdleTimeoutRead(String id) async
    test('test partnerIdleTimeoutRead', () async {
      // TODO
    });

    //Future partnerIdleTimeoutUpdate(String id) async
    test('test partnerIdleTimeoutUpdate', () async {
      // TODO
    });

    //Future<MyTokenObtainPair> partnerLoginCreate(MyTokenObtainPair data) async
    test('test partnerLoginCreate', () async {
      // TODO
    });

    //Future<PartnerPasswordResetOtpCodeVerify> partnerPasswordResetOtpVerifyCreate(PartnerPasswordResetOtpCodeVerify data) async
    test('test partnerPasswordResetOtpVerifyCreate', () async {
      // TODO
    });

    //Future<PartnerPasswordResetOTPRequest> partnerPasswordResetRequestOtpCreate(PartnerPasswordResetOTPRequest data) async
    test('test partnerPasswordResetRequestOtpCreate', () async {
      // TODO
    });

    //Future<PaymentMethod> partnerPaymentMethodsCreateCreate(PaymentMethod data) async
    test('test partnerPaymentMethodsCreateCreate', () async {
      // TODO
    });

    //Future partnerPaymentMethodsDeleteDelete(String slug) async
    test('test partnerPaymentMethodsDeleteDelete', () async {
      // TODO
    });

    //Future<List<PaymentMethod>> partnerPaymentMethodsList() async
    test('test partnerPaymentMethodsList', () async {
      // TODO
    });

    //Future<PaymentMethod> partnerPaymentMethodsRead(String slug) async
    test('test partnerPaymentMethodsRead', () async {
      // TODO
    });

    //Future<PaymentMethod> partnerPaymentMethodsUpdatePartialUpdate(String slug, PaymentMethod data) async
    test('test partnerPaymentMethodsUpdatePartialUpdate', () async {
      // TODO
    });

    //Future<PaymentMethod> partnerPaymentMethodsUpdateUpdate(String slug, PaymentMethod data) async
    test('test partnerPaymentMethodsUpdateUpdate', () async {
      // TODO
    });

    //Future partnerPlansCreateCreate() async
    test('test partnerPlansCreateCreate', () async {
      // TODO
    });

    //Future partnerPlansDeleteDelete(String planSlug) async
    test('test partnerPlansDeleteDelete', () async {
      // TODO
    });

    //Future partnerPlansList() async
    test('test partnerPlansList', () async {
      // TODO
    });

    //Future partnerPlansReadList(String planSlug) async
    test('test partnerPlansReadList', () async {
      // TODO
    });

    //Future partnerPlansUpdateUpdate(String planSlug) async
    test('test partnerPlansUpdateUpdate', () async {
      // TODO
    });

    // Retourne les informations du profil de l'utilisateur connecté. Vérifie le token JWT à chaque appel.
    //
    //Future partnerProfileList() async
    test('test partnerProfileList', () async {
      // TODO
    });

    //Future<PurchaseSubscription> partnerPurchaseSubscriptionPlanCreate(PurchaseSubscription data) async
    test('test partnerPurchaseSubscriptionPlanCreate', () async {
      // TODO
    });

    //Future partnerRateLimitCreateCreate() async
    test('test partnerRateLimitCreateCreate', () async {
      // TODO
    });

    //Future partnerRateLimitDeleteDelete(String id) async
    test('test partnerRateLimitDeleteDelete', () async {
      // TODO
    });

    //Future partnerRateLimitList() async
    test('test partnerRateLimitList', () async {
      // TODO
    });

    //Future partnerRateLimitPartialUpdate(String id) async
    test('test partnerRateLimitPartialUpdate', () async {
      // TODO
    });

    //Future partnerRateLimitRead(String id) async
    test('test partnerRateLimitRead', () async {
      // TODO
    });

    //Future partnerRateLimitUpdate(String id) async
    test('test partnerRateLimitUpdate', () async {
      // TODO
    });

    //Future<TokenRefresh> partnerRefreshTokenCreate(TokenRefresh data) async
    test('test partnerRefreshTokenCreate', () async {
      // TODO
    });

    //Future<ConfirmRegisterEmailOtp> partnerRegisterConfirmCreate(ConfirmRegisterEmailOtp data) async
    test('test partnerRegisterConfirmCreate', () async {
      // TODO
    });

    //Future<PartnerRegisterInit> partnerRegisterCreate(PartnerRegisterInit data) async
    test('test partnerRegisterCreate', () async {
      // TODO
    });

    //Future<ResendVerifyEmailOtp> partnerResendVerifyEmailOtpCreate(ResendVerifyEmailOtp data) async
    test('test partnerResendVerifyEmailOtpCreate', () async {
      // TODO
    });

    //Future<PartnerResetPassword> partnerResetPasswordCreate(PartnerResetPassword data) async
    test('test partnerResetPasswordCreate', () async {
      // TODO
    });

    //Future<Role> partnerRolesCreateCreate(Role data) async
    test('test partnerRolesCreateCreate', () async {
      // TODO
    });

    //Future partnerRolesDeleteDelete(String slug) async
    test('test partnerRolesDeleteDelete', () async {
      // TODO
    });

    //Future<List<Role>> partnerRolesList() async
    test('test partnerRolesList', () async {
      // TODO
    });

    //Future<Role> partnerRolesRead(String slug) async
    test('test partnerRolesRead', () async {
      // TODO
    });

    //Future<Role> partnerRolesUpdatePartialUpdate(String slug, Role data) async
    test('test partnerRolesUpdatePartialUpdate', () async {
      // TODO
    });

    //Future<Role> partnerRolesUpdateUpdate(String slug, Role data) async
    test('test partnerRolesUpdateUpdate', () async {
      // TODO
    });

    // 👥 Récupérer les utilisateurs actifs
    //
    // Cette API retourne tous les utilisateurs actuellement connectés à un routeur MikroTik associé au partenaire.  Elle inclut les utilisateurs Hotspot et PPP avec leur IP, MAC, trafic consommé et uptime.
    //
    //Future partnerRoutersActiveUsersList(String slug) async
    test('test partnerRoutersActiveUsersList', () async {
      // TODO
    });

    //Future<Router> partnerRoutersAddCreate(Router data) async
    test('test partnerRoutersAddCreate', () async {
      // TODO
    });

    //Future partnerRoutersDeleteDelete(String routerId) async
    test('test partnerRoutersDeleteDelete', () async {
      // TODO
    });

    //Future partnerRoutersDetailsList(String routerSlug) async
    test('test partnerRoutersDetailsList', () async {
      // TODO
    });

    // 🔁 Redémarrer les Hotspots d’un routeur
    //
    // Cette API permet de **redémarrer tous les services Hotspot** d’un routeur MikroTik associé au partenaire actuellement connecté.  Elle vérifie les permissions et l’association du routeur avant d’effectuer l’opération.  **Réponse de succès :** - Nom du routeur - Adresse IP - Liste des hotspots redémarrés - Date et heure du redémarrage
    //
    //Future partnerRoutersHotspotsRestartCreate(String slug) async
    test('test partnerRoutersHotspotsRestartCreate', () async {
      // TODO
    });

    //Future partnerRoutersListList() async
    test('test partnerRoutersListList', () async {
      // TODO
    });

    // 🔄 Redémarrer un routeur MikroTik
    //
    // Cette API permet de redémarrer un routeur MikroTik associé au partenaire connecté. Le routeur est identifié par son **slug** passé dans l'URL. Le partenaire doit avoir les permissions nécessaires (`setting-access`).  Réponse de succès : ```json {   \"error\": false,   \"message\": \"Redémarrage du routeur lancé avec succès\",   \"data\": {     \"router\": \"MainRouter\",     \"ip_address\": \"192.168.88.1\",     \"status\": \"Reboot command sent\"   } } ```
    //
    //Future partnerRoutersRebootCreate(String slug) async
    test('test partnerRoutersRebootCreate', () async {
      // TODO
    });

    // 🔍 Récupérer les ressources système d’un routeur
    //
    // Cette API permet de **récupérer toutes les informations du système** d’un routeur MikroTik associé au partenaire actuellement connecté.  Elle vérifie les permissions et l’association du routeur avant d’effectuer l’opération.  **Réponse de succès :** - Nom du routeur - Adresse IP - Version - Uptime - Mémoire libre / totale - CPU, charge CPU - Espace disque - Et d'autres informations système disponibles
    //
    //Future partnerRoutersResourcesList(String slug) async
    test('test partnerRoutersResourcesList', () async {
      // TODO
    });

    //Future partnerRoutersUpdateUpdate(String routerSlug) async
    test('test partnerRoutersUpdateUpdate', () async {
      // TODO
    });

    //Future partnerSessionsActiveList() async
    test('test partnerSessionsActiveList', () async {
      // TODO
    });

    //Future partnerSessionsDisconnectCreate() async
    test('test partnerSessionsDisconnectCreate', () async {
      // TODO
    });

    //Future partnerSharedUsersCreateCreate() async
    test('test partnerSharedUsersCreateCreate', () async {
      // TODO
    });

    //Future partnerSharedUsersDeleteDelete(String id) async
    test('test partnerSharedUsersDeleteDelete', () async {
      // TODO
    });

    //Future partnerSharedUsersList() async
    test('test partnerSharedUsersList', () async {
      // TODO
    });

    //Future partnerSharedUsersPartialUpdate(String id) async
    test('test partnerSharedUsersPartialUpdate', () async {
      // TODO
    });

    //Future partnerSharedUsersRead(String id) async
    test('test partnerSharedUsersRead', () async {
      // TODO
    });

    //Future partnerSharedUsersUpdate(String id) async
    test('test partnerSharedUsersUpdate', () async {
      // TODO
    });

    //Future partnerTransactionsAdditionalDevicesList() async
    test('test partnerTransactionsAdditionalDevicesList', () async {
      // TODO
    });

    //Future partnerTransactionsAssignedPlansList() async
    test('test partnerTransactionsAssignedPlansList', () async {
      // TODO
    });

    //Future partnerTransactionsList() async
    test('test partnerTransactionsList', () async {
      // TODO
    });

    //Future<UpdatePartner> partnerUpdatePartialUpdate(UpdatePartner data) async
    test('test partnerUpdatePartialUpdate', () async {
      // TODO
    });

    //Future<UpdatePartner> partnerUpdateUpdate(UpdatePartner data) async
    test('test partnerUpdateUpdate', () async {
      // TODO
    });

    //Future partnerValidityCreateCreate() async
    test('test partnerValidityCreateCreate', () async {
      // TODO
    });

    //Future partnerValidityDeleteDelete(String id) async
    test('test partnerValidityDeleteDelete', () async {
      // TODO
    });

    //Future partnerValidityList() async
    test('test partnerValidityList', () async {
      // TODO
    });

    //Future partnerValidityPartialUpdate(String id) async
    test('test partnerValidityPartialUpdate', () async {
      // TODO
    });

    //Future partnerValidityRead(String id) async
    test('test partnerValidityRead', () async {
      // TODO
    });

    //Future partnerValidityUpdate(String id) async
    test('test partnerValidityUpdate', () async {
      // TODO
    });

    //Future<VerifyEmailOtp> partnerVerifyEmailOtpCreate(VerifyEmailOtp data) async
    test('test partnerVerifyEmailOtpCreate', () async {
      // TODO
    });

    // Récupère toutes les transactions du partenaire sans filtre ni tri.
    //
    // Retourne la liste complète des transactions du partenaire connecté, avec les totaux calculés (montant total, revenus, paiements).
    //
    //Future<List<WalletTransaction>> partnerWalletAllTransactionsList() async
    test('test partnerWalletAllTransactionsList', () async {
      // TODO
    });

    // Récupère le solde du wallet du partner
    //
    // Retourne le solde du wallet du partner.
    //
    //Future<Object> partnerWalletBalanceRead() async
    test('test partnerWalletBalanceRead', () async {
      // TODO
    });

    // Récupère les transactions du partenaire connecté avec filtres, recherche et pagination.
    //
    // Retourne la liste complète des transactions du partenaire connecté, avec filtres (status, type, période), recherche et pagination.
    //
    //Future<List<WalletTransaction>> partnerWalletTransactionsList({ String search, String status, String type, String period, String startDate, String endDate }) async
    test('test partnerWalletTransactionsList', () async {
      // TODO
    });

    //Future<WithdrawalRequest> partnerWithdrawalsCreateCreate(WithdrawalRequest data) async
    test('test partnerWithdrawalsCreateCreate', () async {
      // TODO
    });

    // Récupère la liste des demandes de retraits (Partner).
    //
    // Retourne la liste des demandes de retraits du partenaire connecté avec recherche et filtres.
    //
    //Future<List<WithdrawalRequest>> partnerWithdrawalsList({ String search, String status, String period, String startDate, String endDate }) async
    test('test partnerWithdrawalsList', () async {
      // TODO
    });

  });
}
