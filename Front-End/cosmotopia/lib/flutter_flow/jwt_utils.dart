import 'dart:convert';
import '/app_state.dart';

class JwtUtils {
  /// Decode JWT token and extract payload
  static Map<String, dynamic>? decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      
      final payload = parts[1];
      // Add padding if needed
      var normalizedSource = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalizedSource));
      
      return json.decode(decoded) as Map<String, dynamic>;
    } catch (e) {
      print('Error decoding JWT: $e');
      return null;
    }
  }
  
  /// Get user role from JWT token
  static String? getUserRole(String token) {
    final payload = decodeJwt(token);
    if (payload == null) return null;
    
    // JWT claim for role can be either 'role' or 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role'
    return payload['role'] ?? 
           payload['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] ??
           payload['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/role'];
  }
  
  /// Check if user has Administrator role
  static bool isAdministrator(String? token) {
    if (token == null || token.isEmpty) {
      // Fallback to stored role in FFAppState
      return FFAppState().userRole == 'Administrator';
    }
    final role = getUserRole(token);
    return role == 'Administrator';
  }
  
  /// Check if user has Manager role
  static bool isManager(String? token) {
    if (token == null || token.isEmpty) {
      // Fallback to stored role in FFAppState
      return FFAppState().userRole == 'Manager';
    }
    final role = getUserRole(token);
    return role == 'Manager';
  }
  
  /// Check if user has Affiliate role
  static bool isAffiliate(String? token) {
    if (token == null || token.isEmpty) {
      // Fallback to stored role in FFAppState
      return FFAppState().userRole == 'Affiliates';
    }
    final role = getUserRole(token);
    return role == 'Affiliates';
  }
  
  /// Check if user has Customer role
  static bool isCustomer(String? token) {
    if (token == null || token.isEmpty) {
      // Fallback to stored role in FFAppState
      return FFAppState().userRole == 'Customers';
    }
    final role = getUserRole(token);
    return role == 'Customers';
  }
  
  /// Check if user has admin privileges (Administrator or Manager)
  static bool hasAdminPrivileges(String? token) {
    return isAdministrator(token) || isManager(token);
  }
  
  /// Get user ID from JWT token
  static String? getUserId(String token) {
    final payload = decodeJwt(token);
    if (payload == null) return null;
    
    return payload['nameid'] ?? 
           payload['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ??
           payload['sub'];
  }
  
  /// Get user email from JWT token
  static String? getUserEmail(String token) {
    final payload = decodeJwt(token);
    if (payload == null) return null;
    
    return payload['email'] ?? 
           payload['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'];
  }
  
  /// Get user first name from JWT token
  static String? getUserFirstName(String token) {
    final payload = decodeJwt(token);
    if (payload == null) return null;
    
    return payload['FirstName'];
  }
  
  /// Get user last name from JWT token
  static String? getUserLastName(String token) {
    final payload = decodeJwt(token);
    if (payload == null) return null;
    
    return payload['LastName'];
  }
  
  /// Check if token is expired
  static bool isTokenExpired(String token) {
    final payload = decodeJwt(token);
    if (payload == null) return true;
    
    final exp = payload['exp'];
    if (exp == null) return true;
    
    final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    return DateTime.now().isAfter(expiryDate);
  }
} 