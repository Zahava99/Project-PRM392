import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServiceCart {
  static const String baseUrl = 'http://10.0.2.2:5192';

  static Future<http.Response> addToCart({
    required String productId,
    required int quantity,
    required String token,
  }) {
    final body = {
      'productId': productId,
      'quantity': quantity,
    };
    return http.post(
      Uri.parse('$baseUrl/api/cart/add'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> getCart({required String token}) {
    return http.get(
      Uri.parse('$baseUrl/api/cart'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<http.Response> deleteCartItem({required String productId, required String token}) {
    return http.delete(
      Uri.parse('$baseUrl/api/cart/remove/$productId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<http.Response> updateCart({
    required String productId,
    required int quantity,
    required String token,
  }) {
    final body = {
      'productId': productId,
      'quantity': quantity,
    };
    return http.put(
      Uri.parse('$baseUrl/api/cart/update'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }

  /// Clears all items from the cart by removing each product individually
  static Future<bool> clearAllCart({required String token}) async {
    try {
      // First get the current cart
      final cartResponse = await getCart(token: token);
      if (cartResponse.statusCode != 200) {
        print('❌ Failed to get cart: ${cartResponse.statusCode}');
        return false;
      }

      final cartData = jsonDecode(cartResponse.body);
      if (cartData == null || cartData.isEmpty) {
        print('✅ Cart is already empty');
        return true;
      }

      // Remove each item from the cart
      bool allSuccess = true;
      for (final item in cartData) {
        final productId = item['productId'] ?? item['product']?['productId'];
        if (productId != null) {
          final removeResponse = await deleteCartItem(productId: productId, token: token);
          if (removeResponse.statusCode != 200) {
            print('❌ Failed to remove product $productId: ${removeResponse.statusCode}');
            allSuccess = false;
          } else {
            print('✅ Removed product $productId from cart');
          }
        }
      }

      return allSuccess;
    } catch (e) {
      print('❌ Error clearing cart: $e');
      return false;
    }
  }
} 