import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/home/bottom_page/bottom_page_widget.dart';
import '/backend/api_service.dart';

class PaymentSuccessPageWidget extends StatefulWidget {
  const PaymentSuccessPageWidget({
    super.key,
    this.orderCode,
    this.amount,
  });

  final String? orderCode;
  final String? amount;

  static String routeName = 'PaymentSuccessPage';
  static String routePath = '/payment-success';

  @override
  State<PaymentSuccessPageWidget> createState() => _PaymentSuccessPageWidgetState();
}

class _PaymentSuccessPageWidgetState extends State<PaymentSuccessPageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    print('✅ PaymentSuccessPage initialized with orderCode: ${widget.orderCode}, amount: ${widget.amount}');
    
    // Clear cart sau khi thanh toán thành công
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Clear FFAppState orderlist
      FFAppState().orderlist = [];
      FFAppState().update(() {});
      
      // Also clear cart via API
      try {
        final cartCleared = await ApiService.clearAllCart(token: FFAppState().token);
        if (cartCleared) {
          print('🛒 ✅ Cart cleared successfully via API after bank transfer payment');
        } else {
          print('🛒 ❌ Failed to clear cart via API after bank transfer payment');
        }
      } catch (e) {
        print('🛒 ❌ Error clearing cart via API: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      body: SafeArea(
        top: true,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(24.0, 48.0, 24.0, 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon
              Container(
                width: 120.0,
                height: 120.0,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(60.0),
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 60.0,
                ),
              ),
              
              const SizedBox(height: 32.0),
              
              // Success Title
              Text(
                'Thanh toán thành công!',
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'SF Pro Display',
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16.0),
              
              // Success Message
              Text(
                'Cảm ơn bạn đã mua hàng! Đơn hàng của bạn đã được xác nhận và sẽ được xử lý sớm nhất.',
                style: FlutterFlowTheme.of(context).bodyLarge.override(
                  fontFamily: 'SF Pro Text',
                  color: FlutterFlowTheme.of(context).secondaryText,
                  fontSize: 16.0,
                  lineHeight: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24.0),
              
              // Order Info Card
              if (widget.orderCode != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 16.0),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).alternate,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: FlutterFlowTheme.of(context).primaryBackground,
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Mã đơn hàng:',
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'SF Pro Text',
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                          ),
                          Text(
                            widget.orderCode!,
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'SF Pro Text',
                              color: FlutterFlowTheme.of(context).primaryText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (widget.amount != null) ...[
                        const SizedBox(height: 8.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Số tiền:',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'SF Pro Text',
                                color: FlutterFlowTheme.of(context).secondaryText,
                              ),
                            ),
                            Text(
                              '${widget.amount} VND',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'SF Pro Text',
                                color: FlutterFlowTheme.of(context).primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32.0),
              ],
              
              // Continue Shopping Button
              FFButtonWidget(
                onPressed: () async {
                  context.goNamed(BottomPageWidget.routeName);
                },
                text: 'Tiếp tục mua sắm',
                options: FFButtonOptions(
                  width: double.infinity,
                  height: 56.0,
                  padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                  iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  color: FlutterFlowTheme.of(context).primary,
                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                    fontFamily: 'SF Pro Text',
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                  elevation: 0.0,
                  borderSide: const BorderSide(
                    color: Colors.transparent,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              
              const SizedBox(height: 16.0),
              
              // View Orders Button
              // FFButtonWidget(
              //   onPressed: () async {
              //     // Navigate to orders page (you can implement this)
              //     context.goNamed(BottomPageWidget.routeName);
              //   },
              //   text: 'Xem đơn hàng của tôi',
              //   options: FFButtonOptions(
              //     width: double.infinity,
              //     height: 56.0,
              //     padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
              //     iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
              //     color: Colors.transparent,
              //     textStyle: FlutterFlowTheme.of(context).titleSmall.override(
              //       fontFamily: 'SF Pro Text',
              //       color: FlutterFlowTheme.of(context).primary,
              //       fontSize: 16.0,
              //       fontWeight: FontWeight.w600,
              //     ),
              //     elevation: 0.0,
              //     borderSide: BorderSide(
              //       color: FlutterFlowTheme.of(context).primary,
              //       width: 2.0,
              //     ),
              //     borderRadius: BorderRadius.circular(12.0),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
} 