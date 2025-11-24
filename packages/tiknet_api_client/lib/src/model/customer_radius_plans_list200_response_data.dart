//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:tiknet_api_client/src/model/customer_radius_plans_list200_response_data_plans_inner.dart';
import 'package:json_annotation/json_annotation.dart';

part 'customer_radius_plans_list200_response_data.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CustomerRadiusPlansList200ResponseData {
  /// Returns a new [CustomerRadiusPlansList200ResponseData] instance.
  CustomerRadiusPlansList200ResponseData({

     this.username,

     this.plans,
  });

      /// Nom d'utilisateur
  @JsonKey(
    
    name: r'username',
    required: false,
    includeIfNull: false
  )


  final String? username;



  @JsonKey(
    
    name: r'plans',
    required: false,
    includeIfNull: false
  )


  final List<CustomerRadiusPlansList200ResponseDataPlansInner>? plans;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CustomerRadiusPlansList200ResponseData &&
      other.username == username &&
      other.plans == plans;

    @override
    int get hashCode =>
        username.hashCode +
        plans.hashCode;

  factory CustomerRadiusPlansList200ResponseData.fromJson(Map<String, dynamic> json) => _$CustomerRadiusPlansList200ResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerRadiusPlansList200ResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

