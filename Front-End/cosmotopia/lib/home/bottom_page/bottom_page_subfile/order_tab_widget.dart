import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '/all_component/order_empty/order_empty_widget.dart';
import '/all_component/order_empty/order_empty_model.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cosmotopia/backend/schema/structs/order_struct.dart';
import 'bottom_page_helpers.dart';
import '../bottom_page_model.dart';

class OrderTabWidget extends StatelessWidget {
  final BottomPageModel model;
  final Map<String, AnimationInfo> animationsMap;
  final List<OrderStruct> activeOrders;
  final List<OrderStruct> completedOrders;
  final bool isLoadingOrders;
  final String? ordersError;

  const OrderTabWidget({
    super.key,
    required this.model,
    required this.animationsMap,
    required this.activeOrders,
    required this.completedOrders,
    required this.isLoadingOrders,
    this.ordersError,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 63.0, 0.0, 16.0),
          child: Text(
            'My Order',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'SF Pro Text',
                  fontSize: 24.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                  lineHeight: 1.5,
                ),
          ).animateOnPageLoad(animationsMap['textOnPageLoadAnimation1']!),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
            child: Column(
              children: [
                Align(
                  alignment: Alignment(0.0, 0),
                  child: TabBar(
                    labelColor: FlutterFlowTheme.of(context).primary,
                    unselectedLabelColor: FlutterFlowTheme.of(context).black40,
                    labelStyle: FlutterFlowTheme.of(context).titleMedium.override(
                          fontFamily: 'SF Pro Text',
                          fontSize: 16.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                        ),
                    unselectedLabelStyle: TextStyle(),
                    indicatorColor: FlutterFlowTheme.of(context).primary,
                    padding: EdgeInsets.all(4.0),
                    tabs: [
                      Tab(text: 'Active'),
                      Tab(text: 'Completed'),
                    ],
                    controller: model.tabBarController,
                    onTap: (i) async {
                      [() async {}, () async {}][i]();
                    },
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: model.tabBarController,
                    children: [
                      // Active Orders Tab
                      _buildOrdersTab(context, activeOrders, model.orderEmptyModel1),
                      // Completed Orders Tab
                      _buildOrdersTab(context, completedOrders, model.orderEmptyModel2),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersTab(BuildContext context, List<OrderStruct> orders, OrderEmptyModel orderEmptyModel) {
    if (isLoadingOrders) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (ordersError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
            SizedBox(height: 16),
            Text(
              'Error loading orders',
              style: FlutterFlowTheme.of(context).bodyMedium,
            ),
            Text(
              ordersError!,
              style: FlutterFlowTheme.of(context).bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    if (orders.isEmpty) {
      return wrapWithModel(
        model: orderEmptyModel,
        updateCallback: () => {},
        child: OrderEmptyWidget(),
      );
    }
    
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(0, 24.0, 0, 24.0),
      scrollDirection: Axis.vertical,
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _buildOrderItem(context, orders[index]);
      },
    );
  }

  Widget _buildOrderItem(BuildContext context, OrderStruct order) {
    final orderDetail = order.orderDetails.isNotEmpty ? order.orderDetails.first : null;
    final orderDate = DateTime.tryParse(order.orderDate);
    final formattedDate = orderDate != null 
        ? DateFormat('dd MMM,yyyy').format(orderDate)
        : order.orderDate;

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 16.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          boxShadow: [
            BoxShadow(
              blurRadius: 16.0,
              color: FlutterFlowTheme.of(context).shadowColor,
              offset: Offset(0.0, 4.0),
            )
          ],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Header with ID and Date
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      'ID',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'SF Pro Text',
                            fontSize: 16.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                            lineHeight: 1.5,
                          ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(1.0, 0.0, 0.0, 0.0),
                      child: Text(
                        order.orderId.length > 6 
                            ? order.orderId.substring(order.orderId.length - 6)
                            : order.orderId,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'SF Pro Text',
                              color: FlutterFlowTheme.of(context).black40,
                              fontSize: 17.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.normal,
                              lineHeight: 1.5,
                            ),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: AlignmentDirectional(1.0, -1.0),
                        child: Text(
                          formattedDate,
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'SF Pro Text',
                                color: FlutterFlowTheme.of(context).black40,
                                fontSize: 17.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.normal,
                                lineHeight: 1.5,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              Divider(
                height: 0.0,
                thickness: 1.0,
                color: FlutterFlowTheme.of(context).black40,
              ),
              
              // Product info
              if (orderDetail != null)
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 12.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: orderDetail.imageUrl.isNotEmpty && orderDetail.imageUrl.startsWith('http')
                            ? Image.network(
                                orderDetail.imageUrl,
                                width: 89.0,
                                height: 89.0,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Image.asset(
                                  'assets/images/placeholder.png',
                                  width: 89.0,
                                  height: 89.0,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Image.asset(
                                'assets/images/placeholder.png',
                                width: 89.0,
                                height: 89.0,
                                fit: BoxFit.cover,
                              ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 0.0, 0.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                orderDetail.name,
                                maxLines: 2,
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      fontFamily: 'SF Pro Text',
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                      lineHeight: 1.5,
                                    ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 7.0, 0.0, 0.0),
                                child: Text(
                                  NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(orderDetail.unitPrice),
                                  maxLines: 1,
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        fontFamily: 'SF Pro Text',
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                        lineHeight: 1.5,
                                      ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                                child: Text(
                                  'Qty: ${orderDetail.quantity}',
                                  maxLines: 1,
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        fontFamily: 'SF Pro Text',
                                        color: FlutterFlowTheme.of(context).secondaryText,
                                        fontSize: 14.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.normal,
                                        lineHeight: 1.5,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Status
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: BottomPageHelpers.getStatusColor(order.status, context).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(44.0),
                        border: Border.all(
                          color: BottomPageHelpers.getStatusColor(order.status, context),
                          width: 1.0,
                        ),
                      ),
                      child: Align(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 7.0, 0.0, 7.0),
                          child: Text(
                            BottomPageHelpers.getStatusText(order.status),
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: 'SF Pro Text',
                                  color: BottomPageHelpers.getStatusColor(order.status, context),
                                  fontSize: 14.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ),
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
} 