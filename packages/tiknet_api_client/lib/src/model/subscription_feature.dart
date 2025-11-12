//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'subscription_feature.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SubscriptionFeature {
  /// Returns a new [SubscriptionFeature] instance.
  SubscriptionFeature({

     this.id,

    required  this.name,

     this.slug,

     this.description,
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





    @override
    bool operator ==(Object other) => identical(this, other) || other is SubscriptionFeature &&
      other.id == id &&
      other.name == name &&
      other.slug == slug &&
      other.description == description;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        (slug == null ? 0 : slug.hashCode) +
        (description == null ? 0 : description.hashCode);

  factory SubscriptionFeature.fromJson(Map<String, dynamic> json) => _$SubscriptionFeatureFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionFeatureToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

