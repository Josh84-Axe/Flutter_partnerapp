# tiknet_api_client.api.CustomerApi

## Load the API package
```dart
import 'package:tiknet_api_client/api.dart';
```

All URIs are relative to *https://api.tiknetafrica.com/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**customerActivateInternetCreate**](CustomerApi.md#customeractivateinternetcreate) | **POST** /customer/activate-internet/ | 
[**customerCheckActiveConnexionList**](CustomerApi.md#customercheckactiveconnexionlist) | **GET** /customer/check-active-connexion/ | 
[**customerCheckActivePlanList**](CustomerApi.md#customercheckactiveplanlist) | **GET** /customer/check-active-plan/ | 
[**customerDefaultRouterPlansList**](CustomerApi.md#customerdefaultrouterplanslist) | **GET** /customer/default-router-plans/ | 
[**customerExchangeRateList**](CustomerApi.md#customerexchangeratelist) | **GET** /customer/exchange-rate/ | 
[**customerPlansDetailList**](CustomerApi.md#customerplansdetaillist) | **GET** /customer/plans/{slug}/detail/ | 
[**customerProfileList**](CustomerApi.md#customerprofilelist) | **GET** /customer/profile/ | 
[**customerProfileUpdateUpdate**](CustomerApi.md#customerprofileupdateupdate) | **PUT** /customer/profile/update/ | 
[**customerPurchaseAdditionalDeviceCreate**](CustomerApi.md#customerpurchaseadditionaldevicecreate) | **POST** /customer/purchase-additional-device/ | 
[**customerPurchasePlanCreate**](CustomerApi.md#customerpurchaseplancreate) | **POST** /customer/purchase-plan/ | 
[**customerRadiusDataList**](CustomerApi.md#customerradiusdatalist) | **GET** /customer/radius-data/ | 
[**customerRadiusPlansList**](CustomerApi.md#customerradiusplanslist) | **GET** /customer/radius-plans/ | 
[**customerRegisterCreate**](CustomerApi.md#customerregistercreate) | **POST** /customer/register/ | 
[**customerRemainingTimeList**](CustomerApi.md#customerremainingtimelist) | **GET** /customer/remaining-time/ | 
[**customerResendOtpCreate**](CustomerApi.md#customerresendotpcreate) | **POST** /customer/resend-otp/ | 
[**customerResendVerifyEmailOtpCreate**](CustomerApi.md#customerresendverifyemailotpcreate) | **POST** /customer/resend-verify-email-otp/ | 
[**customerRoamingPlansList**](CustomerApi.md#customerroamingplanslist) | **GET** /customer/roaming-plans/ | 
[**customerRoamingPlansRead**](CustomerApi.md#customerroamingplansread) | **GET** /customer/roaming-plans/{slug}/ | 
[**customerRouterPlansList**](CustomerApi.md#customerrouterplanslist) | **GET** /customer/router-plans/ | 
[**customerRouterPlansRead**](CustomerApi.md#customerrouterplansread) | **GET** /customer/router-plans/{slug}/ | 
[**customerSigninCreate**](CustomerApi.md#customersignincreate) | **POST** /customer/signin/ | 
[**customerTokenCreate**](CustomerApi.md#customertokencreate) | **POST** /customer/token/ | 
[**customerTokenRefreshCreate**](CustomerApi.md#customertokenrefreshcreate) | **POST** /customer/token/refresh/ | 
[**customerTransactionsList**](CustomerApi.md#customertransactionslist) | **GET** /customer/transactions/ | 
[**customerVerifyDeviceCreate**](CustomerApi.md#customerverifydevicecreate) | **POST** /customer/verify-device/ | 
[**customerVerifyEmailOtpCreate**](CustomerApi.md#customerverifyemailotpcreate) | **POST** /customer/verify-email-otp/ | 


# **customerActivateInternetCreate**
> customerActivateInternetCreate()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getCustomerApi();

try {
    api.customerActivateInternetCreate();
} catch on DioException (e) {
    print('Exception when calling CustomerApi->customerActivateInternetCreate: $e\n');
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

# **customerCheckActiveConnexionList**
> customerCheckActiveConnexionList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getCustomerApi();

try {
    api.customerCheckActiveConnexionList();
} catch on DioException (e) {
    print('Exception when calling CustomerApi->customerCheckActiveConnexionList: $e\n');
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

# **customerCheckActivePlanList**
> customerCheckActivePlanList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getCustomerApi();

try {
    api.customerCheckActivePlanList();
} catch on DioException (e) {
    print('Exception when calling CustomerApi->customerCheckActivePlanList: $e\n');
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

# **customerDefaultRouterPlansList**
> customerDefaultRouterPlansList()



Récupère les plans pour le router par défaut de l'utilisateur connecté.

### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getCustomerApi();

try {
    api.customerDefaultRouterPlansList();
} catch on DioException (e) {
    print('Exception when calling CustomerApi->customerDefaultRouterPlansList: $e\n');
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

# **customerExchangeRateList**
> customerExchangeRateList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getCustomerApi();

try {
    api.customerExchangeRateList();
} catch on DioException (e) {
    print('Exception when calling CustomerApi->customerExchangeRateList: $e\n');
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

# **customerPlansDetailList**
> customerPlansDetailList(slug)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getCustomerApi();
final String slug = slug_example; // String | 

try {
    api.customerPlansDetailList(slug);
} catch on DioException (e) {
    print('Exception when calling CustomerApi->customerPlansDetailList: $e\n');
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

# **customerProfileList**
> customerProfileList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getCustomerApi();

try {
    api.customerProfileList();
} catch on DioException (e) {
    print('Exception when calling CustomerApi->customerProfileList: $e\n');
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

# **customerProfileUpdateUpdate**
> customerProfileUpdateUpdate()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getCustomerApi();

try {
    api.customerProfileUpdateUpdate();
} catch on DioException (e) {
    print('Exception when calling CustomerApi->customerProfileUpdateUpdate: $e\n');
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

# **customerPurchaseAdditionalDeviceCreate**
> customerPurchaseAdditionalDeviceCreate()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getCustomerApi();

try {
    api.customerPurchaseAdditionalDeviceCreate();
} catch on DioException (e) {
    print('Exception when calling CustomerApi->customerPurchaseAdditionalDeviceCreate: $e\n');
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

# **customerPurchasePlanCreate**
> customerPurchasePlanCreate()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getCustomerApi();

try {
    api.customerPurchasePlanCreate();
} catch on DioException (e) {
    print('Exception when calling CustomerApi->customerPurchasePlanCreate: $e\n');
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

# **customerRadiusDataList**
> customerRadiusDataList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getCustomerApi();

try {
    api.customerRadiusDataList();
} catch on DioException (e) {
    print('Exception when calling CustomerApi->customerRadiusDataList: $e\n');
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

# **customerRadiusPlansList**
> CustomerRadiusPlansList200Response customerRadiusPlansList()



Récupère la liste des plans associés à l'utilisateur authentifié depuis la table user_plans.

### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getCustomerApi();

try {
    final response = api.customerRadiusPlansList();
    print(response);
} catch on DioException (e) {
    print('Exception when calling CustomerApi->customerRadiusPlansList: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**CustomerRadiusPlansList200Response**](CustomerRadiusPlansList200Response.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **customerRegisterCreate**
> CustomerRegister customerRegisterCreate(data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getCustomerApi();
final CustomerRegister data = ; // CustomerRegister | 

try {
    final response = api.customerRegisterCreate(data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling CustomerApi->customerRegisterCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **data** | [**CustomerRegister**](CustomerRegister.md)|  | 

### Return type

[**CustomerRegister**](CustomerRegister.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **customerRemainingTimeList**
> customerRemainingTimeList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getCustomerApi();

try {
    api.customerRemainingTimeList();
} catch on DioException (e) {
    print('Exception when calling CustomerApi->customerRemainingTimeList: $e\n');
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

# **customerResendOtpCreate**
> customerResendOtpCreate()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getCustomerApi();

try {
    api.customerResendOtpCreate();
} catch on DioException (e) {
    print('Exception when calling CustomerApi->customerResendOtpCreate: $e\n');
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

# **customerResendVerifyEmailOtpCreate**
> customerResendVerifyEmailOtpCreate()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getCustomerApi();

try {
    api.customerResendVerifyEmailOtpCreate();
} catch on DioException (e) {
    print('Exception when calling CustomerApi->customerResendVerifyEmailOtpCreate: $e\n');
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

# **customerRoamingPlansList**
> customerRoamingPlansList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getCustomerApi();

try {
    api.customerRoamingPlansList();
} catch on DioException (e) {
    print('Exception when calling CustomerApi->customerRoamingPlansList: $e\n');
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

# **customerRoamingPlansRead**
> customerRoamingPlansRead(slug)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getCustomerApi();
final String slug = slug_example; // String | 

try {
    api.customerRoamingPlansRead(slug);
} catch on DioException (e) {
    print('Exception when calling CustomerApi->customerRoamingPlansRead: $e\n');
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

# **customerRouterPlansList**
> customerRouterPlansList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getCustomerApi();

try {
    api.customerRouterPlansList();
} catch on DioException (e) {
    print('Exception when calling CustomerApi->customerRouterPlansList: $e\n');
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

# **customerRouterPlansRead**
> customerRouterPlansRead(slug)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getCustomerApi();
final String slug = slug_example; // String | 

try {
    api.customerRouterPlansRead(slug);
} catch on DioException (e) {
    print('Exception when calling CustomerApi->customerRouterPlansRead: $e\n');
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

# **customerSigninCreate**
> CustomerSignIn customerSigninCreate(data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getCustomerApi();
final CustomerSignIn data = ; // CustomerSignIn | 

try {
    final response = api.customerSigninCreate(data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling CustomerApi->customerSigninCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **data** | [**CustomerSignIn**](CustomerSignIn.md)|  | 

### Return type

[**CustomerSignIn**](CustomerSignIn.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **customerTokenCreate**
> CustomerTokenObtainPair customerTokenCreate(data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getCustomerApi();
final CustomerTokenObtainPair data = ; // CustomerTokenObtainPair | 

try {
    final response = api.customerTokenCreate(data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling CustomerApi->customerTokenCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **data** | [**CustomerTokenObtainPair**](CustomerTokenObtainPair.md)|  | 

### Return type

[**CustomerTokenObtainPair**](CustomerTokenObtainPair.md)

### Authorization

[Bearer](../README.md#Bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **customerTokenRefreshCreate**
> TokenRefresh customerTokenRefreshCreate(data)



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getCustomerApi();
final TokenRefresh data = ; // TokenRefresh | 

try {
    final response = api.customerTokenRefreshCreate(data);
    print(response);
} catch on DioException (e) {
    print('Exception when calling CustomerApi->customerTokenRefreshCreate: $e\n');
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

# **customerTransactionsList**
> customerTransactionsList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getCustomerApi();

try {
    api.customerTransactionsList();
} catch on DioException (e) {
    print('Exception when calling CustomerApi->customerTransactionsList: $e\n');
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

# **customerVerifyDeviceCreate**
> customerVerifyDeviceCreate()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getCustomerApi();

try {
    api.customerVerifyDeviceCreate();
} catch on DioException (e) {
    print('Exception when calling CustomerApi->customerVerifyDeviceCreate: $e\n');
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

# **customerVerifyEmailOtpCreate**
> customerVerifyEmailOtpCreate()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getCustomerApi();

try {
    api.customerVerifyEmailOtpCreate();
} catch on DioException (e) {
    print('Exception when calling CustomerApi->customerVerifyEmailOtpCreate: $e\n');
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

