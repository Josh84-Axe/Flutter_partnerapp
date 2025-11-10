//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'withdrawal_request.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WithdrawalRequest {
  /// Returns a new [WithdrawalRequest] instance.
  WithdrawalRequest({

     this.id,

    required  this.paymentMethod,

    required  this.amount,

     this.reference,

     this.status,

     this.requestedAt,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false
  )


  final int? id;



  @JsonKey(
    
    name: r'payment_method',
    required: true,
    includeIfNull: false
  )


  final int paymentMethod;



  @JsonKey(
    
    name: r'amount',
    required: true,
    includeIfNull: false
  )


  final double amount;



  @JsonKey(
    
    name: r'reference',
    required: false,
    includeIfNull: false
  )


  final String? reference;



  @JsonKey(
    
    name: r'status',
    required: false,
    includeIfNull: false
  )


  final WithdrawalRequestStatusEnum? status;



  @JsonKey(
    
    name: r'requested_at',
    required: false,
    includeIfNull: false
  )


  final DateTime? requestedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WithdrawalRequest &&
      other.id == id &&
      other.paymentMethod == paymentMethod &&
      other.amount == amount &&
      other.reference == reference &&
      other.status == status &&
      other.requestedAt == requestedAt;

    @override
    int get hashCode =>
        id.hashCode +
        paymentMethod.hashCode +
        amount.hashCode +
        reference.hashCode +
        status.hashCode +
        requestedAt.hashCode;

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) => _$WithdrawalRequestFromJson(json);

  Map<String, dynamic> toJson() => _$WithdrawalRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum WithdrawalRequestStatusEnum {
  @JsonValue(r'pending')
  pending,
  @JsonValue(r'approved')
  approved,
  @JsonValue(r'rejected')
  rejected,
  @JsonValue(r'completed')
  completed,
}


