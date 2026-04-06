import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// Services & Storage
import 'services/api/token_storage.dart';
import 'services/api/api_client_factory.dart';
import 'services/api/api_config.dart';
import 'services/support_ticket_service.dart';
import 'services/pwa_service.dart';
import 'services/update_service.dart';

// Repositories
import 'repositories/auth_repository.dart';
import 'repositories/wallet_repository.dart';
import 'repositories/transaction_repository.dart';
import 'repositories/payment_method_repository.dart';
import 'repositories/customer_repository.dart';
import 'repositories/collaborator_repository.dart';
import 'repositories/role_repository.dart';
import 'repositories/partner_repository.dart';
import 'repositories/plan_repository.dart';
import 'repositories/router_repository.dart';
import 'repositories/hotspot_repository.dart';
import 'repositories/session_repository.dart';
import 'repositories/plan_config_repository.dart';
import 'repositories/subscription_repository.dart';
import 'repositories/ticket_repository.dart';
import 'repositories/voucher_repository.dart';

final locator = GetIt.instance;

// Global Navigator Key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> setupLocator() async {
  // --- Core Services ---
  
  final tokenStorage = TokenStorage();
  locator.registerSingleton<TokenStorage>(tokenStorage);

  final apiClientFactory = ApiClientFactory(
    tokenStorage: tokenStorage,
    baseUrl: ApiConfig.baseUrl,
    onLogout: () {
      if (kDebugMode) print('🚪 [Locator] Global logout triggered');
      tokenStorage.clearTokens().then((_) {
        navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
      });
    },
  );
  locator.registerSingleton<ApiClientFactory>(apiClientFactory);

  final dio = apiClientFactory.createDio();
  locator.registerSingleton<Dio>(dio);

  // --- External Services ---
  locator.registerLazySingleton<SupportTicketService>(() => SupportTicketService(dio: dio));
  locator.registerLazySingleton<UpdateService>(() => UpdateService());
  locator.registerLazySingleton<PwaService>(() => PwaService());

  // --- Repositories ---
  locator.registerLazySingleton<AuthRepository>(() => AuthRepository(dio: dio, tokenStorage: tokenStorage));
  locator.registerLazySingleton<PartnerRepository>(() => PartnerRepository(dio: dio));
  locator.registerLazySingleton<WalletRepository>(() => WalletRepository(dio: dio));
  locator.registerLazySingleton<TransactionRepository>(() => TransactionRepository(dio: dio));
  locator.registerLazySingleton<PaymentMethodRepository>(() => PaymentMethodRepository(dio: dio));
  locator.registerLazySingleton<CustomerRepository>(() => CustomerRepository(dio: dio));
  locator.registerLazySingleton<CollaboratorRepository>(() => CollaboratorRepository(dio: dio));
  locator.registerLazySingleton<RoleRepository>(() => RoleRepository(dio: dio));
  locator.registerLazySingleton<SubscriptionRepository>(() => SubscriptionRepository(dio: dio));
  locator.registerLazySingleton<PlanRepository>(() => PlanRepository(dio: dio));
  locator.registerLazySingleton<RouterRepository>(() => RouterRepository(dio: dio));
  locator.registerLazySingleton<HotspotRepository>(() => HotspotRepository(dio: dio));
  locator.registerLazySingleton<SessionRepository>(() => SessionRepository(dio: dio));
  locator.registerLazySingleton<PlanConfigRepository>(() => PlanConfigRepository(dio: dio));
  locator.registerLazySingleton<TicketRepository>(() => TicketRepository(ticketService: locator<SupportTicketService>()));
  locator.registerLazySingleton<VoucherRepository>(() => VoucherRepository(dio: dio));
}
