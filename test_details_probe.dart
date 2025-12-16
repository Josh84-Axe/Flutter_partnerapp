import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.tiknetafrica.com/v1',
    headers: {
      'Content-Type': 'application/json',
    },
    validateStatus: (status) => true,
  ));

  String? accessToken;
  // We saw customer: 2770 in the previous output. Let's try to use that ID as the username, 
  // or finding the username from the customer list if possible. 
  // Usually username is needed, but sometimes ID works. 
  // Let's try to find the real username for ID 2770 if possible.
  
  try {
    // 1. Login
    print('🔐 Logging in...');
    final loginResponse = await dio.post('/partner/login/', data: {
      'email': 'sientey@hotmail.com',
      'password': 'MyStr0ng!Pass2025',
    });
    accessToken = loginResponse.data['data']['access'];
    dio.options.headers['Authorization'] = 'Bearer $accessToken';
    print('✅ Login Successful');

    // 2. Find a valid username.
    // We'll fetch assigned plans again to get a User ID.
    print('\n📋 Fetching Assigned Plans to pick a user...');
    final plansResponse = await dio.get('/partner/assigned-plans/');
    final plansData = plansResponse.data['data']['results'] as List;
    final firstPlan = plansData.first;
    final customerId = firstPlan['customer'];
    final customerName = firstPlan['customer_name']; // This might be the name, not username.
    
    print('Found Plan for Customer ID: $customerId (Name: $customerName)');
    
    // Attempt to lookup username via customer list filtering? 
    // Or just try using ID as username.
    // Or fetch /partner/customers/{id}/?
    
    // Let's try getting customer list and matching ID
    // List lookup failed (returned String). Let's just try candidates directly.
    print('HEADERS: ${dio.options.headers}');
    
    // Sanity Check
    print('\n🔍 Probing /partner/roles/list/ (Sanity Check)...');
    try {
        final roles = await dio.get('/partner/roles/list/');
        print('✅ Roles Status: ${roles.statusCode} (Access OK)');
    } catch (e) {
        print('❌ Roles Status Failed: $e');
    }

    // Dump Purchased Plans
    print('\n🔍 Probing /partner/purchased-plans/ (Looking for Username Patterns)...');
    try {
        final purchased = await dio.get('/partner/purchased-plans/');
        if (purchased.data['data'] != null && 
            (purchased.data['data'] is List || purchased.data['data']['results'] is List)) {
            
            final list = (purchased.data['data'] is List) ? purchased.data['data'] : purchased.data['data']['results'];
            if (list.isNotEmpty) {
                print('📋 Full Purchased Plan Record:');
                print(list.first);
                // Look for fields
            } else {
                print('⚠️ Purchased plans list empty.');
            }
        }
    } catch (e) {
        print('❌ Purchased Plans Failed: $e');
    }
    
    // Retry Customer List - Focused Probe
    print('\n🔍 Retrying /partner/customers/list/ ...');
    try {
        final customersResponse = await dio.get('/partner/customers/list/');
        print('Status: ${customersResponse.statusCode}');
        
        if (customersResponse.statusCode == 200) {
             final data = customersResponse.data;
             List results = [];
             if (data is Map && data.containsKey('data')) {
                 if (data['data'] is Map && data['data']['results'] is List) {
                     results = data['data']['results'];
                 } else if (data['data'] is List) {
                     results = data['data'];
                 }
             }
             
             print('Found ${results.length} customers.');
             
             if (results.isNotEmpty) {
                 final firstUser = results.first;
                 print('👤 Sample User: $firstUser');
                 final username = firstUser['username'];
                 print('🎯 Targeted Username: $username');
                 
                 if (username != null) {
                     // Probe details for this valid username
                     print('\n📊 Probing Data Usage for $username...');
                     try {
                        final resp = await dio.get('/partner/customers/$username/data-usage/');
                        print('Response: ${resp.data}');
                     } catch(e) { print('Error: $e'); }

                     print('\n💳 Probing Assigned Transactions for $username...');
                     try {
                        final resp = await dio.get('/partner/customers/$username/transactions/assigned/');
                        print('Response: ${resp.data}');
                     } catch(e) { print('Error: $e'); }

                     print('\n💰 Probing Wallet Transactions for $username...');
                     try {
                        final resp = await dio.get('/partner/customers/$username/transactions/wallet/');
                        print('Response: ${resp.data}');
                     } catch(e) { print('Error: $e'); }
                 }
             }
        }
    } catch (e) {
         print('❌ Error: $e');
    }



  } catch (e) {
    print('❌ Error: $e');
  }
}
