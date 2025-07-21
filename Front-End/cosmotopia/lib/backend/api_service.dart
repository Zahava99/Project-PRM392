// Import all API service modules
import 'api_service/api_service_auth.dart';
import 'api_service/api_service_product.dart';
import 'api_service/api_service_cart.dart';
import 'api_service/api_service_order.dart';
import 'api_service/api_service_chat.dart';
import 'api_service/api_service_user.dart';
import 'api_service/api_service_analytics.dart';
import 'api_service/api_service_affiliate.dart';
import 'api_service/api_service_payment.dart';

// Re-export necessary types
import 'dart:io' show File;
import 'package:http/http.dart' as http;
/// Main API Service class that delegates to specific service modules
/// This maintains backward compatibility while organizing code into modules
class ApiService {
  // ============ AUTHENTICATION METHODS ============
  static Future<http.Response> login(String email, String password) =>
      ApiServiceAuth.login(email, password);

  static Future<http.Response> registerWithOtp(String email, String password, String phone, {String? firstName, String? lastName}) =>
      ApiServiceAuth.registerWithOtp(email, password, phone, firstName: firstName, lastName: lastName);

  static Future<http.Response> verifyOtp(String email, String otp) =>
      ApiServiceAuth.verifyOtp(email, otp);

  static Future<http.Response> editProfile({
    required String token,
    required String firstName,
    required String lastName,
    required String phone,
  }) => ApiServiceAuth.editProfile(
    token: token,
    firstName: firstName,
    lastName: lastName,
    phone: phone,
  );
  static Future<http.Response> getCurrentUser({required String token}) =>
      ApiServiceAuth.getCurrentUser(token: token);

  static Future<http.Response> updateAddress(String address, {required String token}) =>
      ApiServiceAuth.updateAddress(address, token: token);

  // ============ PRODUCT METHODS ============
  static Future<http.Response> getAllCategory({int page = 1, int pageSize = 10}) =>
      ApiServiceProduct.getAllCategory(page: page, pageSize: pageSize);

  static Future<http.Response> getAllProducts({int page = 1, int pageSize = 10, String? categoryId, String? search}) =>
      ApiServiceProduct.getAllProducts(page: page, pageSize: pageSize, categoryId: categoryId, search: search);

  static Future<http.Response> getProductById(String productId) =>
      ApiServiceProduct.getProductById(productId);

  static Future<http.Response> getTopSellingProducts({int top = 10}) =>
      ApiServiceProduct.getTopSellingProducts(top: top);

  static Future<http.Response> createProduct({
    required String productName,
    required String description,
    required double price,
    required String categoryId,
    required String token,
    String? imageUrl,
    int? stockQuantity,
    String? brand,
    Map<String, dynamic>? additionalFields,
  }) => ApiServiceProduct.createProduct(
    productName: productName,
    description: description,
    price: price,
    categoryId: categoryId,
    token: token,
    imageUrl: imageUrl,
    stockQuantity: stockQuantity,
    brand: brand,
    additionalFields: additionalFields,
  );
  static Future<http.Response> updateProduct({
    required String productId,
    required String productName,
    required String description,
    required double price,
    required String categoryId,
    required String token,
    String? imageUrl,
    int? stockQuantity,
    String? brand,
    Map<String, dynamic>? additionalFields,
  }) => ApiServiceProduct.updateProduct(
    productId: productId,
    productName: productName,
    description: description,
    price: price,
    categoryId: categoryId,
    token: token,
    imageUrl: imageUrl,
    stockQuantity: stockQuantity,
    brand: brand,
    additionalFields: additionalFields,
  );
  static Future<http.Response> deleteProduct(String productId, {required String token}) =>
      ApiServiceProduct.deleteProduct(productId, token: token);

  static Future<List<http.Response>> deleteMultipleProducts(List<String> productIds, {required String token}) =>
      ApiServiceProduct.deleteMultipleProducts(productIds, token: token);

  static Future<http.Response> getAllBrands() =>
      ApiServiceProduct.getAllBrands();

  // ============ CART METHODS ============
  static Future<http.Response> addToCart({
    required String productId,
    required int quantity,
    required String token,
  }) => ApiServiceCart.addToCart(
    productId: productId,
    quantity: quantity,
    token: token,
  );
  static Future<http.Response> getCart({required String token}) =>
      ApiServiceCart.getCart(token: token);

  static Future<http.Response> deleteCartItem({required String productId, required String token}) =>
      ApiServiceCart.deleteCartItem(productId: productId, token: token);

  static Future<http.Response> updateCart({
    required String productId,
    required int quantity,
    required String token,
  }) => ApiServiceCart.updateCart(
    productId: productId,
    quantity: quantity,
    token: token,
  );

  static Future<bool> clearAllCart({required String token}) =>
      ApiServiceCart.clearAllCart(token: token);

  // ============ ORDER METHODS ============
  static Future<http.Response> postOrder(Map<String, dynamic> orderBody, {required String token}) =>
      ApiServiceOrder.postOrder(orderBody, token: token);

  static Future<http.Response> getUserOrders({
    required String token,
    int page = 1,
    int pageSize = 100,
  }) => ApiServiceOrder.getUserOrders(
    token: token,
    page: page,
    pageSize: pageSize,
  );
  static Future<http.Response> getAllOrders({
    required String token,
    int page = 1,
    int pageSize = 20,
    String? status,
  }) => ApiServiceOrder.getAllOrders(
    token: token,
    page: page,
    pageSize: pageSize,
    status: status,
  );
  static Future<http.Response> updateOrderStatus({
    required String orderId,
    required int status,
    required String token,
  }) => ApiServiceOrder.updateOrderStatus(
    orderId: orderId,
    status: status,
    token: token,
  );
  @deprecated
  static Future<http.Response> deleteOrder(String orderId, {required String token}) =>
      ApiServiceOrder.deleteOrder(orderId, token: token);

  static Future<Map<String, dynamic>> getOrderAnalytics({required String token}) =>
      ApiServiceOrder.getOrderAnalytics(token: token);

  // ============ CHAT METHODS ============
  static Future<http.Response> sendChatMessage({
    required String message,
    required String token,
  }) => ApiServiceChat.sendChatMessage(
    message: message,
    token: token,
  );
  static Future<http.Response> analyzeBeautyImage({
    required File imageFile,
    required String token,
  }) => ApiServiceChat.analyzeBeautyImage(
    imageFile: imageFile,
    token: token,
  );
  // ============ USER MANAGEMENT METHODS ============
  static Future<http.Response> getAllUsers({required String token, int page = 1, int pageSize = 100}) =>
      ApiServiceUser.getAllUsers(token: token, page: page, pageSize: pageSize);

  static Future<http.Response> getUserById(String userId, {required String token}) =>
      ApiServiceUser.getUserById(userId, token: token);

  static Future<http.Response> editUserStatusAndRole({
    required String userId,
    required String token,
    int? userStatus,
    int? roleType,
  }) => ApiServiceUser.editUserStatusAndRole(
    userId: userId,
    token: token,
    userStatus: userStatus,
    roleType: roleType,
  );
  // ============ ANALYTICS METHODS ============
  static Future<Map<String, dynamic>> getAnalyticsDashboard({required String token}) =>
      ApiServiceAnalytics.getAnalyticsDashboard(token: token);

  static Future<http.Response> getAnalyticsSummary({required String token}) =>
      ApiServiceAnalytics.getAnalyticsSummary(token: token);

  // ============ AFFILIATE METHODS ============
  static Future<http.Response> registerAffiliate({
    required String token,
    String? bankAccount,
    String? bankName,
    String? idCard,
    String? taxCode,
  }) => ApiServiceAffiliate.registerAffiliate(
    token: token,
    bankAccount: bankAccount,
    bankName: bankName,
    idCard: idCard,
    taxCode: taxCode,
  );
  static Future<http.Response> checkAffiliateStatus({required String token}) =>
      ApiServiceAffiliate.checkAffiliateStatus(token: token);

  static Future<http.Response> generateAffiliateLink({
    required String productId,
    required String token,
    Map<String, String>? customParams,
  }) => ApiServiceAffiliate.generateAffiliateLink(
    productId: productId,
    token: token,
    customParams: customParams,
  );
  static Future<http.Response> getAffiliateDashboard({required String token}) =>
      ApiServiceAffiliate.getAffiliateDashboard(token: token);

  static Future<http.Response> getAffiliateEarnings({
    required String token,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
  }) => ApiServiceAffiliate.getAffiliateEarnings(
    token: token,
    period: period,
    startDate: startDate,
    endDate: endDate,
  );
  static Future<http.Response> requestAffiliateWithdrawal({
    required String token,
    required double amount,
    required String bankAccount,
    required String bankName,
    String? notes,
  }) => ApiServiceAffiliate.requestAffiliateWithdrawal(
    token: token,
    amount: amount,
    bankAccount: bankAccount,
    bankName: bankName,
    notes: notes,
  );
  static Future<http.Response> getAffiliateWithdrawals({
    required String token,
    int page = 1,
    int pageSize = 20,
    String? status,
  }) => ApiServiceAffiliate.getAffiliateWithdrawals(
    token: token,
    page: page,
    pageSize: pageSize,
    status: status,
  );
  static Future<http.Response> getAffiliateCommissions({
    required String token,
    int page = 1,
    int pageSize = 20,
    DateTime? startDate,
    DateTime? endDate,
  }) => ApiServiceAffiliate.getAffiliateCommissions(
    token: token,
    page: page,
    pageSize: pageSize,
    startDate: startDate,
    endDate: endDate,
  );
  static Future<http.Response> updateAffiliateLinkStatus({
    required String token,
    required String linkId,
    required String status,
  }) => ApiServiceAffiliate.updateAffiliateLinkStatus(
    token: token,
    linkId: linkId,
    status: status,
  );
  static Future<http.Response> getAffiliatePerformance({
    required String token,
    String period = 'month',
  }) => ApiServiceAffiliate.getAffiliatePerformance(
    token: token,
    period: period,
  );
  static Future<http.Response> getAffiliateProfile({required String token}) =>
      ApiServiceAffiliate.getAffiliateProfile(token: token);

  static Future<http.Response> getAffiliateStats({
    required String token,
    required DateTime startDate,
    required DateTime endDate,
  }) => ApiServiceAffiliate.getAffiliateStats(
    token: token,
    startDate: startDate,
    endDate: endDate,
  );
  static Future<http.Response> trackAffiliateClick({
    required String referralCode,
    required String token, // Thêm token parameter
    Map<String, dynamic>? metadata,
  }) => ApiServiceAffiliate.trackAffiliateClick(
    referralCode: referralCode,
    token: token, // Truyền token xuống
    metadata: metadata,
  );
  static Future<http.Response> getMyAffiliateLinks({
    required String token,
    int page = 1,
    int pageSize = 20,
  }) => ApiServiceAffiliate.getMyAffiliateLinks(
    token: token,
    page: page,
    pageSize: pageSize,
  );
  // ============ PAYMENT METHODS ============
  static Future<http.Response> getAllPayments({
    int page = 1,
    int pageSize = 10,
    String? status,
    required String token,
  }) => ApiServicePayment.getAllPayments(
    page: page,
    pageSize: pageSize,
    status: status,
    token: token,
  );
  static Future<http.Response> getPaymentByTransactionId({
    required String transactionId,
    required String token,
  }) => ApiServicePayment.getPaymentByTransactionId(
    transactionId: transactionId,
    token: token,
  );
  static Future<http.Response> updatePaymentStatus({
    required String transactionId,
    required int newStatus,
    required String token,
  }) => ApiServicePayment.updatePaymentStatus(
    transactionId: transactionId,
    newStatus: newStatus,
    token: token,
  );
  static Future<http.Response> createPaymentLink({
    required String orderId,
    required String token,
  }) => ApiServicePayment.createPaymentLink(
    orderId: orderId,
    token: token,
  );
  static Future<http.Response> deletePayment({
    required String paymentId,
    required String token,
  }) => ApiServicePayment.deletePayment(
    paymentId: paymentId,
    token: token,
  );
} 