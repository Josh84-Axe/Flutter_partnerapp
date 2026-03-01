
import 'package:dio/dio.dart';

const String baseUrl = 'https://api.tiknetafrica.com/v1';
// Using the token from previously saved credentials or asking user? 
// I'll use the one from the login flow if possible, or just hardcode for this script if I know it.
// Actually, I can use the same credentials to login first.

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    validateStatus: (status) => status! < 500,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  try {
    // 1. Login
    print('🔐 Logging in...');
    final loginRes = await dio.post('/auth/login/', data: {
      'email': 'sientey@hotmail.com',
      'password': 'MyStr0ng!Pass2026',
    });

    if (loginRes.statusCode != 200) {
      print('❌ Login failed: ${loginRes.statusCode} - ${loginRes.data}');
      return;
    }

    final token = loginRes.data['access'];
    dio.options.headers['Authorization'] = 'Bearer $token';
    print('✅ Login successful. Token obtained.');

    // 2. Fetch Vouchers (All plans)
    print('🎫 Fetching vouchers...');
    final vouchersRes = await dio.get('/partner/plans/tickets/');
    
    if (vouchersRes.statusCode == 200) {
      final List data = vouchersRes.data['data'];
      print('✅ Fetched ${data.length} vouchers.');
      
      // 3. Find USED vouchers
      final usedVouchers = data.where((v) => v['is_used'] == true).toList();
      print('🔍 Found ${usedVouchers.length} USED vouchers.');

      if (usedVouchers.isNotEmpty) {
        print('⬇️ Dumping first 3 USED vouchers JSON:');
        for (var i = 0; i < (usedVouchers.length > 3 ? 3 : usedVouchers.length); i++) {
          print('--- Voucher ${i + 1} ---');
          print(usedVouchers[i]);
        }
      } else {
        print('⚠️ No used vouchers found. Dumping first 3 ACTIVE vouchers to check structure:');
        for (var i = 0; i < (data.length > 3 ? 3 : data.length); i++) {
          print('--- Voucher ${i + 1} ---');
          print(data[i]);
        }
      }
    } else {
      print('❌ Fetch failed: ${vouchersRes.statusCode} - ${vouchersRes.data}');
    }

  } catch (e) {
    print('❌ Error: $e');
  }
}
