//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'update_withdrawal_request_status.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateWithdrawalRequestStatus {
  /// Returns a new [UpdateWithdrawalRequestStatus] instance.
  UpdateWithdrawalRequestStatus({

    required  this.status,
  });

      /// New status for the withdrawl request (pending, approved, completed or rejected).
  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false
  )


  final UpdateWithdrawalRequestStatusStatusEnum status;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UpdateWithdrawalRequestStatus &&
      other.status == status;

    @override
    int get hashCode =>
        status.hashCode;

  factory UpdateWithdrawalRequestStatus.fromJson(Map<String, dynamic> json) => _$UpdateWithdrawalRequestStatusFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateWithdrawalRequestStatusToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

/// New status for the withdrawl request (pending, approved, completed or rejected).
enum UpdateWithdrawalRequestStatusStatusEnum {
  @JsonValue(r'pending')
  pending,
  @JsonValue(r'approved')
  approved,
  @JsonValue(r'completed')
  completed,
  @JsonValue(r'rejected')
  rejected,
}


