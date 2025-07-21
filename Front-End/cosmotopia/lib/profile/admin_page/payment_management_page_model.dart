import '/backend/api_service.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/all_component/appbar/appbar_model.dart';
import 'payment_management_page_widget.dart' show PaymentManagementPageWidget;
import 'package:flutter/material.dart';
import 'dart:convert';

class PaymentManagementPageModel
    extends FlutterFlowModel<PaymentManagementPageWidget> {
  ///  Local state fields for this page.

  List<PaymentTransactionStruct> payments = [];
  List<PaymentTransactionStruct> filteredPayments = [];
  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';
  int currentPage = 1;
  int totalPages = 1;
  bool hasMoreData = true;
  int? selectedStatusFilter;
  String searchQuery = '';

  // Selected payment for details
  PaymentTransactionStruct? selectedPayment;

  // Analytics data
  bool isLoadingAnalytics = false;
  Map<String, dynamic> analyticsData = {};

  // Status distribution for tabs
  Map<String, int> statusDistribution = {
    'Pending': 0,
    'Success': 0,
    'Failed': 0,
  };

  ///  State fields for stateful widgets in this page.

  late AppbarModel appbarModel;

  @override
  void initState(BuildContext context) {
    appbarModel = createModel(context, () => AppbarModel());
    loadPayments(); // calculateAnalytics() will be called after payments are loaded
  }

  @override
  void dispose() {
    appbarModel.dispose();
  }

  // Load payments with pagination
  Future<void> loadPayments({bool refresh = false}) async {
    if (refresh) {
      currentPage = 1;
      payments.clear();
      hasMoreData = true;
    }

    if (isLoading || !hasMoreData) return;

    isLoading = true;
    hasError = false;
    errorMessage = '';

    try {
      final token = FFAppState().token;
      if (token.isEmpty) {
        throw Exception('No access token available');
      }

      final response = await ApiService.getAllPayments(
        page: currentPage,
        pageSize: 10,
        status: selectedStatusFilter?.toString(),
        token: token,
      );

      print('📤 Load payments - Status Code: ${response.statusCode}');
      print('📤 Load payments - Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> paymentList = data['payments'] ?? [];
        
        final newPayments = <PaymentTransactionStruct>[];
        for (var json in paymentList) {
          try {
            print('🔍 Processing payment JSON: $json');
            final payment = PaymentTransactionStruct.fromMap(json);
            print('  Parsed payment: ID=${payment.transactionId}, Status=${payment.status}, Amount=${payment.amount}');
            newPayments.add(payment);
          } catch (e) {
            print('❌ Error parsing payment: $e');
            print('❌ JSON data: $json');
          }
        }

        if (refresh) {
          payments = newPayments;
        } else {
          payments.addAll(newPayments);
        }

        totalPages = data['totalPages'] ?? 1;
        hasMoreData = currentPage < totalPages;
        
        if (hasMoreData) {
          currentPage++;
        }

        // Recalculate analytics after loading payments
        calculateAnalytics();
      } else {
        throw Exception('Failed to load payments: ${response.statusCode}');
      }
    } catch (e) {
      hasError = true;
      errorMessage = e.toString();
      print('❌ Error loading payments: $e');
    } finally {
      isLoading = false;
    }
  }



  // Update payment status
  Future<bool> updatePaymentStatus(String transactionId, int newStatus) async {
    try {
      final token = FFAppState().token;
      if (token.isEmpty) {
        throw Exception('No access token available');
      }

      final response = await ApiService.updatePaymentStatus(
        transactionId: transactionId,
        newStatus: newStatus,
        token: token,
      );

      print('📤 Update payment status - Status Code: ${response.statusCode}');
      print('📤 Update payment status - Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Update local payment data
        final paymentIndex = payments.indexWhere((p) => p.transactionId == transactionId);
        if (paymentIndex != -1) {
          final updatedPayment = payments[paymentIndex];
          updatedPayment.status = newStatus.toString();
          payments[paymentIndex] = updatedPayment;
        }
        
        // Recalculate analytics after status update
        calculateAnalytics();
        return true;
      } else {
        throw Exception('Failed to update payment status: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage = e.toString();
      print('❌ Error updating payment status: $e');
      return false;
    }
  }



  // Calculate analytics from existing payments data
  void calculateAnalytics() {
    isLoadingAnalytics = true;
    
    try {
      int totalPayments = payments.length;
      int pendingPayments = payments.where((p) => p.status == '0').length;
      int successPayments = payments.where((p) => p.status == '1').length;
      int failedPayments = payments.where((p) => p.status == '2').length;
      
      double totalRevenue = payments
          .where((p) => p.status == '1')
          .fold(0.0, (sum, p) => sum + p.amount);
      
      double pendingAmount = payments
          .where((p) => p.status == '0')
          .fold(0.0, (sum, p) => sum + p.amount);
      
      print('🔍 Analytics Debug:');
      print('  Total Payments: $totalPayments');
      print('  Pending Payments: $pendingPayments');
      print('  Success Payments: $successPayments');
      print('  Failed Payments: $failedPayments');
      print('  Total Revenue: $totalRevenue');
      print('  Pending Amount: $pendingAmount');
      
      analyticsData = {
        'totalPayments': totalPayments,
        'pendingPayments': pendingPayments,
        'successPayments': successPayments,
        'failedPayments': failedPayments,
        'totalRevenue': totalRevenue,
        'pendingAmount': pendingAmount,
        'successRate': totalPayments > 0 ? (successPayments / totalPayments * 100) : 0.0,
      };

      // Apply filters after calculating analytics
      _applyFilters();
    } catch (e) {
      print('❌ Error calculating analytics: $e');
      analyticsData = {
        'totalPayments': 0,
        'pendingPayments': 0,
        'successPayments': 0,
        'failedPayments': 0,
        'totalRevenue': 0.0,
        'pendingAmount': 0.0,
        'successRate': 0.0,
      };
    } finally {
      isLoadingAnalytics = false;
    }
  }

  // Get payment status color
  Color getStatusColor(String status) {
    switch (status) {
      case '1': // Success
        return Colors.green;
      case '2': // Failed
        return Colors.red;
      case '0': // Pending
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Get payment status text
  String getStatusText(String status) {
    switch (status) {
      case '1':
        return 'Success';
      case '2':
        return 'Failed';
      case '0':
        return 'Pending';
      default:
        return 'Unknown';
    }
  }

  // Get payment status icon
  IconData getStatusIcon(String status) {
    switch (status) {
      case '1': // Success
        return Icons.check_circle;
      case '2': // Failed
        return Icons.error;
      case '0': // Pending
        return Icons.schedule;
      default:
        return Icons.help;
    }
  }

  // Format date
  String formatDate(dynamic date) {
    if (date == null) return 'N/A';
    
    DateTime? dateTime;
    if (date is String) {
      try {
        dateTime = DateTime.parse(date);
      } catch (e) {
        return date; // Return original string if parsing fails
      }
    } else if (date is DateTime) {
      dateTime = date;
    } else {
      return 'N/A';
    }
    
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Format currency
  String formatCurrency(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }

  // Search and filter methods
  void setSearchQuery(String query) {
    searchQuery = query;
    _applyFilters();
  }

  void setStatusFilter(int? status) {
    selectedStatusFilter = status;
    _applyFilters();
  }

  void _applyFilters() {
    filteredPayments = payments.where((payment) {
      bool matchesSearch = searchQuery.isEmpty ||
          payment.transactionId.toLowerCase().contains(searchQuery.toLowerCase()) ||
          payment.orderId.toLowerCase().contains(searchQuery.toLowerCase()) ||
          payment.paymentMethod.toLowerCase().contains(searchQuery.toLowerCase());

      bool matchesStatus = selectedStatusFilter == null || payment.status == selectedStatusFilter.toString();

      return matchesSearch && matchesStatus;
    }).toList();

    _updateStatusDistribution();
  }

  void _updateStatusDistribution() {
    statusDistribution = {
      'Pending': payments.where((p) => p.status == '0').length,
      'Success': payments.where((p) => p.status == '1').length,
      'Failed': payments.where((p) => p.status == '2').length,
    };
  }

  int get filteredPaymentsCount => filteredPayments.length;

  // Delete functionality commented out due to business rules
  // Future<bool> deletePayment(String paymentId) async {
  //   try {
  //     final token = FFAppState().token;
  //     if (token.isEmpty) {
  //       throw Exception('No access token available');
  //     }

  //     final response = await ApiService.deletePayment(
  //       paymentId: paymentId,
  //       token: token,
  //     );

  //     if (response.statusCode == 200 || response.statusCode == 204) {
  //       // Remove from local list
  //       payments.removeWhere((p) => p.transactionId == paymentId);
  //       calculateAnalytics();
  //       return true;
  //     } else {
  //       throw Exception('Failed to delete payment: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     errorMessage = e.toString();
  //     print('❌ Error deleting payment: $e');
  //     return false;
  //   }
  // }
} 