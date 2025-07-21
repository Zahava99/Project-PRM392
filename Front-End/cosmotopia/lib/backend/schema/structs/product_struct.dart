// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ProductStruct extends BaseStruct {
  ProductStruct({
    String? productId,
    String? name,
    String? description,
    int? price,
    List<String>? imageUrls,
    int? stockQuantity,
    int? commissionRate,
    String? categoryId,
    String? brandId,
    String? createAt,
    String? updatedAt,
    bool? isActive,
    Map<String, dynamic>? category,
    Map<String, dynamic>? brand,
  })  : _productId = productId,
        _name = name,
        _description = description,
        _price = price,
        _imageUrls = imageUrls,
        _stockQuantity = stockQuantity,
        _commissionRate = commissionRate,
        _categoryId = categoryId,
        _brandId = brandId,
        _createAt = createAt,
        _updatedAt = updatedAt,
        _isActive = isActive,
        _category = category,
        _brand = brand;

  // "productId" field.
  String? _productId;
  String get productId => _productId ?? '';
  set productId(String? val) => _productId = val;

  bool hasProductId() => _productId != null;

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  set name(String? val) => _name = val;

  bool hasName() => _name != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  set description(String? val) => _description = val;

  bool hasDescription() => _description != null;

  // "price" field.
  int? _price;
  int get price => _price ?? 0;
  set price(int? val) => _price = val;

  void incrementPrice(int amount) => price = price + amount;

  bool hasPrice() => _price != null;

  // "imageUrls" field.
  List<String>? _imageUrls;
  List<String> get imageUrls => _imageUrls ?? [];
  set imageUrls(List<String>? val) => _imageUrls = val;

  bool hasImageUrls() => _imageUrls != null;

  // "stockQuantity" field.
  int? _stockQuantity;
  int get stockQuantity => _stockQuantity ?? 0;
  set stockQuantity(int? val) => _stockQuantity = val;

  void incrementStockQuantity(int amount) => stockQuantity = stockQuantity + amount;

  bool hasStockQuantity() => _stockQuantity != null;

  // "commissionRate" field.
  int? _commissionRate;
  int get commissionRate => _commissionRate ?? 0;
  set commissionRate(int? val) => _commissionRate = val;

  void incrementCommissionRate(int amount) => commissionRate = commissionRate + amount;

  bool hasCommissionRate() => _commissionRate != null;

  // "categoryId" field.
  String? _categoryId;
  String get categoryId => _categoryId ?? '';
  set categoryId(String? val) => _categoryId = val;

  bool hasCategoryId() => _categoryId != null;

  // "brandId" field.
  String? _brandId;
  String get brandId => _brandId ?? '';
  set brandId(String? val) => _brandId = val;

  bool hasBrandId() => _brandId != null;

  // "createAt" field.
  String? _createAt;
  String get createAt => _createAt ?? '';
  set createAt(String? val) => _createAt = val;

  bool hasCreateAt() => _createAt != null;

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

  // "category" field.
  Map<String, dynamic>? _category;
  Map<String, dynamic> get category => _category ?? {};
  set category(Map<String, dynamic>? val) => _category = val;

  bool hasCategory() => _category != null;

  // "brand" field.
  Map<String, dynamic>? _brand;
  Map<String, dynamic> get brand => _brand ?? {};
  set brand(Map<String, dynamic>? val) => _brand = val;

  bool hasBrand() => _brand != null;

  static ProductStruct fromMap(Map<String, dynamic> data) => ProductStruct(
        productId: data['productId'] as String?,
        name: data['name'] as String?,
        description: data['description'] as String?,
        price: data['price'] is double 
            ? (data['price'] as double).round() 
            : castToType<int>(data['price']),
        imageUrls: (data['imageUrls'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        stockQuantity: data['stockQuantity'] is double 
            ? (data['stockQuantity'] as double).round() 
            : castToType<int>(data['stockQuantity']),
        commissionRate: data['commissionRate'] is double 
            ? (data['commissionRate'] as double).round() 
            : castToType<int>(data['commissionRate']),
        categoryId: data['categoryId'] as String?,
        brandId: data['brandId'] as String?,
        createAt: data['createAt'] as String?,
        updatedAt: data['updatedAt'] as String?,
        isActive: data['isActive'] as bool?,
        category: data['category'] as Map<String, dynamic>?,
        brand: data['brand'] as Map<String, dynamic>?,
      );

  static ProductStruct? maybeFromMap(dynamic data) =>
      data is Map ? ProductStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'productId': _productId,
        'name': _name,
        'description': _description,
        'price': _price,
        'imageUrls': _imageUrls,
        'stockQuantity': _stockQuantity,
        'commissionRate': _commissionRate,
        'categoryId': _categoryId,
        'brandId': _brandId,
        'createAt': _createAt,
        'updatedAt': _updatedAt,
        'isActive': _isActive,
        'category': _category,
        'brand': _brand,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'productId': serializeParam(
          _productId,
          ParamType.String,
        ),
        'name': serializeParam(
          _name,
          ParamType.String,
        ),
        'description': serializeParam(
          _description,
          ParamType.String,
        ),
        'price': serializeParam(
          _price,
          ParamType.int,
        ),
        'imageUrls': serializeParam(
          _imageUrls,
          ParamType.String,
        ),
        'stockQuantity': serializeParam(
          _stockQuantity,
          ParamType.int,
        ),
        'commissionRate': serializeParam(
          _commissionRate,
          ParamType.int,
        ),
        'categoryId': serializeParam(
          _categoryId,
          ParamType.String,
        ),
        'brandId': serializeParam(
          _brandId,
          ParamType.String,
        ),
        'createAt': serializeParam(
          _createAt,
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
        'category': serializeParam(
          _category,
          ParamType.JSON,
        ),
        'brand': serializeParam(
          _brand,
          ParamType.JSON,
        ),
      }.withoutNulls;

  static ProductStruct fromSerializableMap(Map<String, dynamic> data) =>
      ProductStruct(
        productId: deserializeParam(
          data['productId'],
          ParamType.String,
          false,
        ),
        name: deserializeParam(
          data['name'],
          ParamType.String,
          false,
        ),
        description: deserializeParam(
          data['description'],
          ParamType.String,
          false,
        ),
        price: deserializeParam(
          data['price'],
          ParamType.int,
          false,
        ),
        imageUrls: deserializeParam(
          data['imageUrls'],
          ParamType.String,
          true,
        ),
        stockQuantity: deserializeParam(
          data['stockQuantity'],
          ParamType.int,
          false,
        ),
        commissionRate: deserializeParam(
          data['commissionRate'],
          ParamType.int,
          false,
        ),
        categoryId: deserializeParam(
          data['categoryId'],
          ParamType.String,
          false,
        ),
        brandId: deserializeParam(
          data['brandId'],
          ParamType.String,
          false,
        ),
        createAt: deserializeParam(
          data['createAt'],
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
        category: deserializeParam(
          data['category'],
          ParamType.JSON,
          false,
        ),
        brand: deserializeParam(
          data['brand'],
          ParamType.JSON,
          false,
        ),
      );

  @override
  String toString() => 'ProductStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ProductStruct &&
        productId == other.productId &&
        name == other.name &&
        description == other.description &&
        price == other.price &&
        imageUrls == other.imageUrls &&
        stockQuantity == other.stockQuantity &&
        commissionRate == other.commissionRate &&
        categoryId == other.categoryId &&
        brandId == other.brandId &&
        createAt == other.createAt &&
        updatedAt == other.updatedAt &&
        isActive == other.isActive &&
        category == other.category &&
        brand == other.brand;
  }

  @override
  int get hashCode => const ListEquality().hash([
        productId,
        name,
        description,
        price,
        imageUrls,
        stockQuantity,
        commissionRate,
        categoryId,
        brandId,
        createAt,
        updatedAt,
        isActive,
        category,
        brand
      ]);
}

ProductStruct createProductStruct({
  String? productId,
  String? name,
  String? description,
  int? price,
  List<String>? imageUrls,
  int? stockQuantity,
  int? commissionRate,
  String? categoryId,
  String? brandId,
  String? createAt,
  String? updatedAt,
  bool? isActive,
  Map<String, dynamic>? category,
  Map<String, dynamic>? brand,
}) =>
    ProductStruct(
      productId: productId,
      name: name,
      description: description,
      price: price,
      imageUrls: imageUrls,
      stockQuantity: stockQuantity,
      commissionRate: commissionRate,
      categoryId: categoryId,
      brandId: brandId,
      createAt: createAt,
      updatedAt: updatedAt,
      isActive: isActive,
      category: category,
      brand: brand,
    ); 