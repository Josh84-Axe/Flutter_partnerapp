//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'subscription_plan.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SubscriptionPlan {
  /// Returns a new [SubscriptionPlan] instance.
  SubscriptionPlan({

     this.id,

    required  this.name,

     this.slug,

    required  this.price,

     this.duration,

    required  this.features,

     this.isActive,

     this.createdAt,
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
    
    name: r'price',
    required: true,
    includeIfNull: false
  )


  final double price;



  @JsonKey(
    
    name: r'duration',
    required: false,
    includeIfNull: false
  )


  final SubscriptionPlanDurationEnum? duration;



  @JsonKey(
    
    name: r'features',
    required: true,
    includeIfNull: false
  )


  final Set<int> features;



  @JsonKey(
    
    name: r'is_active',
    required: false,
    includeIfNull: false
  )


  final bool? isActive;



  @JsonKey(
    
    name: r'created_at',
    required: false,
    includeIfNull: false
  )


  final DateTime? createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SubscriptionPlan &&
      other.id == id &&
      other.name == name &&
      other.slug == slug &&
      other.price == price &&
      other.duration == duration &&
      other.features == features &&
      other.isActive == isActive &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        (slug == null ? 0 : slug.hashCode) +
        price.hashCode +
        duration.hashCode +
        features.hashCode +
        isActive.hashCode +
        createdAt.hashCode;

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) => _$SubscriptionPlanFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionPlanToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum SubscriptionPlanDurationEnum {
  @JsonValue(r'monthly')
  monthly,
  @JsonValue(r'yearly')
  yearly,
}


