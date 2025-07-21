// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PaymentTransactionStruct extends BaseStruct {
  PaymentTransactionStruct({
    String? paymentTransactionId,
    String? orderId,
    String? paymentMethod,
    String? transactionId,
    String? requestId,
    double? amount,
    String? status,
    DateTime? transactionDate,
    int? resultCode,
    String? responseTime,
    OrderInfoStruct? orderInfo,
  })  : _paymentTransactionId = paymentTransactionId,
        _orderId = orderId,
        _paymentMethod = paymentMethod,
        _transactionId = transactionId,
        _requestId = requestId,
        _amount = amount,
        _status = status,
        _transactionDate = transactionDate,
        _resultCode = resultCode,
        _responseTime = responseTime,
        _orderInfo = orderInfo;

  // "paymentTransactionId" field.
  String? _paymentTransactionId;
  String get paymentTransactionId => _paymentTransactionId ?? '';
  set paymentTransactionId(String? val) => _paymentTransactionId = val;

  bool hasPaymentTransactionId() => _paymentTransactionId != null;

  // "orderId" field.
  String? _orderId;
  String get orderId => _orderId ?? '';
  set orderId(String? val) => _orderId = val;

  bool hasOrderId() => _orderId != null;

  // "paymentMethod" field.
  String? _paymentMethod;
  String get paymentMethod => _paymentMethod ?? '';
  set paymentMethod(String? val) => _paymentMethod = val;

  bool hasPaymentMethod() => _paymentMethod != null;

  // "transactionId" field.
  String? _transactionId;
  String get transactionId => _transactionId ?? '';
  set transactionId(String? val) => _transactionId = val;

  bool hasTransactionId() => _transactionId != null;

  // "requestId" field.
  String? _requestId;
  String get requestId => _requestId ?? '';
  set requestId(String? val) => _requestId = val;

  bool hasRequestId() => _requestId != null;

  // "amount" field.
  double? _amount;
  double get amount => _amount ?? 0.0;
  set amount(double? val) => _amount = val;

  bool hasAmount() => _amount != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  set status(String? val) => _status = val;

  bool hasStatus() => _status != null;

  // "transactionDate" field.
  DateTime? _transactionDate;
  DateTime? get transactionDate => _transactionDate;
  set transactionDate(DateTime? val) => _transactionDate = val;

  bool hasTransactionDate() => _transactionDate != null;

  // "resultCode" field.
  int? _resultCode;
  int get resultCode => _resultCode ?? 0;
  set resultCode(int? val) => _resultCode = val;

  bool hasResultCode() => _resultCode != null;

  // "responseTime" field.
  String? _responseTime;
  String get responseTime => _responseTime ?? '';
  set responseTime(String? val) => _responseTime = val;

  bool hasResponseTime() => _responseTime != null;

  // "orderInfo" field.
  OrderInfoStruct? _orderInfo;
  OrderInfoStruct get orderInfo => _orderInfo ?? OrderInfoStruct();
  set orderInfo(OrderInfoStruct? val) => _orderInfo = val;

  bool hasOrderInfo() => _orderInfo != null;

  static PaymentTransactionStruct fromMap(Map<String, dynamic> data) =>
      PaymentTransactionStruct(
        paymentTransactionId: data['paymentTransactionId'] as String?,
        orderId: data['orderId'] as String?,
        paymentMethod: data['paymentMethod'] as String?,
        transactionId: data['transactionId'] as String?,
        requestId: data['requestId'] as String?,
        amount: castToType<double>(data['amount']),
        status: data['status']?.toString(), // Convert int to string
        transactionDate: data['transactionDate'] != null 
            ? DateTime.parse(data['transactionDate']) 
            : null,
        resultCode: castToType<int>(data['resultCode']),
        responseTime: data['responseTime'] as String?,
        orderInfo: OrderInfoStruct.maybeFromMap(data['orderInfo']),
      );

  static PaymentTransactionStruct? maybeFromMap(dynamic data) => data is Map
      ? PaymentTransactionStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'paymentTransactionId': _paymentTransactionId,
        'orderId': _orderId,
        'paymentMethod': _paymentMethod,
        'transactionId': _transactionId,
        'requestId': _requestId,
        'amount': _amount,
        'status': _status,
        'transactionDate': _transactionDate?.millisecondsSinceEpoch,
        'resultCode': _resultCode,
        'responseTime': _responseTime,
        'orderInfo': _orderInfo?.toMap(),
      };

  @override
  Map<String, dynamic> toSerializableMap() => toMap();

  @override
  String toString() => 'PaymentTransactionStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is PaymentTransactionStruct &&
        paymentTransactionId == other.paymentTransactionId &&
        orderId == other.orderId &&
        paymentMethod == other.paymentMethod &&
        transactionId == other.transactionId &&
        requestId == other.requestId &&
        amount == other.amount &&
        status == other.status &&
        transactionDate == other.transactionDate &&
        resultCode == other.resultCode &&
        responseTime == other.responseTime &&
        orderInfo == other.orderInfo;
  }

  @override
  int get hashCode => const ListEquality().hash([
        paymentTransactionId,
        orderId,
        paymentMethod,
        transactionId,
        requestId,
        amount,
        status,
        transactionDate,
        resultCode,
        responseTime,
        orderInfo
      ]);

  // Helper methods for payment status
  bool get isPending => status == 'Pending' || status == '0';
  bool get isSuccess => status == 'Success' || status == '1';
  bool get isFailed => status == 'Failed' || status == '2';
  
  String get statusDisplay {
    switch (status) {
      case 'Pending':
      case '0':
        return 'Pending';
      case 'Success':
      case '1':
        return 'Success';
      case 'Failed':
      case '2':
        return 'Failed';
      default:
        return 'Unknown';
    }
  }
}

class OrderInfoStruct extends BaseStruct {
  OrderInfoStruct({
    String? orderId,
    String? customerName,
    String? customerEmail,
    double? totalAmount,
    DateTime? orderDate,
    String? address,
    int? productCount,
  })  : _orderId = orderId,
        _customerName = customerName,
        _customerEmail = customerEmail,
        _totalAmount = totalAmount,
        _orderDate = orderDate,
        _address = address,
        _productCount = productCount;

  // "orderId" field.
  String? _orderId;
  String get orderId => _orderId ?? '';
  set orderId(String? val) => _orderId = val;

  bool hasOrderId() => _orderId != null;

  // "customerName" field.
  String? _customerName;
  String get customerName => _customerName ?? '';
  set customerName(String? val) => _customerName = val;

  bool hasCustomerName() => _customerName != null;

  // "customerEmail" field.
  String? _customerEmail;
  String get customerEmail => _customerEmail ?? '';
  set customerEmail(String? val) => _customerEmail = val;

  bool hasCustomerEmail() => _customerEmail != null;

  // "totalAmount" field.
  double? _totalAmount;
  double get totalAmount => _totalAmount ?? 0.0;
  set totalAmount(double? val) => _totalAmount = val;

  bool hasTotalAmount() => _totalAmount != null;

  // "orderDate" field.
  DateTime? _orderDate;
  DateTime? get orderDate => _orderDate;
  set orderDate(DateTime? val) => _orderDate = val;

  bool hasOrderDate() => _orderDate != null;

  // "address" field.
  String? _address;
  String get address => _address ?? '';
  set address(String? val) => _address = val;

  bool hasAddress() => _address != null;

  // "productCount" field.
  int? _productCount;
  int get productCount => _productCount ?? 0;
  set productCount(int? val) => _productCount = val;

  bool hasProductCount() => _productCount != null;

  static OrderInfoStruct fromMap(Map<String, dynamic> data) => OrderInfoStruct(
        orderId: data['orderId'] as String?,
        customerName: data['customerName'] as String?,
        customerEmail: data['customerEmail'] as String?,
        totalAmount: castToType<double>(data['totalAmount']),
        orderDate: data['orderDate'] != null 
            ? DateTime.parse(data['orderDate']) 
            : null,
        address: data['address'] as String?,
        productCount: castToType<int>(data['productCount']),
      );

  static OrderInfoStruct? maybeFromMap(dynamic data) => data is Map
      ? OrderInfoStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'orderId': _orderId,
        'customerName': _customerName,
        'customerEmail': _customerEmail,
        'totalAmount': _totalAmount,
        'orderDate': _orderDate?.millisecondsSinceEpoch,
        'address': _address,
        'productCount': _productCount,
      };

  @override
  Map<String, dynamic> toSerializableMap() => toMap();

  @override
  String toString() => 'OrderInfoStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is OrderInfoStruct &&
        orderId == other.orderId &&
        customerName == other.customerName &&
        customerEmail == other.customerEmail &&
        totalAmount == other.totalAmount &&
        orderDate == other.orderDate &&
        address == other.address &&
        productCount == other.productCount;
  }

  @override
  int get hashCode => const ListEquality().hash([
        orderId,
        customerName,
        customerEmail,
        totalAmount,
        orderDate,
        address,
        productCount
      ]);
} 