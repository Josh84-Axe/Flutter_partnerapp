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
  String? targetUsername;

  // Helper to print section headers
  void printHeader(String title) {
    print('\n' + '=' * 50);
    print(title);
    print('=' * 50);
  }

  // Helper to print response data summary
  void printResponse(Response response) {
    print('Status: ${response.statusCode}');
    if (response.data is Map) {
      final data = response.data as Map;
      if (data.containsKey('data')) {
        final innerData = data['data'];
        if (innerData is List) {
          print('Data Type: List (Length: ${innerData.length})');
          if (innerData.isNotEmpty) print('Sample Item: ${innerData.first}');
        } else if (innerData is Map) {
             if (innerData.containsKey('results')) {
                final results = innerData['results'];
                 print('Data Type: Paginated List (Length: ${results.length})');
                 if (results.isNotEmpty) print('Sample Item: ${results.first}');
             } else {
                print('Data Type: Map');
                print('Content: $innerData');
             }
        } else {
          print('Data: $innerData');
        }
      } else {
        print('Root Data: $data');
      }
    } else if (response.data is List) {
      print('Data Type: List (Length: ${response.data.length})');
      if (response.data.isNotEmpty) print('Sample Item: ${response.data.first}');
    } else {
      print('Raw Data: ${response.data}');
    }
  }

  try {
    // 1. Login
    printHeader('1. Logging In');
    final loginResponse = await dio.post('/partner/login/', data: {
      'email': 'sientey@hotmail.com',
      'password': 'MyStr0ng!Pass2025',
    });
    
    if (loginResponse.statusCode == 200) {
      accessToken = loginResponse.data['data']['access'];
      dio.options.headers['Authorization'] = 'Bearer $accessToken';
      print('✅ Login Successful');
    } else {
      print('❌ Login Failed');
      return;
    }

    // 2. Fetch Customers to get a username
    printHeader('2. Fetching Customers (to find target)');
    final customersResponse = await dio.get('/partner/customers/');
    if (customersResponse.statusCode == 200) {
      final data = customersResponse.data['data'];
      List results = [];
      if (data is Map && data.containsKey('results')) {
        results = data['results'];
      } else if (data is List) {
        results = data;
      }
      
      if (results.isNotEmpty) {
        // Pick a user who likely has data/plans -> usually index 0 is newest, let's try a few
        final user = results.first; 
        targetUsername = user['username'] ?? user['id']?.toString(); // Fallback
        print('✅ Found Target User: $targetUsername (${user['first_name']} ${user['last_name']})');
        print('User Record: $user');
      } else {
        print('⚠️ No customers found. Proceeding with limited scope.');
      }
    }

    // 3. Probe /partner/assigned-plans/
    printHeader('3. Probing /partner/assigned-plans/');
    final assignedPlansResponse = await dio.get('/partner/assigned-plans/');
    printResponse(assignedPlansResponse);

    // 4. Probe /partner/purchased-plans/
    printHeader('4. Probing /partner/purchased-plans/');
    final purchasedPlansResponse = await dio.get('/partner/purchased-plans/');
    printResponse(purchasedPlansResponse);

    if (targetUsername != null) {
      // 5. Probe /partner/customers/{username}/data-usage/
      printHeader('5. Probing Data Usage for $targetUsername');
      final dataUsageResponse = await dio.get('/partner/customers/$targetUsername/data-usage/');
      printResponse(dataUsageResponse);

      // 6. Probe /partner/customers/{username}/transactions/assigned/
      printHeader('6. Probing Assigned Transactions for $targetUsername');
      final txAssignedResponse = await dio.get('/partner/customers/$targetUsername/transactions/assigned/');
      printResponse(txAssignedResponse);

      // 7. Probe /partner/customers/{username}/transactions/wallet/
      printHeader('7. Probing Wallet Transactions for $targetUsername');
      final txWalletResponse = await dio.get('/partner/customers/$targetUsername/transactions/wallet/');
      printResponse(txWalletResponse);
    }

  } catch (e) {
    print('❌ Error: $e');
  }
}
