import 'dart:convert';
import 'package:http/http.dart' as http;
import '/backend/api_service/api_service_chat.dart';
import '/backend/schema/structs/index.dart';
import '/backend/services/chat_history_service.dart';

class ChatbotService {
  // API endpoints
  static const String _chatbotProcessEndpoint = '/api/Chatbot/process';
  static const String _chatbotProcessWithHistoryEndpoint = '/api/Chatbot/process-with-history';
  static const String _chatbotSearchEndpoint = '/api/Chatbot/search-products';
  static const String _chatbotResetEndpoint = '/api/Chatbot/reset-context';
  static const String _chatbotImageEndpoint = '/api/Chatbot/process-with-image';

  /// Xử lý tin nhắn chatbot với chat history
  static Future<Map<String, dynamic>> processMessageWithHistory(
    String message, {
    String? sessionId,
    int? userId,
    bool saveToHistory = true,
  }) async {
    print('🔄 processMessageWithHistory called:');
    print('  📝 Message: $message');
    print('  🆔 Session ID: $sessionId');
    print('  👤 User ID: $userId');
    print('  💾 Save to history: $saveToHistory');

    try {
      final requestData = {
        'message': message,
        'sessionId': sessionId,
        'userId': userId,
        'isProductQuery': false,
        'context': null,
      };

      print('🚀 Calling backend process-with-history endpoint...');
      final response = await http.post(
        Uri.parse('${ApiServiceChat.baseUrl}$_chatbotProcessWithHistoryEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestData),
      );
      
      print('📡 Backend response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Backend processing successful');
        
        // Xử lý response data
        final products = <ProductStruct>[];
        if (data['products'] != null) {
          for (var productData in data['products']) {
            try {
              final product = ProductStruct.fromMap(productData);
              products.add(product);
            } catch (e) {
              print('❌ Error parsing product: $e');
              continue;
            }
          }
        }

        return {
          'success': true,
          'message': data['message'] ?? 'No response',
          'products': products,
          'hasProducts': data['hasProducts'] ?? false,
          'shouldSendToAPI': data['shouldSendToAPI'] ?? false,
          'context': data['context'],
        };
      } else {
        print('❌ Backend API error: ${response.statusCode}');
        print('📄 Response body: ${response.body}');
        return {
          'success': false,
          'message': 'Có lỗi xảy ra khi xử lý tin nhắn.',
          'products': <ProductStruct>[],
          'hasProducts': false,
          'shouldSendToAPI': false,
          'error': 'API Error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('💥 Error in processMessageWithHistory: $e');
      return {
        'success': false,
        'message': 'Có lỗi xảy ra khi kết nối với server.',
        'products': <ProductStruct>[],
        'hasProducts': false,
        'shouldSendToAPI': false,
        'error': e.toString(),
      };
    }
  }

  /// Xử lý tin nhắn chatbot (method gốc)
  static Future<Map<String, dynamic>> processMessage(
    String message, {
    String? sessionId,
    int? userId,
  }) async {
    try {
      final requestData = {
        'message': message,
        'sessionId': sessionId,
        'userId': userId,
        'isProductQuery': false,
        'context': null,
      };

      final response = await http.post(
        Uri.parse('${ApiServiceChat.baseUrl}$_chatbotProcessEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestData),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Xử lý response data
        final products = <ProductStruct>[];
        if (data['products'] != null) {
          for (var productData in data['products']) {
            try {
              final product = ProductStruct.fromMap(productData);
              products.add(product);
            } catch (err) {
              print('Error mapping product: $err');
            }
          }
      }
      
      return {
          'message': data['message'] ?? 'Có lỗi xảy ra',
        'products': products,
          'hasProducts': data['hasProducts'] ?? false,
          'shouldSendToAPI': data['shouldSendToAPI'] ?? false,
          'isSearchResult': data['isSearchResult'] ?? false,
          'similarProducts': data['similarProducts'] ?? [],
          'hasSimilarProducts': data['hasSimilarProducts'] ?? false,
          'context': data['context'],
          'success': data['success'] ?? true,
        };
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return {
          'message': 'Xin lỗi, tôi không thể xử lý yêu cầu của bạn lúc này. Vui lòng thử lại sau.',
          'products': <ProductStruct>[],
          'hasProducts': false,
          'shouldSendToAPI': false,
          'isSearchResult': false,
          'similarProducts': [],
          'hasSimilarProducts': false,
          'success': false,
        };
      }
    } catch (e) {
      print('Error calling chatbot API: $e');
      return {
        'message': 'Đã xảy ra lỗi kết nối. Vui lòng kiểm tra mạng và thử lại.',
        'products': <ProductStruct>[],
        'hasProducts': false,
        'shouldSendToAPI': false,
        'isSearchResult': false,
        'similarProducts': [],
        'hasSimilarProducts': false,
        'success': false,
      };
    }
  }

  /// Xử lý tin nhắn với hình ảnh
  static Future<Map<String, dynamic>> processMessageWithImage(
    String message,
    String imageBase64, {
    String? sessionId,
    int? userId,
  }) async {
    try {
      final requestData = {
        'message': message,
        'sessionId': sessionId,
        'userId': userId,
        'imageBase64': imageBase64,
      };

      final response = await http.post(
        Uri.parse('${ApiServiceChat.baseUrl}$_chatbotImageEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        return {
          'message': data['message'] ?? 'Có lỗi xảy ra',
          'products': <ProductStruct>[],
          'hasProducts': false,
          'shouldSendToAPI': false,
          'isSearchResult': false,
          'similarProducts': [],
          'hasSimilarProducts': false,
          'context': data['context'],
          'success': data['success'] ?? true,
        };
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return {
          'message': 'Xin lỗi, tôi không thể phân tích hình ảnh của bạn lúc này.',
          'products': <ProductStruct>[],
        'hasProducts': false,
          'success': false,
      };
      }
    } catch (e) {
      print('Error calling image analysis API: $e');
      return {
        'message': 'Đã xảy ra lỗi kết nối. Vui lòng kiểm tra mạng và thử lại.',
        'products': <ProductStruct>[],
        'hasProducts': false,
        'success': false,
      };
    }
  }

  /// Tìm kiếm sản phẩm
  static Future<List<ProductStruct>> searchProducts(String query) async {
    try {
      final requestData = {'query': query};

      final response = await http.post(
        Uri.parse('${ApiServiceChat.baseUrl}$_chatbotSearchEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final products = <ProductStruct>[];
        
        if (data['products'] != null) {
          for (var productData in data['products']) {
            try {
              final product = ProductStruct.fromMap(productData);
              products.add(product);
            } catch (err) {
              print('Error mapping product: $err');
            }
          }
        }
        
        return products;
    } else {
        print('Search API Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error calling search products API: $e');
      return [];
    }
  }

  /// Reset context phiên chat
  static Future<bool> resetContext(String sessionId) async {
    try {
      final requestData = {'sessionId': sessionId};

      final response = await http.post(
        Uri.parse('${ApiServiceChat.baseUrl}$_chatbotResetEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Reset context API Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error calling reset context API: $e');
      return false;
    }
    }

  /// Kiểm tra xem tin nhắn có liên quan đến sản phẩm không (đơn giản hóa)
  static bool isProductRelated(String message) {
    final productKeywords = [
      'sản phẩm', 'mỹ phẩm', 'kem', 'serum', 'tẩy trang', 'rửa mặt',
      'dưỡng ẩm', 'chống nắng', 'trang điểm', 'son', 'phấn', 'mascara',
      'giới thiệu', 'gợi ý', 'khuyến nghị', 'tư vấn', 'skincare', 'makeup'
    ];
    
    final lowerMessage = message.toLowerCase();
    return productKeywords.any((keyword) => lowerMessage.contains(keyword));
    }

  /// Tạo session ID mới
  static String generateSessionId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Utility method để xử lý enhanced message (tương thích với code cũ)
  static Future<Map<String, dynamic>> processMessageEnhanced(String message, {String? sessionId, int? userId}) async {
    return await processMessage(message, sessionId: sessionId, userId: userId);
    }

  /// Placeholder methods để tương thích với code cũ (sẽ gọi API)
  static Future<List<ProductStruct>> getRelevantProducts(String message) async {
    return await searchProducts(message);
  }

  /// Tìm sản phẩm tương tự (sẽ được xử lý ở backend)
  static Future<Map<String, dynamic>> findSimilarProducts(String productName, String message) async {
    // Gọi processMessage với message chứa thông tin về sản phẩm tương tự
    final enhancedMessage = 'tìm sản phẩm tương tự $productName: $message';
    return await processMessage(enhancedMessage);
  }

  /// Tìm thêm sản phẩm khác (sẽ được xử lý ở backend)
  static Future<Map<String, dynamic>> findMoreSimilarProducts(String message) async {
    return await processMessage(message);
  }
} 