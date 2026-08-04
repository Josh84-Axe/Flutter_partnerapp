//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'partner_register_init.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PartnerRegisterInit {
  /// Returns a new [PartnerRegisterInit] instance.
  PartnerRegisterInit({

    required  this.firstName,

    required  this.email,

     this.phone,

     this.addresse,

     this.city,

    required  this.country,

     this.numberOfRouter,

    required  this.password,

    required  this.password2,
  });

  @JsonKey(
    
    name: r'first_name',
    required: true,
    includeIfNull: false
  )


  final String firstName;



  @JsonKey(
    
    name: r'email',
    required: true,
    includeIfNull: false
  )


  final String email;



  @JsonKey(
    
    name: r'phone',
    required: false,
    includeIfNull: false
  )


  final String? phone;



  @JsonKey(
    
    name: r'addresse',
    required: false,
    includeIfNull: false
  )


  final String? addresse;



  @JsonKey(
    
    name: r'city',
    required: false,
    includeIfNull: false
  )


  final String? city;



  @JsonKey(
    
    name: r'country',
    required: true,
    includeIfNull: false
  )


  final String country;



  @JsonKey(
    
    name: r'number_of_router',
    required: false,
    includeIfNull: false
  )


  final int? numberOfRouter;



  @JsonKey(
    
    name: r'password',
    required: true,
    includeIfNull: false
  )


  final String password;



  @JsonKey(
    
    name: r'password2',
    required: true,
    includeIfNull: false
  )


  final String password2;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PartnerRegisterInit &&
      other.firstName == firstName &&
      other.email == email &&
      other.phone == phone &&
      other.addresse == addresse &&
      other.city == city &&
      other.country == country &&
      other.numberOfRouter == numberOfRouter &&
      other.password == password &&
      other.password2 == password2;

    @override
    int get hashCode =>
        firstName.hashCode +
        email.hashCode +
        phone.hashCode +
        addresse.hashCode +
        city.hashCode +
        country.hashCode +
        numberOfRouter.hashCode +
        password.hashCode +
        password2.hashCode;

  factory PartnerRegisterInit.fromJson(Map<String, dynamic> json) => _$PartnerRegisterInitFromJson(json);

  Map<String, dynamic> toJson() => _$PartnerRegisterInitToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

