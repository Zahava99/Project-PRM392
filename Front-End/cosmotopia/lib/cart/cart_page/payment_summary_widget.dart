import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/cart/cart_page/shipping_service.dart';

class PaymentSummaryWidget extends StatelessWidget {
  final List<dynamic> cartItems;
  final int shippingFee;

  const PaymentSummaryWidget({
    super.key,
    required this.cartItems,
    required this.shippingFee,
  });

  num get subtotal => cartItems.fold<num>(0, (sum, item) => 
    sum + ((item['product']['price'] ?? 0) * (item['quantity'] ?? 1)));

  num get total => subtotal + shippingFee;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(20.0, 24.0, 20.0, 12.0),
          child: Text(
            'Payment Summary',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'SF Pro Text',
                  fontSize: 18.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w600,
                  lineHeight: 1.5,
                ),
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
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
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  _buildSummaryRow(
                    context,
                    'Price ( Tax included )',
                    '${NumberFormat('#,###', 'vi_VN').format(subtotal)} ₫',
                  ),
                  SizedBox(height: 16.0),
                  _buildShippingRow(context),
                  SizedBox(height: 16.0),
                  Divider(thickness: 1.0, color: Color(0xFFF0F0F0)),
                  SizedBox(height: 16.0),
                  _buildSummaryRow(
                    context,
                    'Total Price',
                    '${NumberFormat('#,###', 'vi_VN').format(total)} ₫',
                    isBold: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'SF Pro Text',
                fontSize: isBold ? 18.0 : 17.0,
                letterSpacing: 0.0,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                lineHeight: 1.5,
              ),
        ),
        Text(
          value,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'SF Pro Text',
                fontSize: isBold ? 18.0 : 17.0,
                letterSpacing: 0.0,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                lineHeight: 1.5,
              ),
        ),
      ],
    );
  }

  Widget _buildShippingRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Shipping',
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'SF Pro Text',
                fontSize: 17.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.normal,
                lineHeight: 1.5,
              ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (shippingFee == 0)
              Container(
                padding: EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                margin: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.0),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  'FREE',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'SF Pro Text',
                        color: Colors.green,
                        fontSize: 12.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                        lineHeight: 1.0,
                      ),
                ),
              ),
            Text(
              shippingFee == 0 ? '0 ₫' : '${NumberFormat('#,###', 'vi_VN').format(shippingFee)} ₫',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'SF Pro Text',
                    fontSize: 17.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.normal,
                    lineHeight: 1.5,
                    decoration: shippingFee == 0 ? TextDecoration.lineThrough : TextDecoration.none,
                    color: shippingFee == 0 ? FlutterFlowTheme.of(context).secondaryText : null,
                  ),
            ),
          ],
        ),
      ],
    );
  }
} 