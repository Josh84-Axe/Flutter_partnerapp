# tiknet_api_client.api.RadiusApi

## Load the API package
```dart
import 'package:tiknet_api_client/api.dart';
```

All URIs are relative to *https://api.tiknetafrica.com/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**radiusRadacctList**](RadiusApi.md#radiusradacctlist) | **GET** /radius/radacct/ | 
[**radiusRadcheckList**](RadiusApi.md#radiusradchecklist) | **GET** /radius/radcheck/ | 
[**radiusRadreplyList**](RadiusApi.md#radiusradreplylist) | **GET** /radius/radreply/ | 
[**radiusUserBalancesList**](RadiusApi.md#radiususerbalanceslist) | **GET** /radius/user-balances/ | 
[**radiusUserMacsList**](RadiusApi.md#radiususermacslist) | **GET** /radius/user-macs/ | 
[**radiusUserPlansList**](RadiusApi.md#radiususerplanslist) | **GET** /radius/user-plans/ | 


# **radiusRadacctList**
> radiusRadacctList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getRadiusApi();

try {
    api.radiusRadacctList();
} catch on DioException (e) {
    print('Exception when calling RadiusApi->radiusRadacctList: $e\n');
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

# **radiusRadcheckList**
> radiusRadcheckList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getRadiusApi();

try {
    api.radiusRadcheckList();
} catch on DioException (e) {
    print('Exception when calling RadiusApi->radiusRadcheckList: $e\n');
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

# **radiusRadreplyList**
> radiusRadreplyList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getRadiusApi();

try {
    api.radiusRadreplyList();
} catch on DioException (e) {
    print('Exception when calling RadiusApi->radiusRadreplyList: $e\n');
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

# **radiusUserBalancesList**
> radiusUserBalancesList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getRadiusApi();

try {
    api.radiusUserBalancesList();
} catch on DioException (e) {
    print('Exception when calling RadiusApi->radiusUserBalancesList: $e\n');
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

# **radiusUserMacsList**
> radiusUserMacsList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getRadiusApi();

try {
    api.radiusUserMacsList();
} catch on DioException (e) {
    print('Exception when calling RadiusApi->radiusUserMacsList: $e\n');
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

# **radiusUserPlansList**
> radiusUserPlansList()



### Example
```dart
import 'package:tiknet_api_client/api.dart';
// TODO Configure API key authorization: Bearer
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKey = 'YOUR_API_KEY';
// uncomment below to setup prefix (e.g. Bearer) for API key, if needed
//defaultApiClient.getAuthentication<ApiKeyAuth>('Bearer').apiKeyPrefix = 'Bearer';

final api = TiknetApiClient().getRadiusApi();

try {
    api.radiusUserPlansList();
} catch on DioException (e) {
    print('Exception when calling RadiusApi->radiusUserPlansList: $e\n');
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

