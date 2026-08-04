//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:dio/dio.dart';
import 'package:tiknet_api_client/src/auth/api_key_auth.dart';
import 'package:tiknet_api_client/src/auth/basic_auth.dart';
import 'package:tiknet_api_client/src/auth/bearer_auth.dart';
import 'package:tiknet_api_client/src/auth/oauth.dart';
import 'package:tiknet_api_client/src/api/admin_api.dart';
import 'package:tiknet_api_client/src/api/customer_api.dart';
import 'package:tiknet_api_client/src/api/partner_api.dart';
import 'package:tiknet_api_client/src/api/radius_api.dart';

class TiknetApiClient {
  static const String basePath = r'https://api.tiknetafrica.com/v1';

  final Dio dio;
  TiknetApiClient({
    Dio? dio,
    String? basePathOverride,
    List<Interceptor>? interceptors,
  })  : 
        this.dio = dio ??
            Dio(BaseOptions(
              baseUrl: basePathOverride ?? basePath,
              connectTimeout: const Duration(milliseconds: 5000),
              receiveTimeout: const Duration(milliseconds: 3000),
            )) {
    if (interceptors == null) {
      this.dio.interceptors.addAll([
        OAuthInterceptor(),
        BasicAuthInterceptor(),
        BearerAuthInterceptor(),
        ApiKeyAuthInterceptor(),
      ]);
    } else {
      this.dio.interceptors.addAll(interceptors);
    }
  }

  void setOAuthToken(String name, String token) {
    if (this.dio.interceptors.any((i) => i is OAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is OAuthInterceptor) as OAuthInterceptor).tokens[name] = token;
    }
  }

  void setBearerAuth(String name, String token) {
    if (this.dio.interceptors.any((i) => i is BearerAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BearerAuthInterceptor) as BearerAuthInterceptor).tokens[name] = token;
    }
  }

  void setBasicAuth(String name, String username, String password) {
    if (this.dio.interceptors.any((i) => i is BasicAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BasicAuthInterceptor) as BasicAuthInterceptor).authInfo[name] = BasicAuthInfo(username, password);
    }
  }

  void setApiKey(String name, String apiKey) {
    if (this.dio.interceptors.any((i) => i is ApiKeyAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((element) => element is ApiKeyAuthInterceptor) as ApiKeyAuthInterceptor).apiKeys[name] = apiKey;
    }
  }

  /// Get AdminApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  AdminApi getAdminApi() {
    return AdminApi(dio);
  }

  /// Get CustomerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  CustomerApi getCustomerApi() {
    return CustomerApi(dio);
  }

  /// Get PartnerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  PartnerApi getPartnerApi() {
    return PartnerApi(dio);
  }

  /// Get RadiusApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  RadiusApi getRadiusApi() {
    return RadiusApi(dio);
  }
}
