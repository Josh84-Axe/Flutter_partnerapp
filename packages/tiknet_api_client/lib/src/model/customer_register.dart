//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'customer_register.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CustomerRegister {
  /// Returns a new [CustomerRegister] instance.
  CustomerRegister({

    required  this.firstName,

    required  this.phone,

     this.macAddress,

     this.routerDnsName,
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



  @JsonKey(
    
    name: r'router_dns_name',
    required: false,
    includeIfNull: false
  )


  final String? routerDnsName;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CustomerRegister &&
      other.firstName == firstName &&
      other.phone == phone &&
      other.macAddress == macAddress &&
      other.routerDnsName == routerDnsName;

    @override
    int get hashCode =>
        firstName.hashCode +
        phone.hashCode +
        macAddress.hashCode +
        routerDnsName.hashCode;

  factory CustomerRegister.fromJson(Map<String, dynamic> json) => _$CustomerRegisterFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerRegisterToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

