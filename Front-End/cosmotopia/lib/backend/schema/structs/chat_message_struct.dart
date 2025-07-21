// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ChatMessageStruct extends BaseStruct {
  ChatMessageStruct({
    String? messageId,
    String? sessionId,
    String? content,
    bool? isFromUser,
    String? sentAt,
    List<String>? recommendedProductIds,
  })  : _messageId = messageId,
        _sessionId = sessionId,
        _content = content,
        _isFromUser = isFromUser,
        _sentAt = sentAt,
        _recommendedProductIds = recommendedProductIds;

  // "messageId" field.
  String? _messageId;
  String get messageId => _messageId ?? '';
  set messageId(String? val) => _messageId = val;

  bool hasMessageId() => _messageId != null;

  // "sessionId" field.
  String? _sessionId;
  String get sessionId => _sessionId ?? '';
  set sessionId(String? val) => _sessionId = val;

  bool hasSessionId() => _sessionId != null;

  // "content" field.
  String? _content;
  String get content => _content ?? '';
  set content(String? val) => _content = val;

  bool hasContent() => _content != null;

  // "isFromUser" field.
  bool? _isFromUser;
  bool get isFromUser => _isFromUser ?? false;
  set isFromUser(bool? val) => _isFromUser = val;

  bool hasIsFromUser() => _isFromUser != null;

  // "sentAt" field.
  String? _sentAt;
  String get sentAt => _sentAt ?? '';
  set sentAt(String? val) => _sentAt = val;

  bool hasSentAt() => _sentAt != null;

  // "recommendedProductIds" field.
  List<String>? _recommendedProductIds;
  List<String> get recommendedProductIds => _recommendedProductIds ?? const [];
  set recommendedProductIds(List<String>? val) => _recommendedProductIds = val;

  void updateRecommendedProductIds(Function(List<String>) updateFn) {
    updateFn(_recommendedProductIds ??= []);
  }

  bool hasRecommendedProductIds() => _recommendedProductIds != null;

  static ChatMessageStruct fromMap(Map<String, dynamic> data) => ChatMessageStruct(
        messageId: data['messageId'] as String?,
        sessionId: data['sessionId'] as String?,
        content: data['content'] as String?,
        isFromUser: data['isFromUser'] as bool?,
        sentAt: data['sentAt'] as String?,
        recommendedProductIds: getDataList(data['recommendedProductIds']),
      );

  static ChatMessageStruct? maybeFromMap(dynamic data) => data is Map
      ? ChatMessageStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'messageId': _messageId,
        'sessionId': _sessionId,
        'content': _content,
        'isFromUser': _isFromUser,
        'sentAt': _sentAt,
        'recommendedProductIds': _recommendedProductIds,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'messageId': serializeParam(
          _messageId,
          ParamType.String,
        ),
        'sessionId': serializeParam(
          _sessionId,
          ParamType.String,
        ),
        'content': serializeParam(
          _content,
          ParamType.String,
        ),
        'isFromUser': serializeParam(
          _isFromUser,
          ParamType.bool,
        ),
        'sentAt': serializeParam(
          _sentAt,
          ParamType.String,
        ),
        'recommendedProductIds': serializeParam(
          _recommendedProductIds,
          ParamType.String,
          isList: true,
        ),
      }.withoutNulls;

  static ChatMessageStruct fromSerializableMap(Map<String, dynamic> data) => ChatMessageStruct(
        messageId: deserializeParam(
          data['messageId'],
          ParamType.String,
          false,
        ),
        sessionId: deserializeParam(
          data['sessionId'],
          ParamType.String,
          false,
        ),
        content: deserializeParam(
          data['content'],
          ParamType.String,
          false,
        ),
        isFromUser: deserializeParam(
          data['isFromUser'],
          ParamType.bool,
          false,
        ),
        sentAt: deserializeParam(
          data['sentAt'],
          ParamType.String,
          false,
        ),
        recommendedProductIds: deserializeParam<String>(
          data['recommendedProductIds'],
          ParamType.String,
          true,
        ),
      );

  @override
  String toString() => 'ChatMessageStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is ChatMessageStruct &&
        messageId == other.messageId &&
        sessionId == other.sessionId &&
        content == other.content &&
        isFromUser == other.isFromUser &&
        sentAt == other.sentAt &&
        listEquality.equals(recommendedProductIds, other.recommendedProductIds);
  }

  @override
  int get hashCode => const ListEquality().hash([
        messageId,
        sessionId,
        content,
        isFromUser,
        sentAt,
        recommendedProductIds
      ]);
}

ChatMessageStruct createChatMessageStruct({
  String? messageId,
  String? sessionId,
  String? content,
  bool? isFromUser,
  String? sentAt,
  List<String>? recommendedProductIds,
}) =>
    ChatMessageStruct(
      messageId: messageId,
      sessionId: sessionId,
      content: content,
      isFromUser: isFromUser,
      sentAt: sentAt,
      recommendedProductIds: recommendedProductIds,
    ); 