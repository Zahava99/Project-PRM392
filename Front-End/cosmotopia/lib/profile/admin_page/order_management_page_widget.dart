import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/all_component/appbar/appbar_widget.dart';
import '/backend/schema/structs/index.dart';
import 'package:flutter/material.dart';
import 'order_management_page_model.dart';
export 'order_management_page_model.dart';

class OrderManagementPageWidget extends StatefulWidget {
  const OrderManagementPageWidget({super.key});

  static String routeName = 'OrderManagementPage';
  static String routePath = 'orderManagementPage';

  @override
  State<OrderManagementPageWidget> createState() => _OrderManagementPageWidgetState();
}

class _OrderManagementPageWidgetState extends State<OrderManagementPageWidget>
    with TickerProviderStateMixin {
  late OrderManagementPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OrderManagementPageModel());
    _tabController = TabController(length: 5, vsync: this); // Changed from 6 to 5 tabs
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
                  title: 'Order Management',
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
              
                    // Orders List
              Expanded(
                      child: _buildOrdersList(),
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
                    'Total Orders',
                    _model.getAnalyticsSummary('totalOrders'),
                    Icons.shopping_cart,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 12.0), // Reduced spacing
                Expanded(
                  child: _buildAnalyticsCard(
                    'Completed',
                    _model.getAnalyticsSummary('deliveredOrders'),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                SizedBox(width: 12.0), // Reduced spacing
                Expanded(
                  child: _buildAnalyticsCard(
                    'Revenue',
                    '₫${_formatCurrency(double.tryParse(_model.getAnalyticsSummary('totalRevenue')) ?? 0.0)}',
                    Icons.monetization_on,
                    Colors.orange,
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
                fontSize: 16.0, // Reduced from default headlineSmall
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
                hintText: 'Search orders...',
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
                    Icon(Icons.schedule, color: Colors.orange, size: 16),
                    SizedBox(width: 8),
                    Text('Pending'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.blue, size: 16),
                    SizedBox(width: 8),
                    Text('Paid'), // Changed from 'Confirmed' to 'Paid'
                  ],
                ),
              ),
              PopupMenuItem(
                value: 2,
                child: Row(
                  children: [
                    Icon(Icons.local_shipping, color: Colors.purple, size: 16),
                    SizedBox(width: 8),
                    Text('Shipped'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 3,
                child: Row(
                  children: [
                    Icon(Icons.done_all, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Text('Delivered'),
                  ],
                ),
              ),
              // Removed Cancelled option from filter dropdown
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
          Tab(text: 'All (${_model.filteredOrdersCount})'),
          Tab(text: 'Pending (${_model.statusDistribution['Pending'] ?? 0})'),
          Tab(text: 'Paid (${_model.statusDistribution['Paid'] ?? 0})'), // Changed from 'Confirmed'
          Tab(text: 'Shipped (${_model.statusDistribution['Shipped'] ?? 0})'),
          Tab(text: 'Delivered (${_model.statusDistribution['Delivered'] ?? 0})'),
          // Removed Cancelled tab
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
            case 4:
              _model.setStatusFilter(3);
              break;
            // Removed case 5 for Cancelled
          }
          safeSetState(() {});
        },
      ),
    );
  }

  Widget _buildOrdersList() {
    return Builder(
      builder: (context) {
        if (_model.isLoading && _model.orders.isEmpty) {
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
                  'Error loading orders',
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
                    _model.loadOrders(refresh: true);
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

        if (_model.filteredOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No orders found',
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
            await _model.loadOrders(refresh: true);
            safeSetState(() {});
          },
          child: ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: _model.filteredOrders.length + (_model.hasMoreData ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _model.filteredOrders.length) {
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
                          _model.loadOrders();
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

              final order = _model.filteredOrders[index];
              return _buildOrderCard(order);
            },
          ),
        );
      },
    );
  }

  Widget _buildOrderCard(OrderStruct order) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () {
          _showOrderDetailsDialog(order);
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: EdgeInsets.all(16.0),
      child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.orderId}',
                        style: FlutterFlowTheme.of(context).titleMedium.override(
                            fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                        SizedBox(height: 4),
                      Text(
                          order.customerName,
                          style: FlutterFlowTheme.of(context).bodyMedium,
                      ),
                        SizedBox(height: 2),
                      Text(
                          order.phoneNumber,
                          style: FlutterFlowTheme.of(context).bodySmall,
                      ),
                    ],
                  ),
                ),
                  // Status Badge
                    Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _model.getStatusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                            color: _model.getStatusColor(order.status),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _model.getStatusText(order.status),
                      style: FlutterFlowTheme.of(context).labelSmall.override(
                        fontFamily: 'Inter',
                              color: _model.getStatusColor(order.status),
                        fontWeight: FontWeight.w600,
                      ),
                            ),
                          ),
                        ],
                      ),
              
              SizedBox(height: 12),
              
              // Order Info
              Row(
                children: [
                  Icon(Icons.monetization_on, size: 16, color: Colors.green),
                  SizedBox(width: 4),
                                      Text(
                    '₫${order.totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
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
                    _formatDate(order.orderDate),
                    style: FlutterFlowTheme.of(context).bodySmall,
                    ),
                  ],
                ),
              
              SizedBox(height: 8),
          
              // Payment Method
                Row(
                  children: [
                  Icon(Icons.payment, size: 16, color: Colors.blue),
                  SizedBox(width: 4),
                    Text(
                    order.paymentMethod,
                    style: FlutterFlowTheme.of(context).bodySmall,
                    ),
                  ],
                ),
              
              SizedBox(height: 8),
              
              // Address
                Row(
                  children: [
                  Icon(Icons.location_on, size: 16, color: Colors.red),
                  SizedBox(width: 4),
                    Expanded(
                      child: Text(
                      order.address,
                      style: FlutterFlowTheme.of(context).bodySmall,
                      maxLines: 2,
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
                      _showOrderDetailsDialog(order);
                    },
                    icon: Icon(Icons.visibility, size: 16),
                    label: Text('View Details'),
                    style: TextButton.styleFrom(
                      foregroundColor: FlutterFlowTheme.of(context).primary,
                  ),
                ),
                  SizedBox(width: 8),
                                    // Only show Edit button if order can be updated
                  if (_model.getAllowedNextStatuses(order).isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        _model.openEditDialog(order);
                        _showEditStatusDialog();
                      },
                      icon: Icon(Icons.edit, size: 16),
                      label: Text('Update Status'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                    ),
              ],
          ),
        ],
      ),
        ),
      ),
    );
  }

  void _showOrderDetailsDialog(OrderStruct order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: Text('Order Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Order ID', order.orderId),
              _buildDetailRow('Customer', order.customerName),
              _buildDetailRow('Phone', order.phoneNumber),
              _buildDetailRow('Status', _model.getStatusText(order.status)),
              _buildDetailRow('Total Amount', '₫${order.totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}'),
              _buildDetailRow('Order Date', _formatDate(order.orderDate)),
                _buildDetailRow('Payment Method', order.paymentMethod),
              _buildDetailRow('Address', order.address),
              
              if (order.orderDetails.isNotEmpty) ...[
                SizedBox(height: 16),
                Text(
                  'Order Items:',
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                ...order.orderDetails.map((detail) => Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                        detail.name,
                          style: FlutterFlowTheme.of(context).bodyMedium,
                        ),
                      ),
                      Text(
                        '${detail.quantity}x ₫${_formatCurrency(detail.unitPrice)}',
                        style: FlutterFlowTheme.of(context).bodySmall,
                      ),
                    ],
                  ),
                )),
              ],
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
            width: 100,
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

    void _showEditStatusDialog() {
    final allowedStatuses = _model.getAllowedNextStatuses(_model.selectedOrder!);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Order Status'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order #${_model.selectedOrder?.orderId}'),
                SizedBox(height: 8),
                Text(
                  'Current Status: ${_model.getStatusText(_model.selectedOrder!.status)}',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    color: _model.getStatusColor(_model.selectedOrder!.status),
                  ),
                ),
                SizedBox(height: 16),
                if (allowedStatuses.isNotEmpty) ...[
                  Text('Select next status:'),
                  SizedBox(height: 8),
                  ...allowedStatuses.map((statusId) {
                    return RadioListTile<int>(
                      title: Text(_model.statusNames[statusId] ?? 'Unknown'),
                      subtitle: Text(_getStatusDescription(statusId)),
                      value: statusId,
                      groupValue: _model.selectedOrderStatus,
                      onChanged: (value) {
                        _model.selectedOrderStatus = value;
                        setDialogState(() {});
                      },
                    );
                  }),
                ] else ...[
                  Text(
                    _getNoUpdateMessage(_model.selectedOrder!.status),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Inter',
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              _model.closeEditDialog();
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          if (allowedStatuses.isNotEmpty)
            TextButton(
              onPressed: _model.selectedOrderStatus != null ? () async {
                final success = await _model.saveOrderChanges();
                Navigator.of(context).pop();
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Order status updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  safeSetState(() {});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update order status: ${_model.errorMessage}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } : null,
              child: Text('Update'),
            ),
        ],
      ),
    );
  }
  
  String _getStatusDescription(int statusId) {
    switch (statusId) {
      case 1: return 'Mark as paid (payment confirmed)';
      case 2: return 'Mark as shipped and provide tracking';
      case 3: return 'Mark as delivered to customer';
      default: return '';
    }
  }
  
  String _getNoUpdateMessage(int currentStatus) {
    switch (currentStatus) {
      case 0: return 'Pending orders cannot be updated directly. Payment must be processed first to change status to "Paid".';
      case 3: return 'This order has been delivered and cannot be updated further.';
      case 4: return 'This order has been cancelled and cannot be updated further.';
      default: return 'This order has reached its final status and cannot be updated further.';
    }
  }

  

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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
} 