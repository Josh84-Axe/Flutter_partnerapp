//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'role.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Role {
  /// Returns a new [Role] instance.
  Role({

     this.id,

    required  this.name,

     this.slug,

     this.description,

     this.permissions,

     this.actif,
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
    
    name: r'description',
    required: false,
    includeIfNull: false
  )


  final String? description;



  @JsonKey(
    
    name: r'permissions',
    required: false,
    includeIfNull: false
  )


  final Set<int>? permissions;



  @JsonKey(
    
    name: r'actif',
    required: false,
    includeIfNull: false
  )


  final bool? actif;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Role &&
      other.id == id &&
      other.name == name &&
      other.slug == slug &&
      other.description == description &&
      other.permissions == permissions &&
      other.actif == actif;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        slug.hashCode +
        (description == null ? 0 : description.hashCode) +
        permissions.hashCode +
        actif.hashCode;

  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);

  Map<String, dynamic> toJson() => _$RoleToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

