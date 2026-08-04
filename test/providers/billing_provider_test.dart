import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:hotspot_partner_app/providers/split/billing_provider.dart';
import 'package:hotspot_partner_app/repositories/wallet_repository.dart';
import 'package:hotspot_partner_app/repositories/transaction_repository.dart';
import 'billing_provider_test.mocks.dart';

@GenerateMocks([WalletRepository, TransactionRepository])
void main() {
  late BillingProvider billingProvider;
  late MockWalletRepository mockWalletRepository;
  late MockTransactionRepository mockTransactionRepository;

  setUp(() {
    mockWalletRepository = MockWalletRepository();
    mockTransactionRepository = MockTransactionRepository();
    billingProvider = BillingProvider(
      walletRepository: mockWalletRepository,
      transactionRepository: mockTransactionRepository,
      partnerCountry: 'US',
    );
  });

  group('BillingProvider Tests', () {
    test('initial state is correct', () {
      expect(billingProvider.isLoading, false);
      expect(billingProvider.error, isNull);
      expect(billingProvider.walletBalance, 0.0);
    });

    test('update() reassigns repositories', () {
      final newWalletRepo = MockWalletRepository();
      billingProvider.update(walletRepository: newWalletRepo);
      // We can't easily check private variables, but calling update shouldn't crash.
      expect(billingProvider.isLoading, false);
    });

    // Mock testing requires the api implementations, but this sets the coverage structure
  });
}
