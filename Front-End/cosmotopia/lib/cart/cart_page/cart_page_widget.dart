import '/all_component/appbar/appbar_widget.dart';
import '/all_component/cartempty/cartempty_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_page_model.dart';
import '/backend/api_service.dart';
import '/custom_code/widgets/swipablewidget.dart';
import '/backend/schema/structs/detail_struct.dart';
import '/cart/payment_page/payment_page_widget.dart';
import '/cart/cart_page/shipping_service.dart';
import '/cart/cart_page/address_section_widget.dart';
import '/cart/cart_page/warehouse_info_widget.dart';
import '/cart/cart_page/payment_summary_widget.dart';
export 'cart_page_model.dart';

class CartPageWidget extends StatefulWidget {
  const CartPageWidget({super.key});

  static String routeName = 'CartPage';
  static String routePath = 'cartPage';

  @override
  State<CartPageWidget> createState() => _CartPageWidgetState();
}

class _CartPageWidgetState extends State<CartPageWidget> with WidgetsBindingObserver {
  late CartPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  List<dynamic> cartItems = [];
  bool _isLoading = true;
  String userAddress = '';
  String estimatedDeliveryTime = '';
  int shippingFee = ShippingService.defaultShippingFee;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CartPageModel());
    WidgetsBinding.instance.addObserver(this);
    _loadCart();
    _loadUserAddress();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh cart when app resumes (user returns from payment)
      print('🔄 App resumed, refreshing cart...');
      _loadCart();
    }
  }

  Future<void> _loadCart() async {
    setState(() { _isLoading = true; });
    final response = await ApiService.getCart(token: FFAppState().token);
    if (response.statusCode == 200) {
      setState(() {
        cartItems = jsonDecode(response.body);
        _syncOrderList();
        _isLoading = false;
        _updateShippingAndTax();
      });
    } else {
      setState(() { _isLoading = false; });
    }
  }

  void _syncOrderList() {
    FFAppState().orderlist = cartItems.map<DetailStruct>((item) {
      final product = item['product'];
      final quantity = item['quantity'] ?? 1;
      return DetailStruct(
        productId: product['productId'] ?? '',
        image: (product['imageUrls'] != null && product['imageUrls'].isNotEmpty)
          ? product['imageUrls'][0]
          : 'https://via.placeholder.com/100',
        title: product['name'] ?? '',
        price: NumberFormat('#,###', 'vi_VN').format(product['price'] ?? 0) + ' ₫',
        description: product['description'] ?? '',
        catetype: product['category']?['name'] ?? '',
        stockQuantity: quantity.toString(),
        brandName: product['brand']?['name'] ?? '',
        isFav: false,
        isJust: false,
        isNew: false,
        isCart: false,
        isColor: false,
      );
    }).toList();
  }

  void _updateShippingAndTax() {
    if (userAddress.isNotEmpty) {
      estimatedDeliveryTime = ShippingService.calculateDeliveryTime(userAddress);
      shippingFee = ShippingService.calculateShippingFee(userAddress);
    }
    
    // Save to FFAppState for payment page
    FFAppState().shippingFee = shippingFee;
    
    // Debug logging
    print('🛒 Cart Page - Shipping Fee: $shippingFee');
    print('💾 Saved to FFAppState - Shipping: ${FFAppState().shippingFee}');
  }

  Future<void> _loadUserAddress() async {
    final response = await ApiService.getCurrentUser(token: FFAppState().token);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        userAddress = data['data']['address'] ?? '';
        FFAppState().address = userAddress;
        _updateShippingAndTax();
      });
    }
  }

  Future<void> _handleQuantityChange(String productId, int newQuantity) async {
    if (newQuantity < 1) {
      await _removeFromCart(productId);
    } else {
      final resp = await ApiService.updateCart(
        productId: productId,
        quantity: newQuantity,
        token: FFAppState().token,
      );
      if (resp.statusCode == 200) {
        _loadCart();
      }
    }
  }

  Future<void> _removeFromCart(String productId) async {
    final resp = await ApiService.deleteCartItem(
      productId: productId,
      token: FFAppState().token,
    );
    if (resp.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xóa sản phẩm khỏi giỏ hàng!')),
      );
      _loadCart();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xóa sản phẩm thất bại!')),
      );
    }
  }

  Widget _buildCartItem(Map<String, dynamic> item) {
    final product = item['product'];
    final quantity = item['quantity'] ?? 1;
    final detail = DetailStruct(
      productId: product['productId'] ?? '',
      image: (product['imageUrls'] != null && product['imageUrls'].isNotEmpty)
        ? product['imageUrls'][0]
        : 'https://via.placeholder.com/100',
      title: product['name'] ?? '',
      price: NumberFormat('#,###', 'vi_VN').format(product['price'] ?? 0) + ' ₫',
      description: product['description'] ?? '',
      catetype: product['category']?['name'] ?? '',
      stockQuantity: product['stockQuantity']?.toString() ?? '',
      brandName: product['brand']?['name'] ?? '',
      isFav: false,
      isJust: false,
      isNew: false,
      isCart: false,
      isColor: false,
    );

    return Container(
      width: double.infinity,
      height: 140.0,
      child: Swipablewidget(
        width: double.infinity,
        height: 140.0,
        data: detail,
        quantity: quantity,
        onIncrease: () => _handleQuantityChange(item['productId'], quantity + 1),
        onDecrease: () => _handleQuantityChange(item['productId'], quantity - 1),
        action: () => _removeFromCart(item['productId']),
        ontapcontainer: () async {},
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

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
            children: [
              wrapWithModel(
                model: _model.appbarModel,
                updateCallback: () => safeSetState(() {}),
                child: AppbarWidget(title: 'Cart'),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(0, 16, 0, 24),
                  children: [
                    if (_isLoading)
                      Center(child: CircularProgressIndicator()),
                    if (!_isLoading && cartItems.isEmpty)
                      Center(
                        child: Container(
                          width: 388.0,
                          height: 214.0,
                          child: CartemptyWidget(),
                        ),
                      ),
                    if (!_isLoading && cartItems.isNotEmpty) ...[
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: cartItems.map((item) => _buildCartItem(item)).toList(),
                      ),
                      AddressSectionWidget(userAddress: userAddress),
                      WarehouseInfoWidget(
                        warehouseAddress: ShippingService.warehouseAddress,
                        estimatedDeliveryTime: estimatedDeliveryTime,
                      ),
                      PaymentSummaryWidget(
                        cartItems: cartItems,
                        shippingFee: shippingFee,
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 24.0),
                child: FFButtonWidget(
                  onPressed: () async {
                    final result = await context.pushNamed(PaymentPageWidget.routeName);
                    // Refresh cart when returning from payment page
                    print('🔄 Returned from payment page, refreshing cart...');
                    _loadCart();
                  },
                  text: 'Continue',
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 56.0,
                    padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                    iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                    color: FlutterFlowTheme.of(context).primary,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily: 'SF Pro Text',
                          color: FlutterFlowTheme.of(context).secondaryBackground,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
