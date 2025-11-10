//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'partner_block_or_unblock_customer.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PartnerBlockOrUnblockCustomer {
  /// Returns a new [PartnerBlockOrUnblockCustomer] instance.
  PartnerBlockOrUnblockCustomer({

     this.blocked,
  });

  @JsonKey(
    
    name: r'blocked',
    required: false,
    includeIfNull: false
  )


  final bool? blocked;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PartnerBlockOrUnblockCustomer &&
      other.blocked == blocked;

    @override
    int get hashCode =>
        blocked.hashCode;

  factory PartnerBlockOrUnblockCustomer.fromJson(Map<String, dynamic> json) => _$PartnerBlockOrUnblockCustomerFromJson(json);

  Map<String, dynamic> toJson() => _$PartnerBlockOrUnblockCustomerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

