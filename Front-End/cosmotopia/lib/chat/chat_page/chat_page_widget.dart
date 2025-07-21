import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/backend/api_service.dart';
import '/backend/services/chatbot_service.dart';
import '/backend/schema/structs/index.dart';
import '/all_component/chat_product_list/chat_product_list_widget.dart';
import '/all_component/similar_products_list/similar_products_list_widget.dart';
import '/all_component/chat_history_sidebar/chat_history_sidebar_widget.dart';
import '/backend/services/chat_history_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_page_model.dart';
export 'chat_page_model.dart';
import '/flutter_flow/jwt_utils.dart';

class ChatPageWidget extends StatefulWidget {
  const ChatPageWidget({super.key});
  static String routeName = 'ChatPage';
  static String routePath = 'chatPage';
  @override
  State<ChatPageWidget> createState() => _ChatPageWidgetState();
}
class _ChatPageWidgetState extends State<ChatPageWidget> {
  late ChatPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  String _sessionId = '';
  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChatPageModel());
    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
    // Initialize session with user ID (placeholder - should get from app state)
    _initializeSession();
  }
  void _initializeSession() async {
    // Get actual user ID from JWT token
    int? userId;
    final token = FFAppState().token;   
    if (token.isNotEmpty) {
      final userIdString = JwtUtils.getUserId(token);
      if (userIdString != null) {
        userId = int.tryParse(userIdString);
        print('🔐 User ID from token: $userId');
      }
    }   
    // Fallback to placeholder if no valid user ID
    if (userId == null) {
      userId = 1; // Fallback for development/testing
      print('⚠️ Using fallback user ID: $userId (token: ${token.isEmpty ? 'empty' : 'present'})');
    }   
    await _model.initializeSession(userId);
    setState(() {
      _sessionId = _model.currentSessionId ?? ChatbotService.generateSessionId();
    });  
    print('🚀 Session initialized - Session ID: $_sessionId, User ID: $userId');    
    // Reset context when starting chat session
    ChatbotService.resetContext(_sessionId);  
    // Add welcome message if no existing messages
    if (_model.messages.isEmpty) {
      _model.addMessage("Xin chào! Tôi có thể giúp gì cho bạn?", false);
    }
  }
  @override
  void dispose() {
    _model.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  String _cleanUpText(String text) {
    // Remove markdown formatting and clean up text step by step
    String cleanText = text;   
    // Remove markdown bold (**text**)
    cleanText = cleanText.replaceAllMapped(
      RegExp(r'\*\*(.*?)\*\*'),
      (match) => match.group(1) ?? '',
    );    
    // Remove markdown italic (*text*) - be careful with single asterisks
    cleanText = cleanText.replaceAllMapped(
      RegExp(r'(?<!\*)\*([^*\n]+)\*(?!\*)'),
      (match) => match.group(1) ?? '',
    );    
    // Convert markdown headers (### text)
    cleanText = cleanText.replaceAllMapped(
      RegExp(r'^#{1,6}\s*(.+)$', multiLine: true),
      (match) => match.group(1) ?? '',
    );    
    // Convert markdown lists (* item) to bullet points
    cleanText = cleanText.replaceAllMapped(
      RegExp(r'^\*\s+(.+)$', multiLine: true),
      (match) => '• ${match.group(1) ?? ''}',
    );    
    // Remove backslashes used for escaping
    cleanText = cleanText.replaceAllMapped(
      RegExp(r'\\([*_#\[\]()~`])'),
      (match) => match.group(1) ?? '',
    );    
    // Remove extra asterisks (3 or more in a row)
    cleanText = cleanText.replaceAll(RegExp(r'\*{3,}'), '');   
    // Remove standalone asterisks on their own lines
    cleanText = cleanText.replaceAll(RegExp(r'^\*\s*$', multiLine: true), '');   
    // Clean up multiple spaces
    cleanText = cleanText.replaceAll(RegExp(r' {2,}'), ' ');   
    // Clean up multiple line breaks (max 2)
    cleanText = cleanText.replaceAll(RegExp(r'\n{3,}'), '\n\n');   
    // Remove leading/trailing whitespace from each line and filter empty lines
    cleanText = cleanText
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .join('\n')
        .trim();
    
    return cleanText;
  }
  Future<void> _sendMessage() async {
    final message = _model.textController?.text.trim() ?? '';
    if (message.isEmpty) return;
    // Add user message
    setState(() {
      _model.addMessage(message, true);
      _model.setLoading(true);
    });   
    _model.textController?.clear();
    _scrollToBottom();
    try {
      // Debug logging
      print('💬 Sending message with history:');
      print('  Message: $message');
      print('  Session ID: $_sessionId');
      print('  User ID: ${_model.currentUserId}');
      print('  Save to history: true');   
      // Xử lý tin nhắn bằng chatbot service với history
      final result = await ChatbotService.processMessageWithHistory(
        message,
        sessionId: _sessionId,
        userId: _model.currentUserId,
        saveToHistory: true,
      );      
      print('✅ Message processed - Success: ${result['success']}');     
      setState(() {
        _model.setLoading(false);
      });
      if (result['hasSimilarProducts'] == true) {
        // Hiển thị tin nhắn với danh sách sản phẩm tương tự
        setState(() {
          _model.addMessage(
            result['message'], 
            false, 
            similarProducts: result['similarProducts'],
          );
        });
      } else if (result['hasProducts'] == true) {
        // Hiển thị tin nhắn với danh sách sản phẩm
        setState(() {
          _model.addMessage(
            result['message'], 
            false, 
            products: result['products'],
          );
        });
      } else if (result['isSearchResult'] == true) {
        // Hiển thị kết quả tìm kiếm Google
        setState(() {
          _model.addMessage(result['message'], false);
        });
      } else if (result['shouldSendToAPI'] == true) {
        // Gửi tin nhắn đến API chatbot
        await _sendToChatAPI(message);
      } else {
        // Hiển thị tin nhắn thông thường
        setState(() {
          _model.addMessage(result['message'], false);
        });
      }
    } catch (e) {
      print('❌ Error in _sendMessage: $e');
      setState(() {
        _model.setLoading(false);
        _model.addMessage("Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.", false);
      });
    }  
    _scrollToBottom();
  }
  Future<void> _sendToChatAPI(String message) async {
    try {
      final token = FFAppState().token;
      if (token.isEmpty) {
        setState(() {
          _model.addMessage("Bạn cần đăng nhập để sử dụng tính năng chat.", false);
        });
        return;
      }
      final response = await ApiService.sendChatMessage(
        message: message,
        token: token,
      );
      print('=== CHAT RESPONSE DEBUG ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('========================');
      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          print('Parsed JSON: $responseData');          
          String botReply = 'Xin lỗi, tôi không thể trả lời lúc này.';         
          // Try different possible response structures
          if (responseData['response'] != null) {
            botReply = responseData['response'];
          } else if (responseData['candidates'] != null && 
              responseData['candidates'].isNotEmpty &&
              responseData['candidates'][0]['content'] != null &&
              responseData['candidates'][0]['content']['parts'] != null &&
              responseData['candidates'][0]['content']['parts'].isNotEmpty) {
            botReply = responseData['candidates'][0]['content']['parts'][0]['text'] ?? botReply;
          } else if (responseData['message'] != null) {
            botReply = responseData['message'];
          } else if (responseData['reply'] != null) {
            botReply = responseData['reply'];
          } else if (responseData['text'] != null) {
            botReply = responseData['text'];
          }          
          // Clean up the text before displaying
          String cleanedReply = _cleanUpText(botReply);          
          setState(() {
            _model.addMessage(cleanedReply, false);
          });
        } catch (e) {
          print('JSON Parse Error: $e');
          setState(() {
            _model.addMessage("Lỗi parse response: $e", false);
          });
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        setState(() {
          _model.addMessage("Xin lỗi, có lỗi xảy ra. Status: ${response.statusCode}", false);
        });
      }
    } catch (e) {
      setState(() {
        _model.addMessage("Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.", false);
      });
    }
  }
  Widget _buildMessageBubble(Map<String, dynamic> messageData) {
    final message = messageData['message'] as String;
    final isUser = messageData['isUser'] as bool;
    final timestamp = messageData['timestamp'] as DateTime;
    final products = messageData['products'] as List<ProductStruct>?;
    final similarProducts = messageData['similarProducts'] as List<Map<String, dynamic>>?;
    return Column(
      children: [
        Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isUser 
            ? FlutterFlowTheme.of(context).primary
            : FlutterFlowTheme.of(context).lightGray,
          borderRadius: BorderRadius.circular(16.0),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'SF Pro Text',
                color: isUser 
                  ? FlutterFlowTheme.of(context).secondaryBackground
                  : FlutterFlowTheme.of(context).primaryText,
                fontSize: 16.0,
                letterSpacing: 0.0,
                lineHeight: 1.4,
              ),
            ),
                // Hiển thị danh sách sản phẩm nếu có
                if (products != null && products.isNotEmpty) ...[
                  SizedBox(height: 12.0),
                  ChatProductListWidget(products: products),
                ],
            SizedBox(height: 4.0),
            Text(
              DateFormat('HH:mm').format(timestamp),
              style: FlutterFlowTheme.of(context).bodySmall.override(
                fontFamily: 'SF Pro Text',
                color: isUser 
                  ? FlutterFlowTheme.of(context).secondaryBackground.withOpacity(0.7)
                  : FlutterFlowTheme.of(context).secondaryText,
                fontSize: 12.0,
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
      ),
        ),
        // Hiển thị danh sách sản phẩm tương tự nếu có
        if (similarProducts != null && similarProducts.isNotEmpty) ...[
          SimilarProductsListWidget(similarProducts: similarProducts),
        ],
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        resizeToAvoidBottomInset: true, // ✅ THÊM ĐỂ AVOID KEYBOARD OVERLAY
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          leading: InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              context.safePop();
            },
            child: Icon(
              Icons.arrow_back_rounded,
              color: FlutterFlowTheme.of(context).secondaryBackground,
              size: 30.0,
            ),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.smart_toy,
                  color: FlutterFlowTheme.of(context).primary,
                  size: 24.0,
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 0.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cosmotopia AI',
                      style: FlutterFlowTheme.of(context).headlineSmall.override(
                        fontFamily: 'SF Pro Text',
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        fontSize: 18.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Trợ lý làm đẹp',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily: 'SF Pro Text',
                        color: FlutterFlowTheme.of(context).secondaryBackground.withOpacity(0.8),
                        fontSize: 12.0,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            // Chat History Toggle Button
            IconButton(
              icon: Icon(
                _model.showSessionHistory ? Icons.close : Icons.history,
                color: FlutterFlowTheme.of(context).secondaryBackground,
              ),
              onPressed: () {
                setState(() {
                  _model.toggleSessionHistory();
                });
              },
            ),
            // New Chat Button
            IconButton(
              icon: Icon(
                Icons.add_comment_outlined,
                color: FlutterFlowTheme.of(context).secondaryBackground,
              ),
              onPressed: () async {
                await _model.startNewSession();
                setState(() {
                  _sessionId = _model.currentSessionId ?? ChatbotService.generateSessionId();
                });
                ChatbotService.resetContext(_sessionId);
              },
            ),
          ],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: Column( // ✅ ĐỔI THÀNH COLUMN THAY VÌ ROW
          children: [
            // Main content area
            Expanded(
              child: Row(
                children: [
                  // Chat History Sidebar
                  if (_model.showSessionHistory)
                    ChatHistorySidebarWidget(
                      sessions: _model.userSessions,
                      currentSessionId: _model.currentSessionId,
                      isLoading: _model.isLoadingSessions,
                      onSessionSelected: (sessionId) async {
                        await _model.loadChatHistory(sessionId);
                        setState(() {
                          _sessionId = sessionId;
                        });
                        ChatbotService.resetContext(_sessionId);
                      },
                      onNewSession: () async {
                        await _model.startNewSession();
                        setState(() {
                          _sessionId = _model.currentSessionId ?? ChatbotService.generateSessionId();
                        });
                        ChatbotService.resetContext(_sessionId);
                      },
                      onDeleteSession: (sessionId) async {
                        await _model.deleteSession(sessionId);
                        setState(() {});
                      },
                    ),
                  
                  // Main Chat Area
                  Expanded(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: 200, // ✅ MINIMUM WIDTH CHO MAIN CHAT AREA
                      ),
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        itemCount: _model.messages.length + (_model.isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _model.messages.length && _model.isLoading) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).lightGray,
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 16.0,
                                      height: 16.0,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          FlutterFlowTheme.of(context).primary,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.0),
                                    Text(
                                      'Đang soạn tin...',
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        fontFamily: 'SF Pro Text',
                                        color: FlutterFlowTheme.of(context).secondaryText,
                                        fontSize: 14.0,
                                        letterSpacing: 0.0,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return _buildMessageBubble(_model.messages[index]);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Text Input Area - LUÔN Ở BOTTOM
            Container(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 4.0,
                    color: Color(0x33000000),
                    offset: Offset(0.0, -2.0),
                  )
                ],
              ),
              child: SafeArea( // ✅ SAFEA AREA CHỈ CHO TEXT INPUT
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _model.textController,
                          focusNode: _model.textFieldFocusNode,
                          onFieldSubmitted: (_) => _sendMessage(),
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                            hintText: 'Nhập tin nhắn...',
                            hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'SF Pro Text',
                              color: FlutterFlowTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).borderColor,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).primary,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                            filled: true,
                            fillColor: FlutterFlowTheme.of(context).lightGray,
                            contentPadding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 12.0),
                          ),
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'SF Pro Text',
                            letterSpacing: 0.0,
                          ),
                          maxLines: null,
                          minLines: 1,
                          validator: _model.textControllerValidator?.asValidator(context),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                        child: FFButtonWidget(
                          onPressed: _model.isLoading ? null : _sendMessage,
                          text: '',
                          icon: Icon(
                            Icons.send,
                            color: FlutterFlowTheme.of(context).secondaryBackground,
                            size: 20.0,
                          ),
                          options: FFButtonOptions(
                            width: 48.0,
                            height: 48.0,
                            padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                            color: _model.isLoading 
                              ? FlutterFlowTheme.of(context).secondaryText
                              : FlutterFlowTheme.of(context).primary,
                            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                              fontFamily: 'SF Pro Text',
                              color: FlutterFlowTheme.of(context).secondaryBackground,
                              letterSpacing: 0.0,
                            ),
                            elevation: 0.0,
                            borderSide: BorderSide(
                              color: Colors.transparent,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 