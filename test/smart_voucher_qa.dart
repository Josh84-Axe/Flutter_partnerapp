import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const String baseUrl = 'https://api.tiknetafrica.com/v1';
  const String email = 'sientey@hotmail.com';
  const String password = 'MyStr0ng!Pass2026';
  
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    validateStatus: (status) => true,
  ));

  test('Smart Voucher API QA', () async {
    print('--- Smart Voucher API QA ---');
    
    // 1. Login
    print('1. Logging in as $email...');
    final loginResponse = await dio.post('/partner/login/', data: {
      'email': email,
      'password': password,
    });
    
    print('Login Status: ${loginResponse.statusCode}');
    if (loginResponse.statusCode != 200) {
      print('❌ Login failed: ${loginResponse.data}');
      return;
    }
    
    final data = loginResponse.data['data'];
    final String accessToken = data['access'];
    print('✅ Login successful. Token: ${accessToken.substring(0, 10)}...');
    
    dio.options.headers['Authorization'] = 'Bearer $accessToken';

    // 2. Fetch Plans (to get a valid plan_id)
    print('\n2. Fetching plans...');
    final plansResponse = await dio.get('/partner/plans/');
    print('Plans Status: ${plansResponse.statusCode}');
    
    if (plansResponse.statusCode != 200) {
       print('❌ Failed to fetch plans');
       return;
    }
    
    final List plans = plansResponse.data['data'] ?? [];
    if (plans.isEmpty) {
      print('⚠️ No plans found. Cannot test voucher generation.');
      return;
    }
    
    final planId = plans.first['id'].toString();
    print('✅ Found ${plans.length} plans. Using Plan ID: $planId (${plans.first['name']})');

    // 3. Test New Ticket List Endpoint
    print('\n3. Testing GET /partner/plans/tickets/ ...');
    final ticketsResponseBefore = await dio.get('/partner/plans/tickets/');
    print('Tickets Before Status: ${ticketsResponseBefore.statusCode}');
    final List ticketsBefore = ticketsResponseBefore.data['data'] ?? [];
    print('Tickets Before Count: ${ticketsBefore.length}');

    // 4. Test New Ticket Generate Endpoint
    print('\n4. Testing POST /partner/plans/tickets/generate/ ...');
    final generateResponse = await dio.post('/partner/plans/tickets/generate/', data: {
      'plan': planId,
      'count': 5,
    });
    print('Generate Status: ${generateResponse.statusCode}');
    print('Generate Response: ${generateResponse.data}');
    
    if (generateResponse.statusCode == 201 || generateResponse.statusCode == 200) {
      print('✅ Tickets generated successfully');
      
      // 5. Check List After Generation
      print('\n5. Checking list after generation...');
      final ticketsResponseAfter = await dio.get('/partner/plans/tickets/');
      final List ticketsAfter = ticketsResponseAfter.data['data'] ?? [];
      print('Tickets After Count: ${ticketsAfter.length}');
      
      print('\n5b. Testing filtered list: GET /partner/plans/tickets/?plan=$planId ...');
      final filteredResponse = await dio.get('/partner/plans/tickets/', queryParameters: {'plan': planId});
      final List filteredTickets = filteredResponse.data['data'] ?? [];
      print('Filtered Tickets Count: ${filteredTickets.length}');
    }

    // 6. Test Download/Export Endpoint with POST and parameters
    print('\n6. Testing POST /partner/plans/tickets/export/ ...');
    final postExportResponse = await dio.post('/partner/plans/tickets/export/', data: {
      'plan': planId,
      'format': 'pdf',
    });
    print('POST Export Status: ${postExportResponse.statusCode}');
    print('POST Export Response: ${postExportResponse.data}');
  });
}
