import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServiceAuth {
  static const String baseUrl = 'http://10.0.2.2:5192';

  static Future<http.Response> login(String email, String password) {
    return http.post(
      Uri.parse('$baseUrl/api/User/Login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
  }

  static Future<http.Response> registerWithOtp(String email, String password, String phone, {String? firstName, String? lastName}) async {
    // Generate OTP expiration (typically 5-10 minutes from now)
    final otpExpiration = DateTime.now().add(Duration(minutes: 10)).toIso8601String();
    
    // Remove country code from phone number (backend expects phone without country code)
    String cleanPhone = phone;
    if (phone.startsWith('+84')) {
      cleanPhone = phone.substring(3); // Remove +84
    } else if (phone.startsWith('84')) {
      cleanPhone = phone.substring(2); // Remove 84
    }
    // Also remove any other country codes that might be present
    cleanPhone = cleanPhone.replaceAll(RegExp(r'[^0-9]'), ''); // Keep only digits
    
    // Ensure phone number is exactly 10 digits (Vietnamese format)
    if (cleanPhone.length == 11 && cleanPhone.startsWith('1')) {
      // If it's 11 digits starting with 1, remove the first digit
      cleanPhone = cleanPhone.substring(1);
    } else if (cleanPhone.length == 9) {
      // If it's 9 digits, add 0 at the beginning
      cleanPhone = '0' + cleanPhone;
    }
    
    // Validate phone number length
    if (cleanPhone.length != 10) {
      throw Exception('Phone number must be exactly 10 digits. Current: ${cleanPhone.length} digits ($cleanPhone)');
    }
    
    final body = {
      'email': email,
      'firstName': firstName ?? '',
      'lastName': lastName ?? '',
      'password': password,
      'confirmPassword': password, // Same as password for registration
      'phone': cleanPhone,
      'otpExpiration': otpExpiration,
    };
    
    print('📤 Registration request body: ${jsonEncode(body)}');
    print('📞 Original phone: $phone -> Clean phone: $cleanPhone');
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/User/registerwithotp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      
      print('📥 Registration response status: ${response.statusCode}');
      print('📥 Registration response body: ${response.body}');
      
      return response;
    } catch (e) {
      print('❌ Registration API error: $e');
      rethrow;
    }
  }

  static Future<http.Response> verifyOtp(String email, String otp) {
    final body = {
      'email': email,
      'otp': otp,
    };
    
    print('📤 OTP verification request body: ${jsonEncode(body)}');
    
    return http.post(
      Uri.parse('$baseUrl/api/User/verifyotp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> editProfile({
    required String token,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    // Clean phone number (remove country code if present)
    String cleanPhone = phone;
    if (phone.startsWith('+84')) {
      cleanPhone = phone.substring(3);
    } else if (phone.startsWith('84')) {
      cleanPhone = phone.substring(2);
    }
    cleanPhone = cleanPhone.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Ensure phone number is exactly 10 digits
    if (cleanPhone.length == 11 && cleanPhone.startsWith('1')) {
      cleanPhone = cleanPhone.substring(1);
    } else if (cleanPhone.length == 9) {
      cleanPhone = '0' + cleanPhone;
    }
    
    final body = {
      'firstName': firstName,
      'lastName': lastName,
      'phone': cleanPhone,
    };
    
    print('📤 Edit profile request body: ${jsonEncode(body)}');
    print('📞 Original phone: $phone -> Clean phone: $cleanPhone');
    
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/User/EditSelf'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );
      
      print('📥 Edit profile response status: ${response.statusCode}');
      print('📥 Edit profile response body: ${response.body}');
      
      return response;
    } catch (e) {
      print('❌ Edit profile API error: $e');
      rethrow;
    }
  }

  static Future<http.Response> getCurrentUser({required String token}) {
    return http.get(
      Uri.parse('$baseUrl/api/User/GetCurrentUser'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<http.Response> updateAddress(String address, {required String token}) {
    return http.put(
      Uri.parse('$baseUrl/api/User/UpdateAddress'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'address': address}),
    );
  }
} 