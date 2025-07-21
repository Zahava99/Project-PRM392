import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServiceUser {
  static const String baseUrl = 'http://10.0.2.2:5192';

  /// Get all users (Admin only)
  static Future<http.Response> getAllUsers({required String token, int page = 1, int pageSize = 100}) {
    return http.get(
      Uri.parse('$baseUrl/api/User/GetAllUsers?page=$page&pageSize=$pageSize'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  /// Get user by ID (Admin only)
  static Future<http.Response> getUserById(String userId, {required String token}) {
    return http.get(
      Uri.parse('$baseUrl/api/User/GetUserById/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  /// Edit user status and role (Admin only)
  static Future<http.Response> editUserStatusAndRole({
    required String userId,
    required String token,
    int? userStatus,
    int? roleType,
  }) {
    final body = <String, dynamic>{};
    if (userStatus != null) {
      body['userStatus'] = userStatus;
    }
    if (roleType != null) {
      body['roleType'] = roleType;
    }

    print('📤 Edit user status/role request body: ${jsonEncode(body)}');

    return http.put(
      Uri.parse('$baseUrl/api/User/EditUserStatusAndRole/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }
} 