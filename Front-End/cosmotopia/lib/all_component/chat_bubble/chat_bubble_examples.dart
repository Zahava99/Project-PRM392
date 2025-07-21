import '/flutter_flow/flutter_flow_theme.dart';
import '/all_component/chat_bubble/chat_bubble_widget.dart';
import 'package:flutter/material.dart';

/// Examples of how to use ChatBubbleWidget with different configurations
class ChatBubbleExamples {
  
  /// Example 1: Default draggable bubble (bottom right)
  static Widget defaultBubble() {
    return ChatBubbleWidget(
      isDraggable: true,
      size: 60.0,
      onTap: () {
        // Handle tap
      },
    );
  }

  /// Example 2: Fixed position bubble (top right)
  static Widget topRightBubble(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return ChatBubbleWidget(
      initialPosition: Offset(screenSize.width - 80, 100),
      isDraggable: false,
      size: 50.0,
      onTap: () {
        // Handle tap
      },
    );
  }

  /// Example 3: Bottom left bubble
  static Widget bottomLeftBubble() {
    return ChatBubbleWidget(
      initialPosition: Offset(20, 600),
      isDraggable: true,
      size: 55.0,
      onTap: () {
        // Handle tap
      },
    );
  }

  /// Example 4: Center bubble (not draggable)
  static Widget centerBubble(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return ChatBubbleWidget(
      initialPosition: Offset(
        screenSize.width / 2 - 30,
        screenSize.height / 2 - 30,
      ),
      isDraggable: false,
      size: 60.0,
      onTap: () {
        // Handle tap
      },
    );
  }

  /// Example 5: Small bubble for compact layouts
  static Widget smallBubble() {
    return ChatBubbleWidget(
      initialPosition: Offset(300, 200),
      isDraggable: true,
      size: 40.0,
      onTap: () {
        // Handle tap
      },
    );
  }

  /// Example 6: Large bubble for emphasis
  static Widget largeBubble() {
    return ChatBubbleWidget(
      initialPosition: Offset(50, 300),
      isDraggable: true,
      size: 80.0,
      onTap: () {
        // Handle tap
      },
    );
  }

  /// Example usage in a Stack widget
  static Widget examplePage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Bubble Examples'),
        backgroundColor: FlutterFlowTheme.of(context).primary,
      ),
      body: Stack(
        children: [
          // Your main content here
          Container(
            width: double.infinity,
            height: double.infinity,
            color: FlutterFlowTheme.of(context).secondaryBackground,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Chat Bubble Examples',
                    style: FlutterFlowTheme.of(context).headlineMedium,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Try dragging the bubbles around!',
                    style: FlutterFlowTheme.of(context).bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          
          // Multiple chat bubbles with different configurations
          defaultBubble(),
          topRightBubble(context),
          smallBubble(),
          
          // You can add more bubbles as needed
        ],
      ),
    );
  }
}

/// Predefined positions for common use cases
class ChatBubblePositions {
  static Offset topLeft(double margin) => Offset(margin, margin + 50);
  static Offset topRight(BuildContext context, double margin) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Offset(screenWidth - 60 - margin, margin + 50);
  }
  static Offset bottomLeft(BuildContext context, double margin) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Offset(margin, screenHeight - 60 - margin - 100);
  }
  static Offset bottomRight(BuildContext context, double margin) {
    final screenSize = MediaQuery.of(context).size;
    return Offset(
      screenSize.width - 60 - margin,
      screenSize.height - 60 - margin - 100,
    );
  }
  static Offset center(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Offset(
      screenSize.width / 2 - 30,
      screenSize.height / 2 - 30,
    );
  }
} 