import '/flutter_flow/flutter_flow_util.dart';
import '/backend/api_service.dart';
import '/backend/schema/structs/index.dart';
import '/all_component/appbar/appbar_model.dart';
import 'order_management_page_widget.dart' show OrderManagementPageWidget;
import 'package:flutter/material.dart';
import 'dart:convert';

class OrderManagementPageModel extends FlutterFlowModel<OrderManagementPageWidget> {
  // Appbar model
  late AppbarModel appbarModel;
  
  // Order list state
  List<OrderStruct> orders = [];
  List<OrderStruct> filteredOrders = [];
  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';
  
  // Pagination
  int currentPage = 1;
  int pageSize = 20;
  bool hasMoreData = true;
  
  // Filter state
  int? selectedStatusFilter; // null means all statuses
  String searchQuery = '';
  
  // Edit dialog state
  bool isEditDialogOpen = false;
  OrderStruct? selectedOrder;
  int? selectedOrderStatus;
  
  // Analytics state
  Map<String, dynamic> analytics = {};
  bool isLoadingAnalytics = false;
  
  // Status mappings - Updated based on backend rules
  final Map<int, String> statusNames = {
    0: 'Pending',
    1: 'Paid',        // Backend calls this "Paid" not "Confirmed"
    2: 'Shipped',
    3: 'Delivered',
    4: 'Cancelled',
  };
  
  final Map<int, Color> statusColors = {
    0: Colors.orange,
    1: Colors.blue,
    2: Colors.purple,
    3: Colors.green,
    4: Colors.red,
  };

  @override
  void initState(BuildContext context) {
    appbarModel = createModel(context, () => AppbarModel());
    loadOrders();
  }

  @override
  void dispose() {
    appbarModel.dispose();
  }
  
  // Load orders from API
  Future<void> loadOrders({bool refresh = false}) async {
    if (refresh) {
      currentPage = 1;
      orders.clear();
      filteredOrders.clear();
      hasMoreData = true;
    }
    
    if (isLoading || !hasMoreData) return;
    
    isLoading = true;
    hasError = false;
    
    try {
      final token = FFAppState().token;
      if (token.isEmpty) {
        throw Exception('No access token available');
      }
      
      final response = await ApiService.getAllOrders(
        token: token,
        page: currentPage,
        pageSize: pageSize,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> newOrdersData = [];
        
        // Handle different response structures based on actual API response
        if (data['orders'] != null) {
          newOrdersData = data['orders'] as List<dynamic>;
        } else if (data['data'] != null) {
          newOrdersData = data['data'] as List<dynamic>;
        } else if (data is List) {
          newOrdersData = data;
        } else if (data['items'] != null) {
          newOrdersData = data['items'] as List<dynamic>;
        }
        
        final List<OrderStruct> newOrders = newOrdersData
            .map((orderData) => OrderStruct.fromMap(orderData))
            .toList();
        
        if (refresh) {
          orders = newOrders;
        } else {
          orders.addAll(newOrders);
        }
        
        _applyFilters();
        calculateAnalytics(); // Calculate analytics after loading orders
        
        // Update pagination based on response metadata
        if (data['totalPages'] != null && data['currentPage'] != null) {
          hasMoreData = data['currentPage'] < data['totalPages'];
        } else {
          hasMoreData = newOrders.length >= pageSize;
        }
        
        if (hasMoreData) {
          currentPage++;
        }
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      hasError = true;
      errorMessage = e.toString();
      print('❌ Error loading orders: $e');
    } finally {
      isLoading = false;
    }
  }
  
  // Load analytics data - calculate from existing orders to avoid duplicate API calls
  void calculateAnalytics() {
    isLoadingAnalytics = true;
    
    try {
      // Calculate analytics from existing orders data
      int totalOrders = orders.length;
      int pendingOrders = orders.where((o) => o.status == 0).length;
      int paidOrders = orders.where((o) => o.status == 1).length; // Changed from confirmedOrders
      int shippedOrders = orders.where((o) => o.status == 2).length;
      int deliveredOrders = orders.where((o) => o.status == 3).length;
      int cancelledOrders = orders.where((o) => o.status == 4).length;
      
      // Safe calculation for total revenue
      double totalRevenue = 0.0;
      try {
        totalRevenue = orders.fold(0.0, (sum, order) {
          return sum + (order.totalAmount ?? 0.0);
        });
      } catch (e) {
        print('❌ Error calculating total revenue: $e');
        totalRevenue = 0.0;
      }
      
      analytics = {
        'totalOrders': totalOrders,
        'pendingOrders': pendingOrders,
        'paidOrders': paidOrders, // Changed from confirmedOrders
        'shippedOrders': shippedOrders,
        'deliveredOrders': deliveredOrders, // This is what the UI expects for "Completed"
        'cancelledOrders': cancelledOrders,
        'totalRevenue': totalRevenue,
        // Keep legacy fields for backward compatibility
        'confirmedOrders': paidOrders, // For backward compatibility
        'completedOrders': deliveredOrders, // For backward compatibility
      };
    } catch (e) {
      print('❌ Error calculating analytics: $e');
      // Set default values on error
      analytics = {
        'totalOrders': 0,
        'pendingOrders': 0,
        'paidOrders': 0,
        'shippedOrders': 0,
        'deliveredOrders': 0,
        'cancelledOrders': 0,
        'totalRevenue': 0.0,
        'confirmedOrders': 0,
        'completedOrders': 0,
      };
    } finally {
      isLoadingAnalytics = false;
    }
  }
  
  // Apply filters to orders
  void _applyFilters() {
    filteredOrders = orders.where((order) {
      // Filter by status
      if (selectedStatusFilter != null && order.status != selectedStatusFilter) {
        return false;
      }
      
      // Filter by search query
    if (searchQuery.isNotEmpty) {
        return order.orderId.toLowerCase().contains(searchQuery.toLowerCase()) ||
               order.customerName.toLowerCase().contains(searchQuery.toLowerCase()) ||
               order.phoneNumber.contains(searchQuery);
      }
      
      return true;
      }).toList();
    }
    
  // Set status filter
  void setStatusFilter(int? status) {
    selectedStatusFilter = status;
    _applyFilters();
  }
  
  // Set search query
  void setSearchQuery(String query) {
    searchQuery = query;
    _applyFilters();
  }
  
  // Open edit dialog
  void openEditDialog(OrderStruct order) {
    selectedOrder = order;
    selectedOrderStatus = order.status;
    isEditDialogOpen = true;
  }
  
  // Close edit dialog
  void closeEditDialog() {
    selectedOrder = null;
    selectedOrderStatus = null;
    isEditDialogOpen = false;
  }
  
  // Save order changes
  Future<bool> saveOrderChanges() async {
    if (selectedOrder == null || selectedOrderStatus == null) {
      print('❌ Invalid selection: selectedOrder or selectedOrderStatus is null');
      return false;
    }
    
    // Validate status transition
    if (!canUpdateOrderStatus(selectedOrder!, selectedOrderStatus!)) {
      print('❌ Invalid status transition: ${selectedOrder!.status} → $selectedOrderStatus');
      errorMessage = 'Invalid status transition. Please follow the correct order flow.';
      return false;
    }
    
    try {
      final token = FFAppState().token;
      if (token.isEmpty) {
        throw Exception('No access token available');
      }
      
      // Check if user is admin
      final userRole = FFAppState().userRole;
      print('📤 User role: $userRole');
      if (userRole != 'Administrator') {
        throw Exception('Access denied: Only administrators can update order status');
      }
      
      print('📤 Updating order status:');
      print('📤 Order ID: ${selectedOrder!.orderId}');
      print('📤 Current Status: ${selectedOrder!.status}');
      print('📤 New Status: $selectedOrderStatus');
      print('📤 Token length: ${token.length}');
      print('📤 Token preview: ${token.substring(0, 20)}...');
      print('📤 Token valid: ${token.isNotEmpty && token.startsWith('eyJ')}');
      
      // Test token validity by calling getCurrentUser first
      try {
        final userResponse = await ApiService.getCurrentUser(token: token);
        print('📤 Token test - getCurrentUser status: ${userResponse.statusCode}');
        if (userResponse.statusCode == 401) {
          throw Exception('Token expired or invalid. Please login again.');
        }
      } catch (e) {
        print('❌ Token validation failed: $e');
        throw Exception('Authentication failed. Please login again.');
      }
      
      final response = await ApiService.updateOrderStatus(
        orderId: selectedOrder!.orderId,
        status: selectedOrderStatus!,
        token: token,
      );
      
      print('📤 Update order status - Status Code: ${response.statusCode}');
      print('📤 Update order status - Response Body: ${response.body}');
      
      // Accept both 200 and 204 as successful responses
      // 204 No Content is the correct response for successful PUT requests without response body
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Order status updated successfully');
        
        // Update local order data
        final orderIndex = orders.indexWhere((o) => o.orderId == selectedOrder!.orderId);
        if (orderIndex != -1) {
          orders[orderIndex] = orders[orderIndex].copyWith(status: selectedOrderStatus);
          print('✅ Local order data updated');
        }
        
        _applyFilters();
        closeEditDialog();
        calculateAnalytics(); // Refresh analytics after status change
        return true;
      } else {
        // Handle error response with detailed logging
        String errorMessage = 'Failed to update order (Status: ${response.statusCode})';
        print('❌ Update order failed - Status: ${response.statusCode}');
        print('❌ Update order failed - Body: ${response.body}');
        
        if (response.body.isNotEmpty) {
          try {
            final errorData = jsonDecode(response.body);
            errorMessage = errorData['message'] ?? errorMessage;
            print('❌ Parsed error message: $errorMessage');
          } catch (e) {
            // If JSON parsing fails, use the raw body or default message
            errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
            print('❌ JSON parsing failed, using raw body: $errorMessage');
          }
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      errorMessage = e.toString();
      print('❌ Error saving order changes: $e');
      return false;
    }
  }
  
  // Cancel order (instead of delete)
  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    try {
      final token = FFAppState().token;
      if (token.isEmpty) {
        throw Exception('No access token available');
      }
      
      final response = await ApiService.updateOrderStatus(
        orderId: orderId,
        status: 4, // Cancelled status
        token: token,
      );
      
      // Accept both 200 and 204 as successful responses
      if (response.statusCode == 200 || response.statusCode == 204) {
        // Update local order data to cancelled status
        final orderIndex = orders.indexWhere((o) => o.orderId == orderId);
        if (orderIndex != -1) {
          orders[orderIndex] = orders[orderIndex].copyWith(status: 4);
        }
        
        _applyFilters();
        calculateAnalytics(); // Refresh analytics after cancellation
        return true;
      } else {
        // Handle error response
        String errorMessage = 'Failed to cancel order';
        if (response.body.isNotEmpty) {
          try {
            final errorData = jsonDecode(response.body);
            errorMessage = errorData['message'] ?? errorMessage;
          } catch (e) {
            // If JSON parsing fails, use the raw body or default message
            errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
          }
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      errorMessage = e.toString();
      print('❌ Error cancelling order: $e');
      return false;
    }
  }
  
  // Get status text
  String getStatusText(int status) {
    return statusNames[status] ?? 'Unknown';
  }
  
  // Get status color
  Color getStatusColor(int status) {
    return statusColors[status] ?? Colors.grey;
  }
  
  // Get analytics summary
  String getAnalyticsSummary(String key) {
    return analytics[key]?.toString() ?? '0';
  }
  
  // Get total orders count
  int get totalOrdersCount => orders.length;
  
  // Get filtered orders count
  int get filteredOrdersCount => filteredOrders.length;
  
  // Get status distribution for analytics
  Map<String, int> get statusDistribution {
    final distribution = <String, int>{};
    for (final order in orders) {
      final statusText = getStatusText(order.status);
      distribution[statusText] = (distribution[statusText] ?? 0) + 1;
    }
    return distribution;
  }
  
  // Check if order can be cancelled - DISABLED per backend rules
  bool canCancelOrder(OrderStruct order) {
    // Backend doesn't allow cancellation - only status progression
    // Paid → Shipped → Delivered
    return false; // Disable cancel functionality
  }
  
  // Check if order status can be updated based on backend rules
  bool canUpdateOrderStatus(OrderStruct order, int newStatus) {
    switch (order.status) {
      case 0: // Pending - Backend doesn't allow direct updates from Pending
        return false; // Backend requires manual payment processing
      case 1: // Paid - can only go to Shipped
        return newStatus == 2;
      case 2: // Shipped - can only go to Delivered
        return newStatus == 3;
      case 3: // Delivered - final status
        return false;
      case 4: // Cancelled - final status
        return false;
      default:
        return false;
    }
  }
  
  // Get allowed next statuses for an order
  List<int> getAllowedNextStatuses(OrderStruct order) {
    switch (order.status) {
      case 0: // Pending - Backend doesn't allow updates from Pending
        return []; // No updates allowed from Pending status
      case 1: // Paid - can only go to Shipped
        return [2]; // Can only go to Shipped
      case 2: // Shipped - can only go to Delivered
        return [3]; // Can only go to Delivered
      default:
        return []; // No further updates allowed
    }
  }
}

// Extension to add copyWith method to OrderStruct
extension OrderStructExtension on OrderStruct {
  OrderStruct copyWith({
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
  }) {
    return OrderStruct(
      orderId: orderId ?? this.orderId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      salesStaffId: salesStaffId ?? this.salesStaffId,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      address: address ?? this.address,
      orderDetails: orderDetails ?? this.orderDetails,
    );
  }
} 