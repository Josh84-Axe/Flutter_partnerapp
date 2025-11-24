//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'router.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Router {
  /// Returns a new [Router] instance.
  Router({

     this.id,

    required  this.name,

     this.slug,

     this.ref,

    required  this.ipAddress,

    required  this.username,

    required  this.password,

     this.secret,

     this.dnsName,

     this.apiPort,

     this.coaPort,

     this.isActive,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false
  )


  final int? id;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false
  )


  final String name;



  @JsonKey(
    
    name: r'slug',
    required: false,
    includeIfNull: false
  )


  final String? slug;



  @JsonKey(
    
    name: r'ref',
    required: false,
    includeIfNull: false
  )


  final String? ref;



  @JsonKey(
    
    name: r'ip_address',
    required: true,
    includeIfNull: false
  )


  final String ipAddress;



  @JsonKey(
    
    name: r'username',
    required: true,
    includeIfNull: false
  )


  final String username;



  @JsonKey(
    
    name: r'password',
    required: true,
    includeIfNull: false
  )


  final String password;



  @JsonKey(
    
    name: r'secret',
    required: false,
    includeIfNull: false
  )


  final String? secret;



  @JsonKey(
    
    name: r'dns_name',
    required: false,
    includeIfNull: false
  )


  final String? dnsName;



          // minimum: -2147483648
          // maximum: 2147483647
  @JsonKey(
    
    name: r'api_port',
    required: false,
    includeIfNull: false
  )


  final int? apiPort;



          // minimum: -2147483648
          // maximum: 2147483647
  @JsonKey(
    
    name: r'coa_port',
    required: false,
    includeIfNull: false
  )


  final int? coaPort;



  @JsonKey(
    
    name: r'is_active',
    required: false,
    includeIfNull: false
  )


  final bool? isActive;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Router &&
      other.id == id &&
      other.name == name &&
      other.slug == slug &&
      other.ref == ref &&
      other.ipAddress == ipAddress &&
      other.username == username &&
      other.password == password &&
      other.secret == secret &&
      other.dnsName == dnsName &&
      other.apiPort == apiPort &&
      other.coaPort == coaPort &&
      other.isActive == isActive;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        (slug == null ? 0 : slug.hashCode) +
        ref.hashCode +
        ipAddress.hashCode +
        username.hashCode +
        password.hashCode +
        (secret == null ? 0 : secret.hashCode) +
        (dnsName == null ? 0 : dnsName.hashCode) +
        apiPort.hashCode +
        coaPort.hashCode +
        isActive.hashCode;

  factory Router.fromJson(Map<String, dynamic> json) => _$RouterFromJson(json);

  Map<String, dynamic> toJson() => _$RouterToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

