import '/flutter_flow/flutter_flow_util.dart';
import 'chat_bubble_widget.dart' show ChatBubbleWidget;
import 'package:flutter/material.dart';

class ChatBubbleModel extends FlutterFlowModel<ChatBubbleWidget> {
  ///  Local state fields for this component.
  Offset position = Offset(0, 0);
  bool showPulse = true;
  bool hasNotification = false;
  bool isDragging = false;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  void updatePosition(Offset newPosition) {
    position = newPosition;
  }

  void togglePulse() {
    showPulse = !showPulse;
  }

  void setNotification(bool hasNotif) {
    hasNotification = hasNotif;
  }

  void setDragging(bool dragging) {
    isDragging = dragging;
  }
} 