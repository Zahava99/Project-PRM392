import '/all_component/add_card_bottomsheet/add_card_bottomsheet_widget.dart';
import '/all_component/appbar/appbar_widget.dart';
import '/all_component/order_successfull/order_successfull_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'payment_page_model.dart';
import '/backend/api_service.dart';
import '/all_component/payment_webview_dialog.dart';
export 'payment_page_model.dart';

class PaymentPageWidget extends StatefulWidget {
  const PaymentPageWidget({super.key});

  static String routeName = 'PaymentPage';
  static String routePath = 'paymentPage';

  @override
  State<PaymentPageWidget> createState() => _PaymentPageWidgetState();
}

class _PaymentPageWidgetState extends State<PaymentPageWidget> {
  late PaymentPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PaymentPageModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

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
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              wrapWithModel(
                model: _model.appbarModel,
                updateCallback: () => safeSetState(() {}),
                child: AppbarWidget(
                  title: 'Payment Method',
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.money, color: Colors.green),
                      title: Text('Trả tiền mặt'),
                      trailing: Radio(
                        value: 0,
                        groupValue: _model.pselected,
                        onChanged: (val) {
                          setState(() => _model.pselected = 0);
                        },
                      ),
                      onTap: () => setState(() => _model.pselected = 0),
                    ),
                    ListTile(
                      leading: Icon(Icons.qr_code, color: Colors.blue),
                      title: Text('QR/Bank Transfer'),
                      trailing: Radio(
                        value: 1,
                        groupValue: _model.pselected,
                        onChanged: (val) {
                          setState(() => _model.pselected = 1);
                        },
                      ),
                      onTap: () => setState(() => _model.pselected = 1),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: AlignmentDirectional(0.0, 0.0),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 48.0, 0.0, 0.0),
                  child: FFButtonWidget(
                    onPressed: () async {
                      await showModalBottomSheet(
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        useSafeArea: true,
                        context: context,
                        builder: (context) {
                          return GestureDetector(
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            child: Padding(
                              padding: MediaQuery.viewInsetsOf(context),
                              child: AddCardBottomsheetWidget(),
                            ),
                          );
                        },
                      ).then((value) => safeSetState(() {}));
                    },
                    text: 'Add New Card',
                    options: FFButtonOptions(
                      width: 190.0,
                      height: 46.0,
                      padding:
                          EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                      iconPadding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: Colors.transparent,
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                fontFamily: 'SF Pro Text',
                                color: FlutterFlowTheme.of(context).primary,
                                fontSize: 15.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.bold,
                                lineHeight: 1.2,
                              ),
                      elevation: 0.0,
                      borderSide: BorderSide(
                        color: FlutterFlowTheme.of(context).primary,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    showLoadingIndicator: false,
                  ),
                ),
              ),
              Flexible(
                child: Align(
                  alignment: AlignmentDirectional(0.0, 1.0),
                  child: Builder(
                    builder: (context) => Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 24.0),
                      child: FFButtonWidget(
                        onPressed: () async {
                          // Xác định phương thức thanh toán
                          String paymentMethod = '';
                          if (_model.pselected == 0) paymentMethod = 'Trả tiền mặt';
                          if (_model.pselected == 1) paymentMethod = 'Chuyển khoản (QR/Bank Transfer)';

                          // Lấy thông tin cart và address từ FFAppState
                          final cartItems = FFAppState().orderlist;
                          final address = FFAppState().address;

                          // Tạo orderDetails, chỉ lấy sản phẩm quantity > 0
                          final orderDetails = cartItems
                              .where((item) => int.tryParse(item.stockQuantity) != null && int.parse(item.stockQuantity) > 0)
                              .map((item) => {
                                'productId': item.productId,
                                'quantity': int.parse(item.stockQuantity),
                              })
                              .toList();

                          // Get shipping and tax
                          final shippingFee = FFAppState().shippingFee;
                          final tax = FFAppState().calculatedTax;

                          if (orderDetails.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Giỏ hàng trống hoặc không có sản phẩm hợp lệ!')),
                            );
                            return;
                          }

                          print('Orderlist: ${FFAppState().orderlist}');
                          print('🚢 Shipping Fee from FFAppState: ${FFAppState().shippingFee}');
                          print('💰 Tax from FFAppState: ${FFAppState().calculatedTax}');

                          // Calculate total amount including shipping and tax
                          final subtotal = orderDetails.fold<num>(0, (sum, item) {
                            try {
                              final productData = FFAppState().orderlist.firstWhere(
                                (orderItem) => orderItem.productId == item['productId'],
                              );
                              final priceString = productData.price.replaceAll(RegExp(r'[^0-9]'), '');
                              final price = int.tryParse(priceString) ?? 0;
                              return sum + (price * (item['quantity'] as int));
                            } catch (e) {
                              print('⚠️ Product not found in orderlist: ${item['productId']}');
                              return sum; // Skip this item if not found
                            }
                          });
                          final totalAmount = subtotal + shippingFee + tax;

                          final orderBody = {
                            'salesStaffId': 0,
                            'orderDate': DateTime.now().toIso8601String(),
                            'paymentMethod': paymentMethod,
                            'address': address,
                            'orderDetails': orderDetails,
                            'shippingFee': shippingFee.toDouble(),
                            'tax': tax.toDouble(), 
                            'totalAmount': totalAmount.toDouble(),
                          };

                          print('📦 Final Order Body: $orderBody');
                          print('💳 Total Amount being sent: $totalAmount (Subtotal: $subtotal + Shipping: $shippingFee + Tax: $tax)');

                          // Gửi API tạo order
                          final response = await ApiService.postOrder(orderBody, token: FFAppState().token);
                          if (response.statusCode == 200 || response.statusCode == 201) {
                            // Clear cart after successful order creation
                            print('🛒 Order created successfully, clearing cart...');
                            final cartCleared = await ApiService.clearAllCart(token: FFAppState().token);
                            if (cartCleared) {
                              print('✅ Cart cleared successfully');
                              // Clear FFAppState orderlist as well
                              FFAppState().orderlist = [];
                            } else {
                              print('❌ Failed to clear cart');
                            }

                            if (_model.pselected == 0) {
                              // Trả tiền mặt: show dialog thành công như cũ
                              await showDialog(
                                context: context,
                                builder: (dialogContext) {
                                  return Dialog(
                                    elevation: 0,
                                    insetPadding: EdgeInsets.zero,
                                    backgroundColor: Colors.transparent,
                                    alignment: AlignmentDirectional(0.0, 0.0)
                                        .resolve(Directionality.of(context)),
                                    child: GestureDetector(
                                      onTap: () {
                                        FocusScope.of(dialogContext).unfocus();
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                      },
                                      child: OrderSuccessfullWidget(
                                        onTapProfile: () async {
                                          Navigator.pop(context);
                                          context.goNamed(BottomPageWidget.routeName);
                                        },
                                      ),
                                    ),
                                  );
                                },
                              );
                            } else if (_model.pselected == 1) {
                              // Chuyển khoản: lấy orderId, gọi API tạo payment link và show WebView
                              final orderData = jsonDecode(response.body);
                              print('🛒 Order Response Data: $orderData');
                              final orderId = orderData['orderId'] ?? orderData['data']?['orderId'];
                              print('🆔 Extracted Order ID: $orderId');
                              
                              if (orderId != null) {
                                print('💳 Creating payment link for order: $orderId');
                                final paymentResp = await ApiService.createPaymentLink(orderId: orderId, token: FFAppState().token);
                                print('💳 Payment Link Response Status: ${paymentResp.statusCode}');
                                print('💳 Payment Link Response Body: ${paymentResp.body}');
                                
                                if (paymentResp.statusCode == 200) {
                                  final paymentData = jsonDecode(paymentResp.body);
                                  print('💳 Payment Data: $paymentData');
                                  final paymentUrl = paymentData['paymentUrl'] ?? paymentData['PaymentUrl'];
                                  print('🔗 Payment URL: $paymentUrl');
                                  
                                  if (paymentUrl != null) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => PaymentWebViewDialog(paymentUrl: paymentUrl),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Không lấy được link thanh toán! Data: $paymentData')),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Tạo payment link thất bại! Status: ${paymentResp.statusCode}, Body: ${paymentResp.body}')),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Không lấy được orderId! Response: $orderData')),
                                );
                              }
                            }
                          } else {
                            print('Order error: \\${response.statusCode} - \\${response.body}');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Order failed! \\${response.body}')),
                            );
                          }
                        },
                        text: 'Pay now',
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 56.0,
                          padding: EdgeInsetsDirectional.fromSTEB(
                              24.0, 0.0, 24.0, 0.0),
                          iconPadding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          color: FlutterFlowTheme.of(context).primary,
                          textStyle:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                    fontFamily: 'SF Pro Text',
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    fontSize: 18.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                    lineHeight: 1.2,
                                  ),
                          elevation: 0.0,
                          borderSide: BorderSide(
                            color: Colors.transparent,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        showLoadingIndicator: false,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
