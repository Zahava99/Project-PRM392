// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ChatSessionStruct extends BaseStruct {
  ChatSessionStruct({
    String? sessionId,
    int? userId,
    String? sessionName,
    String? createdAt,
    String? updatedAt,
    bool? isActive,
    int? messageCount,
    String? lastMessage,
    String? lastMessageTime,
  })  : _sessionId = sessionId,
        _userId = userId,
        _sessionName = sessionName,
        _createdAt = createdAt,
        _updatedAt = updatedAt,
        _isActive = isActive,
        _messageCount = messageCount,
        _lastMessage = lastMessage,
        _lastMessageTime = lastMessageTime;

  // "sessionId" field.
  String? _sessionId;
  String get sessionId => _sessionId ?? '';
  set sessionId(String? val) => _sessionId = val;

  bool hasSessionId() => _sessionId != null;

  // "userId" field.
  int? _userId;
  int get userId => _userId ?? 0;
  set userId(int? val) => _userId = val;

  bool hasUserId() => _userId != null;

  // "sessionName" field.
  String? _sessionName;
  String get sessionName => _sessionName ?? '';
  set sessionName(String? val) => _sessionName = val;

  bool hasSessionName() => _sessionName != null;

  // "createdAt" field.
  String? _createdAt;
  String get createdAt => _createdAt ?? '';
  set createdAt(String? val) => _createdAt = val;

  bool hasCreatedAt() => _createdAt != null;

  // "updatedAt" field.
  String? _updatedAt;
  String get updatedAt => _updatedAt ?? '';
  set updatedAt(String? val) => _updatedAt = val;

  bool hasUpdatedAt() => _updatedAt != null;

  // "isActive" field.
  bool? _isActive;
  bool get isActive => _isActive ?? false;
  set isActive(bool? val) => _isActive = val;

  bool hasIsActive() => _isActive != null;

  // "messageCount" field.
  int? _messageCount;
  int get messageCount => _messageCount ?? 0;
  set messageCount(int? val) => _messageCount = val;

  bool hasMessageCount() => _messageCount != null;

  // "lastMessage" field.
  String? _lastMessage;
  String get lastMessage => _lastMessage ?? '';
  set lastMessage(String? val) => _lastMessage = val;

  bool hasLastMessage() => _lastMessage != null;

  // "lastMessageTime" field.
  String? _lastMessageTime;
  String get lastMessageTime => _lastMessageTime ?? '';
  set lastMessageTime(String? val) => _lastMessageTime = val;

  bool hasLastMessageTime() => _lastMessageTime != null;

  static ChatSessionStruct fromMap(Map<String, dynamic> data) => ChatSessionStruct(
        sessionId: data['sessionId'] as String?,
        userId: castToType<int>(data['userId']),
        sessionName: data['sessionName'] as String?,
        createdAt: data['createdAt'] as String?,
        updatedAt: data['updatedAt'] as String?,
        isActive: data['isActive'] as bool?,
        messageCount: castToType<int>(data['messageCount']),
        lastMessage: data['lastMessage'] as String?,
        lastMessageTime: data['lastMessageTime'] as String?,
      );

  static ChatSessionStruct? maybeFromMap(dynamic data) => data is Map
      ? ChatSessionStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'sessionId': _sessionId,
        'userId': _userId,
        'sessionName': _sessionName,
        'createdAt': _createdAt,
        'updatedAt': _updatedAt,
        'isActive': _isActive,
        'messageCount': _messageCount,
        'lastMessage': _lastMessage,
        'lastMessageTime': _lastMessageTime,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'sessionId': serializeParam(
          _sessionId,
          ParamType.String,
        ),
        'userId': serializeParam(
          _userId,
          ParamType.int,
        ),
        'sessionName': serializeParam(
          _sessionName,
          ParamType.String,
        ),
        'createdAt': serializeParam(
          _createdAt,
          ParamType.String,
        ),
        'updatedAt': serializeParam(
          _updatedAt,
          ParamType.String,
        ),
        'isActive': serializeParam(
          _isActive,
          ParamType.bool,
        ),
        'messageCount': serializeParam(
          _messageCount,
          ParamType.int,
        ),
        'lastMessage': serializeParam(
          _lastMessage,
          ParamType.String,
        ),
        'lastMessageTime': serializeParam(
          _lastMessageTime,
          ParamType.String,
        ),
      }.withoutNulls;

  static ChatSessionStruct fromSerializableMap(Map<String, dynamic> data) => ChatSessionStruct(
        sessionId: deserializeParam(
          data['sessionId'],
          ParamType.String,
          false,
        ),
        userId: deserializeParam(
          data['userId'],
          ParamType.int,
          false,
        ),
        sessionName: deserializeParam(
          data['sessionName'],
          ParamType.String,
          false,
        ),
        createdAt: deserializeParam(
          data['createdAt'],
          ParamType.String,
          false,
        ),
        updatedAt: deserializeParam(
          data['updatedAt'],
          ParamType.String,
          false,
        ),
        isActive: deserializeParam(
          data['isActive'],
          ParamType.bool,
          false,
        ),
        messageCount: deserializeParam(
          data['messageCount'],
          ParamType.int,
          false,
        ),
        lastMessage: deserializeParam(
          data['lastMessage'],
          ParamType.String,
          false,
        ),
        lastMessageTime: deserializeParam(
          data['lastMessageTime'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'ChatSessionStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ChatSessionStruct &&
        sessionId == other.sessionId &&
        userId == other.userId &&
        sessionName == other.sessionName &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        isActive == other.isActive &&
        messageCount == other.messageCount &&
        lastMessage == other.lastMessage &&
        lastMessageTime == other.lastMessageTime;
  }

  @override
  int get hashCode => const ListEquality().hash([
        sessionId,
        userId,
        sessionName,
        createdAt,
        updatedAt,
        isActive,
        messageCount,
        lastMessage,
        lastMessageTime
      ]);
}

ChatSessionStruct createChatSessionStruct({
  String? sessionId,
  int? userId,
  String? sessionName,
  String? createdAt,
  String? updatedAt,
  bool? isActive,
  int? messageCount,
  String? lastMessage,
  String? lastMessageTime,
}) =>
    ChatSessionStruct(
      sessionId: sessionId,
      userId: userId,
      sessionName: sessionName,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
      messageCount: messageCount,
      lastMessage: lastMessage,
      lastMessageTime: lastMessageTime,
    ); 