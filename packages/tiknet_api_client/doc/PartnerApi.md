# tiknet_api_client.api.PartnerApi

## Load the API package
```dart
import 'package:tiknet_api_client/api.dart';
```

All URIs are relative to *https://api.tiknetafrica.com/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**partnerAdditionalDevicesCreateCreate**](PartnerApi.md#partneradditionaldevicescreatecreate) | **POST** /partner/additional-devices/create/ | 
[**partnerAdditionalDevicesDeleteDelete**](PartnerApi.md#partneradditionaldevicesdeletedelete) | **DELETE** /partner/additional-devices/{id}/delete/ | 
[**partnerAdditionalDevicesList**](PartnerApi.md#partneradditionaldeviceslist) | **GET** /partner/additional-devices/ | 
[**partnerAdditionalDevicesPartialUpdate**](PartnerApi.md#partneradditionaldevicespartialupdate) | **PATCH** /partner/additional-devices/{id}/ | 
[**partnerAdditionalDevicesRead**](PartnerApi.md#partneradditionaldevicesread) | **GET** /partner/additional-devices/{id}/ | 
[**partnerAdditionalDevicesUpdate**](PartnerApi.md#partneradditionaldevicesupdate) | **PUT** /partner/additional-devices/{id}/ | 
[**partnerAssignPlanCreate**](PartnerApi.md#partnerassignplancreate) | **POST** /partner/assign-plan/ | 
[**partnerAssignedPlansList**](PartnerApi.md#partnerassignedplanslist) | **GET** /partner/assigned-plans/ | 
[**partnerChangePasswordCreate**](PartnerApi.md#partnerchangepasswordcreate) | **POST** /partner/change-password/ | Changer le mot de passe (Partner/Collaborator)
[**partnerCheckTokenList**](PartnerApi.md#partnerchecktokenlist) | **GET** /partner/check-token/ | 
[**partnerCollaboratorsAssignRoleCreate**](PartnerApi.md#partnercollaboratorsassignrolecreate) | **POST** /partner/collaborators/{username}/assign-role/ | Assigner un rôle à un collaborateur
[**partnerCollaboratorsCreateCreate**](PartnerApi.md#partnercollaboratorscreatecreate) | **POST** /partner/collaborators/create/ | 
[**partnerCollaboratorsDeleteDelete**](PartnerApi.md#partnercollaboratorsdeletedelete) | **DELETE** /partner/collaborators/{username}/delete/ | Supprimer un collaborateur
[**partnerCollaboratorsList**](PartnerApi.md#partnercollaboratorslist) | **GET** /partner/collaborators/ | 
[**partnerCollaboratorsUpdateRoleUpdate**](PartnerApi.md#partnercollaboratorsupdateroleupdate) | **PUT** /partner/collaborators/{username}/update-role/ | Mettre à jour le rôle d’un collaborateur
[**partnerCustomersAllListList**](PartnerApi.md#partnercustomersalllistlist) | **GET** /partner/customers/all/list/ | 
[**partnerCustomersBlockOrUnblockPartialUpdate**](PartnerApi.md#partnercustomersblockorunblockpartialupdate) | **PATCH** /partner/customers/{username}/block-or-unblock/ | 
[**partnerCustomersBlockOrUnblockUpdate**](PartnerApi.md#partnercustomersblockorunblockupdate) | **PUT** /partner/customers/{username}/block-or-unblock/ | 
[**partnerCustomersListList**](PartnerApi.md#partnercustomerslistlist) | **GET** /partner/customers/list/ | 
[**partnerCustomersPaginateListList**](PartnerApi.md#partnercustomerspaginatelistlist) | **GET** /partner/customers/paginate-list/ | 
[**partnerCustomersTransactionsList**](PartnerApi.md#partnercustomerstransactionslist) | **GET** /partner/customers/{username}/transactions/ | Récupère les transactions d’un client spécifique
[**partnerDashboardList**](PartnerApi.md#partnerdashboardlist) | **GET** /partner/dashboard/ | 
[**partnerDataLimitCreateCreate**](PartnerApi.md#partnerdatalimitcreatecreate) | **POST** /partner/data-limit/create/ | 
[**partnerDataLimitDeleteDelete**](PartnerApi.md#partnerdatalimitdeletedelete) | **DELETE** /partner/data-limit/{id}/delete/ | 
[**partnerDataLimitList**](PartnerApi.md#partnerdatalimitlist) | **GET** /partner/data-limit/ | 
[**partnerDataLimitPartialUpdate**](PartnerApi.md#partnerdatalimitpartialupdate) | **PATCH** /partner/data-limit/{id}/ | 
[**partnerDataLimitRead**](PartnerApi.md#partnerdatalimitread) | **GET** /partner/data-limit/{id}/ | 
[**partnerDataLimitUpdate**](PartnerApi.md#partnerdatalimitupdate) | **PUT** /partner/data-limit/{id}/ | 
[**partnerHotspotProfilesCreateCreate**](PartnerApi.md#partnerhotspotprofilescreatecreate) | **POST** /partner/hotspot/profiles/create/ | 
[**partnerHotspotProfilesDeleteDelete**](PartnerApi.md#partnerhotspotprofilesdeletedelete) | **DELETE** /partner/hotspot/profiles/{profile_slug}/delete/ | 
[**partnerHotspotProfilesDetailList**](PartnerApi.md#partnerhotspotprofilesdetaillist) | **GET** /partner/hotspot/profiles/{profile_slug}/detail/ | 
[**partnerHotspotProfilesListList**](PartnerApi.md#partnerhotspotprofileslistlist) | **GET** /partner/hotspot/profiles/list/ | 
[**partnerHotspotProfilesPaginateListList**](PartnerApi.md#partnerhotspotprofilespaginatelistlist) | **GET** /partner/hotspot/profiles/paginate-list/ | 
[**partnerHotspotProfilesUpdateList**](PartnerApi.md#partnerhotspotprofilesupdatelist) | **GET** /partner/hotspot/profiles/{profile_slug}/update/ | 
[**partnerHotspotProfilesUpdateUpdate**](PartnerApi.md#partnerhotspotprofilesupdateupdate) | **PUT** /partner/hotspot/profiles/{profile_slug}/update/ | 
[**partnerHotspotUsersCreateCreate**](PartnerApi.md#partnerhotspotuserscreatecreate) | **POST** /partner/hotspot/users/create/ | 
[**partnerHotspotUsersDeleteDelete**](PartnerApi.md#partnerhotspotusersdeletedelete) | **DELETE** /partner/hotspot/users/{id}/delete/ | 
[**partnerHotspotUsersListList**](PartnerApi.md#partnerhotspotuserslistlist) | **GET** /partner/hotspot/users/list/ | 
[**partnerHotspotUsersReadList**](PartnerApi.md#partnerhotspotusersreadlist) | **GET** /partner/hotspot/users/{username}/read/ | 
[**partnerHotspotUsersUpdateUpdate**](PartnerApi.md#partnerhotspotusersupdateupdate) | **PUT** /partner/hotspot/users/{username}/update/ | 
[**partnerIdleTimeoutCreateCreate**](PartnerApi.md#partneridletimeoutcreatecreate) | **POST** /partner/idle-timeout/create/ | 
[**partnerIdleTimeoutDeleteDelete**](PartnerApi.md#partneridletimeoutdeletedelete) | **DELETE** /partner/idle-timeout/{id}/delete/ | 
[**partnerIdleTimeoutList**](PartnerApi.md#partneridletimeoutlist) | **GET** /partner/idle-timeout/ | 
[**partnerIdleTimeoutPartialUpdate**](PartnerApi.md#partneridletimeoutpartialupdate) | **PATCH** /partner/idle-timeout/{id}/ | 
[**partnerIdleTimeoutRead**](PartnerApi.md#partneridletimeoutread) | **GET** /partner/idle-timeout/{id}/ | 
[**partnerIdleTimeoutUpdate**](PartnerApi.md#partneridletimeoutupdate) | **PUT** /partner/idle-timeout/{id}/ | 
[**partnerLoginCreate**](PartnerApi.md#partnerlogincreate) | **POST** /partner/login/ | 
[**partnerPasswordResetOtpVerifyCreate**](PartnerApi.md#partnerpasswordresetotpverifycreate) | **POST** /partner/password-reset-otp-verify/ | 
[**partnerPasswordResetRequestOtpCreate**](PartnerApi.md#partnerpasswordresetrequestotpcreate) | **POST** /partner/password-reset-request-otp/ | 
[**partnerPaymentMethodsCreateCreate**](PartnerApi.md#partnerpaymentmethodscreatecreate) | **POST** /partner/payment-methods/create/ | 
[**partnerPaymentMethodsDeleteDelete**](PartnerApi.md#partnerpaymentmethodsdeletedelete) | **DELETE** /partner/payment-methods/{slug}/delete/ | 
[**partnerPaymentMethodsList**](PartnerApi.md#partnerpaymentmethodslist) | **GET** /partner/payment-methods/ | 
[**partnerPaymentMethodsRead**](PartnerApi.md#partnerpaymentmethodsread) | **GET** /partner/payment-methods/{slug}/ | 
[**partnerPaymentMethodsUpdatePartialUpdate**](PartnerApi.md#partnerpaymentmethodsupdatepartialupdate) | **PATCH** /partner/payment-methods/{slug}/update/ | 
[**partnerPaymentMethodsUpdateUpdate**](PartnerApi.md#partnerpaymentmethodsupdateupdate) | **PUT** /partner/payment-methods/{slug}/update/ | 
[**partnerPlansCreateCreate**](PartnerApi.md#partnerplanscreatecreate) | **POST** /partner/plans/create/ | 
[**partnerPlansDeleteDelete**](PartnerApi.md#partnerplansdeletedelete) | **DELETE** /partner/plans/{plan_slug}/delete/ | 
[**partnerPlansList**](PartnerApi.md#partnerplanslist) | **GET** /partner/plans/ | 
[**partnerPlansReadList**](PartnerApi.md#partnerplansreadlist) | **GET** /partner/plans/{plan_slug}/read/ | 
[**partnerPlansUpdateUpdate**](PartnerApi.md#partnerplansupdateupdate) | **PUT** /partner/plans/{plan_slug}/update/ | 
[**partnerProfileList**](PartnerApi.md#partnerprofilelist) | **GET** /partner/profile/ | 
[**partnerPurchaseSubscriptionPlanCreate**](PartnerApi.md#partnerpurchasesubscriptionplancreate) | **POST** /partner/purchase-subscription-plan/ | 
[**partnerRateLimitCreateCreate**](PartnerApi.md#partnerratelimitcreatecreate) | **POST** /partner/rate-limit/create/ | 
[**partnerRateLimitDeleteDelete**](PartnerApi.md#partnerratelimitdeletedelete) | **DELETE** /partner/rate-limit/{id}/delete/ | 
[**partnerRateLimitList**](PartnerApi.md#partnerratelimitlist) | **GET** /partner/rate-limit/ | 
[**partnerRateLimitPartialUpdate**](PartnerApi.md#partnerratelimitpartialupdate) | **PATCH** /partner/rate-limit/{id}/ | 
[**partnerRateLimitRead**](PartnerApi.md#partnerratelimitread) | **GET** /partner/rate-limit/{id}/ | 
[**partnerRateLimitUpdate**](PartnerApi.md#partnerratelimitupdate) | **PUT** /partner/rate-limit/{id}/ | 
[**partnerRefreshTokenCreate**](PartnerApi.md#partnerrefreshtokencreate) | **POST** /partner/refresh/token/ | 
[**partnerRegisterConfirmCreate**](PartnerApi.md#partnerregisterconfirmcreate) | **POST** /partner/register-confirm/ | 
[**partnerRegisterCreate**](PartnerApi.md#partnerregistercreate) | **POST** /partner/register/ | 
[**partnerResendVerifyEmailOtpCreate**](PartnerApi.md#partnerresendverifyemailotpcreate) | **POST** /partner/resend-verify-email-otp/ | 
[**partnerResetPasswordCreate**](PartnerApi.md#partnerresetpasswordcreate) | **POST** /partner/reset-password/ | 
[**partnerRolesCreateCreate**](PartnerApi.md#partnerrolescreatecreate) | **POST** /partner/roles/create/ | 
[**partnerRolesDeleteDelete**](PartnerApi.md#partnerrolesdeletedelete) | **DELETE** /partner/roles/{slug}/delete/ | 
[**partnerRolesList**](PartnerApi.md#partnerroleslist) | **GET** /partner/roles/ | 
[**partnerRolesRead**](PartnerApi.md#partnerrolesread) | **GET** /partner/roles/{slug}/ | 
[**partnerRolesUpdatePartialUpdate**](PartnerApi.md#partnerrolesupdatepartialupdate) | **PATCH** /partner/roles/{slug}/update/ | 
[**partnerRolesUpdateUpdate**](PartnerApi.md#partnerrolesupdateupdate) | **PUT** /partner/roles/{slug}/update/ | 
[**partnerRoutersActiveUsersList**](PartnerApi.md#partnerroutersactiveuserslist) | **GET** /partner/routers/{slug}/active-users/ | 👥 Récupérer les utilisateurs actifs
[**partnerRoutersAddCreate**](PartnerApi.md#partnerroutersaddcreate) | **POST** /partner/routers-add/ | 
[**partnerRoutersDeleteDelete**](PartnerApi.md#partnerroutersdeletedelete) | **DELETE** /partner/routers/{router_id}/delete/ | 
[**partnerRoutersDetailsList**](PartnerApi.md#partnerroutersdetailslist) | **GET** /partner/routers/{router_slug}/details/ | 
[**partnerRoutersHotspotsRestartCreate**](PartnerApi.md#partnerroutershotspotsrestartcreate) | **POST** /partner/routers/{slug}/hotspots/restart/ | 🔁 Redémarrer les Hotspots d’un routeur
[**partnerRoutersListList**](PartnerApi.md#partnerrouterslistlist) | **GET** /partner/routers/list/ | 
[**partnerRoutersRebootCreate**](PartnerApi.md#partnerroutersrebootcreate) | **POST** /partner/routers/{slug}/reboot/ | 🔄 Redémarrer un routeur MikroTik
[**partnerRoutersResourcesList**](PartnerApi.md#partnerroutersresourceslist) | **GET** /partner/routers/{slug}/resources/ | 🔍 Récupérer les ressources système d’un routeur
[**partnerRoutersUpdateUpdate**](PartnerApi.md#partnerroutersupdateupdate) | **PUT** /partner/routers/{router_slug}/update/ | 
[**partnerSessionsActiveList**](PartnerApi.md#partnersessionsactivelist) | **GET** /partner/sessions/active/ | 
[**partnerSessionsDisconnectCreate**](PartnerApi.md#partnersessionsdisconnectcreate) | **POST** /partner/sessions/disconnect/ | 
[**partnerSharedUsersCreateCreate**](PartnerApi.md#partnershareduserscreatecreate) | **POST** /partner/shared-users/create/ | 
[**partnerSharedUsersDeleteDelete**](PartnerApi.md#partnersharedusersdeletedelete) | **DELETE** /partner/shared-users/{id}/delete/ | 
[**partnerSharedUsersList**](PartnerApi.md#partnershareduserslist) | **GET** /partner/shared-users/ | 
[**partnerSharedUsersPartialUpdate**](PartnerApi.md#partnershareduserspartialupdate) | **PATCH** /partner/shared-users/{id}/ | 
[**partnerSharedUsersRead**](PartnerApi.md#partnersharedusersread) | **GET** /partner/shared-users/{id}/ | 
[**partnerSharedUsersUpdate**](PartnerApi.md#partnersharedusersupdate) | **PUT** /partner/shared-users/{id}/ | 
[**partnerTransactionsAdditionalDevicesList**](PartnerApi.md#partnertransactionsadditionaldeviceslist) | **GET** /partner/transactions/additional-devices/ | 
[**partnerTransactionsAssignedPlansList**](PartnerApi.md#partnertransactionsassignedplanslist) | **GET** /partner/transactions/assigned-plans/ | 
[**partnerTransactionsList**](PartnerApi.md#partnertransactionslist) | **GET** /partner/transactions/ | 
[**partnerUpdatePartialUpdate**](PartnerApi.md#partnerupdatepartialupdate) | **PATCH** /partner/update/ | 
[**partnerUpdateUpdate**](PartnerApi.md#partnerupdateupdate) | **PUT** /partner/update/ | 
[**partnerValidityCreateCreate**](PartnerApi.md#partnervaliditycreatecreate) | **POST** /partner/validity/create/ | 
[**partnerValidityDeleteDelete**](PartnerApi.md#partnervaliditydeletedelete) | **DELETE** /partner/validity/{id}/delete/ | 
[**partnerValidityList**](PartnerApi.md#partnervaliditylist) | **GET** /partner/validity/ | 
[**partnerValidityPartialUpdate**](PartnerApi.md#partnervaliditypartialupdate) | **PATCH** /partner/validity/{id}/ | 
[**partnerValidityRead**](PartnerApi.md#partnervalidityread) | **GET** /partner/validity/{id}/ | 
[**partnerValidityUpdate**](PartnerApi.md#partnervalidityupdate) | **PUT** /partner/validity/{id}/ | 
[**partnerVerifyEmailOtpCreate**](PartnerApi.md#partnerverifyemailotpcreate) | **POST** /partner/verify-email-otp/ | 
[**partnerWalletAllTransactionsList**](PartnerApi.md#partnerwalletalltransactionslist) | **GET** /partner/wallet/all-transactions/ | Récupère toutes les transactions du partenaire sans filtre ni tri.
[**partnerWalletBalanceRead**](PartnerApi.md#partnerwalletbalanceread) | **GET** /partner/wallet/balance/ | Récupère le solde du wallet du partner
[**partnerWalletTransactionsList**](PartnerApi.md#partnerwallettransactionslist) | **GET** /partner/wallet/transactions/ | Récupère les transactions du partenaire connecté avec filtres, recherche et pagination.
[**partnerWithdrawalsCreateCreate**](PartnerApi.md#partnerwithdrawalscreatecreate) | **POST** /partner/withdrawals/create/ | 
[**partnerWithdrawalsList**](PartnerApi.md#partnerwithdrawalslist) | **GET** /partner/withdrawals/ | Récupère la liste des demandes de retraits (Partner).


# **partnerAdditionalDevicesCreateCreate**
> partnerAdditionalDevicesCreateCreate()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();

try {
    api.partnerAdditionalDevicesCreateCreate();
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerAdditionalDevicesCreateCreate: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerAdditionalDevicesDeleteDelete**
> partnerAdditionalDevicesDeleteDelete(id)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String id = id_example; // String | 

try {
    api.partnerAdditionalDevicesDeleteDelete(id);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerAdditionalDevicesDeleteDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerAdditionalDevicesList**
> partnerAdditionalDevicesList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();

try {
    api.partnerAdditionalDevicesList();
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerAdditionalDevicesList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerAdditionalDevicesPartialUpdate**
> partnerAdditionalDevicesPartialUpdate(id)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String id = id_example; // String | 

try {
    api.partnerAdditionalDevicesPartialUpdate(id);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerAdditionalDevicesPartialUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerAdditionalDevicesRead**
> partnerAdditionalDevicesRead(id)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String id = id_example; // String | 

try {
    api.partnerAdditionalDevicesRead(id);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerAdditionalDevicesRead: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerAdditionalDevicesUpdate**
> partnerAdditionalDevicesUpdate(id)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String id = id_example; // String | 

try {
    api.partnerAdditionalDevicesUpdate(id);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerAdditionalDevicesUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerAssignPlanCreate**
> partnerAssignPlanCreate()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();

try {
    api.partnerAssignPlanCreate();
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerAssignPlanCreate: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerAssignedPlansList**
> partnerAssignedPlansList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();

try {
    api.partnerAssignedPlansList();
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerAssignedPlansList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerChangePasswordCreate**
> partnerChangePasswordCreate(data)

Changer le mot de passe (Partner/Collaborator)

 Cette API permet à un utilisateur connecté (partenaire ou collaborateur) de modifier son mot de passe en fournissant l'ancien mot de passe et le nouveau. 

### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final PartnerChangePasswordCreateRequest data = ; // PartnerChangePasswordCreateRequest | 

try {
    api.partnerChangePasswordCreate(data);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerChangePasswordCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **data** | [**PartnerChangePasswordCreateRequest**](PartnerChangePasswordCreateRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerCheckTokenList**
> partnerCheckTokenList()



Vérifie la validité du token et retourne les informations de l'utilisateur.

### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();

try {
    api.partnerCheckTokenList();
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerCheckTokenList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerCollaboratorsAssignRoleCreate**
> partnerCollaboratorsAssignRoleCreate(username, data)

Assigner un rôle à un collaborateur

 Cette API permet à un partenaire d’assigner un rôle à un collaborateur existant. Le rôle doit appartenir au même partenaire. 

### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String username = username_example; // String | Nom d'utilisateur du collaborateur
final PartnerCollaboratorsAssignRoleCreateRequest data = ; // PartnerCollaboratorsAssignRoleCreateRequest | 

try {
    api.partnerCollaboratorsAssignRoleCreate(username, data);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerCollaboratorsAssignRoleCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **username** | **String**| Nom d'utilisateur du collaborateur | 
 **data** | [**PartnerCollaboratorsAssignRoleCreateRequest**](PartnerCollaboratorsAssignRoleCreateRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerCollaboratorsCreateCreate**
> PartnerCollaboratorRegister partnerCollaboratorsCreateCreate(data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final PartnerCollaboratorRegister data = ; // PartnerCollaboratorRegister | 

try {
    final response = api.partnerCollaboratorsCreateCreate(data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerCollaboratorsCreateCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **data** | [**PartnerCollaboratorRegister**](PartnerCollaboratorRegister.md)|  | 

### Return type

[**PartnerCollaboratorRegister**](PartnerCollaboratorRegister.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerCollaboratorsDeleteDelete**
> partnerCollaboratorsDeleteDelete(username)

Supprimer un collaborateur

 Cette API permet à un partenaire de supprimer un collaborateur existant associé à son compte. Le collaborateur sera supprimé de la base de données. 

### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String username = username_example; // String | Nom d'utilisateur du collaborateur à supprimer

try {
    api.partnerCollaboratorsDeleteDelete(username);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerCollaboratorsDeleteDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **username** | **String**| Nom d'utilisateur du collaborateur à supprimer | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerCollaboratorsList**
> partnerCollaboratorsList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();

try {
    api.partnerCollaboratorsList();
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerCollaboratorsList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerCollaboratorsUpdateRoleUpdate**
> partnerCollaboratorsUpdateRoleUpdate(username, data)

Mettre à jour le rôle d’un collaborateur

 Cette API permet à un partenaire de modifier le rôle d’un collaborateur déjà existant. Le nouveau rôle doit appartenir au même partenaire. 

### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String username = username_example; // String | Nom d'utilisateur du collaborateur
final PartnerCollaboratorsUpdateRoleUpdateRequest data = ; // PartnerCollaboratorsUpdateRoleUpdateRequest | 

try {
    api.partnerCollaboratorsUpdateRoleUpdate(username, data);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerCollaboratorsUpdateRoleUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **username** | **String**| Nom d'utilisateur du collaborateur | 
 **data** | [**PartnerCollaboratorsUpdateRoleUpdateRequest**](PartnerCollaboratorsUpdateRoleUpdateRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerCustomersAllListList**
> partnerCustomersAllListList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();

try {
    api.partnerCustomersAllListList();
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerCustomersAllListList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerCustomersBlockOrUnblockPartialUpdate**
> PartnerBlockOrUnblockCustomer partnerCustomersBlockOrUnblockPartialUpdate(username, data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String username = username_example; // String | 
final PartnerBlockOrUnblockCustomer data = ; // PartnerBlockOrUnblockCustomer | 

try {
    final response = api.partnerCustomersBlockOrUnblockPartialUpdate(username, data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerCustomersBlockOrUnblockPartialUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **username** | **String**|  | 
 **data** | [**PartnerBlockOrUnblockCustomer**](PartnerBlockOrUnblockCustomer.md)|  | 

### Return type

[**PartnerBlockOrUnblockCustomer**](PartnerBlockOrUnblockCustomer.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerCustomersBlockOrUnblockUpdate**
> PartnerBlockOrUnblockCustomer partnerCustomersBlockOrUnblockUpdate(username, data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String username = username_example; // String | 
final PartnerBlockOrUnblockCustomer data = ; // PartnerBlockOrUnblockCustomer | 

try {
    final response = api.partnerCustomersBlockOrUnblockUpdate(username, data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerCustomersBlockOrUnblockUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **username** | **String**|  | 
 **data** | [**PartnerBlockOrUnblockCustomer**](PartnerBlockOrUnblockCustomer.md)|  | 

### Return type

[**PartnerBlockOrUnblockCustomer**](PartnerBlockOrUnblockCustomer.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerCustomersListList**
> partnerCustomersListList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();

try {
    api.partnerCustomersListList();
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerCustomersListList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerCustomersPaginateListList**
> partnerCustomersPaginateListList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();

try {
    api.partnerCustomersPaginateListList();
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerCustomersPaginateListList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerCustomersTransactionsList**
> List<WalletTransaction> partnerCustomersTransactionsList(username, search, status, period, startDate, endDate, sort)

Récupère les transactions d’un client spécifique

Cette API permet au partenaire connecté de **récupérer la liste des transactions** de type `revenue` pour un **client spécifique** (identifié par son `username`).  **Filtres disponibles :** - `search`: référence, statut, montant... - `status`: success / pending / failed - `period`: today / this_week / this_month / this_year - `start_date` et `end_date`  **Réponse :** Retourne les transactions du client, avec pagination et totaux.

### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String username = username_example; // String | Nom d’utilisateur (username) du client dont on veut les transactions
final String search = search_example; // String | Recherche (référence, statut, montant...)
final String status = status_example; // String | Filtrer par status (success/pending/failed)
final String period = period_example; // String | Période (today/this_week/this_month/this_year)
final String startDate = startDate_example; // String | Date de début (YYYY-MM-DD)
final String endDate = endDate_example; // String | Date de fin (YYYY-MM-DD)
final String sort = sort_example; // String | Tri : amount_asc / amount_desc / date (défaut)

try {
    final response = api.partnerCustomersTransactionsList(username, search, status, period, startDate, endDate, sort);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerCustomersTransactionsList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **username** | **String**| Nom d’utilisateur (username) du client dont on veut les transactions | 
 **search** | **String**| Recherche (référence, statut, montant...) | [optional] 
 **status** | **String**| Filtrer par status (success/pending/failed) | [optional] 
 **period** | **String**| Période (today/this_week/this_month/this_year) | [optional] 
 **startDate** | **String**| Date de début (YYYY-MM-DD) | [optional] 
 **endDate** | **String**| Date de fin (YYYY-MM-DD) | [optional] 
 **sort** | **String**| Tri : amount_asc / amount_desc / date (défaut) | [optional] 

### Return type

[**List&lt;WalletTransaction&gt;**](WalletTransaction.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerDashboardList**
> partnerDashboardList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();

try {
    api.partnerDashboardList();
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerDashboardList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerDataLimitCreateCreate**
> partnerDataLimitCreateCreate()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();

try {
    api.partnerDataLimitCreateCreate();
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerDataLimitCreateCreate: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerDataLimitDeleteDelete**
> partnerDataLimitDeleteDelete(id)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String id = id_example; // String | 

try {
    api.partnerDataLimitDeleteDelete(id);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerDataLimitDeleteDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerDataLimitList**
> partnerDataLimitList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();

try {
    api.partnerDataLimitList();
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerDataLimitList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerDataLimitPartialUpdate**
> partnerDataLimitPartialUpdate(id)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String id = id_example; // String | 

try {
    api.partnerDataLimitPartialUpdate(id);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerDataLimitPartialUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerDataLimitRead**
> partnerDataLimitRead(id)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String id = id_example; // String | 

try {
    api.partnerDataLimitRead(id);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerDataLimitRead: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerDataLimitUpdate**
> partnerDataLimitUpdate(id)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String id = id_example; // String | 

try {
    api.partnerDataLimitUpdate(id);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerDataLimitUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerHotspotProfilesCreateCreate**
> partnerHotspotProfilesCreateCreate()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();

try {
    api.partnerHotspotProfilesCreateCreate();
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerHotspotProfilesCreateCreate: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerHotspotProfilesDeleteDelete**
> partnerHotspotProfilesDeleteDelete(profileSlug)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String profileSlug = profileSlug_example; // String | 

try {
    api.partnerHotspotProfilesDeleteDelete(profileSlug);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerHotspotProfilesDeleteDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **profileSlug** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerHotspotProfilesDetailList**
> partnerHotspotProfilesDetailList(profileSlug)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String profileSlug = profileSlug_example; // String | 

try {
    api.partnerHotspotProfilesDetailList(profileSlug);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerHotspotProfilesDetailList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **profileSlug** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerHotspotProfilesListList**
> partnerHotspotProfilesListList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();

try {
    api.partnerHotspotProfilesListList();
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerHotspotProfilesListList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerHotspotProfilesPaginateListList**
> partnerHotspotProfilesPaginateListList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();

try {
    api.partnerHotspotProfilesPaginateListList();
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerHotspotProfilesPaginateListList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerHotspotProfilesUpdateList**
> partnerHotspotProfilesUpdateList(profileSlug)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String profileSlug = profileSlug_example; // String | 

try {
    api.partnerHotspotProfilesUpdateList(profileSlug);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerHotspotProfilesUpdateList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **profileSlug** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerHotspotProfilesUpdateUpdate**
> partnerHotspotProfilesUpdateUpdate(profileSlug)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String profileSlug = profileSlug_example; // String | 

try {
    api.partnerHotspotProfilesUpdateUpdate(profileSlug);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerHotspotProfilesUpdateUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **profileSlug** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerHotspotUsersCreateCreate**
> partnerHotspotUsersCreateCreate()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();

try {
    api.partnerHotspotUsersCreateCreate();
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerHotspotUsersCreateCreate: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerHotspotUsersDeleteDelete**
> partnerHotspotUsersDeleteDelete(id)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String id = id_example; // String | 

try {
    api.partnerHotspotUsersDeleteDelete(id);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerHotspotUsersDeleteDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerHotspotUsersListList**
> partnerHotspotUsersListList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();

try {
    api.partnerHotspotUsersListList();
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerHotspotUsersListList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerHotspotUsersReadList**
> partnerHotspotUsersReadList(username)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String username = username_example; // String | 

try {
    api.partnerHotspotUsersReadList(username);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerHotspotUsersReadList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **username** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerHotspotUsersUpdateUpdate**
> partnerHotspotUsersUpdateUpdate(username)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String username = username_example; // String | 

try {
    api.partnerHotspotUsersUpdateUpdate(username);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerHotspotUsersUpdateUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **username** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerIdleTimeoutCreateCreate**
> partnerIdleTimeoutCreateCreate()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();

try {
    api.partnerIdleTimeoutCreateCreate();
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerIdleTimeoutCreateCreate: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerIdleTimeoutDeleteDelete**
> partnerIdleTimeoutDeleteDelete(id)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String id = id_example; // String | 

try {
    api.partnerIdleTimeoutDeleteDelete(id);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerIdleTimeoutDeleteDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerIdleTimeoutList**
> partnerIdleTimeoutList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();

try {
    api.partnerIdleTimeoutList();
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerIdleTimeoutList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerIdleTimeoutPartialUpdate**
> partnerIdleTimeoutPartialUpdate(id)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String id = id_example; // String | 

try {
    api.partnerIdleTimeoutPartialUpdate(id);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerIdleTimeoutPartialUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerIdleTimeoutRead**
> partnerIdleTimeoutRead(id)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String id = id_example; // String | 

try {
    api.partnerIdleTimeoutRead(id);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerIdleTimeoutRead: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerIdleTimeoutUpdate**
> partnerIdleTimeoutUpdate(id)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String id = id_example; // String | 

try {
    api.partnerIdleTimeoutUpdate(id);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerIdleTimeoutUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerLoginCreate**
> MyTokenObtainPair partnerLoginCreate(data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final MyTokenObtainPair data = ; // MyTokenObtainPair | 

try {
    final response = api.partnerLoginCreate(data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerLoginCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **data** | [**MyTokenObtainPair**](MyTokenObtainPair.md)|  | 

### Return type

[**MyTokenObtainPair**](MyTokenObtainPair.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerPasswordResetOtpVerifyCreate**
> PartnerPasswordResetOtpCodeVerify partnerPasswordResetOtpVerifyCreate(data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final PartnerPasswordResetOtpCodeVerify data = ; // PartnerPasswordResetOtpCodeVerify | 

try {
    final response = api.partnerPasswordResetOtpVerifyCreate(data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerPasswordResetOtpVerifyCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **data** | [**PartnerPasswordResetOtpCodeVerify**](PartnerPasswordResetOtpCodeVerify.md)|  | 

### Return type

[**PartnerPasswordResetOtpCodeVerify**](PartnerPasswordResetOtpCodeVerify.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerPasswordResetRequestOtpCreate**
> PartnerPasswordResetOTPRequest partnerPasswordResetRequestOtpCreate(data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final PartnerPasswordResetOTPRequest data = ; // PartnerPasswordResetOTPRequest | 

try {
    final response = api.partnerPasswordResetRequestOtpCreate(data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerPasswordResetRequestOtpCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **data** | [**PartnerPasswordResetOTPRequest**](PartnerPasswordResetOTPRequest.md)|  | 

### Return type

[**PartnerPasswordResetOTPRequest**](PartnerPasswordResetOTPRequest.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerPaymentMethodsCreateCreate**
> PaymentMethod partnerPaymentMethodsCreateCreate(data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final PaymentMethod data = ; // PaymentMethod | 

try {
    final response = api.partnerPaymentMethodsCreateCreate(data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerPaymentMethodsCreateCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **data** | [**PaymentMethod**](PaymentMethod.md)|  | 

### Return type

[**PaymentMethod**](PaymentMethod.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerPaymentMethodsDeleteDelete**
> partnerPaymentMethodsDeleteDelete(slug)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String slug = slug_example; // String | 

try {
    api.partnerPaymentMethodsDeleteDelete(slug);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerPaymentMethodsDeleteDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **slug** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerPaymentMethodsList**
> List<PaymentMethod> partnerPaymentMethodsList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();

try {
    final response = api.partnerPaymentMethodsList();
    print(response);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerPaymentMethodsList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;PaymentMethod&gt;**](PaymentMethod.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerPaymentMethodsRead**
> PaymentMethod partnerPaymentMethodsRead(slug)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String slug = slug_example; // String | 

try {
    final response = api.partnerPaymentMethodsRead(slug);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerPaymentMethodsRead: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **slug** | **String**|  | 

### Return type

[**PaymentMethod**](PaymentMethod.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerPaymentMethodsUpdatePartialUpdate**
> PaymentMethod partnerPaymentMethodsUpdatePartialUpdate(slug, data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String slug = slug_example; // String | 
final PaymentMethod data = ; // PaymentMethod | 

try {
    final response = api.partnerPaymentMethodsUpdatePartialUpdate(slug, data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerPaymentMethodsUpdatePartialUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **slug** | **String**|  | 
 **data** | [**PaymentMethod**](PaymentMethod.md)|  | 

### Return type

[**PaymentMethod**](PaymentMethod.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerPaymentMethodsUpdateUpdate**
> PaymentMethod partnerPaymentMethodsUpdateUpdate(slug, data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String slug = slug_example; // String | 
final PaymentMethod data = ; // PaymentMethod | 

try {
    final response = api.partnerPaymentMethodsUpdateUpdate(slug, data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerPaymentMethodsUpdateUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **slug** | **String**|  | 
 **data** | [**PaymentMethod**](PaymentMethod.md)|  | 

### Return type

[**PaymentMethod**](PaymentMethod.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerPlansCreateCreate**
> partnerPlansCreateCreate()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();

try {
    api.partnerPlansCreateCreate();
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerPlansCreateCreate: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerPlansDeleteDelete**
> partnerPlansDeleteDelete(planSlug)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String planSlug = planSlug_example; // String | 

try {
    api.partnerPlansDeleteDelete(planSlug);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerPlansDeleteDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **planSlug** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerPlansList**
> partnerPlansList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();

try {
    api.partnerPlansList();
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerPlansList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerPlansReadList**
> partnerPlansReadList(planSlug)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String planSlug = planSlug_example; // String | 

try {
    api.partnerPlansReadList(planSlug);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerPlansReadList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **planSlug** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerPlansUpdateUpdate**
> partnerPlansUpdateUpdate(planSlug)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String planSlug = planSlug_example; // String | 

try {
    api.partnerPlansUpdateUpdate(planSlug);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerPlansUpdateUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **planSlug** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerProfileList**
> partnerProfileList()



Retourne les informations du profil de l'utilisateur connecté. Vérifie le token JWT à chaque appel.

### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();

try {
    api.partnerProfileList();
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerProfileList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerPurchaseSubscriptionPlanCreate**
> PurchaseSubscription partnerPurchaseSubscriptionPlanCreate(data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final PurchaseSubscription data = ; // PurchaseSubscription | 

try {
    final response = api.partnerPurchaseSubscriptionPlanCreate(data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerPurchaseSubscriptionPlanCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **data** | [**PurchaseSubscription**](PurchaseSubscription.md)|  | 

### Return type

[**PurchaseSubscription**](PurchaseSubscription.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerRateLimitCreateCreate**
> partnerRateLimitCreateCreate()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();

try {
    api.partnerRateLimitCreateCreate();
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerRateLimitCreateCreate: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerRateLimitDeleteDelete**
> partnerRateLimitDeleteDelete(id)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String id = id_example; // String | 

try {
    api.partnerRateLimitDeleteDelete(id);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerRateLimitDeleteDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerRateLimitList**
> partnerRateLimitList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();

try {
    api.partnerRateLimitList();
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerRateLimitList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerRateLimitPartialUpdate**
> partnerRateLimitPartialUpdate(id)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String id = id_example; // String | 

try {
    api.partnerRateLimitPartialUpdate(id);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerRateLimitPartialUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerRateLimitRead**
> partnerRateLimitRead(id)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String id = id_example; // String | 

try {
    api.partnerRateLimitRead(id);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerRateLimitRead: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerRateLimitUpdate**
> partnerRateLimitUpdate(id)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String id = id_example; // String | 

try {
    api.partnerRateLimitUpdate(id);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerRateLimitUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerRefreshTokenCreate**
> TokenRefresh partnerRefreshTokenCreate(data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final TokenRefresh data = ; // TokenRefresh | 

try {
    final response = api.partnerRefreshTokenCreate(data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerRefreshTokenCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **data** | [**TokenRefresh**](TokenRefresh.md)|  | 

### Return type

[**TokenRefresh**](TokenRefresh.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerRegisterConfirmCreate**
> ConfirmRegisterEmailOtp partnerRegisterConfirmCreate(data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final ConfirmRegisterEmailOtp data = ; // ConfirmRegisterEmailOtp | 

try {
    final response = api.partnerRegisterConfirmCreate(data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerRegisterConfirmCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **data** | [**ConfirmRegisterEmailOtp**](ConfirmRegisterEmailOtp.md)|  | 

### Return type

[**ConfirmRegisterEmailOtp**](ConfirmRegisterEmailOtp.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerRegisterCreate**
> PartnerRegisterInit partnerRegisterCreate(data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final PartnerRegisterInit data = ; // PartnerRegisterInit | 

try {
    final response = api.partnerRegisterCreate(data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerRegisterCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **data** | [**PartnerRegisterInit**](PartnerRegisterInit.md)|  | 

### Return type

[**PartnerRegisterInit**](PartnerRegisterInit.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerResendVerifyEmailOtpCreate**
> ResendVerifyEmailOtp partnerResendVerifyEmailOtpCreate(data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final ResendVerifyEmailOtp data = ; // ResendVerifyEmailOtp | 

try {
    final response = api.partnerResendVerifyEmailOtpCreate(data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerResendVerifyEmailOtpCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **data** | [**ResendVerifyEmailOtp**](ResendVerifyEmailOtp.md)|  | 

### Return type

[**ResendVerifyEmailOtp**](ResendVerifyEmailOtp.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerResetPasswordCreate**
> PartnerResetPassword partnerResetPasswordCreate(data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final PartnerResetPassword data = ; // PartnerResetPassword | 

try {
    final response = api.partnerResetPasswordCreate(data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerResetPasswordCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **data** | [**PartnerResetPassword**](PartnerResetPassword.md)|  | 

### Return type

[**PartnerResetPassword**](PartnerResetPassword.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerRolesCreateCreate**
> Role partnerRolesCreateCreate(data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final Role data = ; // Role | 

try {
    final response = api.partnerRolesCreateCreate(data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerRolesCreateCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **data** | [**Role**](Role.md)|  | 

### Return type

[**Role**](Role.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerRolesDeleteDelete**
> partnerRolesDeleteDelete(slug)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String slug = slug_example; // String | 

try {
    api.partnerRolesDeleteDelete(slug);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerRolesDeleteDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **slug** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerRolesList**
> List<Role> partnerRolesList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();

try {
    final response = api.partnerRolesList();
    print(response);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerRolesList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;Role&gt;**](Role.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerRolesRead**
> Role partnerRolesRead(slug)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String slug = slug_example; // String | 

try {
    final response = api.partnerRolesRead(slug);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerRolesRead: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **slug** | **String**|  | 

### Return type

[**Role**](Role.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerRolesUpdatePartialUpdate**
> Role partnerRolesUpdatePartialUpdate(slug, data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String slug = slug_example; // String | 
final Role data = ; // Role | 

try {
    final response = api.partnerRolesUpdatePartialUpdate(slug, data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerRolesUpdatePartialUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **slug** | **String**|  | 
 **data** | [**Role**](Role.md)|  | 

### Return type

[**Role**](Role.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerRolesUpdateUpdate**
> Role partnerRolesUpdateUpdate(slug, data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String slug = slug_example; // String | 
final Role data = ; // Role | 

try {
    final response = api.partnerRolesUpdateUpdate(slug, data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerRolesUpdateUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **slug** | **String**|  | 
 **data** | [**Role**](Role.md)|  | 

### Return type

[**Role**](Role.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerRoutersActiveUsersList**
> partnerRoutersActiveUsersList(slug)

👥 Récupérer les utilisateurs actifs

Cette API retourne tous les utilisateurs actuellement connectés à un routeur MikroTik associé au partenaire.  Elle inclut les utilisateurs Hotspot et PPP avec leur IP, MAC, trafic consommé et uptime.

### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String slug = slug_example; // String | Slug unique du routeur à interroger

try {
    api.partnerRoutersActiveUsersList(slug);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerRoutersActiveUsersList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **slug** | **String**| Slug unique du routeur à interroger | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerRoutersAddCreate**
> Router partnerRoutersAddCreate(data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final Router data = ; // Router | 

try {
    final response = api.partnerRoutersAddCreate(data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerRoutersAddCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **data** | [**Router**](Router.md)|  | 

### Return type

[**Router**](Router.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerRoutersDeleteDelete**
> partnerRoutersDeleteDelete(routerId)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String routerId = routerId_example; // String | 

try {
    api.partnerRoutersDeleteDelete(routerId);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerRoutersDeleteDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **routerId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerRoutersDetailsList**
> partnerRoutersDetailsList(routerSlug)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String routerSlug = routerSlug_example; // String | 

try {
    api.partnerRoutersDetailsList(routerSlug);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerRoutersDetailsList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **routerSlug** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerRoutersHotspotsRestartCreate**
> partnerRoutersHotspotsRestartCreate(slug)

🔁 Redémarrer les Hotspots d’un routeur

Cette API permet de **redémarrer tous les services Hotspot** d’un routeur MikroTik associé au partenaire actuellement connecté.  Elle vérifie les permissions et l’association du routeur avant d’effectuer l’opération.  **Réponse de succès :** - Nom du routeur - Adresse IP - Liste des hotspots redémarrés - Date et heure du redémarrage

### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String slug = slug_example; // String | Slug unique du routeur à redémarrer

try {
    api.partnerRoutersHotspotsRestartCreate(slug);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerRoutersHotspotsRestartCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **slug** | **String**| Slug unique du routeur à redémarrer | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerRoutersListList**
> partnerRoutersListList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();

try {
    api.partnerRoutersListList();
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerRoutersListList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerRoutersRebootCreate**
> partnerRoutersRebootCreate(slug)

🔄 Redémarrer un routeur MikroTik

Cette API permet de redémarrer un routeur MikroTik associé au partenaire connecté. Le routeur est identifié par son **slug** passé dans l'URL. Le partenaire doit avoir les permissions nécessaires (`setting-access`).  Réponse de succès : ```json {   \"error\": false,   \"message\": \"Redémarrage du routeur lancé avec succès\",   \"data\": {     \"router\": \"MainRouter\",     \"ip_address\": \"192.168.88.1\",     \"status\": \"Reboot command sent\"   } } ```

### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String slug = slug_example; // String | Slug unique du routeur à redémarrer

try {
    api.partnerRoutersRebootCreate(slug);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerRoutersRebootCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **slug** | **String**| Slug unique du routeur à redémarrer | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerRoutersResourcesList**
> partnerRoutersResourcesList(slug)

🔍 Récupérer les ressources système d’un routeur

Cette API permet de **récupérer toutes les informations du système** d’un routeur MikroTik associé au partenaire actuellement connecté.  Elle vérifie les permissions et l’association du routeur avant d’effectuer l’opération.  **Réponse de succès :** - Nom du routeur - Adresse IP - Version - Uptime - Mémoire libre / totale - CPU, charge CPU - Espace disque - Et d'autres informations système disponibles

### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String slug = slug_example; // String | Slug unique du routeur dont on veut récupérer les ressources

try {
    api.partnerRoutersResourcesList(slug);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerRoutersResourcesList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **slug** | **String**| Slug unique du routeur dont on veut récupérer les ressources | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerRoutersUpdateUpdate**
> partnerRoutersUpdateUpdate(routerSlug)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String routerSlug = routerSlug_example; // String | 

try {
    api.partnerRoutersUpdateUpdate(routerSlug);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerRoutersUpdateUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **routerSlug** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerSessionsActiveList**
> partnerSessionsActiveList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();

try {
    api.partnerSessionsActiveList();
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerSessionsActiveList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerSessionsDisconnectCreate**
> partnerSessionsDisconnectCreate()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();

try {
    api.partnerSessionsDisconnectCreate();
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerSessionsDisconnectCreate: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerSharedUsersCreateCreate**
> partnerSharedUsersCreateCreate()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();

try {
    api.partnerSharedUsersCreateCreate();
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerSharedUsersCreateCreate: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerSharedUsersDeleteDelete**
> partnerSharedUsersDeleteDelete(id)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String id = id_example; // String | 

try {
    api.partnerSharedUsersDeleteDelete(id);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerSharedUsersDeleteDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerSharedUsersList**
> partnerSharedUsersList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();

try {
    api.partnerSharedUsersList();
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerSharedUsersList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerSharedUsersPartialUpdate**
> partnerSharedUsersPartialUpdate(id)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String id = id_example; // String | 

try {
    api.partnerSharedUsersPartialUpdate(id);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerSharedUsersPartialUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerSharedUsersRead**
> partnerSharedUsersRead(id)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String id = id_example; // String | 

try {
    api.partnerSharedUsersRead(id);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerSharedUsersRead: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerSharedUsersUpdate**
> partnerSharedUsersUpdate(id)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String id = id_example; // String | 

try {
    api.partnerSharedUsersUpdate(id);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerSharedUsersUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerTransactionsAdditionalDevicesList**
> partnerTransactionsAdditionalDevicesList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();

try {
    api.partnerTransactionsAdditionalDevicesList();
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerTransactionsAdditionalDevicesList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerTransactionsAssignedPlansList**
> partnerTransactionsAssignedPlansList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();

try {
    api.partnerTransactionsAssignedPlansList();
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerTransactionsAssignedPlansList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerTransactionsList**
> partnerTransactionsList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();

try {
    api.partnerTransactionsList();
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerTransactionsList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerUpdatePartialUpdate**
> UpdatePartner partnerUpdatePartialUpdate(data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final UpdatePartner data = ; // UpdatePartner | 

try {
    final response = api.partnerUpdatePartialUpdate(data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerUpdatePartialUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **data** | [**UpdatePartner**](UpdatePartner.md)|  | 

### Return type

[**UpdatePartner**](UpdatePartner.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerUpdateUpdate**
> UpdatePartner partnerUpdateUpdate(data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final UpdatePartner data = ; // UpdatePartner | 

try {
    final response = api.partnerUpdateUpdate(data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerUpdateUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **data** | [**UpdatePartner**](UpdatePartner.md)|  | 

### Return type

[**UpdatePartner**](UpdatePartner.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerValidityCreateCreate**
> partnerValidityCreateCreate()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();

try {
    api.partnerValidityCreateCreate();
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerValidityCreateCreate: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerValidityDeleteDelete**
> partnerValidityDeleteDelete(id)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String id = id_example; // String | 

try {
    api.partnerValidityDeleteDelete(id);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerValidityDeleteDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerValidityList**
> partnerValidityList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();

try {
    api.partnerValidityList();
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerValidityList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerValidityPartialUpdate**
> partnerValidityPartialUpdate(id)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String id = id_example; // String | 

try {
    api.partnerValidityPartialUpdate(id);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerValidityPartialUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerValidityRead**
> partnerValidityRead(id)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String id = id_example; // String | 

try {
    api.partnerValidityRead(id);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerValidityRead: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerValidityUpdate**
> partnerValidityUpdate(id)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String id = id_example; // String | 

try {
    api.partnerValidityUpdate(id);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerValidityUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerVerifyEmailOtpCreate**
> VerifyEmailOtp partnerVerifyEmailOtpCreate(data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final VerifyEmailOtp data = ; // VerifyEmailOtp | 

try {
    final response = api.partnerVerifyEmailOtpCreate(data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerVerifyEmailOtpCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **data** | [**VerifyEmailOtp**](VerifyEmailOtp.md)|  | 

### Return type

[**VerifyEmailOtp**](VerifyEmailOtp.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerWalletAllTransactionsList**
> List<WalletTransaction> partnerWalletAllTransactionsList()

Récupère toutes les transactions du partenaire sans filtre ni tri.

Retourne la liste complète des transactions du partenaire connecté, avec les totaux calculés (montant total, revenus, paiements).

### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();

try {
    final response = api.partnerWalletAllTransactionsList();
    print(response);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerWalletAllTransactionsList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;WalletTransaction&gt;**](WalletTransaction.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerWalletBalanceRead**
> Object partnerWalletBalanceRead()

Récupère le solde du wallet du partner

Retourne le solde du wallet du partner.

### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();

try {
    final response = api.partnerWalletBalanceRead();
    print(response);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerWalletBalanceRead: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

**Object**

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerWalletTransactionsList**
> List<WalletTransaction> partnerWalletTransactionsList(search, status, type, period, startDate, endDate)

Récupère les transactions du partenaire connecté avec filtres, recherche et pagination.

Retourne la liste complète des transactions du partenaire connecté, avec filtres (status, type, période), recherche et pagination.

### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String search = search_example; // String | Recherche (référence, statut, montant...)
final String status = status_example; // String | Filtrer par status (success/pending/failed)
final String type = type_example; // String | Filtrer par type (revenue/payout)
final String period = period_example; // String | Période (today/this_week/this_month/this_year)
final String startDate = startDate_example; // String | Date de début (YYYY-MM-DD)
final String endDate = endDate_example; // String | Date de fin (YYYY-MM-DD)

try {
    final response = api.partnerWalletTransactionsList(search, status, type, period, startDate, endDate);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerWalletTransactionsList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **search** | **String**| Recherche (référence, statut, montant...) | [optional] 
 **status** | **String**| Filtrer par status (success/pending/failed) | [optional] 
 **type** | **String**| Filtrer par type (revenue/payout) | [optional] 
 **period** | **String**| Période (today/this_week/this_month/this_year) | [optional] 
 **startDate** | **String**| Date de début (YYYY-MM-DD) | [optional] 
 **endDate** | **String**| Date de fin (YYYY-MM-DD) | [optional] 

### Return type

[**List&lt;WalletTransaction&gt;**](WalletTransaction.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerWithdrawalsCreateCreate**
> WithdrawalRequest partnerWithdrawalsCreateCreate(data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final WithdrawalRequest data = ; // WithdrawalRequest | 

try {
    final response = api.partnerWithdrawalsCreateCreate(data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerWithdrawalsCreateCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **data** | [**WithdrawalRequest**](WithdrawalRequest.md)|  | 

### Return type

[**WithdrawalRequest**](WithdrawalRequest.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **partnerWithdrawalsList**
> List<WithdrawalRequest> partnerWithdrawalsList(search, status, period, startDate, endDate)

Récupère la liste des demandes de retraits (Partner).

Retourne la liste des demandes de retraits du partenaire connecté avec recherche et filtres.

### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getPartnerApi();
final String search = search_example; // String | Recherche par référence, statut, montant...
final String status = status_example; // String | Filtrer par statut (pending, approved, rejected, completed)
final String period = period_example; // String | Période (today, this_week, this_month, this_year)
final String startDate = startDate_example; // String | Date de début (YYYY-MM-DD)
final String endDate = endDate_example; // String | Date de fin (YYYY-MM-DD)

try {
    final response = api.partnerWithdrawalsList(search, status, period, startDate, endDate);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PartnerApi->partnerWithdrawalsList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **search** | **String**| Recherche par référence, statut, montant... | [optional] 
 **status** | **String**| Filtrer par statut (pending, approved, rejected, completed) | [optional] 
 **period** | **String**| Période (today, this_week, this_month, this_year) | [optional] 
 **startDate** | **String**| Date de début (YYYY-MM-DD) | [optional] 
 **endDate** | **String**| Date de fin (YYYY-MM-DD) | [optional] 

### Return type

[**List&lt;WithdrawalRequest&gt;**](WithdrawalRequest.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

