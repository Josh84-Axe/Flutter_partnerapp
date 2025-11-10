//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'customer_radius_plans_list200_response_data_plans_inner.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CustomerRadiusPlansList200ResponseDataPlansInner {
  /// Returns a new [CustomerRadiusPlansList200ResponseDataPlansInner] instance.
  CustomerRadiusPlansList200ResponseDataPlansInner({

     this.username,

     this.planName,

     this.purchaseDate,

     this.validityDuration,

     this.status,
  });

      /// Nom d'utilisateur
  @JsonKey(
    
    name: r'username',
    required: false,
    includeIfNull: false
  )


  final String? username;



      /// Nom du plan
  @JsonKey(
    
    name: r'plan_name',
    required: false,
    includeIfNull: false
  )


  final String? planName;



      /// Date d'achat du plan
  @JsonKey(
    
    name: r'purchase_date',
    required: false,
    includeIfNull: false
  )


  final DateTime? purchaseDate;



      /// Durée de validité (ex: '24h', '30d')
  @JsonKey(
    
    name: r'validity_duration',
    required: false,
    includeIfNull: false
  )


  final String? validityDuration;



      /// Statut du plan ('pending', 'is_on_use', 'is_expired')
  @JsonKey(
    
    name: r'status',
    required: false,
    includeIfNull: false
  )


  final String? status;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CustomerRadiusPlansList200ResponseDataPlansInner &&
      other.username == username &&
      other.planName == planName &&
      other.purchaseDate == purchaseDate &&
      other.validityDuration == validityDuration &&
      other.status == status;

    @override
    int get hashCode =>
        username.hashCode +
        planName.hashCode +
        purchaseDate.hashCode +
        validityDuration.hashCode +
        status.hashCode;

  factory CustomerRadiusPlansList200ResponseDataPlansInner.fromJson(Map<String, dynamic> json) => _$CustomerRadiusPlansList200ResponseDataPlansInnerFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerRadiusPlansList200ResponseDataPlansInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

