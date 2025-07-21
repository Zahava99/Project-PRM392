import '/flutter_flow/flutter_flow_util.dart';
import '/backend/schema/structs/index.dart';
import '/backend/services/chat_history_service.dart';
import '/backend/api_service.dart';
import 'dart:convert';
import 'chat_page_widget.dart' show ChatPageWidget;
import 'package:flutter/material.dart';

class ChatPageModel extends FlutterFlowModel<ChatPageWidget> {
  ///  Local state fields for this page.
  List<Map<String, dynamic>> messages = [];
  bool isLoading = false;
  
  // Chat history state
  String? currentSessionId;
  int? currentUserId;
  List<ChatSessionStruct> userSessions = [];
  bool isLoadingSessions = false;
  bool showSessionHistory = false;

  ///  State fields for stateful widgets in this page.
  final unfocusNode = FocusNode();
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }



  void setLoading(bool loading) {
    isLoading = loading;
  }

  // Session management methods
  Future<void> initializeSession(int userId) async {
    print('🔄 Initializing session for user ID: $userId');
    currentUserId = userId;
    
    try {
      // Try to get active session or create new one
      print('🔍 Getting or creating session ID...');
      currentSessionId = await ChatHistoryService.getOrCreateSessionId(userId);
      print('✅ Session ID obtained: $currentSessionId');
      
      // Load user sessions for history
      print('📋 Loading user sessions...');
      await loadUserSessions();
      print('✅ User sessions loaded: ${userSessions.length} sessions');
    } catch (e) {
      print('❌ Error initializing session: $e');
      // Fallback: generate local session ID
      currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
      print('🔄 Using fallback session ID: $currentSessionId');
    }
  }

  Future<void> loadUserSessions() async {
    if (currentUserId == null) return;
    
    isLoadingSessions = true;
    userSessions = await ChatHistoryService.getUserSessions(currentUserId!);
    isLoadingSessions = false;
  }

  Future<void> loadChatHistory(String sessionId) async {
    isLoading = true;
    messages.clear();
    
    final history = await ChatHistoryService.getChatHistory(sessionId);
    
    for (final message in history) {
      // Parse UTC time and convert to local
      DateTime? timestamp;
      try {
        if (message.sentAt.isNotEmpty) {
          final utcDateTime = DateTime.parse(message.sentAt).toUtc();
          timestamp = utcDateTime.toLocal();
        }
      } catch (e) {
        print('Error parsing timestamp: ${message.sentAt}');
        timestamp = DateTime.now();
      }
      
      // Parse products from recommendedProductIds if available
      List<ProductStruct>? products;
      if (!message.isFromUser && message.recommendedProductIds.isNotEmpty) {
        print('🛍️ DEBUG loadChatHistory - Found recommendedProductIds: ${message.recommendedProductIds}');
        products = await _loadProductsFromIds(message.recommendedProductIds);
        print('🛍️ DEBUG loadChatHistory - Loaded ${products?.length ?? 0} products');
      }
      
      addMessage(
        message.content,
        message.isFromUser,
        timestamp: timestamp,
        products: products,
      );
    }
    
    currentSessionId = sessionId;
    isLoading = false;
  }

  /// Helper method to load ProductStruct objects from product IDs
  Future<List<ProductStruct>?> _loadProductsFromIds(List<String> productIds) async {
    try {
      final products = <ProductStruct>[];
      
      // Load each product by ID from API
      for (final productId in productIds) {
        try {
          print('🔍 Loading product with ID: $productId');
          final response = await ApiService.getProductById(productId);
          
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            print('📦 Product API response: $data');
            
            // Try different response formats
            Map<String, dynamic>? productData;
            if (data is Map<String, dynamic>) {
              productData = data['product'] ?? data['data'] ?? data;
            } else if (data is List && data.isNotEmpty) {
              productData = data[0];
            }
            
            if (productData != null) {
              final product = ProductStruct.fromMap(productData);
              products.add(product);
              print('✅ Loaded product: ${product.name}');
            } else {
              print('⚠️ No product data found for ID: $productId');
            }
          } else {
            print('❌ Product API error for $productId: ${response.statusCode}');
          }
        } catch (e) {
          print('❌ Error loading product $productId: $e');
          continue;
        }
      }
      
      print('🛍️ Successfully loaded ${products.length} products out of ${productIds.length} IDs');
      return products.isNotEmpty ? products : null;
    } catch (e) {
      print('❌ Error loading products from IDs: $e');
      return null;
    }
  }

  Future<void> startNewSession({String? sessionName}) async {
    if (currentUserId == null) return;
    
    final newSession = await ChatHistoryService.startNewSession(
      currentUserId!, 
      sessionName: sessionName,
    );
    
    if (newSession != null) {
      currentSessionId = newSession.sessionId;
      messages.clear();
      await loadUserSessions(); // Refresh sessions list
      
      // Add welcome message for new session
      addMessage("Xin chào! Tôi có thể giúp gì cho bạn?", false);
    }
  }

  Future<void> deleteSession(String sessionId) async {
    final success = await ChatHistoryService.deleteSession(sessionId);
    if (success) {
      userSessions.removeWhere((session) => session.sessionId == sessionId);
      
      // If deleted current session, start new one
      if (sessionId == currentSessionId) {
        await startNewSession();
      }
    }
  }

  void toggleSessionHistory() {
    showSessionHistory = !showSessionHistory;
  }

  void addMessage(String message, bool isUser, {List<ProductStruct>? products, List<Map<String, dynamic>>? similarProducts, DateTime? timestamp}) {
    messages.add({
      'message': message,
      'isUser': isUser,
      'timestamp': timestamp ?? DateTime.now(),
      'products': products,
      'similarProducts': similarProducts,
    });
  }

  String get currentSessionName {
    if (currentSessionId == null) return 'Current Chat';
    
    final session = userSessions.firstWhere(
      (s) => s.sessionId == currentSessionId,
      orElse: () => createChatSessionStruct(sessionName: 'Current Chat'),
    );
    
    return session.sessionName.isNotEmpty ? session.sessionName : 'Chat Session';
  }
} 