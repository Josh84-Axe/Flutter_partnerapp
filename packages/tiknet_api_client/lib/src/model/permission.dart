//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'permission.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Permission {
  /// Returns a new [Permission] instance.
  Permission({

     this.id,

    required  this.name,

    required  this.slug,

     this.description,

     this.isActif,
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
    required: true,
    includeIfNull: false
  )


  final String slug;



  @JsonKey(
    
    name: r'description',
    required: false,
    includeIfNull: false
  )


  final String? description;



  @JsonKey(
    
    name: r'is_actif',
    required: false,
    includeIfNull: false
  )


  final bool? isActif;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Permission &&
      other.id == id &&
      other.name == name &&
      other.slug == slug &&
      other.description == description &&
      other.isActif == isActif;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        slug.hashCode +
        (description == null ? 0 : description.hashCode) +
        isActif.hashCode;

  factory Permission.fromJson(Map<String, dynamic> json) => _$PermissionFromJson(json);

  Map<String, dynamic> toJson() => _$PermissionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

