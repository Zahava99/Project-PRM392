// ignore_for_file: unnecessary_getters_setters

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class RecommendedProductStruct extends BaseStruct {
  RecommendedProductStruct({
    ProductStruct? product,
    String? reason,
    int? matchScore,
  })  : _product = product,
        _reason = reason,
        _matchScore = matchScore;

  // "product" field.
  ProductStruct? _product;
  ProductStruct get product => _product ?? ProductStruct();
  set product(ProductStruct? val) => _product = val;
  bool hasProduct() => _product != null;

  // "reason" field.
  String? _reason;
  String get reason => _reason ?? '';
  set reason(String? val) => _reason = val;
  bool hasReason() => _reason != null;

  // "matchScore" field.
  int? _matchScore;
  int get matchScore => _matchScore ?? 0;
  set matchScore(int? val) => _matchScore = val;
  void incrementMatchScore(int amount) => matchScore = matchScore + amount;
  bool hasMatchScore() => _matchScore != null;

  static RecommendedProductStruct fromMap(Map<String, dynamic> data) => RecommendedProductStruct(
        product: ProductStruct.maybeFromMap(data['product']),
        reason: data['reason'] as String?,
        matchScore: castToType<int>(data['matchScore']),
      );

  static RecommendedProductStruct? maybeFromMap(dynamic data) =>
      data is Map ? RecommendedProductStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'product': _product?.toMap(),
        'reason': _reason,
        'matchScore': _matchScore,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'product': serializeParam(
          _product,
          ParamType.DataStruct,
        ),
        'reason': serializeParam(
          _reason,
          ParamType.String,
        ),
        'matchScore': serializeParam(
          _matchScore,
          ParamType.int,
        ),
      }.withoutNulls;

  static RecommendedProductStruct fromSerializableMap(Map<String, dynamic> data) =>
      RecommendedProductStruct(
        product: deserializeStructParam(
          data['product'],
          ParamType.DataStruct,
          false,
          structBuilder: ProductStruct.fromSerializableMap,
        ),
        reason: deserializeParam(
          data['reason'],
          ParamType.String,
          false,
        ),
        matchScore: deserializeParam(
          data['matchScore'],
          ParamType.int,
          false,
        ),
      );

  @override
  String toString() => 'RecommendedProductStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is RecommendedProductStruct &&
        product == other.product &&
        reason == other.reason &&
        matchScore == other.matchScore;
  }

  @override
  int get hashCode => const ListEquality().hash([
        product,
        reason,
        matchScore,
      ]);
}

RecommendedProductStruct createRecommendedProductStruct({
  ProductStruct? product,
  String? reason,
  int? matchScore,
}) =>
    RecommendedProductStruct(
      product: product,
      reason: reason,
      matchScore: matchScore,
    ); 