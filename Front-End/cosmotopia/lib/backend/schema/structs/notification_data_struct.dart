// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class NotificationDataStruct extends BaseStruct {
  NotificationDataStruct({
    String? image,
    String? titile,
    String? message,
    String? time,
  })  : _image = image,
        _titile = titile,
        _message = message,
        _time = time;

  // "image" field.
  String? _image;
  String get image => _image ?? '';
  set image(String? val) => _image = val;

  bool hasImage() => _image != null;

  // "titile" field.
  String? _titile;
  String get titile => _titile ?? '';
  set titile(String? val) => _titile = val;

  bool hasTitile() => _titile != null;

  // "message" field.
  String? _message;
  String get message => _message ?? '';
  set message(String? val) => _message = val;

  bool hasMessage() => _message != null;

  // "time" field.
  String? _time;
  String get time => _time ?? '';
  set time(String? val) => _time = val;

  bool hasTime() => _time != null;

  static NotificationDataStruct fromMap(Map<String, dynamic> data) =>
      NotificationDataStruct(
        image: data['image'] as String?,
        titile: data['titile'] as String?,
        message: data['message'] as String?,
        time: data['time'] as String?,
      );

  static NotificationDataStruct? maybeFromMap(dynamic data) => data is Map
      ? NotificationDataStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'image': _image,
        'titile': _titile,
        'message': _message,
        'time': _time,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'image': serializeParam(
          _image,
          ParamType.String,
        ),
        'titile': serializeParam(
          _titile,
          ParamType.String,
        ),
        'message': serializeParam(
          _message,
          ParamType.String,
        ),
        'time': serializeParam(
          _time,
          ParamType.String,
        ),
      }.withoutNulls;

  static NotificationDataStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      NotificationDataStruct(
        image: deserializeParam(
          data['image'],
          ParamType.String,
          false,
        ),
        titile: deserializeParam(
          data['titile'],
          ParamType.String,
          false,
        ),
        message: deserializeParam(
          data['message'],
          ParamType.String,
          false,
        ),
        time: deserializeParam(
          data['time'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'NotificationDataStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is NotificationDataStruct &&
        image == other.image &&
        titile == other.titile &&
        message == other.message &&
        time == other.time;
  }

  @override
  int get hashCode => const ListEquality().hash([image, titile, message, time]);
}

NotificationDataStruct createNotificationDataStruct({
  String? image,
  String? titile,
  String? message,
  String? time,
}) =>
    NotificationDataStruct(
      image: image,
      titile: titile,
      message: message,
      time: time,
    );
