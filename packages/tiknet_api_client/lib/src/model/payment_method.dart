//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'payment_method.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PaymentMethod {
  /// Returns a new [PaymentMethod] instance.
  PaymentMethod({

     this.id,

    required  this.name,

     this.slug,

     this.numbers,

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



          // minimum: -9223372036854775808
          // maximum: 9223372036854775807
  @JsonKey(
    
    name: r'numbers',
    required: false,
    includeIfNull: false
  )


  final int? numbers;



  @JsonKey(
    
    name: r'description',
    required: false,
    includeIfNull: false
  )


  final String? description;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PaymentMethod &&
      other.id == id &&
      other.name == name &&
      other.slug == slug &&
      other.numbers == numbers &&
      other.description == description;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        (slug == null ? 0 : slug.hashCode) +
        numbers.hashCode +
        (description == null ? 0 : description.hashCode);

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => _$PaymentMethodFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentMethodToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

