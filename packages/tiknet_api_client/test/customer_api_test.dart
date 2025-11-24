import 'package:test/test.dart';
import 'package:tiknet_api_client/tiknet_api_client.dart';


/// tests for CustomerApi
void main() {
  final instance = TiknetApiClient().getCustomerApi();

  group(CustomerApi, () {
    //Future customerActivateInternetCreate() async
    test('test customerActivateInternetCreate', () async {
      // TODO
    });

    //Future customerCheckActiveConnexionList() async
    test('test customerCheckActiveConnexionList', () async {
      // TODO
    });

    //Future customerCheckActivePlanList() async
    test('test customerCheckActivePlanList', () async {
      // TODO
    });

    // Récupère les plans pour le router par défaut de l'utilisateur connecté.
    //
    //Future customerDefaultRouterPlansList() async
    test('test customerDefaultRouterPlansList', () async {
      // TODO
    });

    //Future customerExchangeRateList() async
    test('test customerExchangeRateList', () async {
      // TODO
    });

    //Future customerPlansDetailList(String slug) async
    test('test customerPlansDetailList', () async {
      // TODO
    });

    //Future customerProfileList() async
    test('test customerProfileList', () async {
      // TODO
    });

    //Future customerProfileUpdateUpdate() async
    test('test customerProfileUpdateUpdate', () async {
      // TODO
    });

    //Future customerPurchaseAdditionalDeviceCreate() async
    test('test customerPurchaseAdditionalDeviceCreate', () async {
      // TODO
    });

    //Future customerPurchasePlanCreate() async
    test('test customerPurchasePlanCreate', () async {
      // TODO
    });

    //Future customerRadiusDataList() async
    test('test customerRadiusDataList', () async {
      // TODO
    });

    // Récupère la liste des plans associés à l'utilisateur authentifié depuis la table user_plans.
    //
    //Future<CustomerRadiusPlansList200Response> customerRadiusPlansList() async
    test('test customerRadiusPlansList', () async {
      // TODO
    });

    //Future<CustomerRegister> customerRegisterCreate(CustomerRegister data) async
    test('test customerRegisterCreate', () async {
      // TODO
    });

    //Future customerRemainingTimeList() async
    test('test customerRemainingTimeList', () async {
      // TODO
    });

    //Future customerResendOtpCreate() async
    test('test customerResendOtpCreate', () async {
      // TODO
    });

    //Future customerResendVerifyEmailOtpCreate() async
    test('test customerResendVerifyEmailOtpCreate', () async {
      // TODO
    });

    //Future customerRoamingPlansList() async
    test('test customerRoamingPlansList', () async {
      // TODO
    });

    //Future customerRoamingPlansRead(String slug) async
    test('test customerRoamingPlansRead', () async {
      // TODO
    });

    //Future customerRouterPlansList() async
    test('test customerRouterPlansList', () async {
      // TODO
    });

    //Future customerRouterPlansRead(String slug) async
    test('test customerRouterPlansRead', () async {
      // TODO
    });

    //Future<CustomerSignIn> customerSigninCreate(CustomerSignIn data) async
    test('test customerSigninCreate', () async {
      // TODO
    });

    //Future<CustomerTokenObtainPair> customerTokenCreate(CustomerTokenObtainPair data) async
    test('test customerTokenCreate', () async {
      // TODO
    });

    //Future<TokenRefresh> customerTokenRefreshCreate(TokenRefresh data) async
    test('test customerTokenRefreshCreate', () async {
      // TODO
    });

    //Future customerTransactionsList() async
    test('test customerTransactionsList', () async {
      // TODO
    });

    //Future customerVerifyDeviceCreate() async
    test('test customerVerifyDeviceCreate', () async {
      // TODO
    });

    //Future customerVerifyEmailOtpCreate() async
    test('test customerVerifyEmailOtpCreate', () async {
      // TODO
    });

  });
}
