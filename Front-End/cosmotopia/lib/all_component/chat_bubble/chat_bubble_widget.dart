import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'chat_bubble_model.dart';
export 'chat_bubble_model.dart';

class ChatBubbleWidget extends StatefulWidget {
  const ChatBubbleWidget({
    super.key,
    this.initialPosition,
    this.isDraggable = true,
    this.size = 56.0,
    this.onTap,
  });

  final Offset? initialPosition;
  final bool isDraggable;
  final double size;
  final VoidCallback? onTap;

  @override
  State<ChatBubbleWidget> createState() => _ChatBubbleWidgetState();
}

class _ChatBubbleWidgetState extends State<ChatBubbleWidget>
    with TickerProviderStateMixin {
  late ChatBubbleModel _model;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChatBubbleModel());
    
    // Initialize position
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialPosition != null) {
        _model.position = widget.initialPosition!;
      } else {
        // Default position: bottom right with some margin
        final screenSize = MediaQuery.of(context).size;
        _model.position = Offset(
          screenSize.width - widget.size - 20,
          screenSize.height - widget.size - 100,
        );
      }
      setState(() {});
    });

    // Animation setup
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _model.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.isDraggable) return;
    
    setState(() {
      _model.position = Offset(
        _model.position.dx + details.delta.dx,
        _model.position.dy + details.delta.dy,
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.isDraggable) return;
    
    // Snap to edges if close enough
    final screenSize = MediaQuery.of(context).size;
    final threshold = 50.0;
    
    setState(() {
      double newX = _model.position.dx;
      double newY = _model.position.dy;
      
      // Snap to left or right edge
      if (_model.position.dx < threshold) {
        newX = 20.0;
      } else if (_model.position.dx > screenSize.width - widget.size - threshold) {
        newX = screenSize.width - widget.size - 20.0;
      }
      
      // Keep within screen bounds
      newX = newX.clamp(20.0, screenSize.width - widget.size - 20.0);
      newY = newY.clamp(50.0, screenSize.height - widget.size - 100.0);
      
      _model.position = Offset(newX, newY);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _model.position.dx,
      top: _model.position.dy,
      child: GestureDetector(
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        onTap: () {
          // Add tap animation
          _animationController.forward().then((_) {
            _animationController.reverse();
          });
          
          // Execute callback or default navigation
          if (widget.onTap != null) {
            widget.onTap!();
          } else {
            context.pushNamed(ChatPageWidget.routeName);
          }
        },
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: FlutterFlowTheme.of(context).primary.withOpacity(0.3),
                      blurRadius: 12.0,
                      spreadRadius: 2.0,
                      offset: Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8.0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Main icon
                    Center(
                      child: Icon(
                        Icons.smart_toy,
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        size: widget.size * 0.5,
                      ),
                    ),
                    // Pulse effect
                    if (_model.showPulse)
                      Positioned.fill(
                        child: Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: FlutterFlowTheme.of(context).primary.withOpacity(0.5),
                                width: 2.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    // Notification badge (optional)
                    if (_model.hasNotification)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 16.0,
                          height: 16.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).error,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: FlutterFlowTheme.of(context).secondaryBackground,
                              width: 2.0,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '!',
                              style: TextStyle(
                                color: FlutterFlowTheme.of(context).secondaryBackground,
                                fontSize: 10.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
} 