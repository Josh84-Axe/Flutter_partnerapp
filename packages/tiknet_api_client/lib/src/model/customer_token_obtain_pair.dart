//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'customer_token_obtain_pair.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CustomerTokenObtainPair {
  /// Returns a new [CustomerTokenObtainPair] instance.
  CustomerTokenObtainPair({

    required  this.firstName,

    required  this.phone,

     this.macAddress,
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



  @JsonKey(
    
    name: r'mac_address',
    required: false,
    includeIfNull: false
  )


  final String? macAddress;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CustomerTokenObtainPair &&
      other.firstName == firstName &&
      other.phone == phone &&
      other.macAddress == macAddress;

    @override
    int get hashCode =>
        firstName.hashCode +
        phone.hashCode +
        macAddress.hashCode;

  factory CustomerTokenObtainPair.fromJson(Map<String, dynamic> json) => _$CustomerTokenObtainPairFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerTokenObtainPairToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

