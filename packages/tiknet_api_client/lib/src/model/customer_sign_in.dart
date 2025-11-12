//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'customer_sign_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CustomerSignIn {
  /// Returns a new [CustomerSignIn] instance.
  CustomerSignIn({

    required  this.firstName,

    required  this.phone,
  });

  @JsonKey(
    
    name: r'first_name',
    required: true,
    includeIfNull: false
  )


  final String firstName;



  @JsonKey(
    
    name: r'phone',
    required: true,
    includeIfNull: false
  )


  final String phone;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CustomerSignIn &&
      other.firstName == firstName &&
      other.phone == phone;

    @override
    int get hashCode =>
        firstName.hashCode +
        phone.hashCode;

  factory CustomerSignIn.fromJson(Map<String, dynamic> json) => _$CustomerSignInFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerSignInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

