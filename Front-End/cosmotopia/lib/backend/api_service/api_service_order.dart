import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServiceOrder {
  static const String baseUrl = 'http://10.0.2.2:5192';

  static Future<http.Response> postOrder(Map<String, dynamic> orderBody, {required String token}) {
    return http.post(
      Uri.parse('$baseUrl/api/Order'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(orderBody),
    );
  }

  static Future<http.Response> getUserOrders({
    required String token,
    int page = 1,
    int pageSize = 100,
  }) {
    return http.get(
      Uri.parse('$baseUrl/api/Order/user/orders?page=$page&pageSize=$pageSize'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<http.Response> getAllOrders({
    required String token,
    int page = 1,
    int pageSize = 20,
    String? status,
  }) {
    String url = '$baseUrl/api/Order?page=$page&pageSize=$pageSize';
    if (status != null) url += '&status=$status';

    return http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<http.Response> updateOrderStatus({
    required String orderId,
    required int status,
    required String token,
  }) async {
    // Use the exact format that worked in the curl command
    final body = {
      'orderId': orderId,
      'status': status,
    };

    final url = '$baseUrl/api/Order/$orderId';
    print('🔗 PUT Request URL: $url');
    print('📦 Request Body: ${jsonEncode(body)}');
    print('🔑 Authorization: Bearer ${token.substring(0, 20)}...');

    // Use the exact same headers as the successful curl command
    final headers = {
      'accept': '*/*',
      'Content-Type': 'application/json-patch+json',
      'Authorization': 'Bearer $token',
    };
    
    print('📋 Request Headers: $headers');
    
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Headers: ${response.headers}');
      print('📥 Response Body: ${response.body}');
      
      return response;
    } catch (e) {
      print('❌ HTTP Request failed: $e');
      rethrow;
    }
  }

  /// Delete order (Admin only) - DEPRECATED: Use cancelOrder instead
  /// Orders should not be deleted for business/audit reasons
  @deprecated
  static Future<http.Response> deleteOrder(String orderId, {required String token}) {
    return http.delete(
      Uri.parse('$baseUrl/api/Order/$orderId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  /// Get order analytics (Admin only)
  static Future<Map<String, dynamic>> getOrderAnalytics({required String token}) async {
    try {
      final response = await getAllOrders(token: token, page: 1, pageSize: 100);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> orders = data['orders'] ?? [];
        
        // Calculate analytics
        int totalOrders = orders.length;
        int pendingOrders = orders.where((o) => o['status'] == 0).length;
        int confirmedOrders = orders.where((o) => o['status'] == 1).length;
        int shippedOrders = orders.where((o) => o['status'] == 2).length;
        int deliveredOrders = orders.where((o) => o['status'] == 3).length;
        int cancelledOrders = orders.where((o) => o['status'] == 4).length;
        
        double totalRevenue = orders.fold(0.0, (sum, order) => sum + (order['totalAmount'] ?? 0.0));
        
        return {
          'totalOrders': totalOrders,
          'pendingOrders': pendingOrders,
          'confirmedOrders': confirmedOrders,
          'shippedOrders': shippedOrders,
          'deliveredOrders': deliveredOrders,
          'cancelledOrders': cancelledOrders,
          'totalRevenue': totalRevenue,
        };
      } else {
        throw Exception('Failed to load orders for analytics');
      }
    } catch (e) {
      print('❌ Error getting order analytics: $e');
      return {};
    }
  }
} 