//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'wallet_transaction.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WalletTransaction {
  /// Returns a new [WalletTransaction] instance.
  WalletTransaction({

     this.id,

     this.user,

     this.customer,

    required  this.paymentReference,

    required  this.amountPaid,

     this.status,

     this.type,

     this.modelType,

    required  this.modelId,

     this.relatedModel,

     this.createdAt,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false
  )


  final int? id;



  @JsonKey(
    
    name: r'user',
    required: false,
    includeIfNull: false
  )


  final int? user;



  @JsonKey(
    
    name: r'customer',
    required: false,
    includeIfNull: false
  )


  final int? customer;



  @JsonKey(
    
    name: r'payment_reference',
    required: true,
    includeIfNull: false
  )


  final String paymentReference;



  @JsonKey(
    
    name: r'amount_paid',
    required: true,
    includeIfNull: false
  )


  final double amountPaid;



  @JsonKey(
    
    name: r'status',
    required: false,
    includeIfNull: false
  )


  final WalletTransactionStatusEnum? status;



  @JsonKey(
    
    name: r'type',
    required: false,
    includeIfNull: false
  )


  final WalletTransactionTypeEnum? type;



  @JsonKey(
    
    name: r'model_type',
    required: false,
    includeIfNull: false
  )


  final int? modelType;



          // minimum: 0
          // maximum: 2147483647
  @JsonKey(
    
    name: r'model_id',
    required: true,
    includeIfNull: false
  )


  final int modelId;



  @JsonKey(
    
    name: r'related_model',
    required: false,
    includeIfNull: false
  )


  final String? relatedModel;



  @JsonKey(
    
    name: r'created_at',
    required: false,
    includeIfNull: false
  )


  final DateTime? createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WalletTransaction &&
      other.id == id &&
      other.user == user &&
      other.customer == customer &&
      other.paymentReference == paymentReference &&
      other.amountPaid == amountPaid &&
      other.status == status &&
      other.type == type &&
      other.modelType == modelType &&
      other.modelId == modelId &&
      other.relatedModel == relatedModel &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        id.hashCode +
        (user == null ? 0 : user.hashCode) +
        (customer == null ? 0 : customer.hashCode) +
        paymentReference.hashCode +
        amountPaid.hashCode +
        status.hashCode +
        type.hashCode +
        modelType.hashCode +
        modelId.hashCode +
        relatedModel.hashCode +
        createdAt.hashCode;

  factory WalletTransaction.fromJson(Map<String, dynamic> json) => _$WalletTransactionFromJson(json);

  Map<String, dynamic> toJson() => _$WalletTransactionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum WalletTransactionStatusEnum {
  @JsonValue(r'pending')
  pending,
  @JsonValue(r'success')
  success,
  @JsonValue(r'failed')
  failed,
}



enum WalletTransactionTypeEnum {
  @JsonValue(r'revenue')
  revenue,
  @JsonValue(r'payout')
  payout,
}


