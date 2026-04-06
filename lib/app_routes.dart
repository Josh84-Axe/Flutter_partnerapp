import 'package:flutter/material.dart';
import 'package:hotspot_partner_app/screens/auth_wrapper.dart';
import 'package:hotspot_partner_app/screens/home_screen.dart';

// Screens
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/plans_screen.dart';
import 'screens/settings_screen.dart';
import 'feature/launch/splash_screen.dart';
import 'feature/launch/onboarding_screen.dart';
import 'feature/auth/login_screen_m3.dart';
import 'screens/notifications_screen.dart';
import 'screens/language_screen.dart';
import 'feature/auth/forgot_password_screen.dart';
import 'feature/auth/verify_password_reset_otp_screen.dart';
import 'screens/email_verification_screen.dart';
import 'feature/auth/reset_password_screen.dart';

import 'screens/reset_email_sent_screen.dart';
import 'screens/set_new_password_screen.dart';
import 'screens/password_success_screen.dart';
import 'screens/profiles_screen.dart';
import 'screens/router_details_screen.dart';

import 'screens/bulk_actions_screen.dart';
import 'models/hotspot_profile_model.dart';
import 'models/user_model.dart';

import 'screens/hotspot_user_screen.dart';
import 'screens/configurations_screen.dart';
import 'screens/router_registration_screen.dart';
import 'screens/config/rate_limit_config_screen.dart';
import 'screens/config/idle_time_config_screen.dart';
import 'screens/config/plan_validity_config_screen.dart';
import 'screens/config/data_limit_config_screen.dart';
import 'screens/config/shared_user_config_screen.dart';
import 'screens/config/additional_device_config_screen.dart';

import 'screens/internet_plans_settings_screen.dart';
import 'screens/subscription_management_screen.dart';
import 'screens/router_settings_screen.dart';
import 'screens/add_router_screen.dart';

import 'screens/create_edit_plan_screen.dart';
import 'screens/assign_user_screen.dart';
import 'screens/create_role_screen.dart';
import 'screens/worker_profile_setup_screen.dart';
import 'screens/worker_activation_screen.dart';
import 'screens/router_assign_screen.dart';
import 'screens/onboarding/onboarding_flow.dart';
import 'screens/about_app_screen.dart';
import 'screens/empty_state_screen.dart';
import 'screens/wallet_overview_screen.dart';
import 'screens/payout_request_screen.dart';
import 'screens/payout_submitted_screen.dart';
import 'screens/revenue_breakdown_screen.dart';
import 'screens/security/password_and_2fa_screen.dart';
import 'screens/security/authenticators_screen.dart';
import 'screens/security/success_2fa_screen.dart';
import 'screens/partner_profile_screen.dart';
import 'screens/otp_validation_screen.dart';
import 'screens/reporting_screen.dart';
import 'screens/report_preview_screen.dart';
import 'screens/export_success_screen.dart';
import 'screens/create_edit_user_profile_screen.dart';
import 'screens/notification_settings_screen.dart';
import 'screens/notification_center_screen.dart';
import 'screens/notification_router_screen.dart';
import 'screens/user_details_screen.dart';
import 'screens/role_permission_screen.dart';
import 'screens/assign_role_screen.dart';
import 'screens/router_health_screen.dart';
import 'screens/transaction_payment_history_screen.dart';
import 'screens/transaction_history_screen.dart';
import 'screens/payout_history_screen.dart';
import 'screens/transaction_details_screen.dart';
import 'screens/add_payout_method_screen.dart';
import 'screens/assign_router_screen.dart';
import 'screens/voucher_list_screen.dart';

import 'screens/hotspot_users_management_screen.dart';
import 'screens/plan_assignment_screen.dart';
import 'screens/session_management_screen.dart';
import 'screens/collaborators_management_screen.dart';
import 'screens/payment_methods_screen.dart';
import 'screens/assigned_plans_list_screen.dart';
import 'screens/active_sessions_screen.dart';
import 'screens/help_support_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> get routes => {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/auth-wrapper': (context) => const AuthWrapper(),
        '/login': (context) => const LoginScreenM3(),
        '/login-old': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/home': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/language': (context) => const LanguageScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/reset-email-sent': (context) => const ResetEmailSentScreen(),
        '/set-new-password': (context) => const SetNewPasswordScreen(),
        '/password-success': (context) => const PasswordSuccessScreen(),
        '/profiles': (context) => const ProfilesScreen(),
        '/bulk-actions': (context) => const BulkActionsScreen(),
        '/hotspot-user': (context) => const HotspotUserScreen(),
        '/configurations': (context) => const ConfigurationsScreen(),
        '/router-registration': (context) => const RouterRegistrationScreen(),
        '/config/rate-limit': (context) => const RateLimitConfigScreen(),
        '/config/idle-time': (context) => const IdleTimeConfigScreen(),
        '/config/plan-validity': (context) => const PlanValidityConfigScreen(),
        '/config/data-limit': (context) => const DataLimitConfigScreen(),
        '/config/shared-users': (context) => const SharedUserConfigScreen(),
        '/config/additional-devices': (context) => const AdditionalDeviceConfigScreen(),
        '/internet-plan': (context) => const PlansScreen(),
        '/internet-plans-settings': (context) => const InternetPlansSettingsScreen(),
        '/subscription-management': (context) => const SubscriptionManagementScreen(),
        '/router-settings': (context) => const RouterSettingsScreen(),
        '/add-router': (context) => const AddRouterScreen(),
        '/role-permissions': (context) => const RolePermissionScreen(),
        '/assign-role': (context) => const AssignRoleScreen(),
        '/worker-profile-setup': (context) => const WorkerProfileSetupScreen(),
        '/worker-activation': (context) => const WorkerActivationScreen(),
        '/wallet-overview': (context) => const WalletOverviewScreen(),
        '/payout-request': (context) => const PayoutRequestScreen(),
        '/payout-submitted': (context) => const PayoutSubmittedScreen(),
        '/revenue-breakdown': (context) => const RevenueBreakdownScreen(),
        '/router-health': (context) => const RouterHealthScreen(),
        '/transaction-payment-history': (context) => const TransactionPaymentHistoryScreen(),
        '/transaction-history': (context) => const TransactionHistoryScreen(),
        '/payout-history': (context) => const PayoutHistoryScreen(),
        '/transaction-details': (context) => const TransactionDetailsScreen(),
        '/add-payout-method': (context) => const AddPayoutMethodScreen(),
        '/assign-router': (context) => const AssignRouterScreen(),
        '/security/password-2fa': (context) => const PasswordAndTwoFactorScreen(),
        '/security/authenticators': (context) => const AuthenticatorsScreen(),
        '/security/2fa-success': (context) => const TwoFactorSuccessScreen(),
        '/partner-profile': (context) => const PartnerProfileScreen(),
        '/otp-validation': (context) => const OtpValidationScreen(),
        '/reporting': (context) => const ReportingScreen(),
        '/report-preview': (context) => const ReportPreviewScreen(),
        '/export-success': (context) => const ExportSuccessScreen(),
        '/create-edit-user-profile': (context) {
          final profile = ModalRoute.of(context)?.settings.arguments as HotspotProfileModel?;
          return CreateEditUserProfileScreen(profile: profile);
        },
        '/notification-settings': (context) => const NotificationSettingsScreen(),
        '/notification-center': (context) => const NotificationCenterScreen(),
        '/notification-router': (context) => const NotificationRouterScreen(),
        '/user-details': (context) {
          final user = ModalRoute.of(context)?.settings.arguments as UserModel;
          return UserDetailsScreen(user: user);
        },
        '/onboarding-old': (context) => const OnboardingFlow(),
        '/about': (context) => const AboutAppScreen(),
        '/empty-state': (context) => const EmptyStateScreen(),
        '/email-verification': (context) {
          return const EmailVerificationScreen();
        },
        '/hotspot-users-management': (context) => const HotspotUsersManagementScreen(),
        '/plan-assignment': (context) => const PlanAssignmentScreen(),
        '/session-management': (context) => const SessionManagementScreen(),
        '/collaborators-management': (context) => const CollaboratorsManagementScreen(),
        '/payment-methods': (context) => const PaymentMethodsScreen(),
        '/assigned-plans-list': (context) => const AssignedPlansListScreen(),
        '/active-sessions': (context) => const ActiveSessionsScreen(),
        '/support': (context) => const HelpSupportScreen(),
      };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/router-details':
        final router = settings.arguments;
        return MaterialPageRoute(
          builder: (context) => RouterDetailsScreen(router: router as dynamic),
        );
      case '/profile-editor':
        final profile = settings.arguments as HotspotProfileModel?;
        return MaterialPageRoute(
          builder: (context) => CreateEditUserProfileScreen(profile: profile),
        );
      case '/create-edit-plan':
        final planData = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => CreateEditPlanScreen(planData: planData),
        );
      case '/assign-user':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => AssignUserScreen(
            planId: args['planId'] as String,
            planName: args['planName'] as String,
          ),
        );
      case '/create-role':
        final roleData = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => CreateRoleScreen(roleData: roleData),
        );
      case '/router-assign':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => RouterAssignScreen(
            userId: args['userId'] as String,
            userName: args['userName'] as String,
          ),
        );
      case '/verify-password-reset-otp':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => VerifyPasswordResetOtpScreen(
            email: args['email'] as String,
            otpId: args['otp_id']?.toString() ?? '',
          ),
        );
      case '/reset-password':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(
            email: args['email'] as String,
            token: args['token'] as String,
          ),
        );
      case '/vouchers':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => VoucherListScreen(
            planId: args['planId'] as String,
            planName: args['planName'] as String,
          ),
        );
      default:
        return null;
    }
  }
}
