import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServicePayment {
  static const String baseUrl = 'http://10.0.2.2:5192';

  static Future<http.Response> getAllPayments({
    int page = 1,
    int pageSize = 10,
    String? status,
    required String token,
  }) async {
    String url = '$baseUrl/api/Payment/payments?page=$page&pageSize=$pageSize';
    if (status != null && status.isNotEmpty) {
      url += '&status=$status';
    }

    return http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<http.Response> getPaymentByTransactionId({
    required String transactionId,
    required String token,
  }) async {
    return http.get(
      Uri.parse('$baseUrl/api/Payment/payment/$transactionId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<http.Response> updatePaymentStatus({
    required String transactionId,
    required int newStatus,
    required String token,
  }) async {
    return http.put(
      Uri.parse('$baseUrl/api/Payment/update-payment-status/$transactionId?newStatus=$newStatus'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<http.Response> createPaymentLink({
    required String orderId,
    required String token,
  }) async {
    return http.post(
      Uri.parse('$baseUrl/api/Payment/create-payment-link'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'orderId': orderId,
      }),
    );
  }

  static Future<http.Response> deletePayment({
    required String paymentId,
    required String token,
  }) async {
    return http.delete(
      Uri.parse('$baseUrl/api/Payment/$paymentId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }
} 