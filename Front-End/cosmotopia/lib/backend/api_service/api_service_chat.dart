import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ApiServiceChat {
  static const String baseUrl = 'http://10.0.2.2:5192';

  static Future<http.Response> sendChatMessage({
    required String message,
    required String token,
  }) {
    return http.post(
      Uri.parse('$baseUrl/api/Chat'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'message': message}),
    );
  }

  static Future<http.Response> analyzeBeautyImage({
    required File imageFile,
    required String token,
  }) async {
    try {
      print('🔗 API URL: $baseUrl/api/chat');
      print('📁 File exists: ${await imageFile.exists()}');
      print('📏 File size: ${await imageFile.length()} bytes');
      
      // Convert image to base64
      Uint8List imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      
      print('📤 Sending beauty analysis request...');
      print('📊 Base64 length: ${base64Image.length}');
      
      final message = '''Phân tích ảnh này và đưa ra kết quả dưới dạng JSON với format sau:
{
  "skinTone": "Warm Light|Warm Medium|Warm Deep|Cool Light|Cool Medium|Cool Deep|Neutral Light|Neutral Medium",
  "skinType": "Dry|Oily|Combination|Normal|Sensitive",
  "faceShape": "Oval|Round|Square|Heart|Diamond|Rectangle",
  "recommendations": [
    "Gợi ý 1 về trang điểm",
    "Gợi ý 2 về trang điểm",
    "Gợi ý 3 về trang điểm"
  ]
}

Hãy phân tích ảnh và đưa ra các gợi ý trang điểm phù hợp với tông da, loại da và hình dạng khuôn mặt.''';

      final requestBody = {
        'message': message,
        'imageBase64': base64Image,
        'hasImage': true,
      };

      print('📦 Request body keys: ${requestBody.keys}');
      print('📦 Image field length: ${base64Image.length}');

      final response = await http.post(
        Uri.parse('$baseUrl/api/chat'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      ).timeout(Duration(seconds: 30));

      // Check for Gemini API errors  
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final responseText = responseBody['response'] ?? '';
        
        // Detect Gemini overload/rate limit errors
        if (responseText.contains('ServiceUnavailable') || 
            responseText.contains('overloaded') ||
            responseText.contains('503') ||
            responseText.contains('RESOURCE_EXHAUSTED') ||
            responseText.contains('quota')) {
          print('⚠️ Gemini API overloaded: $responseText');
          throw Exception('GEMINI_OVERLOADED');
        }
        
        // Detect when Gemini doesn't see the image
        if (responseText.contains('cần bạn cung cấp hình ảnh') ||
            responseText.contains('tải ảnh lên') ||
            responseText.contains('không thể truy cập URL') ||
            responseText.contains('không thể phân tích hình ảnh')) {
          print('👁️ Gemini cannot see the image: $responseText');
          throw Exception('GEMINI_NO_IMAGE');
        }
      }

      return response;
    } catch (e) {
      print('❌ API Error: $e');
      rethrow;
    }
  }
} 