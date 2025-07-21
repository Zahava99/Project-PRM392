import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import '/backend/api_service/api_service_chat.dart';
import '/backend/schema/structs/index.dart';

class ChatHistoryService {
  // API endpoints for chat history
  static const String _startSessionEndpoint = '/api/Chatbot/sessions/start';
  static const String _getUserSessionsEndpoint = '/api/Chatbot/sessions';
  static const String _getChatHistoryEndpoint = '/api/Chatbot/sessions';
  static const String _saveMessageEndpoint = '/api/Chatbot/sessions/messages';
  static const String _getActiveSessionEndpoint = '/api/Chatbot/sessions';
  static const String _deactivateSessionEndpoint = '/api/Chatbot/sessions';
  static const String _deleteSessionEndpoint = '/api/Chatbot/sessions';

  /// Bắt đầu session chat mới
  static Future<ChatSessionStruct?> startNewSession(int userId, {String? sessionName}) async {
    try {
      final requestData = {
        'userId': userId,
        'sessionName': sessionName,
      };

      print('📤 Calling start new session API:');
      print('  🌐 URL: ${ApiServiceChat.baseUrl}$_startSessionEndpoint');
      print('  📊 Request data: ${jsonEncode(requestData)}');

      final response = await http.post(
        Uri.parse('${ApiServiceChat.baseUrl}$_startSessionEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      print('📥 Start session API response:');
      print('  📊 Status Code: ${response.statusCode}');
      print('  📄 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Session created successfully');
        return ChatSessionStruct.fromMap(data);
      } else {
        print('❌ Start session API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error starting new session: $e');
      return null;
    }
  }

  /// Lấy danh sách sessions của user
  static Future<List<ChatSessionStruct>> getUserSessions(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiServiceChat.baseUrl}$_getUserSessionsEndpoint/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('🕐 DEBUG getUserSessions - API Response (first session): ${data.isNotEmpty ? data.first : 'No sessions'}');
        
        final sessions = data.map((session) => ChatSessionStruct.fromMap(session)).toList();
        if (sessions.isNotEmpty) {
          print('🕐 DEBUG getUserSessions - First session lastMessageTime: ${sessions.first.lastMessageTime}');
        }
        return sessions;
      } else {
        print('Get user sessions API Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error getting user sessions: $e');
      return [];
    }
  }

  /// Lấy lịch sử chat của session
  static Future<List<ChatMessageStruct>> getChatHistory(String sessionId) async {
    try {
      print('📤 Calling get chat history API for session: $sessionId');
      final response = await http.get(
        Uri.parse('${ApiServiceChat.baseUrl}$_getChatHistoryEndpoint/$sessionId/history'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('📥 Get chat history API response:');
      print('  📊 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> messages = data['messages'] ?? [];
        
        print('  📄 Total messages received: ${messages.length}');
        
        final chatMessages = messages.map((message) {
          print('🛍️ DEBUG getChatHistory - Raw message data: $message');
          final chatMessage = ChatMessageStruct.fromMap(message);
          print('🛍️ DEBUG getChatHistory - Parsed ChatMessageStruct:');
          print('  - Content: ${chatMessage.content.substring(0, math.min(50, chatMessage.content.length))}...');
          print('  - IsFromUser: ${chatMessage.isFromUser}');
          print('  - RecommendedProductIds: ${chatMessage.recommendedProductIds}');
          return chatMessage;
        }).toList();
        
        return chatMessages;
      } else {
        print('Get chat history API Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error getting chat history: $e');
      return [];
    }
  }

  /// Lưu tin nhắn vào session
  static Future<ChatMessageStruct?> saveMessage(
    String sessionId,
    String content,
    bool isFromUser, {
    List<String>? recommendedProductIds,
  }) async {
    try {
      final requestData = {
        'sessionId': sessionId,
        'content': content,
        'isFromUser': isFromUser,
        'recommendedProductIds': recommendedProductIds,
      };

      print('📤 Calling save message API:');
      print('  🌐 URL: ${ApiServiceChat.baseUrl}$_saveMessageEndpoint');
      print('  📊 Request data: ${jsonEncode(requestData)}');

      final response = await http.post(
        Uri.parse('${ApiServiceChat.baseUrl}$_saveMessageEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      print('📥 Save message API response:');
      print('  📊 Status Code: ${response.statusCode}');
      print('  📄 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Message saved successfully');
        return ChatMessageStruct.fromMap(data);
      } else if (response.statusCode == 404 && response.body.contains('Chat session')) {
        print('⚠️ Session not found, skipping save for now');
        // Session doesn't exist on server, but continue chat functionality
        // TODO: Could implement auto-creation of session here
        return null;
      } else {
        print('❌ Save message API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error saving message: $e');
      return null;
    }
  }

  /// Lấy active session của user
  static Future<ChatSessionStruct?> getActiveSession(int userId) async {
    try {
      final url = '${ApiServiceChat.baseUrl}$_getActiveSessionEndpoint/$userId/active';
      print('📤 Calling get active session API:');
      print('  🌐 URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('📥 Get active session API response:');
      print('  📊 Status Code: ${response.statusCode}');
      print('  📄 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Active session found');
        return ChatSessionStruct.fromMap(data);
      } else if (response.statusCode == 404) {
        // No active session found
        print('ℹ️ No active session found (404)');
        return null;
      } else {
        print('❌ Get active session API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error getting active session: $e');
      return null;
    }
  }

  /// Deactivate session
  static Future<bool> deactivateSession(String sessionId) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiServiceChat.baseUrl}$_deactivateSessionEndpoint/$sessionId/deactivate'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Deactivate session API Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error deactivating session: $e');
      return false;
    }
  }

  /// Xóa session
  static Future<bool> deleteSession(String sessionId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiServiceChat.baseUrl}$_deleteSessionEndpoint/$sessionId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Delete session API Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error deleting session: $e');
      return false;
    }
  }

  /// Utility method để lấy sessionId từ existing session hoặc tạo mới
  static Future<String> getOrCreateSessionId(int userId) async {
    print('🔄 getOrCreateSessionId called for user: $userId');
    
    try {
      // Thử lấy active session trước
      print('🔍 Checking for active session...');
      final activeSession = await getActiveSession(userId);
      if (activeSession != null) {
        print('✅ Found existing active session: ${activeSession.sessionId}');
        return activeSession.sessionId;
      }
      
      print('⚠️ No active session found, creating new session...');
      // Nếu không có active session, tạo mới
      final newSession = await startNewSession(userId);
      if (newSession != null) {
        print('✅ Created new session successfully: ${newSession.sessionId}');
        return newSession.sessionId;
      }
      
      print('❌ Failed to create new session via API');
      // Fallback tạo local session ID
      final fallbackSessionId = DateTime.now().millisecondsSinceEpoch.toString();
      print('🔄 Using fallback session ID: $fallbackSessionId');
      return fallbackSessionId;
    } catch (e) {
      print('❌ Error in getOrCreateSessionId: $e');
      // Fallback tạo local session ID
      final fallbackSessionId = DateTime.now().millisecondsSinceEpoch.toString();
      print('🔄 Using fallback session ID due to error: $fallbackSessionId');
      return fallbackSessionId;
    }
  }

  /// Helper method để convert product IDs từ ProductStruct list
  static List<String> extractProductIds(List<ProductStruct> products) {
    return products.map((product) => product.productId).toList();
  }
} 