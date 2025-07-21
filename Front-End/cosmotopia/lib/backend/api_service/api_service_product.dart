import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServiceProduct {
  static const String baseUrl = 'http://10.0.2.2:5192';

  // ============ CATEGORY OPERATIONS ============

  static Future<http.Response> getAllCategory({int page = 1, int pageSize = 10}) {
    return http.get(
      Uri.parse('$baseUrl/api/Category/GetAllCategory?page=$page&pageSize=$pageSize'),
      headers: {'Content-Type': 'application/json'},
    );
  }

  // ============ PRODUCT OPERATIONS ============

  static Future<http.Response> getAllProducts({int page = 1, int pageSize = 10, String? categoryId, String? search}) {
    String url = '$baseUrl/api/Product/GetAllProduct?page=$page&pageSize=$pageSize';
    if (categoryId != null && categoryId.isNotEmpty) {
      url += '&categoryId=$categoryId';
    }
    if (search != null && search.isNotEmpty) {
      url += '&search=${Uri.encodeComponent(search)}';
    }
    return http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );
  }

  static Future<http.Response> getProductById(String productId) {
    return http.get(
      Uri.parse('$baseUrl/api/Product/GetProductBy/$productId'),
      headers: {'Content-Type': 'application/json'},
    );
  }

  static Future<http.Response> getTopSellingProducts({int top = 10}) {
    return http.get(
      Uri.parse('$baseUrl/api/Product/GetTopSellingProducts?top=$top'),
      headers: {'Content-Type': 'application/json'},
    );
  }

  static Future<http.Response> createProduct({
    required String productName,
    required String description,
    required double price,
    required String categoryId,
    required String token,
    String? imageUrl,
    int? stockQuantity,
    String? brand,
    Map<String, dynamic>? additionalFields,
  }) {
    final body = {
      'name': productName,  // Server expects 'name', not 'productName'
      'description': description,
      'price': price,
      'stockQuantity': stockQuantity ?? 0,
      'commissionRate': 2,  // Default commission rate
      'categoryId': categoryId,
      'brandId': brand,  // Changed from 'brand' to 'brandId' if needed
      'imageUrls': imageUrl != null ? [imageUrl] : [],  // Server expects array
      // Add any additional fields
      if (additionalFields != null) ...additionalFields,
    };

    print('📤 Create product request body: ${jsonEncode(body)}');

    return http.post(
      Uri.parse('$baseUrl/api/Product/CreateProduct'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> updateProduct({
    required String productId,
    required String productName,
    required String description,
    required double price,
    required String categoryId,
    required String token,
    String? imageUrl,
    int? stockQuantity,
    String? brand,
    Map<String, dynamic>? additionalFields,
  }) {
    final body = {
      'name': productName,  // Server expects 'name', not 'productName'
      'description': description,
      'price': price,
      'stockQuantity': stockQuantity ?? 0,
      'commissionRate': 2,  // Default commission rate
      'categoryId': categoryId,
      'brandId': brand,  // Changed from 'brand' to 'brandId'
      'imageUrls': imageUrl != null ? [imageUrl] : [],  // Server expects array
      // Add any additional fields
      if (additionalFields != null) ...additionalFields,
    };

    print('📤 Update product request body: ${jsonEncode(body)}');

    return http.put(
      Uri.parse('$baseUrl/api/Product/UpdateProduct/$productId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> deleteProduct(String productId, {required String token}) {
    return http.delete(
      Uri.parse('$baseUrl/api/Product/DeleteProduct/$productId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<List<http.Response>> deleteMultipleProducts(List<String> productIds, {required String token}) async {
    List<http.Response> responses = [];
    
    for (String productId in productIds) {
      try {
        final response = await deleteProduct(productId, token: token);
        responses.add(response);
      } catch (e) {
        print('❌ Error deleting product $productId: $e');
        // Create a mock error response
        responses.add(http.Response('{"error": "Failed to delete product: $e"}', 500));
      }
    }
    
    return responses;
  }

  // ============ BRAND OPERATIONS ============

  static Future<http.Response> getAllBrands() {
    return http.get(
      Uri.parse('$baseUrl/api/Brand/GetAllBrand'),
      headers: {'Content-Type': 'application/json'},
    );
  }
} 