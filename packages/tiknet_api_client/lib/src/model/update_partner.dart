//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'update_partner.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdatePartner {
  /// Returns a new [UpdatePartner] instance.
  UpdatePartner({

     this.firstName,

     this.lastName,

     this.email,

    required  this.phone,

    required  this.country,

     this.state,

     this.city,

     this.addresse,

     this.numberOfRouter,
  });

  @JsonKey(
    
    name: r'first_name',
    required: false,
    includeIfNull: false
  )


  final String? firstName;



  @JsonKey(
    
    name: r'last_name',
    required: false,
    includeIfNull: false
  )


  final String? lastName;



  @JsonKey(
    
    name: r'email',
    required: false,
    includeIfNull: false
  )


  final String? email;



  @JsonKey(
    
    name: r'phone',
    required: true,
    includeIfNull: true
  )


  final String? phone;



  @JsonKey(
    
    name: r'country',
    required: true,
    includeIfNull: true
  )


  final String? country;



  @JsonKey(
    
    name: r'state',
    required: false,
    includeIfNull: false
  )


  final String? state;



  @JsonKey(
    
    name: r'city',
    required: false,
    includeIfNull: false
  )


  final String? city;



  @JsonKey(
    
    name: r'addresse',
    required: false,
    includeIfNull: false
  )


  final String? addresse;



      /// Number of router. Ex: 1, 2, 3, 4, 5, etc.
          // minimum: 0
          // maximum: 2147483647
  @JsonKey(
    
    name: r'number_of_router',
    required: false,
    includeIfNull: false
  )


  final int? numberOfRouter;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UpdatePartner &&
      other.firstName == firstName &&
      other.lastName == lastName &&
      other.email == email &&
      other.phone == phone &&
      other.country == country &&
      other.state == state &&
      other.city == city &&
      other.addresse == addresse &&
      other.numberOfRouter == numberOfRouter;

    @override
    int get hashCode =>
        (firstName == null ? 0 : firstName.hashCode) +
        (lastName == null ? 0 : lastName.hashCode) +
        email.hashCode +
        (phone == null ? 0 : phone.hashCode) +
        (country == null ? 0 : country.hashCode) +
        (state == null ? 0 : state.hashCode) +
        (city == null ? 0 : city.hashCode) +
        (addresse == null ? 0 : addresse.hashCode) +
        numberOfRouter.hashCode;

  factory UpdatePartner.fromJson(Map<String, dynamic> json) => _$UpdatePartnerFromJson(json);

  Map<String, dynamic> toJson() => _$UpdatePartnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

