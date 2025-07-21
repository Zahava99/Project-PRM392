import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/cart/payment_success_page/payment_success_page_widget.dart';
import '/cart/payment_cancel_page/payment_cancel_page_widget.dart';

class PaymentWebViewDialog extends StatefulWidget {
  final String paymentUrl;
  const PaymentWebViewDialog({required this.paymentUrl, super.key});

  @override
  State<PaymentWebViewDialog> createState() => _PaymentWebViewDialogState();
}

class _PaymentWebViewDialogState extends State<PaymentWebViewDialog> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            print('🌐 WebView navigating to: $url');
            
            // Check for payment success deep link (after backend processing)
            if (url.startsWith('cosmotopia://payment-success')) {
              print('✅ Payment Success deep link detected!');
              Navigator.pop(context);
              
              // Parse query parameters from deep link
              final uri = Uri.parse(url);
              final orderCode = uri.queryParameters['orderCode'];
              final amount = uri.queryParameters['amount'];
              
              print('📋 Success params - orderCode: $orderCode, amount: $amount');
              
              // Navigate to success page
              context.goNamed(
                PaymentSuccessPageWidget.routeName,
                queryParameters: {
                  if (orderCode != null) 'orderCode': orderCode,
                  if (amount != null) 'amount': amount,
                },
              );
              return;
            }
            
            // Check for payment cancel deep link (after backend processing)
            if (url.startsWith('cosmotopia://payment-cancel')) {
              print('❌ Payment Cancel deep link detected!');
              Navigator.pop(context);
              
              // Parse query parameters from deep link
              final uri = Uri.parse(url);
              final orderCode = uri.queryParameters['orderCode'];
              final reason = uri.queryParameters['reason'] ?? 'Thanh toán đã bị hủy';
              
              print('📋 Cancel params - orderCode: $orderCode, reason: $reason');
              
              // Navigate to cancel page
              context.goNamed(
                PaymentCancelPageWidget.routeName,
                queryParameters: {
                  if (orderCode != null) 'orderCode': orderCode,
                  'reason': reason,
                },
              );
              return;
            }
            
            // Check for localhost callback (legacy - should redirect to deep link now)
            if (url.contains('/api/Payment/HandlePaymentSuccess')) {
              print('✅ Legacy Payment Success detected - will redirect to deep link');
              // Don't close dialog yet, let backend redirect to deep link
              return;
            }
            
            if (url.contains('/api/Payment/HandlePaymentCancel')) {
              print('❌ Legacy Payment Cancel detected - will redirect to deep link');
              // Don't close dialog yet, let backend redirect to deep link
              return;
            }
            
            // Check for any other localhost redirect (generic fallback)
            if ((url.contains('localhost') || url.contains('127.0.0.1')) && 
                !url.contains('payos.vn') && 
                !url.contains('/api/Payment/Handle')) {
              print('⚠️ Unknown localhost redirect: $url');
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('⚠️ Thanh toán đã kết thúc'),
                  backgroundColor: Colors.grey,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          onPageFinished: (url) {
            print('📄 WebView page finished loading: $url');
          },
          onNavigationRequest: (NavigationRequest request) {
            print('🧭 WebView navigation request: ${request.url}');
            
            // Allow navigation to deep links
            if (request.url.startsWith('cosmotopia://')) {
              print('🔗 Deep link navigation allowed: ${request.url}');
              return NavigationDecision.navigate;
            }
            
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 400,
        height: 600,
        child: Column(
          children: [
            AppBar(
              title: const Text('Quét mã QR/Thanh toán'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    print('🚪 User manually closed payment dialog');
                    Navigator.pop(context);
                  },
                )
              ],
            ),
            Expanded(
              child: WebViewWidget(controller: _controller),
            ),
          ],
        ),
      ),
    );
  }
}
