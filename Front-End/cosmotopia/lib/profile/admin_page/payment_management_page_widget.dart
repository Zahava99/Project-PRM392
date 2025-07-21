import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/all_component/appbar/appbar_widget.dart';
import '/backend/api_service.dart';
import '/backend/schema/structs/index.dart';

import 'payment_management_page_model.dart';
export 'payment_management_page_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentManagementPageWidget extends StatefulWidget {
  const PaymentManagementPageWidget({super.key});

  static String routeName = 'PaymentManagementPage';
  static String routePath = 'paymentManagementPage';

  @override
  State<PaymentManagementPageWidget> createState() =>
      _PaymentManagementPageWidgetState();
}

class _PaymentManagementPageWidgetState
    extends State<PaymentManagementPageWidget> with TickerProviderStateMixin {
  late PaymentManagementPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PaymentManagementPageModel());
    _tabController = TabController(length: 4, vsync: this); // All, Pending, Success, Failed
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Column(
            children: [
              // App Bar
              wrapWithModel(
                model: _model.appbarModel,
                updateCallback: () => safeSetState(() {}),
                child: AppbarWidget(
                  title: 'Payment Management',
                  showBack: true,
                ),
              ),
              
              // Content
              Expanded(
                child: Column(
                  children: [
                    // Analytics Dashboard
                    _buildAnalyticsDashboard(),
              
                    // Search and Filter Section
                    _buildSearchAndFilter(),
                    
                    // Status Tabs
                    _buildStatusTabs(),
              
                    // Payments List
                    Expanded(
                      child: _buildPaymentsList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsDashboard() {
    return Container(
      margin: EdgeInsets.all(16.0),
      child: Builder(
        builder: (context) {
          if (_model.isLoadingAnalytics) {
            return Container(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  blurRadius: 8.0,
                  color: FlutterFlowTheme.of(context).shadowColor,
                  offset: Offset(0.0, 2.0),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildAnalyticsCard(
                    'Total Payments',
                    '${_model.analyticsData['totalPayments'] ?? 0}',
                    Icons.payment,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 12.0),
                Expanded(
                  child: _buildAnalyticsCard(
                    'Revenue',
                    '₫${_formatCurrency(double.tryParse(_model.analyticsData['totalRevenue']?.toString() ?? '0') ?? 0.0)}',
                    Icons.monetization_on,
                    Colors.orange,
                  ),
                ),
                SizedBox(width: 12.0),
                Expanded(
                  child: _buildAnalyticsCard(
                    'Pending Amount',
                    '₫${_formatCurrency(double.tryParse(_model.analyticsData['pendingAmount']?.toString() ?? '0') ?? 0.0)}',
                    Icons.hourglass_empty,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24.0),
          SizedBox(height: 8.0),
          Text(
            title,
            style: FlutterFlowTheme.of(context).labelMedium.override(
              fontFamily: 'Inter',
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.0),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: FlutterFlowTheme.of(context).titleMedium.override(
                fontFamily: 'Inter',
                color: color,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search payments...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              ),
              onChanged: (value) {
                _model.setSearchQuery(value);
                safeSetState(() {});
              },
            ),
          ),
          SizedBox(width: 8.0),
          PopupMenuButton<int?>(
            icon: Icon(Icons.filter_list),
            onSelected: (value) {
              _model.setStatusFilter(value);
              safeSetState(() {});
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: null,
                child: Text('All Status'),
              ),
              PopupMenuItem(
                value: 0,
                child: Row(
                  children: [
                    Icon(Icons.hourglass_empty, color: Colors.orange, size: 16),
                    SizedBox(width: 8),
                    Text('Pending'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Text('Success'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 2,
                child: Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.red, size: 16),
                    SizedBox(width: 8),
                    Text('Failed'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTabs() {
    return Container(
      height: 50.0,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: FlutterFlowTheme.of(context).primary,
        labelColor: FlutterFlowTheme.of(context).primaryText,
        unselectedLabelColor: FlutterFlowTheme.of(context).secondaryText,
        tabs: [
          Tab(text: 'All (${_model.filteredPaymentsCount})'),
          Tab(text: 'Pending (${_model.statusDistribution['Pending'] ?? 0})'),
          Tab(text: 'Success (${_model.statusDistribution['Success'] ?? 0})'),
          Tab(text: 'Failed (${_model.statusDistribution['Failed'] ?? 0})'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              _model.setStatusFilter(null);
              break;
            case 1:
              _model.setStatusFilter(0);
              break;
            case 2:
              _model.setStatusFilter(1);
              break;
            case 3:
              _model.setStatusFilter(2);
              break;
          }
          safeSetState(() {});
        },
      ),
    );
  }

  Widget _buildPaymentsList() {
    return Builder(
      builder: (context) {
        if (_model.isLoading && _model.payments.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        if (_model.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Error loading payments',
                  style: FlutterFlowTheme.of(context).headlineSmall,
                ),
                SizedBox(height: 8),
                Text(
                  _model.errorMessage,
                  style: FlutterFlowTheme.of(context).bodyMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                FFButtonWidget(
                  onPressed: () {
                    _model.loadPayments(refresh: true);
                    safeSetState(() {});
                  },
                  text: 'Retry',
                  options: FFButtonOptions(
                    width: 120,
                    height: 40,
                    padding: EdgeInsets.zero,
                    iconPadding: EdgeInsets.zero,
                    color: FlutterFlowTheme.of(context).primary,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                      fontFamily: 'Inter',
                      color: Colors.white,
                    ),
                    elevation: 2,
                    borderSide: BorderSide(
                      color: Colors.transparent,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          );
        }

        if (_model.filteredPayments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.payment_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No payments found',
                  style: FlutterFlowTheme.of(context).headlineSmall,
                ),
                SizedBox(height: 8),
                Text(
                  'Try adjusting your filters or search query',
                  style: FlutterFlowTheme.of(context).bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await _model.loadPayments(refresh: true);
            safeSetState(() {});
          },
          child: ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: _model.filteredPayments.length + (_model.hasMoreData ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _model.filteredPayments.length) {
                // Load more indicator
                if (_model.isLoading) {
                  return Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else {
                  return Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: FFButtonWidget(
                        onPressed: () {
                          _model.loadPayments();
                          safeSetState(() {});
                        },
                        text: 'Load More',
                        options: FFButtonOptions(
                          width: 120,
                          height: 40,
                          padding: EdgeInsets.zero,
                          iconPadding: EdgeInsets.zero,
                          color: FlutterFlowTheme.of(context).primary,
                          textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                            fontFamily: 'Inter',
                            color: Colors.white,
                          ),
                          elevation: 2,
                          borderSide: BorderSide(
                            color: Colors.transparent,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  );
                }
              }

              final payment = _model.filteredPayments[index];
              return _buildPaymentCard(payment);
            },
          ),
        );
      },
    );
  }

  Widget _buildPaymentCard(PaymentTransactionStruct payment) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () {
          _showPaymentDetailsDialog(payment);
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment #${payment.transactionId}',
                          style: FlutterFlowTheme.of(context).titleMedium.override(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Order #${payment.orderId}',
                          style: FlutterFlowTheme.of(context).bodyMedium,
                        ),
                        SizedBox(height: 2),
                        Text(
                          payment.paymentMethod,
                          style: FlutterFlowTheme.of(context).bodySmall,
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _model.getStatusColor(payment.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _model.getStatusColor(payment.status),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _model.getStatusText(payment.status),
                      style: FlutterFlowTheme.of(context).labelSmall.override(
                        fontFamily: 'Inter',
                        color: _model.getStatusColor(payment.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              // Payment Info
              Row(
                children: [
                  Icon(Icons.monetization_on, size: 16, color: Colors.green),
                  SizedBox(width: 4),
                  Text(
                    '₫${payment.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                    style: FlutterFlowTheme.of(context).titleMedium.override(
                      fontFamily: 'Inter',
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    _model.formatDate(payment.transactionDate),
                    style: FlutterFlowTheme.of(context).bodySmall,
                  ),
                ],
              ),
              
              SizedBox(height: 8),
              
              // Transaction ID
              Row(
                children: [
                  Icon(Icons.receipt, size: 16, color: Colors.blue),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Ref: ${payment.transactionId}',
                      style: FlutterFlowTheme.of(context).bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      _showPaymentDetailsDialog(payment);
                    },
                    icon: Icon(Icons.visibility, size: 16),
                    label: Text('View Details'),
                    style: TextButton.styleFrom(
                      foregroundColor: FlutterFlowTheme.of(context).primary,
                    ),
                  ),
                  SizedBox(width: 8),
                  if (payment.status == '0') // Only show update for pending payments
                    TextButton.icon(
                      onPressed: () {
                        _showUpdateStatusDialog(payment);
                      },
                      icon: Icon(Icons.edit, size: 16),
                      label: Text('Update Status'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                    ),
                  // Delete functionality commented out due to business rules
                  // SizedBox(width: 8),
                  // TextButton.icon(
                  //   onPressed: () {
                  //     _showDeleteConfirmDialog(payment);
                  //   },
                  //   icon: Icon(Icons.delete, size: 16),
                  //   label: Text('Delete'),
                  //   style: TextButton.styleFrom(
                  //     foregroundColor: Colors.red,
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentDetailsDialog(PaymentTransactionStruct payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Transaction ID', payment.transactionId),
              _buildDetailRow('Order ID', payment.orderId),
              _buildDetailRow('Status', _model.getStatusText(payment.status)),
              _buildDetailRow('Amount', '₫${payment.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}'),
              _buildDetailRow('Payment Method', payment.paymentMethod),
              _buildDetailRow('Transaction Date', _model.formatDate(payment.transactionDate)),
              _buildDetailRow('Order Date', _model.formatDate(payment.orderInfo.orderDate)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: FlutterFlowTheme.of(context).bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdateStatusDialog(PaymentTransactionStruct payment) {
    int? selectedStatus;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Update Payment Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Payment #${payment.transactionId}'),
              SizedBox(height: 8),
              Text(
                'Current Status: ${_model.getStatusText(payment.status)}',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: _model.getStatusColor(payment.status),
                ),
              ),
              SizedBox(height: 16),
              Text('Select new status:'),
              SizedBox(height: 8),
              RadioListTile<int>(
                title: Text('Success'),
                subtitle: Text('Mark payment as successful'),
                value: 1,
                groupValue: selectedStatus,
                onChanged: (value) {
                  selectedStatus = value;
                  setDialogState(() {});
                },
              ),
              RadioListTile<int>(
                title: Text('Failed'),
                subtitle: Text('Mark payment as failed'),
                value: 2,
                groupValue: selectedStatus,
                onChanged: (value) {
                  selectedStatus = value;
                  setDialogState(() {});
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: selectedStatus != null ? () async {
                final success = await _model.updatePaymentStatus(payment.transactionId, selectedStatus!);
                Navigator.of(context).pop();
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Payment status updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  safeSetState(() {});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update payment status'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } : null,
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  // Delete functionality commented out due to business rules
  // void _showDeleteConfirmDialog(PaymentTransactionStruct payment) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text('Delete Payment'),
  //       content: Text('Are you sure you want to delete this payment record? This action cannot be undone.'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.of(context).pop(),
  //           child: Text('Cancel'),
  //         ),
  //         TextButton(
  //           onPressed: () async {
  //             Navigator.of(context).pop();
  //             final success = await _model.deletePayment(payment.transactionId);
  //             if (success) {
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 SnackBar(
  //                   content: Text('Payment deleted successfully'),
  //                   backgroundColor: Colors.green,
  //                 ),
  //               );
  //               safeSetState(() {});
  //             } else {
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 SnackBar(
  //                   content: Text('Failed to delete payment'),
  //                   backgroundColor: Colors.red,
  //                 ),
  //               );
  //             }
  //           },
  //           style: TextButton.styleFrom(foregroundColor: Colors.red),
  //           child: Text('Delete'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  String _formatCurrency(double amount) {
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

  // Delete functionality commented out due to business rules
  // Future<void> _deletePayment(String transactionId) async {
  //   final success = await _model.deletePayment(transactionId);
  //   if (success) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Payment deleted successfully'),
  //         backgroundColor: Colors.green,
  //       ),
  //     );
  //     safeSetState(() {});
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Failed to delete payment'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }
} 