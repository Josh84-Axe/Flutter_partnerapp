# tiknet_api_client.api.AdminApi

## Load the API package
```dart
import 'package:tiknet_api_client/api.dart';
```

All URIs are relative to *https://api.tiknetafrica.com/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**adminCustomersActivateOrDeactivatePartialUpdate**](AdminApi.md#admincustomersactivateordeactivatepartialupdate) | **PATCH** /admin/customers/{username}/activate-or-deactivate/ | 
[**adminCustomersActivateOrDeactivateUpdate**](AdminApi.md#admincustomersactivateordeactivateupdate) | **PUT** /admin/customers/{username}/activate-or-deactivate/ | 
[**adminCustomersListList**](AdminApi.md#admincustomerslistlist) | **GET** /admin/customers/list/ | 
[**adminCustomersPaginateListList**](AdminApi.md#admincustomerspaginatelistlist) | **GET** /admin/customers/paginate-list/ | 
[**adminLoginCreate**](AdminApi.md#adminlogincreate) | **POST** /admin/login/ | 
[**adminPartnersActivateOrDeactivatePartialUpdate**](AdminApi.md#adminpartnersactivateordeactivatepartialupdate) | **PATCH** /admin/partners/{username}/activate-or-deactivate/ | 
[**adminPartnersActivateOrDeactivateUpdate**](AdminApi.md#adminpartnersactivateordeactivateupdate) | **PUT** /admin/partners/{username}/activate-or-deactivate/ | 
[**adminPartnersListList**](AdminApi.md#adminpartnerslistlist) | **GET** /admin/partners/list/ | 
[**adminPartnersPaginateListList**](AdminApi.md#adminpartnerspaginatelistlist) | **GET** /admin/partners/paginate-list/ | 
[**adminPartnersUpdateStatusPartialUpdate**](AdminApi.md#adminpartnersupdatestatuspartialupdate) | **PATCH** /admin/partners/{username}/update-status/ | Met à jour le statut d’un partenaire
[**adminPermissionsCreateCreate**](AdminApi.md#adminpermissionscreatecreate) | **POST** /admin/permissions/create/ | 
[**adminPermissionsDeleteDelete**](AdminApi.md#adminpermissionsdeletedelete) | **DELETE** /admin/permissions/{slug}/delete/ | Supprimer une permission
[**adminPermissionsList**](AdminApi.md#adminpermissionslist) | **GET** /admin/permissions/ | 
[**adminPermissionsRead**](AdminApi.md#adminpermissionsread) | **GET** /admin/permissions/{slug}/ | 
[**adminPermissionsUpdatePartialUpdate**](AdminApi.md#adminpermissionsupdatepartialupdate) | **PATCH** /admin/permissions/{slug}/update/ | 
[**adminPermissionsUpdateUpdate**](AdminApi.md#adminpermissionsupdateupdate) | **PUT** /admin/permissions/{slug}/update/ | 
[**adminSubscriptionFeaturesCreateCreate**](AdminApi.md#adminsubscriptionfeaturescreatecreate) | **POST** /admin/subscription-features/create/ | 
[**adminSubscriptionFeaturesDeleteDelete**](AdminApi.md#adminsubscriptionfeaturesdeletedelete) | **DELETE** /admin/subscription-features/{slug}/delete/ | 
[**adminSubscriptionFeaturesList**](AdminApi.md#adminsubscriptionfeatureslist) | **GET** /admin/subscription-features/ | 
[**adminSubscriptionFeaturesRead**](AdminApi.md#adminsubscriptionfeaturesread) | **GET** /admin/subscription-features/{slug}/ | 
[**adminSubscriptionFeaturesUpdatePartialUpdate**](AdminApi.md#adminsubscriptionfeaturesupdatepartialupdate) | **PATCH** /admin/subscription-features/{slug}/update/ | 
[**adminSubscriptionFeaturesUpdateUpdate**](AdminApi.md#adminsubscriptionfeaturesupdateupdate) | **PUT** /admin/subscription-features/{slug}/update/ | 
[**adminSubscriptionPlansCreateCreate**](AdminApi.md#adminsubscriptionplanscreatecreate) | **POST** /admin/subscription-plans/create/ | 
[**adminSubscriptionPlansDeleteDelete**](AdminApi.md#adminsubscriptionplansdeletedelete) | **DELETE** /admin/subscription-plans/{slug}/delete/ | 
[**adminSubscriptionPlansList**](AdminApi.md#adminsubscriptionplanslist) | **GET** /admin/subscription-plans/ | 
[**adminSubscriptionPlansRead**](AdminApi.md#adminsubscriptionplansread) | **GET** /admin/subscription-plans/{slug}/ | 
[**adminSubscriptionPlansUpdatePartialUpdate**](AdminApi.md#adminsubscriptionplansupdatepartialupdate) | **PATCH** /admin/subscription-plans/{slug}/update/ | 
[**adminSubscriptionPlansUpdateUpdate**](AdminApi.md#adminsubscriptionplansupdateupdate) | **PUT** /admin/subscription-plans/{slug}/update/ | 
[**adminWalletAllTransactionsList**](AdminApi.md#adminwalletalltransactionslist) | **GET** /admin/wallet/all-transactions/ | Récupère toutes les transactions des partner sans filtre ni tri pour le super user.
[**adminWalletTransactionsList**](AdminApi.md#adminwallettransactionslist) | **GET** /admin/wallet/transactions/ | Récupère toutes les transactions avec filtres, tri, recherche et pagination (SuperAdmin).
[**adminWithdrawalsList**](AdminApi.md#adminwithdrawalslist) | **GET** /admin/withdrawals/ | Récupère la liste des demandes de retraits (SuperAdmin).
[**adminWithdrawalsUpdateStatusPartialUpdate**](AdminApi.md#adminwithdrawalsupdatestatuspartialupdate) | **PATCH** /admin/withdrawals/{reference}/update-status/ | 
[**adminWithdrawalsUpdateStatusUpdate**](AdminApi.md#adminwithdrawalsupdatestatusupdate) | **PUT** /admin/withdrawals/{reference}/update-status/ | 


# **adminCustomersActivateOrDeactivatePartialUpdate**
> AdminActivateOrDeactivateUser adminCustomersActivateOrDeactivatePartialUpdate(username, data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getAdminApi();
final String username = username_example; // String | 
final AdminActivateOrDeactivateUser data = ; // AdminActivateOrDeactivateUser | 

try {
    final response = api.adminCustomersActivateOrDeactivatePartialUpdate(username, data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminCustomersActivateOrDeactivatePartialUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **username** | **String**|  | 
 **data** | [**AdminActivateOrDeactivateUser**](AdminActivateOrDeactivateUser.md)|  | 

### Return type

[**AdminActivateOrDeactivateUser**](AdminActivateOrDeactivateUser.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminCustomersActivateOrDeactivateUpdate**
> AdminActivateOrDeactivateUser adminCustomersActivateOrDeactivateUpdate(username, data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getAdminApi();
final String username = username_example; // String | 
final AdminActivateOrDeactivateUser data = ; // AdminActivateOrDeactivateUser | 

try {
    final response = api.adminCustomersActivateOrDeactivateUpdate(username, data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminCustomersActivateOrDeactivateUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **username** | **String**|  | 
 **data** | [**AdminActivateOrDeactivateUser**](AdminActivateOrDeactivateUser.md)|  | 

### Return type

[**AdminActivateOrDeactivateUser**](AdminActivateOrDeactivateUser.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminCustomersListList**
> adminCustomersListList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getAdminApi();

try {
    api.adminCustomersListList();
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminCustomersListList: $e\n');
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

# **adminCustomersPaginateListList**
> adminCustomersPaginateListList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getAdminApi();

try {
    api.adminCustomersPaginateListList();
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminCustomersPaginateListList: $e\n');
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

# **adminLoginCreate**
> AdminTokenObtainPair adminLoginCreate(data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getAdminApi();
final AdminTokenObtainPair data = ; // AdminTokenObtainPair | 

try {
    final response = api.adminLoginCreate(data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminLoginCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **data** | [**AdminTokenObtainPair**](AdminTokenObtainPair.md)|  | 

### Return type

[**AdminTokenObtainPair**](AdminTokenObtainPair.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminPartnersActivateOrDeactivatePartialUpdate**
> AdminActivateOrDeactivateUser adminPartnersActivateOrDeactivatePartialUpdate(username, data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getAdminApi();
final String username = username_example; // String | 
final AdminActivateOrDeactivateUser data = ; // AdminActivateOrDeactivateUser | 

try {
    final response = api.adminPartnersActivateOrDeactivatePartialUpdate(username, data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminPartnersActivateOrDeactivatePartialUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **username** | **String**|  | 
 **data** | [**AdminActivateOrDeactivateUser**](AdminActivateOrDeactivateUser.md)|  | 

### Return type

[**AdminActivateOrDeactivateUser**](AdminActivateOrDeactivateUser.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminPartnersActivateOrDeactivateUpdate**
> AdminActivateOrDeactivateUser adminPartnersActivateOrDeactivateUpdate(username, data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getAdminApi();
final String username = username_example; // String | 
final AdminActivateOrDeactivateUser data = ; // AdminActivateOrDeactivateUser | 

try {
    final response = api.adminPartnersActivateOrDeactivateUpdate(username, data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminPartnersActivateOrDeactivateUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **username** | **String**|  | 
 **data** | [**AdminActivateOrDeactivateUser**](AdminActivateOrDeactivateUser.md)|  | 

### Return type

[**AdminActivateOrDeactivateUser**](AdminActivateOrDeactivateUser.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminPartnersListList**
> adminPartnersListList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getAdminApi();

try {
    api.adminPartnersListList();
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminPartnersListList: $e\n');
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

# **adminPartnersPaginateListList**
> adminPartnersPaginateListList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getAdminApi();

try {
    api.adminPartnersPaginateListList();
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminPartnersPaginateListList: $e\n');
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

# **adminPartnersUpdateStatusPartialUpdate**
> adminPartnersUpdateStatusPartialUpdate(username, data)

Met à jour le statut d’un partenaire

### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getAdminApi();
final String username = username_example; // String | Nom d'utilisateur du partenaire à mettre à jour
final UpdatePartnerStatus data = ; // UpdatePartnerStatus | 

try {
    api.adminPartnersUpdateStatusPartialUpdate(username, data);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminPartnersUpdateStatusPartialUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **username** | **String**| Nom d'utilisateur du partenaire à mettre à jour | 
 **data** | [**UpdatePartnerStatus**](UpdatePartnerStatus.md)|  | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminPermissionsCreateCreate**
> Permission adminPermissionsCreateCreate(data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getAdminApi();
final Permission data = ; // Permission | 

try {
    final response = api.adminPermissionsCreateCreate(data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminPermissionsCreateCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **data** | [**Permission**](Permission.md)|  | 

### Return type

[**Permission**](Permission.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminPermissionsDeleteDelete**
> adminPermissionsDeleteDelete(slug)

Supprimer une permission

Supprime une permission du système à partir de son **slug** (réservé au Super Administrateur).

### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getAdminApi();
final String slug = slug_example; // String | Slug de la permission à supprimer

try {
    api.adminPermissionsDeleteDelete(slug);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminPermissionsDeleteDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **slug** | **String**| Slug de la permission à supprimer | 

### Return type

void (empty response body)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminPermissionsList**
> List<Permission> adminPermissionsList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getAdminApi();

try {
    final response = api.adminPermissionsList();
    print(response);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminPermissionsList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;Permission&gt;**](Permission.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminPermissionsRead**
> Permission adminPermissionsRead(slug)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getAdminApi();
final String slug = slug_example; // String | 

try {
    final response = api.adminPermissionsRead(slug);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminPermissionsRead: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **slug** | **String**|  | 

### Return type

[**Permission**](Permission.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminPermissionsUpdatePartialUpdate**
> Permission adminPermissionsUpdatePartialUpdate(slug, data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getAdminApi();
final String slug = slug_example; // String | 
final Permission data = ; // Permission | 

try {
    final response = api.adminPermissionsUpdatePartialUpdate(slug, data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminPermissionsUpdatePartialUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **slug** | **String**|  | 
 **data** | [**Permission**](Permission.md)|  | 

### Return type

[**Permission**](Permission.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminPermissionsUpdateUpdate**
> Permission adminPermissionsUpdateUpdate(slug, data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getAdminApi();
final String slug = slug_example; // String | 
final Permission data = ; // Permission | 

try {
    final response = api.adminPermissionsUpdateUpdate(slug, data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminPermissionsUpdateUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **slug** | **String**|  | 
 **data** | [**Permission**](Permission.md)|  | 

### Return type

[**Permission**](Permission.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminSubscriptionFeaturesCreateCreate**
> SubscriptionFeature adminSubscriptionFeaturesCreateCreate(data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getAdminApi();
final SubscriptionFeature data = ; // SubscriptionFeature | 

try {
    final response = api.adminSubscriptionFeaturesCreateCreate(data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminSubscriptionFeaturesCreateCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **data** | [**SubscriptionFeature**](SubscriptionFeature.md)|  | 

### Return type

[**SubscriptionFeature**](SubscriptionFeature.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminSubscriptionFeaturesDeleteDelete**
> adminSubscriptionFeaturesDeleteDelete(slug)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getAdminApi();
final String slug = slug_example; // String | 

try {
    api.adminSubscriptionFeaturesDeleteDelete(slug);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminSubscriptionFeaturesDeleteDelete: $e\n');
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

# **adminSubscriptionFeaturesList**
> List<SubscriptionFeature> adminSubscriptionFeaturesList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getAdminApi();

try {
    final response = api.adminSubscriptionFeaturesList();
    print(response);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminSubscriptionFeaturesList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;SubscriptionFeature&gt;**](SubscriptionFeature.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminSubscriptionFeaturesRead**
> SubscriptionFeature adminSubscriptionFeaturesRead(slug)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getAdminApi();
final String slug = slug_example; // String | 

try {
    final response = api.adminSubscriptionFeaturesRead(slug);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminSubscriptionFeaturesRead: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **slug** | **String**|  | 

### Return type

[**SubscriptionFeature**](SubscriptionFeature.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminSubscriptionFeaturesUpdatePartialUpdate**
> SubscriptionFeature adminSubscriptionFeaturesUpdatePartialUpdate(slug, data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getAdminApi();
final String slug = slug_example; // String | 
final SubscriptionFeature data = ; // SubscriptionFeature | 

try {
    final response = api.adminSubscriptionFeaturesUpdatePartialUpdate(slug, data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminSubscriptionFeaturesUpdatePartialUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **slug** | **String**|  | 
 **data** | [**SubscriptionFeature**](SubscriptionFeature.md)|  | 

### Return type

[**SubscriptionFeature**](SubscriptionFeature.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminSubscriptionFeaturesUpdateUpdate**
> SubscriptionFeature adminSubscriptionFeaturesUpdateUpdate(slug, data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getAdminApi();
final String slug = slug_example; // String | 
final SubscriptionFeature data = ; // SubscriptionFeature | 

try {
    final response = api.adminSubscriptionFeaturesUpdateUpdate(slug, data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminSubscriptionFeaturesUpdateUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **slug** | **String**|  | 
 **data** | [**SubscriptionFeature**](SubscriptionFeature.md)|  | 

### Return type

[**SubscriptionFeature**](SubscriptionFeature.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminSubscriptionPlansCreateCreate**
> SubscriptionPlan adminSubscriptionPlansCreateCreate(data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getAdminApi();
final SubscriptionPlan data = ; // SubscriptionPlan | 

try {
    final response = api.adminSubscriptionPlansCreateCreate(data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminSubscriptionPlansCreateCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **data** | [**SubscriptionPlan**](SubscriptionPlan.md)|  | 

### Return type

[**SubscriptionPlan**](SubscriptionPlan.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminSubscriptionPlansDeleteDelete**
> adminSubscriptionPlansDeleteDelete(slug)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getAdminApi();
final String slug = slug_example; // String | 

try {
    api.adminSubscriptionPlansDeleteDelete(slug);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminSubscriptionPlansDeleteDelete: $e\n');
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

# **adminSubscriptionPlansList**
> List<SubscriptionPlan> adminSubscriptionPlansList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getAdminApi();

try {
    final response = api.adminSubscriptionPlansList();
    print(response);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminSubscriptionPlansList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**List&lt;SubscriptionPlan&gt;**](SubscriptionPlan.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminSubscriptionPlansRead**
> SubscriptionPlan adminSubscriptionPlansRead(slug)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getAdminApi();
final String slug = slug_example; // String | 

try {
    final response = api.adminSubscriptionPlansRead(slug);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminSubscriptionPlansRead: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **slug** | **String**|  | 

### Return type

[**SubscriptionPlan**](SubscriptionPlan.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminSubscriptionPlansUpdatePartialUpdate**
> SubscriptionPlan adminSubscriptionPlansUpdatePartialUpdate(slug, data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getAdminApi();
final String slug = slug_example; // String | 
final SubscriptionPlan data = ; // SubscriptionPlan | 

try {
    final response = api.adminSubscriptionPlansUpdatePartialUpdate(slug, data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminSubscriptionPlansUpdatePartialUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **slug** | **String**|  | 
 **data** | [**SubscriptionPlan**](SubscriptionPlan.md)|  | 

### Return type

[**SubscriptionPlan**](SubscriptionPlan.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminSubscriptionPlansUpdateUpdate**
> SubscriptionPlan adminSubscriptionPlansUpdateUpdate(slug, data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getAdminApi();
final String slug = slug_example; // String | 
final SubscriptionPlan data = ; // SubscriptionPlan | 

try {
    final response = api.adminSubscriptionPlansUpdateUpdate(slug, data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminSubscriptionPlansUpdateUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **slug** | **String**|  | 
 **data** | [**SubscriptionPlan**](SubscriptionPlan.md)|  | 

### Return type

[**SubscriptionPlan**](SubscriptionPlan.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminWalletAllTransactionsList**
> List<WalletTransaction> adminWalletAllTransactionsList()

Récupère toutes les transactions des partner sans filtre ni tri pour le super user.

Retourne la liste complète des transactions des partenaire connecté, avec les totaux calculés (montant total, revenus, paiements).

### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getAdminApi();

try {
    final response = api.adminWalletAllTransactionsList();
    print(response);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminWalletAllTransactionsList: $e\n');
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

# **adminWalletTransactionsList**
> List<WalletTransaction> adminWalletTransactionsList(search, status, type, modelType, period, startDate, endDate, sort)

Récupère toutes les transactions avec filtres, tri, recherche et pagination (SuperAdmin).

Retourne la liste complète des transactions avec filtres (statut, type, modèle, période), tri, recherche et pagination.

### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getAdminApi();
final String search = search_example; // String | Recherche (référence, utilisateur, email, type...)
final String status = status_example; // String | Filtrer par status (success/pending/failed)
final String type = type_example; // String | Filtrer par type (revenue/payout)
final String modelType = modelType_example; // String | Filtrer par modèle lié (withdrawalrequest, plan...)
final String period = period_example; // String | Période (today/this_week/this_month/this_year)
final String startDate = startDate_example; // String | Date de début (YYYY-MM-DD)
final String endDate = endDate_example; // String | Date de fin (YYYY-MM-DD)
final String sort = sort_example; // String | Tri (amount_asc / amount_desc / created_desc)

try {
    final response = api.adminWalletTransactionsList(search, status, type, modelType, period, startDate, endDate, sort);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminWalletTransactionsList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **search** | **String**| Recherche (référence, utilisateur, email, type...) | [optional] 
 **status** | **String**| Filtrer par status (success/pending/failed) | [optional] 
 **type** | **String**| Filtrer par type (revenue/payout) | [optional] 
 **modelType** | **String**| Filtrer par modèle lié (withdrawalrequest, plan...) | [optional] 
 **period** | **String**| Période (today/this_week/this_month/this_year) | [optional] 
 **startDate** | **String**| Date de début (YYYY-MM-DD) | [optional] 
 **endDate** | **String**| Date de fin (YYYY-MM-DD) | [optional] 
 **sort** | **String**| Tri (amount_asc / amount_desc / created_desc) | [optional] 

### Return type

[**List&lt;WalletTransaction&gt;**](WalletTransaction.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminWithdrawalsList**
> List<WithdrawalRequest> adminWithdrawalsList(search, status, period, startDate, endDate)

Récupère la liste des demandes de retraits (SuperAdmin).

Retourne la liste des demandes de retraits avec recherche, filtres, tri et pagination.

### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getAdminApi();
final String search = search_example; // String | Recherche (reference, partner, email...)
final String status = status_example; // String | Filtrer par statut (pending, approved, rejected, completed)
final String period = period_example; // String | Période (today, this_week, this_month, this_year)
final String startDate = startDate_example; // String | Date de début (YYYY-MM-DD)
final String endDate = endDate_example; // String | Date de fin (YYYY-MM-DD)

try {
    final response = api.adminWithdrawalsList(search, status, period, startDate, endDate);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminWithdrawalsList: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **search** | **String**| Recherche (reference, partner, email...) | [optional] 
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

# **adminWithdrawalsUpdateStatusPartialUpdate**
> UpdateWithdrawalRequestStatus adminWithdrawalsUpdateStatusPartialUpdate(reference, data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getAdminApi();
final String reference = reference_example; // String | 
final UpdateWithdrawalRequestStatus data = ; // UpdateWithdrawalRequestStatus | 

try {
    final response = api.adminWithdrawalsUpdateStatusPartialUpdate(reference, data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminWithdrawalsUpdateStatusPartialUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **reference** | **String**|  | 
 **data** | [**UpdateWithdrawalRequestStatus**](UpdateWithdrawalRequestStatus.md)|  | 

### Return type

[**UpdateWithdrawalRequestStatus**](UpdateWithdrawalRequestStatus.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminWithdrawalsUpdateStatusUpdate**
> UpdateWithdrawalRequestStatus adminWithdrawalsUpdateStatusUpdate(reference, data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getAdminApi();
final String reference = reference_example; // String | 
final UpdateWithdrawalRequestStatus data = ; // UpdateWithdrawalRequestStatus | 

try {
    final response = api.adminWithdrawalsUpdateStatusUpdate(reference, data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AdminApi->adminWithdrawalsUpdateStatusUpdate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **reference** | **String**|  | 
 **data** | [**UpdateWithdrawalRequestStatus**](UpdateWithdrawalRequestStatus.md)|  | 

### Return type

[**UpdateWithdrawalRequestStatus**](UpdateWithdrawalRequestStatus.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

