// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class OrderDetailStruct extends BaseStruct {
  OrderDetailStruct({
    String? orderDetailId,
    String? orderId,
    String? productId,
    String? name,
    String? imageUrl,
    int? quantity,
    double? unitPrice,
  })  : _orderDetailId = orderDetailId,
        _orderId = orderId,
        _productId = productId,
        _name = name,
        _imageUrl = imageUrl,
        _quantity = quantity,
        _unitPrice = unitPrice;

  // "orderDetailId" field.
  String? _orderDetailId;
  String get orderDetailId => _orderDetailId ?? '';
  set orderDetailId(String? val) => _orderDetailId = val;
  bool hasOrderDetailId() => _orderDetailId != null;

  // "orderId" field.
  String? _orderId;
  String get orderId => _orderId ?? '';
  set orderId(String? val) => _orderId = val;
  bool hasOrderId() => _orderId != null;

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

  // "imageUrl" field.
  String? _imageUrl;
  String get imageUrl => _imageUrl ?? '';
  set imageUrl(String? val) => _imageUrl = val;
  bool hasImageUrl() => _imageUrl != null;

  // "quantity" field.
  int? _quantity;
  int get quantity => _quantity ?? 0;
  set quantity(int? val) => _quantity = val;
  void incrementQuantity(int amount) => quantity = quantity + amount;
  bool hasQuantity() => _quantity != null;

  // "unitPrice" field.
  double? _unitPrice;
  double get unitPrice => _unitPrice ?? 0.0;
  set unitPrice(double? val) => _unitPrice = val;
  bool hasUnitPrice() => _unitPrice != null;

  static OrderDetailStruct fromMap(Map<String, dynamic> data) {
    // Handle imageUrl as either String or List<String>
    String? imageUrl;
    if (data['imageUrl'] is List) {
      final imageList = data['imageUrl'] as List;
      imageUrl = imageList.isNotEmpty ? imageList.first.toString() : null;
    } else {
      imageUrl = data['imageUrl'] as String?;
    }
    
    return OrderDetailStruct(
      orderDetailId: data['orderDetailId'] as String?,
      orderId: data['orderId'] as String?,
      productId: data['productId'] as String?,
      name: data['name'] as String?,
      imageUrl: imageUrl,
      quantity: castToType<int>(data['quantity']),
      unitPrice: castToType<double>(data['unitPrice']),
    );
  }

  static OrderDetailStruct? maybeFromMap(dynamic data) =>
      data is Map ? OrderDetailStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'orderDetailId': _orderDetailId,
        'orderId': _orderId,
        'productId': _productId,
        'name': _name,
        'imageUrl': _imageUrl,
        'quantity': _quantity,
        'unitPrice': _unitPrice,
      };

  @override
  String toString() => 'OrderDetailStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is OrderDetailStruct &&
        orderDetailId == other.orderDetailId &&
        orderId == other.orderId &&
        productId == other.productId &&
        name == other.name &&
        imageUrl == other.imageUrl &&
        quantity == other.quantity &&
        unitPrice == other.unitPrice;
  }

  @override
  int get hashCode => const ListEquality().hash([
        orderDetailId,
        orderId,
        productId,
        name,
        imageUrl,
        quantity,
        unitPrice,
      ]);

  @override
  Map<String, dynamic> toSerializableMap() => {
        'orderDetailId': serializeParam(
          _orderDetailId,
          ParamType.String,
        ),
        'orderId': serializeParam(
          _orderId,
          ParamType.String,
        ),
        'productId': serializeParam(
          _productId,
          ParamType.String,
        ),
        'name': serializeParam(
          _name,
          ParamType.String,
        ),
        'imageUrl': serializeParam(
          _imageUrl,
          ParamType.String,
        ),
        'quantity': serializeParam(
          _quantity,
          ParamType.int,
        ),
        'unitPrice': serializeParam(
          _unitPrice,
          ParamType.double,
        ),
      }.withoutNulls;

  static OrderDetailStruct fromSerializableMap(Map<String, dynamic> data) =>
      OrderDetailStruct(
        orderDetailId: deserializeParam(
          data['orderDetailId'],
          ParamType.String,
          false,
        ),
        orderId: deserializeParam(
          data['orderId'],
          ParamType.String,
          false,
        ),
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
        imageUrl: deserializeParam(
          data['imageUrl'],
          ParamType.String,
          false,
        ),
        quantity: deserializeParam(
          data['quantity'],
          ParamType.int,
          false,
        ),
        unitPrice: deserializeParam(
          data['unitPrice'],
          ParamType.double,
          false,
        ),
      );
}

OrderDetailStruct createOrderDetailStruct({
  String? orderDetailId,
  String? orderId,
  String? productId,
  String? name,
  String? imageUrl,
  int? quantity,
  double? unitPrice,
}) =>
    OrderDetailStruct(
      orderDetailId: orderDetailId,
      orderId: orderId,
      productId: productId,
      name: name,
      imageUrl: imageUrl,
      quantity: quantity,
      unitPrice: unitPrice,
    );

class OrderStruct extends BaseStruct {
  OrderStruct({
    String? orderId,
    int? customerId,
    String? customerName,
    String? phoneNumber,
    int? salesStaffId,
    double? totalAmount,
    int? status,
    String? orderDate,
    String? paymentMethod,
    String? address,
    List<OrderDetailStruct>? orderDetails,
  })  : _orderId = orderId,
        _customerId = customerId,
        _customerName = customerName,
        _phoneNumber = phoneNumber,
        _salesStaffId = salesStaffId,
        _totalAmount = totalAmount,
        _status = status,
        _orderDate = orderDate,
        _paymentMethod = paymentMethod,
        _address = address,
        _orderDetails = orderDetails;

  // "orderId" field.
  String? _orderId;
  String get orderId => _orderId ?? '';
  set orderId(String? val) => _orderId = val;
  bool hasOrderId() => _orderId != null;

  // "customerId" field.
  int? _customerId;
  int get customerId => _customerId ?? 0;
  set customerId(int? val) => _customerId = val;
  void incrementCustomerId(int amount) => customerId = customerId + amount;
  bool hasCustomerId() => _customerId != null;

  // "customerName" field.
  String? _customerName;
  String get customerName => _customerName ?? '';
  set customerName(String? val) => _customerName = val;
  bool hasCustomerName() => _customerName != null;

  // "phoneNumber" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  set phoneNumber(String? val) => _phoneNumber = val;
  bool hasPhoneNumber() => _phoneNumber != null;

  // "salesStaffId" field.
  int? _salesStaffId;
  int get salesStaffId => _salesStaffId ?? 0;
  set salesStaffId(int? val) => _salesStaffId = val;
  void incrementSalesStaffId(int amount) => salesStaffId = salesStaffId + amount;
  bool hasSalesStaffId() => _salesStaffId != null;

  // "totalAmount" field.
  double? _totalAmount;
  double get totalAmount => _totalAmount ?? 0.0;
  set totalAmount(double? val) => _totalAmount = val;
  bool hasTotalAmount() => _totalAmount != null;

  // "status" field.
  int? _status;
  int get status => _status ?? 0;
  set status(int? val) => _status = val;
  void incrementStatus(int amount) => status = status + amount;
  bool hasStatus() => _status != null;

  // Helper để get status string
  String get statusString {
    switch (status) {
      case 0: return 'Pending';
      case 1: return 'Paid';     // Changed from 'Confirmed' to 'Paid' to match backend
      case 2: return 'Shipped';
      case 3: return 'Delivered';
      case 4: return 'Cancelled';
      default: return 'Unknown';
    }
  }

  // Helper để check status type
  bool get isPending => status == 0;
  bool get isConfirmed => status == 1;  // Keeping this name for backward compatibility
  bool get isShipped => status == 2;
  bool get isCompleted => status == 3; // Delivered
  bool get isCancelled => status == 4;
  bool get isActive => status >= 0 && status <= 2; // Pending, Confirmed, Shipped

  // "orderDate" field.
  String? _orderDate;
  String get orderDate => _orderDate ?? '';
  set orderDate(String? val) => _orderDate = val;
  bool hasOrderDate() => _orderDate != null;

  // "paymentMethod" field.
  String? _paymentMethod;
  String get paymentMethod => _paymentMethod ?? '';
  set paymentMethod(String? val) => _paymentMethod = val;
  bool hasPaymentMethod() => _paymentMethod != null;

  // "address" field.
  String? _address;
  String get address => _address ?? '';
  set address(String? val) => _address = val;
  bool hasAddress() => _address != null;

  // "orderDetails" field.
  List<OrderDetailStruct>? _orderDetails;
  List<OrderDetailStruct> get orderDetails => _orderDetails ?? const [];
  set orderDetails(List<OrderDetailStruct>? val) => _orderDetails = val;
  
  void updateOrderDetails(Function(List<OrderDetailStruct>) updateFn) {
    updateFn(_orderDetails ??= []);
  }
  
  bool hasOrderDetails() => _orderDetails != null;

  static OrderStruct fromMap(Map<String, dynamic> data) => OrderStruct(
        orderId: data['orderId'] as String?,
        customerId: castToType<int>(data['customerId']),
        customerName: data['customerName'] as String?,
        phoneNumber: data['phoneNumber'] as String?,
        salesStaffId: castToType<int>(data['salesStaffId']),
        totalAmount: castToType<double>(data['totalAmount']),
        status: castToType<int>(data['status']),
        orderDate: data['orderDate'] as String?,
        paymentMethod: data['paymentMethod'] as String?,
        address: data['address'] as String?,
        orderDetails: getStructList(
          data['orderDetails'],
          OrderDetailStruct.fromMap,
        ),
      );

  static OrderStruct? maybeFromMap(dynamic data) =>
      data is Map ? OrderStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'orderId': _orderId,
        'customerId': _customerId,
        'customerName': _customerName,
        'phoneNumber': _phoneNumber,
        'salesStaffId': _salesStaffId,
        'totalAmount': _totalAmount,
        'status': _status,
        'orderDate': _orderDate,
        'paymentMethod': _paymentMethod,
        'address': _address,
        'orderDetails': _orderDetails?.map((e) => e.toMap()).toList(),
      };

  @override
  String toString() => 'OrderStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is OrderStruct &&
        orderId == other.orderId &&
        customerId == other.customerId &&
        customerName == other.customerName &&
        phoneNumber == other.phoneNumber &&
        salesStaffId == other.salesStaffId &&
        totalAmount == other.totalAmount &&
        status == other.status &&
        orderDate == other.orderDate &&
        paymentMethod == other.paymentMethod &&
        address == other.address &&
        listEquality.equals(orderDetails, other.orderDetails);
  }

  @override
  int get hashCode => const ListEquality().hash([
        orderId,
        customerId,
        customerName,
        phoneNumber,
        salesStaffId,
        totalAmount,
        status,
        orderDate,
        paymentMethod,
        address,
        orderDetails,
      ]);

  @override
  Map<String, dynamic> toSerializableMap() => {
        'orderId': serializeParam(
          _orderId,
          ParamType.String,
        ),
        'customerId': serializeParam(
          _customerId,
          ParamType.int,
        ),
        'customerName': serializeParam(
          _customerName,
          ParamType.String,
        ),
        'phoneNumber': serializeParam(
          _phoneNumber,
          ParamType.String,
        ),
        'salesStaffId': serializeParam(
          _salesStaffId,
          ParamType.int,
        ),
        'totalAmount': serializeParam(
          _totalAmount,
          ParamType.double,
        ),
        'status': serializeParam(
          _status,
          ParamType.int,
        ),
        'orderDate': serializeParam(
          _orderDate,
          ParamType.String,
        ),
        'paymentMethod': serializeParam(
          _paymentMethod,
          ParamType.String,
        ),
        'address': serializeParam(
          _address,
          ParamType.String,
        ),
        'orderDetails': serializeParam(
          _orderDetails,
          ParamType.DataStruct,
          isList: true,
        ),
      }.withoutNulls;

  static OrderStruct fromSerializableMap(Map<String, dynamic> data) =>
      OrderStruct(
        orderId: deserializeParam(
          data['orderId'],
          ParamType.String,
          false,
        ),
        customerId: deserializeParam(
          data['customerId'],
          ParamType.int,
          false,
        ),
        customerName: deserializeParam(
          data['customerName'],
          ParamType.String,
          false,
        ),
        phoneNumber: deserializeParam(
          data['phoneNumber'],
          ParamType.String,
          false,
        ),
        salesStaffId: deserializeParam(
          data['salesStaffId'],
          ParamType.int,
          false,
        ),
        totalAmount: deserializeParam(
          data['totalAmount'],
          ParamType.double,
          false,
        ),
        status: deserializeParam(
          data['status'],
          ParamType.int,
          false,
        ),
        orderDate: deserializeParam(
          data['orderDate'],
          ParamType.String,
          false,
        ),
        paymentMethod: deserializeParam(
          data['paymentMethod'],
          ParamType.String,
          false,
        ),
        address: deserializeParam(
          data['address'],
          ParamType.String,
          false,
        ),
        orderDetails: deserializeStructParam<OrderDetailStruct>(
          data['orderDetails'],
          ParamType.DataStruct,
          true,
          structBuilder: OrderDetailStruct.fromSerializableMap,
        ),
      );
}

OrderStruct createOrderStruct({
  String? orderId,
  int? customerId,
  String? customerName,
  String? phoneNumber,
  int? salesStaffId,
  double? totalAmount,
  int? status,
  String? orderDate,
  String? paymentMethod,
  String? address,
}) =>
    OrderStruct(
      orderId: orderId,
      customerId: customerId,
      customerName: customerName,
      phoneNumber: phoneNumber,
      salesStaffId: salesStaffId,
      totalAmount: totalAmount,
      status: status,
      orderDate: orderDate,
      paymentMethod: paymentMethod,
      address: address,
    ); 