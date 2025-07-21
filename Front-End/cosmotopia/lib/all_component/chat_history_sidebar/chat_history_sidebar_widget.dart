import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/backend/schema/structs/index.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math; // ✅ IMPORT MATH
import 'chat_history_sidebar_model.dart';
export 'chat_history_sidebar_model.dart';

class ChatHistorySidebarWidget extends StatefulWidget {
  const ChatHistorySidebarWidget({
    super.key,
    required this.sessions,
    required this.currentSessionId,
    this.onSessionSelected,
    this.onNewSession,
    this.onDeleteSession,
    this.isLoading = false,
  });

  final List<ChatSessionStruct> sessions;
  final String? currentSessionId;
  final Function(String sessionId)? onSessionSelected;
  final VoidCallback? onNewSession;
  final Function(String sessionId)? onDeleteSession;
  final bool isLoading;

  @override
  State<ChatHistorySidebarWidget> createState() => _ChatHistorySidebarWidgetState();
}

class _ChatHistorySidebarWidgetState extends State<ChatHistorySidebarWidget> {
  late ChatHistorySidebarModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChatHistorySidebarModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ RESPONSIVE WIDTH - TỐI ĐA 70% SCREEN WIDTH HOẶC 280PX
    final screenWidth = MediaQuery.of(context).size.width;
    final sidebarWidth = math.min(280.0, screenWidth * 0.7);
    
    return Container(
      width: sidebarWidth,
      height: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(0),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Header
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primaryBackground,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
                topLeft: Radius.circular(0),
                topRight: Radius.circular(0),
              ),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chat History',
                    style: FlutterFlowTheme.of(context).headlineSmall.override(
                          fontFamily: 'Outfit',
                          letterSpacing: 0,
                        ),
                  ),
                  FFButtonWidget(
                    onPressed: widget.onNewSession,
                    text: '',
                    icon: Icon(
                      Icons.add,
                      size: 20,
                    ),
                    options: FFButtonOptions(
                      width: 40,
                      height: 40,
                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                      iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                            fontFamily: 'Readex Pro',
                            color: Colors.white,
                            letterSpacing: 0,
                          ),
                      elevation: 2,
                      borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Sessions List
          Expanded(
            child: widget.isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                  )
                : widget.sessions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 48,
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No chat history yet',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Readex Pro',
                                    color: FlutterFlowTheme.of(context).secondaryText,
                                    letterSpacing: 0,
                                  ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Start a conversation to see your chat history here',
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                    fontFamily: 'Readex Pro',
                                    color: FlutterFlowTheme.of(context).secondaryText,
                                    letterSpacing: 0,
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                        itemCount: widget.sessions.length,
                        itemBuilder: (context, index) {
                          final session = widget.sessions[index];
                          final isCurrentSession = session.sessionId == widget.currentSessionId;
                          
                          return Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 8),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isCurrentSession
                                    ? FlutterFlowTheme.of(context).accent1
                                    : FlutterFlowTheme.of(context).secondaryBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isCurrentSession
                                      ? FlutterFlowTheme.of(context).primary
                                      : FlutterFlowTheme.of(context).alternate,
                                  width: 1,
                                ),
                              ),
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () => widget.onSessionSelected?.call(session.sessionId),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              session.sessionName.isNotEmpty 
                                                  ? session.sessionName 
                                                  : 'Chat Session',
                                              style: FlutterFlowTheme.of(context).bodyLarge.override(
                                                    fontFamily: 'Readex Pro',
                                                    color: isCurrentSession
                                                        ? FlutterFlowTheme.of(context).primary
                                                        : FlutterFlowTheme.of(context).primaryText,
                                                    letterSpacing: 0,
                                                    fontWeight: isCurrentSession 
                                                        ? FontWeight.w600 
                                                        : FontWeight.normal,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 4),
                                            if (session.lastMessage.isNotEmpty)
                                              Text(
                                                session.lastMessage,
                                                style: FlutterFlowTheme.of(context).bodySmall.override(
                                                      fontFamily: 'Readex Pro',
                                                      color: FlutterFlowTheme.of(context).secondaryText,
                                                      letterSpacing: 0,
                                                    ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            SizedBox(height: 4),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  '${session.messageCount} messages',
                                                  style: FlutterFlowTheme.of(context).bodySmall.override(
                                                        fontFamily: 'Readex Pro',
                                                        color: FlutterFlowTheme.of(context).secondaryText,
                                                        letterSpacing: 0,
                                                        fontSize: 12,
                                                      ),
                                                ),
                                                if (session.lastMessageTime.isNotEmpty)
                                                  Text(
                                                    _formatTime(session.lastMessageTime),
                                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                                          fontFamily: 'Readex Pro',
                                                          color: FlutterFlowTheme.of(context).secondaryText,
                                                          letterSpacing: 0,
                                                          fontSize: 12,
                                                        ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (!isCurrentSession)
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () => widget.onDeleteSession?.call(session.sessionId),
                                          child: Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: Icon(
                                              Icons.delete_outline,
                                              color: FlutterFlowTheme.of(context).error,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String timeString) {
    try {
      // Debug logging
      print('🕐 DEBUG _formatTime - Raw timeString: $timeString');
      
      // Parse as UTC time and convert to local
      final utcDateTime = DateTime.parse(timeString).toUtc();
      final localDateTime = utcDateTime.toLocal();
      final now = DateTime.now();
      final difference = now.difference(localDateTime);
      
      print('🕐 DEBUG _formatTime - UTC: ${utcDateTime.toString()}');
      print('🕐 DEBUG _formatTime - Local: ${localDateTime.toString()}');
      print('🕐 DEBUG _formatTime - Now: ${now.toString()}');
      print('🕐 DEBUG _formatTime - Difference: ${difference.inMinutes} minutes');

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      print('❌ DEBUG _formatTime - Error: $e');
      return '';
    }
  }
} 