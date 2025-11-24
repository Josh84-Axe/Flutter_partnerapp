//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'update_partner_status.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdatePartnerStatus {
  /// Returns a new [UpdatePartnerStatus] instance.
  UpdatePartnerStatus({

    required  this.status,
  });

      /// Nouveau statut du partenaire (pending, on_process, validated).
  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false
  )


  final UpdatePartnerStatusStatusEnum status;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UpdatePartnerStatus &&
      other.status == status;

    @override
    int get hashCode =>
        status.hashCode;

  factory UpdatePartnerStatus.fromJson(Map<String, dynamic> json) => _$UpdatePartnerStatusFromJson(json);

  Map<String, dynamic> toJson() => _$UpdatePartnerStatusToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// Nouveau statut du partenaire (pending, on_process, validated).
enum UpdatePartnerStatusStatusEnum {
  @JsonValue(r'pending')
  pending,
  @JsonValue(r'on_process')
  onProcess,
  @JsonValue(r'validated')
  validated,
}


