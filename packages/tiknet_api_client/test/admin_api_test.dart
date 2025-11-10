import 'package:test/test.dart';
import 'package:tiknet_api_client/tiknet_api_client.dart';


/// tests for AdminApi
void main() {
  final instance = TiknetApiClient().getAdminApi();

  group(AdminApi, () {
    //Future<AdminActivateOrDeactivateUser> adminCustomersActivateOrDeactivatePartialUpdate(String username, AdminActivateOrDeactivateUser data) async
    test('test adminCustomersActivateOrDeactivatePartialUpdate', () async {
      // TODO
    });

    //Future<AdminActivateOrDeactivateUser> adminCustomersActivateOrDeactivateUpdate(String username, AdminActivateOrDeactivateUser data) async
    test('test adminCustomersActivateOrDeactivateUpdate', () async {
      // TODO
    });

    //Future adminCustomersListList() async
    test('test adminCustomersListList', () async {
      // TODO
    });

    //Future adminCustomersPaginateListList() async
    test('test adminCustomersPaginateListList', () async {
      // TODO
    });

    //Future<AdminTokenObtainPair> adminLoginCreate(AdminTokenObtainPair data) async
    test('test adminLoginCreate', () async {
      // TODO
    });

    //Future<AdminActivateOrDeactivateUser> adminPartnersActivateOrDeactivatePartialUpdate(String username, AdminActivateOrDeactivateUser data) async
    test('test adminPartnersActivateOrDeactivatePartialUpdate', () async {
      // TODO
    });

    //Future<AdminActivateOrDeactivateUser> adminPartnersActivateOrDeactivateUpdate(String username, AdminActivateOrDeactivateUser data) async
    test('test adminPartnersActivateOrDeactivateUpdate', () async {
      // TODO
    });

    //Future adminPartnersListList() async
    test('test adminPartnersListList', () async {
      // TODO
    });

    //Future adminPartnersPaginateListList() async
    test('test adminPartnersPaginateListList', () async {
      // TODO
    });

    // Met à jour le statut d’un partenaire
    //
    //Future adminPartnersUpdateStatusPartialUpdate(String username, UpdatePartnerStatus data) async
    test('test adminPartnersUpdateStatusPartialUpdate', () async {
      // TODO
    });

    //Future<Permission> adminPermissionsCreateCreate(Permission data) async
    test('test adminPermissionsCreateCreate', () async {
      // TODO
    });

    // Supprimer une permission
    //
    // Supprime une permission du système à partir de son **slug** (réservé au Super Administrateur).
    //
    //Future adminPermissionsDeleteDelete(String slug) async
    test('test adminPermissionsDeleteDelete', () async {
      // TODO
    });

    //Future<List<Permission>> adminPermissionsList() async
    test('test adminPermissionsList', () async {
      // TODO
    });

    //Future<Permission> adminPermissionsRead(String slug) async
    test('test adminPermissionsRead', () async {
      // TODO
    });

    //Future<Permission> adminPermissionsUpdatePartialUpdate(String slug, Permission data) async
    test('test adminPermissionsUpdatePartialUpdate', () async {
      // TODO
    });

    //Future<Permission> adminPermissionsUpdateUpdate(String slug, Permission data) async
    test('test adminPermissionsUpdateUpdate', () async {
      // TODO
    });

    //Future<SubscriptionFeature> adminSubscriptionFeaturesCreateCreate(SubscriptionFeature data) async
    test('test adminSubscriptionFeaturesCreateCreate', () async {
      // TODO
    });

    //Future adminSubscriptionFeaturesDeleteDelete(String slug) async
    test('test adminSubscriptionFeaturesDeleteDelete', () async {
      // TODO
    });

    //Future<List<SubscriptionFeature>> adminSubscriptionFeaturesList() async
    test('test adminSubscriptionFeaturesList', () async {
      // TODO
    });

    //Future<SubscriptionFeature> adminSubscriptionFeaturesRead(String slug) async
    test('test adminSubscriptionFeaturesRead', () async {
      // TODO
    });

    //Future<SubscriptionFeature> adminSubscriptionFeaturesUpdatePartialUpdate(String slug, SubscriptionFeature data) async
    test('test adminSubscriptionFeaturesUpdatePartialUpdate', () async {
      // TODO
    });

    //Future<SubscriptionFeature> adminSubscriptionFeaturesUpdateUpdate(String slug, SubscriptionFeature data) async
    test('test adminSubscriptionFeaturesUpdateUpdate', () async {
      // TODO
    });

    //Future<SubscriptionPlan> adminSubscriptionPlansCreateCreate(SubscriptionPlan data) async
    test('test adminSubscriptionPlansCreateCreate', () async {
      // TODO
    });

    //Future adminSubscriptionPlansDeleteDelete(String slug) async
    test('test adminSubscriptionPlansDeleteDelete', () async {
      // TODO
    });

    //Future<List<SubscriptionPlan>> adminSubscriptionPlansList() async
    test('test adminSubscriptionPlansList', () async {
      // TODO
    });

    //Future<SubscriptionPlan> adminSubscriptionPlansRead(String slug) async
    test('test adminSubscriptionPlansRead', () async {
      // TODO
    });

    //Future<SubscriptionPlan> adminSubscriptionPlansUpdatePartialUpdate(String slug, SubscriptionPlan data) async
    test('test adminSubscriptionPlansUpdatePartialUpdate', () async {
      // TODO
    });

    //Future<SubscriptionPlan> adminSubscriptionPlansUpdateUpdate(String slug, SubscriptionPlan data) async
    test('test adminSubscriptionPlansUpdateUpdate', () async {
      // TODO
    });

    // Récupère toutes les transactions des partner sans filtre ni tri pour le super user.
    //
    // Retourne la liste complète des transactions des partenaire connecté, avec les totaux calculés (montant total, revenus, paiements).
    //
    //Future<List<WalletTransaction>> adminWalletAllTransactionsList() async
    test('test adminWalletAllTransactionsList', () async {
      // TODO
    });

    // Récupère toutes les transactions avec filtres, tri, recherche et pagination (SuperAdmin).
    //
    // Retourne la liste complète des transactions avec filtres (statut, type, modèle, période), tri, recherche et pagination.
    //
    //Future<List<WalletTransaction>> adminWalletTransactionsList({ String search, String status, String type, String modelType, String period, String startDate, String endDate, String sort }) async
    test('test adminWalletTransactionsList', () async {
      // TODO
    });

    // Récupère la liste des demandes de retraits (SuperAdmin).
    //
    // Retourne la liste des demandes de retraits avec recherche, filtres, tri et pagination.
    //
    //Future<List<WithdrawalRequest>> adminWithdrawalsList({ String search, String status, String period, String startDate, String endDate }) async
    test('test adminWithdrawalsList', () async {
      // TODO
    });

    //Future<UpdateWithdrawalRequestStatus> adminWithdrawalsUpdateStatusPartialUpdate(String reference, UpdateWithdrawalRequestStatus data) async
    test('test adminWithdrawalsUpdateStatusPartialUpdate', () async {
      // TODO
    });

    //Future<UpdateWithdrawalRequestStatus> adminWithdrawalsUpdateStatusUpdate(String reference, UpdateWithdrawalRequestStatus data) async
    test('test adminWithdrawalsUpdateStatusUpdate', () async {
      // TODO
    });

  });
}
