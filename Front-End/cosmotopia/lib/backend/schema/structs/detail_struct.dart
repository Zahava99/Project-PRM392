// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class DetailStruct extends BaseStruct {
  DetailStruct({
    String? productId,
    int? prid,
    int? id,
    String? image,
    String? title,
    String? price,
    String? catetype,
    String? stockQuantity,
    bool? isFav,
    bool? isJust,
    bool? isNew,
    bool? isCart,
    bool? isColor,
    String? isResult,
    bool? itsResult,
    String? description,
    String? brandName,
  })  : _productId = productId,
        _prid = prid,
        _id = id,
        _image = image,
        _title = title,
        _price = price,
        _catetype = catetype,
        _stockQuantity = stockQuantity,
        _isFav = isFav,
        _isJust = isJust,
        _isNew = isNew,
        _isCart = isCart,
        _isColor = isColor,
        _isResult = isResult,
        _itsResult = itsResult,
        _description = description,
        _brandName = brandName;

  // "productId" field.
  String? _productId;
  String get productId => _productId ?? '';
  set productId(String? val) => _productId = val;
  bool hasProductId() => _productId != null;

  // "prid" field.
  int? _prid;
  int get prid => _prid ?? 0;
  set prid(int? val) => _prid = val;

  void incrementPrid(int amount) => prid = prid + amount;

  bool hasPrid() => _prid != null;

  // "id" field.
  int? _id;
  int get id => _id ?? 0;
  set id(int? val) => _id = val;

  void incrementId(int amount) => id = id + amount;

  bool hasId() => _id != null;

  // "image" field.
  String? _image;
  String get image => _image ?? '';
  set image(String? val) => _image = val;

  bool hasImage() => _image != null;

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  set title(String? val) => _title = val;

  bool hasTitle() => _title != null;

  // "price" field.
  String? _price;
  String get price => _price ?? '';
  set price(String? val) => _price = val;

  bool hasPrice() => _price != null;

  // "catetype" field.
  String? _catetype;
  String get catetype => _catetype ?? '';
  set catetype(String? val) => _catetype = val;

  bool hasCatetype() => _catetype != null;

  // "stockQuantity" field.
  String? _stockQuantity;
  String get stockQuantity => _stockQuantity ?? '';
  set stockQuantity(String? val) => _stockQuantity = val;
  bool hasStockQuantity() => _stockQuantity != null;

  // "is_fav" field.
  bool? _isFav;
  bool get isFav => _isFav ?? false;
  set isFav(bool? val) => _isFav = val;

  bool hasIsFav() => _isFav != null;

  // "is_just" field.
  bool? _isJust;
  bool get isJust => _isJust ?? false;
  set isJust(bool? val) => _isJust = val;

  bool hasIsJust() => _isJust != null;

  // "is_new" field.
  bool? _isNew;
  bool get isNew => _isNew ?? false;
  set isNew(bool? val) => _isNew = val;

  bool hasIsNew() => _isNew != null;

  // "is_cart" field.
  bool? _isCart;
  bool get isCart => _isCart ?? false;
  set isCart(bool? val) => _isCart = val;

  bool hasIsCart() => _isCart != null;

  // "is_color" field.
  bool? _isColor;
  bool get isColor => _isColor ?? false;
  set isColor(bool? val) => _isColor = val;

  bool hasIsColor() => _isColor != null;

  // "is_result" field.
  String? _isResult;
  String get isResult => _isResult ?? '';
  set isResult(String? val) => _isResult = val;

  bool hasIsResult() => _isResult != null;

  // "its_result" field.
  bool? _itsResult;
  bool get itsResult => _itsResult ?? false;
  set itsResult(bool? val) => _itsResult = val;

  bool hasItsResult() => _itsResult != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  set description(String? val) => _description = val;
  bool hasDescription() => _description != null;

  // "brandName" field.
  String? _brandName;
  String get brandName => _brandName ?? '';
  set brandName(String? val) => _brandName = val;
  bool hasBrandName() => _brandName != null;

  static DetailStruct fromMap(Map<String, dynamic> data) => DetailStruct(
        productId: data['productId'] as String?,
        prid: castToType<int>(data['prid']),
        id: castToType<int>(data['id']),
        image: data['image'] as String?,
        title: data['title'] as String?,
        price: data['price'] as String?,
        catetype: data['catetype'] as String?,
        stockQuantity: data['stockQuantity'] as String?,
        isFav: data['is_fav'] as bool?,
        isJust: data['is_just'] as bool?,
        isNew: data['is_new'] as bool?,
        isCart: data['is_cart'] as bool?,
        isColor: data['is_color'] as bool?,
        isResult: data['is_result'] as String?,
        itsResult: data['its_result'] as bool?,
        description: data['description'] as String?,
        brandName: data['brandName'] as String?,
      );

  static DetailStruct? maybeFromMap(dynamic data) =>
      data is Map ? DetailStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'productId': _productId,
        'prid': _prid,
        'id': _id,
        'image': _image,
        'title': _title,
        'price': _price,
        'catetype': _catetype,
        'stockQuantity': _stockQuantity,
        'is_fav': _isFav,
        'is_just': _isJust,
        'is_new': _isNew,
        'is_cart': _isCart,
        'is_color': _isColor,
        'is_result': _isResult,
        'its_result': _itsResult,
        'description': _description,
        'brandName': _brandName,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'productId': serializeParam(
          _productId,
          ParamType.String,
        ),
        'prid': serializeParam(
          _prid,
          ParamType.int,
        ),
        'id': serializeParam(
          _id,
          ParamType.int,
        ),
        'image': serializeParam(
          _image,
          ParamType.String,
        ),
        'title': serializeParam(
          _title,
          ParamType.String,
        ),
        'price': serializeParam(
          _price,
          ParamType.String,
        ),
        'catetype': serializeParam(
          _catetype,
          ParamType.String,
        ),
        'stockQuantity': serializeParam(
          _stockQuantity,
          ParamType.String,
        ),
        'is_fav': serializeParam(
          _isFav,
          ParamType.bool,
        ),
        'is_just': serializeParam(
          _isJust,
          ParamType.bool,
        ),
        'is_new': serializeParam(
          _isNew,
          ParamType.bool,
        ),
        'is_cart': serializeParam(
          _isCart,
          ParamType.bool,
        ),
        'is_color': serializeParam(
          _isColor,
          ParamType.bool,
        ),
        'is_result': serializeParam(
          _isResult,
          ParamType.String,
        ),
        'its_result': serializeParam(
          _itsResult,
          ParamType.bool,
        ),
        'description': serializeParam(
          _description,
          ParamType.String,
        ),
        'brandName': serializeParam(
          _brandName,
          ParamType.String,
        ),
      }.withoutNulls;

  static DetailStruct fromSerializableMap(Map<String, dynamic> data) =>
      DetailStruct(
        productId: deserializeParam(
          data['productId'],
          ParamType.String,
          false,
        ),
        prid: deserializeParam(
          data['prid'],
          ParamType.int,
          false,
        ),
        id: deserializeParam(
          data['id'],
          ParamType.int,
          false,
        ),
        image: deserializeParam(
          data['image'],
          ParamType.String,
          false,
        ),
        title: deserializeParam(
          data['title'],
          ParamType.String,
          false,
        ),
        price: deserializeParam(
          data['price'],
          ParamType.String,
          false,
        ),
        catetype: deserializeParam(
          data['catetype'],
          ParamType.String,
          false,
        ),
        stockQuantity: deserializeParam(
          data['stockQuantity'],
          ParamType.String,
          false,
        ),
        isFav: deserializeParam(
          data['is_fav'],
          ParamType.bool,
          false,
        ),
        isJust: deserializeParam(
          data['is_just'],
          ParamType.bool,
          false,
        ),
        isNew: deserializeParam(
          data['is_new'],
          ParamType.bool,
          false,
        ),
        isCart: deserializeParam(
          data['is_cart'],
          ParamType.bool,
          false,
        ),
        isColor: deserializeParam(
          data['is_color'],
          ParamType.bool,
          false,
        ),
        isResult: deserializeParam(
          data['is_result'],
          ParamType.String,
          false,
        ),
        itsResult: deserializeParam(
          data['its_result'],
          ParamType.bool,
          false,
        ),
        description: deserializeParam(
          data['description'],
          ParamType.String,
          false,
        ),
        brandName: deserializeParam(
          data['brandName'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'DetailStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is DetailStruct &&
        productId == other.productId &&
        prid == other.prid &&
        id == other.id &&
        image == other.image &&
        title == other.title &&
        price == other.price &&
        catetype == other.catetype &&
        stockQuantity == other.stockQuantity &&
        isFav == other.isFav &&
        isJust == other.isJust &&
        isNew == other.isNew &&
        isCart == other.isCart &&
        isColor == other.isColor &&
        isResult == other.isResult &&
        itsResult == other.itsResult &&
        description == other.description &&
        brandName == other.brandName;
  }

  @override
  int get hashCode => const ListEquality().hash([
        productId,
        prid,
        id,
        image,
        title,
        price,
        catetype,
        stockQuantity,
        isFav,
        isJust,
        isNew,
        isCart,
        isColor,
        isResult,
        itsResult,
        description,
        brandName
      ]);
}

DetailStruct createDetailStruct({
  String? productId,
  int? prid,
  int? id,
  String? image,
  String? title,
  String? price,
  String? catetype,
  String? stockQuantity,
  bool? isFav,
  bool? isJust,
  bool? isNew,
  bool? isCart,
  bool? isColor,
  String? isResult,
  bool? itsResult,
  String? description,
  String? brandName,
}) =>
    DetailStruct(
      productId: productId,
      prid: prid,
      id: id,
      image: image,
      title: title,
      price: price,
      catetype: catetype,
      stockQuantity: stockQuantity,
      isFav: isFav,
      isJust: isJust,
      isNew: isNew,
      isCart: isCart,
      isColor: isColor,
      isResult: isResult,
      itsResult: itsResult,
      description: description,
      brandName: brandName,
    );
