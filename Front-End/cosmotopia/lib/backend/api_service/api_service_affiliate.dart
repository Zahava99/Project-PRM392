import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServiceAffiliate {
  static const String baseUrl = 'http://10.0.2.2:5192';

  /// Register user as affiliate
  static Future<http.Response> registerAffiliate({
    required String token,
    String? bankAccount,
    String? bankName,
    String? idCard,
    String? taxCode,
  }) {
    final body = {
      'bankAccount': bankAccount ?? '',
      'bankName': bankName ?? '',
      'idCard': idCard ?? '',
      'taxCode': taxCode ?? '',
    };

    print('📝 Registering affiliate with body: ${jsonEncode(body)}');
    
    return http.post(
      Uri.parse('$baseUrl/api/Affiliate/register'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }

  /// Check if user is registered as affiliate
  static Future<http.Response> checkAffiliateStatus({
    required String token,
  }) {
    return http.get(
      Uri.parse('$baseUrl/api/Affiliate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  /// Generate affiliate link for a product
  static Future<http.Response> generateAffiliateLink({
    required String productId,
    required String token,
    Map<String, String>? customParams,
  }) {
    final body = {
      'ProductId': productId,  // Changed to match backend DTO (capital P)
    };

    return http.post(
      Uri.parse('$baseUrl/api/Affiliate/generate-link'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }

  /// Get affiliate dashboard statistics
  static Future<http.Response> getAffiliateDashboard({required String token}) {
    return http.get(
      Uri.parse('$baseUrl/api/Affiliate/dashboard'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  /// Get affiliate earnings analytics
  static Future<http.Response> getAffiliateEarnings({
    required String token,
    String? period, // 'day', 'week', 'month', 'year'
    DateTime? startDate,
    DateTime? endDate,
  }) {
    // Use the actual endpoint from backend API
    String url = '$baseUrl/api/Affiliate/earnings/summary';
    List<String> queryParams = [];
    
    if (period != null) queryParams.add('period=$period');
    if (startDate != null) queryParams.add('startDate=${startDate.toIso8601String()}');
    if (endDate != null) queryParams.add('endDate=${endDate.toIso8601String()}');
    
    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }

    print('📊 Calling earnings API: $url');
    return http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  /// Request affiliate withdrawal
  static Future<http.Response> requestAffiliateWithdrawal({
    required String token,
    required double amount,
    required String bankAccount,
    required String bankName,
    String? notes,
  }) {
    final body = {
      'amount': amount,
      'bankAccount': bankAccount,
      'bankName': bankName,
      'notes': notes,
    };

    return http.post(
      Uri.parse('$baseUrl/api/Affiliate/request-withdrawal'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }

  /// Get affiliate withdrawal history
  static Future<http.Response> getAffiliateWithdrawals({
    required String token,
    int page = 1,
    int pageSize = 20,
    String? status, // 'pending', 'approved', 'rejected', 'completed'
  }) {
    String url = '$baseUrl/api/Affiliate/withdrawals?page=$page&pageSize=$pageSize';
    if (status != null) url += '&status=$status';

    return http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  /// Get affiliate commission breakdown
  static Future<http.Response> getAffiliateCommissions({
    required String token,
    int page = 1,
    int pageSize = 20,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    String url = '$baseUrl/api/Affiliate/commissions?page=$page&pageSize=$pageSize';
    List<String> queryParams = [];
    
    if (startDate != null) queryParams.add('startDate=${startDate.toIso8601String()}');
    if (endDate != null) queryParams.add('endDate=${endDate.toIso8601String()}');
    
    if (queryParams.isNotEmpty) {
      url += '&${queryParams.join('&')}';
    }

    return http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  /// Update affiliate link status
  static Future<http.Response> updateAffiliateLinkStatus({
    required String token,
    required String linkId,
    required String status, // 'active', 'inactive'
  }) {
    final body = {
      'linkId': linkId,
      'status': status,
    };

    return http.put(
      Uri.parse('$baseUrl/api/Affiliate/update-link-status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }

  /// Get affiliate performance metrics  
  static Future<http.Response> getAffiliatePerformance({
    required String token,
    String period = 'month', // 'day', 'week', 'month', 'year'
  }) {
    // Calculate date range based on period
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = now.add(Duration(days: 1)); // EndDate is always 1 day after current date
    
    switch (period) {
      case 'day':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'week':
        startDate = now.subtract(Duration(days: 7));
        break;
      case 'year':
        startDate = DateTime(now.year, 1, 1);
        break;
      case 'month':
      default:
        startDate = DateTime(now.year, now.month, 1);
        break;
    }
    
    // Use the actual stats endpoint from backend API
    final startDateStr = startDate.toIso8601String().split('T')[0];
    final endDateStr = endDate.toIso8601String().split('T')[0];
    final url = '$baseUrl/api/Affiliate/stats?startDate=$startDateStr&endDate=$endDateStr';
    
    print('📈 Calling stats API: $url');
    return http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  /// Get affiliate profile information
  static Future<http.Response> getAffiliateProfile({
    required String token,
  }) {
    return http.get(
      Uri.parse('$baseUrl/api/Affiliate/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  /// Get affiliate statistics
  static Future<http.Response> getAffiliateStats({
    required String token,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final startDateStr = startDate.toIso8601String().split('T')[0];
    final endDateStr = endDate.toIso8601String().split('T')[0];
    
    return http.get(
      Uri.parse('$baseUrl/api/Affiliate/stats?startDate=$startDateStr&endDate=$endDateStr'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  /// Track affiliate click
  static Future<http.Response> trackAffiliateClick({
    required String referralCode,
    required String token, // Thêm token parameter
    Map<String, dynamic>? metadata,
  }) {
    return http.get(
      Uri.parse('$baseUrl/api/Affiliate/track-click?referralCode=$referralCode'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Thêm Authorization header
      },
    );
  }

  /// Get affiliate links created by user
  static Future<http.Response> getMyAffiliateLinks({
    required String token,
    int page = 1,
    int pageSize = 20,
  }) {
    return http.get(
      Uri.parse('$baseUrl/api/Affiliate/links?page=$page&pageSize=$pageSize'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }
} 