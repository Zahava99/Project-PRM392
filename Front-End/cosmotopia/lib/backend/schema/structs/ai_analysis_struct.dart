// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class AiAnalysisStruct extends BaseStruct {
  AiAnalysisStruct({
    String? skinTone,
    String? skinType,
    String? faceShape,
    List<String>? recommendations,
  })  : _skinTone = skinTone,
        _skinType = skinType,
        _faceShape = faceShape,
        _recommendations = recommendations;

  // "skinTone" field.
  String? _skinTone;
  String get skinTone => _skinTone ?? '';
  set skinTone(String? val) => _skinTone = val;
  bool hasSkinTone() => _skinTone != null;

  // "skinType" field.
  String? _skinType;
  String get skinType => _skinType ?? '';
  set skinType(String? val) => _skinType = val;
  bool hasSkinType() => _skinType != null;

  // "faceShape" field.
  String? _faceShape;
  String get faceShape => _faceShape ?? '';
  set faceShape(String? val) => _faceShape = val;
  bool hasFaceShape() => _faceShape != null;

  // "recommendations" field.
  List<String>? _recommendations;
  List<String> get recommendations => _recommendations ?? [];
  set recommendations(List<String>? val) => _recommendations = val;
  bool hasRecommendations() => _recommendations != null;

  static AiAnalysisStruct fromMap(Map<String, dynamic> data) => AiAnalysisStruct(
        skinTone: data['skinTone'] as String?,
        skinType: data['skinType'] as String?,
        faceShape: data['faceShape'] as String?,
        recommendations: (data['recommendations'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );

  static AiAnalysisStruct? maybeFromMap(dynamic data) =>
      data is Map ? AiAnalysisStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'skinTone': _skinTone,
        'skinType': _skinType,
        'faceShape': _faceShape,
        'recommendations': _recommendations,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'skinTone': serializeParam(
          _skinTone,
          ParamType.String,
        ),
        'skinType': serializeParam(
          _skinType,
          ParamType.String,
        ),
        'faceShape': serializeParam(
          _faceShape,
          ParamType.String,
        ),
        'recommendations': serializeParam(
          _recommendations,
          ParamType.String,
        ),
      }.withoutNulls;

  static AiAnalysisStruct fromSerializableMap(Map<String, dynamic> data) =>
      AiAnalysisStruct(
        skinTone: deserializeParam(
          data['skinTone'],
          ParamType.String,
          false,
        ),
        skinType: deserializeParam(
          data['skinType'],
          ParamType.String,
          false,
        ),
        faceShape: deserializeParam(
          data['faceShape'],
          ParamType.String,
          false,
        ),
        recommendations: deserializeParam(
          data['recommendations'],
          ParamType.String,
          true,
        ),
      );

  @override
  String toString() => 'AiAnalysisStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is AiAnalysisStruct &&
        skinTone == other.skinTone &&
        skinType == other.skinType &&
        faceShape == other.faceShape &&
        recommendations == other.recommendations;
  }

  @override
  int get hashCode => const ListEquality().hash([
        skinTone,
        skinType,
        faceShape,
        recommendations,
      ]);
}

AiAnalysisStruct createAiAnalysisStruct({
  String? skinTone,
  String? skinType,
  String? faceShape,
  List<String>? recommendations,
}) =>
    AiAnalysisStruct(
      skinTone: skinTone,
      skinType: skinType,
      faceShape: faceShape,
      recommendations: recommendations,
    ); 