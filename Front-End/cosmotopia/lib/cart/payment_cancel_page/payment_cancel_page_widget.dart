import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/home/bottom_page/bottom_page_widget.dart';
import '/cart/payment_page/payment_page_widget.dart';

class PaymentCancelPageWidget extends StatefulWidget {
  const PaymentCancelPageWidget({
    super.key,
    this.orderCode,
    this.reason,
  });

  final String? orderCode;
  final String? reason;

  static String routeName = 'PaymentCancelPage';
  static String routePath = '/payment-cancel';

  @override
  State<PaymentCancelPageWidget> createState() => _PaymentCancelPageWidgetState();
}

class _PaymentCancelPageWidgetState extends State<PaymentCancelPageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    print('❌ PaymentCancelPage initialized with orderCode: ${widget.orderCode}, reason: ${widget.reason}');
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
              // Cancel Icon
              Container(
                width: 120.0,
                height: 120.0,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(60.0),
                ),
                child: Icon(
                  Icons.cancel_outlined,
                  color: Colors.orange,
                  size: 60.0,
                ),
              ),
              
              const SizedBox(height: 32.0),
              
              // Cancel Title
              Text(
                'Thanh toán đã bị hủy',
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'SF Pro Display',
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16.0),
              
              // Cancel Message
              Text(
                'Đơn hàng của bạn chưa được thanh toán. Bạn có thể thử lại hoặc chọn phương thức thanh toán khác.',
                style: FlutterFlowTheme.of(context).bodyLarge.override(
                  fontFamily: 'SF Pro Text',
                  color: FlutterFlowTheme.of(context).secondaryText,
                  fontSize: 16.0,
                  lineHeight: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24.0),
              
              // Order Info Card (if available)
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
                      if (widget.reason != null) ...[
                        const SizedBox(height: 8.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Lý do:',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'SF Pro Text',
                                color: FlutterFlowTheme.of(context).secondaryText,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                widget.reason!,
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: 'SF Pro Text',
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.end,
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
              
              // Try Again Button
              FFButtonWidget(
                onPressed: () async {
                  context.goNamed(PaymentPageWidget.routeName);
                },
                text: 'Thử lại thanh toán',
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
              
              // Back to Home Button
              FFButtonWidget(
                onPressed: () async {
                  context.goNamed(BottomPageWidget.routeName);
                },
                text: 'Về trang chủ',
                options: FFButtonOptions(
                  width: double.infinity,
                  height: 56.0,
                  padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                  iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  color: Colors.transparent,
                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                    fontFamily: 'SF Pro Text',
                    color: FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                  elevation: 0.0,
                  borderSide: BorderSide(
                    color: FlutterFlowTheme.of(context).alternate,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 