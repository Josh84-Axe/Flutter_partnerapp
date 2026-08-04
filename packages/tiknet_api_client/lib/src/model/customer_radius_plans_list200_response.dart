//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:tiknet_api_client/src/model/customer_radius_plans_list200_response_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'customer_radius_plans_list200_response.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CustomerRadiusPlansList200Response {
  /// Returns a new [CustomerRadiusPlansList200Response] instance.
  CustomerRadiusPlansList200Response({

     this.statusCode,

     this.error,

     this.message,

     this.data,
  });

      /// Code HTTP de la réponse
  @JsonKey(
    
    name: r'status_code',
    required: false,
    includeIfNull: false
  )


  final int? statusCode;



      /// Indique si une erreur s'est produite
  @JsonKey(
    
    name: r'error',
    required: false,
    includeIfNull: false
  )


  final bool? error;



      /// Message descriptif
  @JsonKey(
    
    name: r'message',
    required: false,
    includeIfNull: false
  )


  final String? message;



  @JsonKey(
    
    name: r'data',
    required: false,
    includeIfNull: false
  )


  final CustomerRadiusPlansList200ResponseData? data;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CustomerRadiusPlansList200Response &&
      other.statusCode == statusCode &&
      other.error == error &&
      other.message == message &&
      other.data == data;

    @override
    int get hashCode =>
        statusCode.hashCode +
        error.hashCode +
        message.hashCode +
        data.hashCode;

  factory CustomerRadiusPlansList200Response.fromJson(Map<String, dynamic> json) => _$CustomerRadiusPlansList200ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerRadiusPlansList200ResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

