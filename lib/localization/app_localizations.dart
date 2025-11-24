import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  late Map<String, String> _localizedStrings;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  Future<bool> load() async {
    String jsonString = await rootBundle.loadString('lib/localization/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
    return true;
  }

  String translate(String key) => _localizedStrings[key] ?? key;

  String get appTitle => translate('app_title');
  String get manageYourWifiZone => translate('manage_your_wifi_zone');
  String get login => translate('login');
  String get register => translate('register');
  String get email => translate('email');
  String get password => translate('password');
  String get name => translate('name');
  String get phone => translate('phone');
  String get address => translate('address');
  String get city => translate('city');
  String get country => translate('country');
  String get numberOfRouters => translate('number_of_routers');
  String get forgotPassword => translate('forgot_password');
  String get dontHaveAccount => translate('dont_have_account');
  String get alreadyHaveAccount => translate('already_have_account');
  String get signIn => translate('sign_in');
  String get signUp => translate('sign_up');
  String get dashboard => translate('dashboard');
  String get users => translate('users');
  String get plans => translate('plans');
  String get transactions => translate('transactions');
  String get routers => translate('routers');
  String get settings => translate('settings');
  String get totalRevenue => translate('total_revenue');
  String get activeUsers => translate('active_users');
  String get dataUsage => translate('data_usage');
  String get recentActivity => translate('recent_activity');
  String get viewAll => translate('view_all');
  String get addUser => translate('add_user');
  String get editUser => translate('edit_user');
  String get deleteUser => translate('delete_user');
  String get assignPlan => translate('assign_plan');
  String get assignRouter => translate('assign_router');
  String get blockUser => translate('block_user');
  String get unblockUser => translate('unblock_user');
  String get createPlan => translate('create_plan');
  String get planName => translate('plan_name');
  String get price => translate('price');
  String get dataLimit => translate('data_limit');
  String get validity => translate('validity');
  String get speed => translate('speed');
  String get deviceAllowed => translate('device_allowed');
  String get userProfile => translate('user_profile');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get confirm => translate('confirm');
  String get yes => translate('yes');
  String get no => translate('no');
  String get search => translate('search');
  String get filter => translate('filter');
  String get sort => translate('sort');
  String get logout => translate('logout');
  String get profile => translate('profile');
  String get notifications => translate('notifications');
  String get language => translate('language');
  String get theme => translate('theme');
  String get lightMode => translate('light_mode');
  String get darkMode => translate('dark_mode');
  String get english => translate('english');
  String get french => translate('french');
  String get walletBalance => translate('wallet_balance');
  String get requestPayout => translate('request_payout');
  String get paymentHistory => translate('payment_history');
  String get routerStatus => translate('router_status');
  String get online => translate('online');
  String get offline => translate('offline');
  String get connectedUsers => translate('connected_users');
  String get uptime => translate('uptime');
  String get lastSeen => translate('last_seen');
  String get hotspotManagement => translate('hotspot_management');
  String get subscriptionManagement => translate('subscription_management');
  String get notificationsPreferences => translate('notifications_preferences');
  String get securitySettings => translate('security_settings');
  String get userRolesPermissions => translate('user_roles_permissions');
  String get dataPrivacy => translate('data_privacy');
  String get dataExportReporting => translate('data_export_reporting');
  String get support => translate('support');
  String get about => translate('about');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
