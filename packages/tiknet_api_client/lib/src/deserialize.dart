import 'package:tiknet_api_client/src/model/admin_activate_or_deactivate_user.dart';
import 'package:tiknet_api_client/src/model/admin_token_obtain_pair.dart';
import 'package:tiknet_api_client/src/model/confirm_register_email_otp.dart';
import 'package:tiknet_api_client/src/model/customer_radius_plans_list200_response.dart';
import 'package:tiknet_api_client/src/model/customer_radius_plans_list200_response_data.dart';
import 'package:tiknet_api_client/src/model/customer_radius_plans_list200_response_data_plans_inner.dart';
import 'package:tiknet_api_client/src/model/customer_register.dart';
import 'package:tiknet_api_client/src/model/customer_sign_in.dart';
import 'package:tiknet_api_client/src/model/customer_token_obtain_pair.dart';
import 'package:tiknet_api_client/src/model/my_token_obtain_pair.dart';
import 'package:tiknet_api_client/src/model/partner_block_or_unblock_customer.dart';
import 'package:tiknet_api_client/src/model/partner_change_password_create_request.dart';
import 'package:tiknet_api_client/src/model/partner_collaborator_register.dart';
import 'package:tiknet_api_client/src/model/partner_collaborators_assign_role_create_request.dart';
import 'package:tiknet_api_client/src/model/partner_collaborators_update_role_update_request.dart';
import 'package:tiknet_api_client/src/model/partner_password_reset_otp_request.dart';
import 'package:tiknet_api_client/src/model/partner_password_reset_otp_code_verify.dart';
import 'package:tiknet_api_client/src/model/partner_register_init.dart';
import 'package:tiknet_api_client/src/model/partner_reset_password.dart';
import 'package:tiknet_api_client/src/model/payment_method.dart';
import 'package:tiknet_api_client/src/model/permission.dart';
import 'package:tiknet_api_client/src/model/purchase_subscription.dart';
import 'package:tiknet_api_client/src/model/resend_verify_email_otp.dart';
import 'package:tiknet_api_client/src/model/role.dart';
import 'package:tiknet_api_client/src/model/router.dart';
import 'package:tiknet_api_client/src/model/subscription_feature.dart';
import 'package:tiknet_api_client/src/model/subscription_plan.dart';
import 'package:tiknet_api_client/src/model/token_refresh.dart';
import 'package:tiknet_api_client/src/model/update_partner.dart';
import 'package:tiknet_api_client/src/model/update_partner_status.dart';
import 'package:tiknet_api_client/src/model/update_withdrawal_request_status.dart';
import 'package:tiknet_api_client/src/model/verify_email_otp.dart';
import 'package:tiknet_api_client/src/model/wallet_transaction.dart';
import 'package:tiknet_api_client/src/model/withdrawal_request.dart';

final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

  ReturnType deserialize<ReturnType, BaseType>(dynamic value, String targetType, {bool growable= true}) {
      switch (targetType) {
        case 'String':
          return '$value' as ReturnType;
        case 'int':
          return (value is int ? value : int.parse('$value')) as ReturnType;
        case 'bool':
          if (value is bool) {
            return value as ReturnType;
          }
          final valueString = '$value'.toLowerCase();
          return (valueString == 'true' || valueString == '1') as ReturnType;
        case 'double':
          return (value is double ? value : double.parse('$value')) as ReturnType;
        case 'AdminActivateOrDeactivateUser':
          return AdminActivateOrDeactivateUser.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AdminTokenObtainPair':
          return AdminTokenObtainPair.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ConfirmRegisterEmailOtp':
          return ConfirmRegisterEmailOtp.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CustomerRadiusPlansList200Response':
          return CustomerRadiusPlansList200Response.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CustomerRadiusPlansList200ResponseData':
          return CustomerRadiusPlansList200ResponseData.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CustomerRadiusPlansList200ResponseDataPlansInner':
          return CustomerRadiusPlansList200ResponseDataPlansInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CustomerRegister':
          return CustomerRegister.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CustomerSignIn':
          return CustomerSignIn.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CustomerTokenObtainPair':
          return CustomerTokenObtainPair.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MyTokenObtainPair':
          return MyTokenObtainPair.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PartnerBlockOrUnblockCustomer':
          return PartnerBlockOrUnblockCustomer.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PartnerChangePasswordCreateRequest':
          return PartnerChangePasswordCreateRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PartnerCollaboratorRegister':
          return PartnerCollaboratorRegister.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PartnerCollaboratorsAssignRoleCreateRequest':
          return PartnerCollaboratorsAssignRoleCreateRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PartnerCollaboratorsUpdateRoleUpdateRequest':
          return PartnerCollaboratorsUpdateRoleUpdateRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PartnerPasswordResetOTPRequest':
          return PartnerPasswordResetOTPRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PartnerPasswordResetOtpCodeVerify':
          return PartnerPasswordResetOtpCodeVerify.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PartnerRegisterInit':
          return PartnerRegisterInit.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PartnerResetPassword':
          return PartnerResetPassword.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PaymentMethod':
          return PaymentMethod.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Permission':
          return Permission.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PurchaseSubscription':
          return PurchaseSubscription.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ResendVerifyEmailOtp':
          return ResendVerifyEmailOtp.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Role':
          return Role.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Router':
          return Router.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SubscriptionFeature':
          return SubscriptionFeature.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SubscriptionPlan':
          return SubscriptionPlan.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TokenRefresh':
          return TokenRefresh.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UpdatePartner':
          return UpdatePartner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UpdatePartnerStatus':
          return UpdatePartnerStatus.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UpdateWithdrawalRequestStatus':
          return UpdateWithdrawalRequestStatus.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'VerifyEmailOtp':
          return VerifyEmailOtp.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WalletTransaction':
          return WalletTransaction.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WithdrawalRequest':
          return WithdrawalRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        default:
          RegExpMatch? match;

          if (value is List && (match = _regList.firstMatch(targetType)) != null) {
            targetType = match![1]!; // ignore: parameter_assignments
            return value
              .map<BaseType>((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable))
              .toList(growable: growable) as ReturnType;
          }
          if (value is Set && (match = _regSet.firstMatch(targetType)) != null) {
            targetType = match![1]!; // ignore: parameter_assignments
            return value
              .map<BaseType>((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable))
              .toSet() as ReturnType;
          }
          if (value is Map && (match = _regMap.firstMatch(targetType)) != null) {
            targetType = match![1]!; // ignore: parameter_assignments
            return Map<dynamic, BaseType>.fromIterables(
              value.keys,
              value.values.map((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable)),
            ) as ReturnType;
          }
          break;
    } 
    throw Exception('Cannot deserialize');
  }