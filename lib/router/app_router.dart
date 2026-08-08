import '../models/router_configuration_model.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:hotspot_partner_app/screens/auth_wrapper.dart';
import 'package:hotspot_partner_app/screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/registration_screen.dart';
import '../screens/family_registration_screen.dart';
import '../screens/campus_registration_screen.dart';
import '../screens/campus_schedules_screen.dart';
import '../screens/family_add_device_screen.dart';
import '../screens/family_devices_screen.dart';
import '../screens/family_content_policy_screen.dart';
import '../screens/family_schedule_manager_screen.dart';
import '../screens/family_profiles_screen.dart';
import '../screens/family_network_zones_screen.dart';
import '../screens/campus_map_screen.dart';
import '../screens/campus_support_screen.dart';
import '../screens/plans_screen.dart';
import '../screens/settings_screen.dart';
import '../feature/launch/splash_screen.dart';
import '../feature/launch/onboarding_screen.dart';
import '../screens/onboarding/dynamic_tour_screen.dart';
import '../../flavors.dart';
import '../feature/auth/login_screen_m3.dart';
import '../screens/notifications_screen.dart';
import '../screens/language_screen.dart';
import '../feature/auth/forgot_password_screen.dart';
import '../feature/auth/verify_password_reset_otp_screen.dart';
import '../screens/email_verification_screen.dart';
import '../feature/auth/reset_password_screen.dart';
import '../screens/reset_email_sent_screen.dart';
import '../screens/set_new_password_screen.dart';
import '../screens/password_success_screen.dart';
import '../screens/profiles_screen.dart';
import '../screens/router_details_screen.dart';
import '../screens/bulk_actions_screen.dart';
import '../models/hotspot_profile_model.dart';
import '../models/user_model.dart';
import '../screens/hotspot_user_screen.dart';
import '../screens/configurations_screen.dart';
import '../screens/router_registration_screen.dart';
import '../screens/config/rate_limit_config_screen.dart';
import '../screens/config/idle_time_config_screen.dart';
import '../screens/config/plan_validity_config_screen.dart';
import '../screens/config/data_limit_config_screen.dart';
import '../screens/config/shared_user_config_screen.dart';
import '../screens/config/additional_device_config_screen.dart';
import '../screens/internet_plans_settings_screen.dart';
import '../screens/subscription_management_screen.dart';
import '../screens/router_settings_screen.dart';
import '../screens/add_router_screen.dart';
import '../screens/router_ztp_wizard_screen.dart';
import '../screens/create_edit_plan_screen.dart';
import '../screens/assign_user_screen.dart';
import '../screens/create_role_screen.dart';
import '../screens/worker_profile_setup_screen.dart';
import '../screens/worker_activation_screen.dart';
import '../screens/router_assign_screen.dart';
import '../screens/onboarding/onboarding_flow.dart';
import '../screens/about_app_screen.dart';
import '../screens/empty_state_screen.dart';
import '../screens/wallet_overview_screen.dart';
import '../screens/payout_request_screen.dart';
import '../screens/payout_submitted_screen.dart';
import '../screens/revenue_breakdown_screen.dart';
import '../screens/security/password_and_2fa_screen.dart';
import '../screens/security/authenticators_screen.dart';
import '../screens/security/success_2fa_screen.dart';
import '../screens/partner_profile_screen.dart';
import '../screens/otp_validation_screen.dart';
import '../screens/reporting_screen.dart';
import '../screens/report_preview_screen.dart';
import '../screens/export_success_screen.dart';
import '../screens/create_edit_user_profile_screen.dart';
import '../screens/notification_settings_screen.dart';
import '../screens/notification_center_screen.dart';
import '../screens/notification_router_screen.dart';
import '../screens/user_details_screen.dart';
import '../screens/role_permission_screen.dart';
import '../screens/assign_role_screen.dart';
import '../screens/router_health_screen.dart';
import '../screens/transaction_payment_history_screen.dart';
import '../screens/transaction_history_screen.dart';
import '../screens/payout_history_screen.dart';
import '../screens/transaction_details_screen.dart';
import '../screens/add_payout_method_screen.dart';
import '../screens/assign_router_screen.dart';
import '../screens/voucher_list_screen.dart';
import '../screens/hotspot_users_management_screen.dart';
import '../screens/plan_assignment_screen.dart';
import '../screens/session_management_screen.dart';
import '../screens/collaborators_management_screen.dart';
import '../screens/payment_methods_screen.dart';
import '../screens/assigned_plans_list_screen.dart';
import '../screens/active_sessions_screen.dart';
import '../screens/help_support_screen.dart';
import '../screens/setup_pin_screen.dart';
import '../screens/onboarding/variant_selection_screen.dart';


final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),

    GoRoute(
      path: '/dynamic-tour',
      builder: (context, state) => const DynamicTourScreen(),
    ),
    GoRoute(
      path: '/onboarding-old',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/auth-wrapper',
      builder: (context, state) => const AuthWrapper(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreenM3(),
    ),
    GoRoute(
      path: '/setup-pin',
      builder: (context, state) => const SetupPinScreen(),
    ),
    GoRoute(
      path: '/family-add-device',
      builder: (context, state) => const FamilyAddDeviceScreen(),
    ),
    GoRoute(
      path: '/family-devices',
      builder: (context, state) => const FamilyDevicesScreen(),
    ),
    GoRoute(
      path: '/family-schedules',
      builder: (context, state) => const FamilyScheduleManagerScreen(),
    ),
    GoRoute(
      path: '/family-profiles',
      builder: (context, state) => const FamilyProfilesScreen(),
    ),
    GoRoute(
      path: '/family-network-zones',
      builder: (context, state) => const FamilyNetworkZonesScreen(),
    ),
    GoRoute(
      path: '/family-content-policy',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>;
        return FamilyContentPolicyScreen(device: args['device']);
      },
    ),
    GoRoute(
      path: '/campus-schedules',
      builder: (context, state) => const CampusSchedulesScreen(),
    ),
    GoRoute(
      path: '/campus-map',
      builder: (context, state) => const CampusMapScreen(),
    ),
    GoRoute(
      path: '/campus-support',
      builder: (context, state) => const CampusSupportScreen(),
    ),
    GoRoute(
      path: '/login-old',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) {
        final appVariant = F.name;
        if (appVariant == 'family') {
          return const FamilyRegistrationScreen(appVariant: 'family');
        } else if (appVariant == 'campus') {
          return const CampusRegistrationScreen(appVariant: 'campus');
        }
        return RegistrationScreen(appVariant: appVariant);
      },
    ),

    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/language',
      builder: (context, state) => const LanguageScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/reset-email-sent',
      builder: (context, state) => const ResetEmailSentScreen(),
    ),
    GoRoute(
      path: '/set-new-password',
      builder: (context, state) => const SetNewPasswordScreen(),
    ),
    GoRoute(
      path: '/password-success',
      builder: (context, state) => const PasswordSuccessScreen(),
    ),
    GoRoute(
      path: '/profiles',
      builder: (context, state) => const ProfilesScreen(),
    ),
    GoRoute(
      path: '/bulk-actions',
      builder: (context, state) => const BulkActionsScreen(),
    ),
    GoRoute(
      path: '/hotspot-user',
      builder: (context, state) => const HotspotUserScreen(),
    ),
    GoRoute(
      path: '/configurations',
      builder: (context, state) => const ConfigurationsScreen(),
    ),
    GoRoute(
      path: '/router-registration',
      builder: (context, state) => const RouterRegistrationScreen(),
    ),
    GoRoute(
      path: '/config/rate-limit',
      builder: (context, state) => const RateLimitConfigScreen(),
    ),
    GoRoute(
      path: '/config/idle-time',
      builder: (context, state) => const IdleTimeConfigScreen(),
    ),
    GoRoute(
      path: '/config/plan-validity',
      builder: (context, state) => const PlanValidityConfigScreen(),
    ),
    GoRoute(
      path: '/config/data-limit',
      builder: (context, state) => const DataLimitConfigScreen(),
    ),
    GoRoute(
      path: '/config/shared-users',
      builder: (context, state) => const SharedUserConfigScreen(),
    ),
    GoRoute(
      path: '/config/additional-devices',
      builder: (context, state) => const AdditionalDeviceConfigScreen(),
    ),
    GoRoute(
      path: '/internet-plan',
      builder: (context, state) => const PlansScreen(),
    ),
    GoRoute(
      path: '/internet-plans-settings',
      builder: (context, state) => const InternetPlansSettingsScreen(),
    ),
    GoRoute(
      path: '/subscription-management',
      builder: (context, state) => const SubscriptionManagementScreen(),
    ),
    GoRoute(
      path: '/router-settings',
      builder: (context, state) => const RouterSettingsScreen(),
    ),
    GoRoute(
      path: '/add-router',
      builder: (context, state) => AddRouterScreen(
        args: state.extra as RouterConfigurationModel?,
      ),
    ),
    GoRoute(
      path: '/router-ztp-wizard',
      builder: (context, state) {
        int? rId;
        String? rName;
        if (state.extra is Map<String, dynamic>) {
          final map = state.extra as Map<String, dynamic>;
          rId = map['routerId'] is int ? map['routerId'] : int.tryParse(map['routerId']?.toString() ?? '');
          rName = map['routerName']?.toString();
        }
        return RouterZtpWizardScreen(routerId: rId, routerName: rName);
      },
    ),
    GoRoute(
      path: '/role-permissions',
      builder: (context, state) => const RolePermissionScreen(),
    ),
    GoRoute(
      path: '/assign-role',
      builder: (context, state) => const AssignRoleScreen(),
    ),
    GoRoute(
      path: '/worker-profile-setup',
      builder: (context, state) => const WorkerProfileSetupScreen(),
    ),
    GoRoute(
      path: '/worker-activation',
      builder: (context, state) => const WorkerActivationScreen(),
    ),
    GoRoute(
      path: '/wallet-overview',
      builder: (context, state) => const WalletOverviewScreen(),
    ),
    GoRoute(
      path: '/payout-request',
      builder: (context, state) => const PayoutRequestScreen(),
    ),
    GoRoute(
      path: '/payout-submitted',
      builder: (context, state) => const PayoutSubmittedScreen(),
    ),
    GoRoute(
      path: '/revenue-breakdown',
      builder: (context, state) => const RevenueBreakdownScreen(),
    ),
    GoRoute(
      path: '/router-health',
      builder: (context, state) => const RouterHealthScreen(),
    ),
    GoRoute(
      path: '/transaction-payment-history',
      builder: (context, state) => const TransactionPaymentHistoryScreen(),
    ),
    GoRoute(
      path: '/transaction-history',
      builder: (context, state) => const TransactionHistoryScreen(),
    ),
    GoRoute(
      path: '/payout-history',
      builder: (context, state) => const PayoutHistoryScreen(),
    ),
    GoRoute(
      path: '/transaction-details',
      builder: (context, state) => const TransactionDetailsScreen(),
    ),
    GoRoute(
      path: '/add-payout-method',
      builder: (context, state) => const AddPayoutMethodScreen(),
    ),
    GoRoute(
      path: '/assign-router',
      builder: (context, state) => const AssignRouterScreen(),
    ),
    GoRoute(
      path: '/security/password-2fa',
      builder: (context, state) => const PasswordAndTwoFactorScreen(),
    ),
    GoRoute(
      path: '/security/authenticators',
      builder: (context, state) => const AuthenticatorsScreen(),
    ),
    GoRoute(
      path: '/security/2fa-success',
      builder: (context, state) => const TwoFactorSuccessScreen(),
    ),
    GoRoute(
      path: '/partner-profile',
      builder: (context, state) => const PartnerProfileScreen(),
    ),
    GoRoute(
      path: '/otp-validation',
      builder: (context, state) => OtpValidationScreen(
        args: state.extra as Map<String, dynamic>?,
      ),
    ),
    GoRoute(
      path: '/reporting',
      builder: (context, state) => const ReportingScreen(),
    ),
    GoRoute(
      path: '/report-preview',
      builder: (context, state) => const ReportPreviewScreen(),
    ),
    GoRoute(
      path: '/export-success',
      builder: (context, state) => const ExportSuccessScreen(),
    ),
    GoRoute(
      path: '/create-edit-user-profile',
      builder: (context, state) {
        final profile = state.extra as HotspotProfileModel?;
        return CreateEditUserProfileScreen(profile: profile);
      },
    ),
    GoRoute(
      path: '/notification-settings',
      builder: (context, state) => const NotificationSettingsScreen(),
    ),
    GoRoute(
      path: '/notification-center',
      builder: (context, state) => const NotificationCenterScreen(),
    ),
    GoRoute(
      path: '/notification-router',
      builder: (context, state) => const NotificationRouterScreen(),
    ),
    GoRoute(
      path: '/user-details',
      builder: (context, state) {
        final user = state.extra as UserModel;
        return UserDetailsScreen(user: user);
      },
    ),
    GoRoute(
      path: '/onboarding-old',
      builder: (context, state) => const OnboardingFlow(),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutAppScreen(),
    ),
    GoRoute(
      path: '/empty-state',
      builder: (context, state) => const EmptyStateScreen(),
    ),
    GoRoute(
      path: '/email-verification',
      builder: (context, state) {
        return const EmailVerificationScreen();
      },
    ),
    GoRoute(
      path: '/hotspot-users-management',
      builder: (context, state) => const HotspotUsersManagementScreen(),
    ),
    GoRoute(
      path: '/plan-assignment',
      builder: (context, state) => const PlanAssignmentScreen(),
    ),
    GoRoute(
      path: '/session-management',
      builder: (context, state) => const SessionManagementScreen(),
    ),
    GoRoute(
      path: '/collaborators-management',
      builder: (context, state) => const CollaboratorsManagementScreen(),
    ),
    GoRoute(
      path: '/payment-methods',
      builder: (context, state) => const PaymentMethodsScreen(),
    ),
    GoRoute(
      path: '/assigned-plans-list',
      builder: (context, state) => const AssignedPlansListScreen(),
    ),
    GoRoute(
      path: '/active-sessions',
      builder: (context, state) => const ActiveSessionsScreen(),
    ),
    GoRoute(
      path: '/support',
      builder: (context, state) => const HelpSupportScreen(),
    ),
    GoRoute(
      path: '/router-details',
      builder: (context, state) {
        final router = state.extra;
        return RouterDetailsScreen(router: router as dynamic);
      },
    ),
    GoRoute(
      path: '/profile-editor',
      builder: (context, state) {
        final profile = state.extra as HotspotProfileModel?;
        return CreateEditUserProfileScreen(profile: profile);
      },
    ),
    GoRoute(
      path: '/create-edit-plan',
      builder: (context, state) {
        final planData = state.extra as Map<String, dynamic>?;
        return CreateEditPlanScreen(planData: planData);
      },
    ),
    GoRoute(
      path: '/assign-user',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>;
        return AssignUserScreen(
          planId: args['planId'] as String,
          planName: args['planName'] as String,
        );
      },
    ),
    GoRoute(
      path: '/create-role',
      builder: (context, state) {
        final roleData = state.extra as Map<String, dynamic>?;
        return CreateRoleScreen(roleData: roleData);
      },
    ),
    GoRoute(
      path: '/router-assign',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>;
        return RouterAssignScreen(
          userId: args['userId'] as String,
          userName: args['userName'] as String,
        );
      },
    ),
    GoRoute(
      path: '/verify-password-reset-otp',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>;
        return VerifyPasswordResetOtpScreen(
          email: args['email'] as String,
          otpId: args['otp_id']?.toString() ?? '',
        );
      },
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>;
        return ResetPasswordScreen(
          email: args['email'] as String,
          token: args['token'] as String,
        );
      },
    ),
    GoRoute(
      path: '/vouchers',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>;
        return VoucherListScreen(
          planId: args['planId'] as String,
          planName: args['planName'] as String,
        );
      },
    ),
  ],
);
