//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'partner_collaborator_register.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PartnerCollaboratorRegister {
  /// Returns a new [PartnerCollaboratorRegister] instance.
  PartnerCollaboratorRegister({

    required  this.firstName,

    required  this.email,

     this.phone,

     this.addresse,

     this.city,

     this.country,
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
    required: false,
    includeIfNull: false
  )


  final String? country;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PartnerCollaboratorRegister &&
      other.firstName == firstName &&
      other.email == email &&
      other.phone == phone &&
      other.addresse == addresse &&
      other.city == city &&
      other.country == country;

    @override
    int get hashCode =>
        firstName.hashCode +
        email.hashCode +
        phone.hashCode +
        addresse.hashCode +
        city.hashCode +
        country.hashCode;

  factory PartnerCollaboratorRegister.fromJson(Map<String, dynamic> json) => _$PartnerCollaboratorRegisterFromJson(json);

  Map<String, dynamic> toJson() => _$PartnerCollaboratorRegisterToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

