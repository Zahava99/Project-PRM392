import '/all_component/appbar/appbar_widget.dart';
import '/backend/api_service.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'generate_link_model.dart';
export 'generate_link_model.dart';

class GenerateLinkWidget extends StatefulWidget {
  const GenerateLinkWidget({super.key});

  static String routeName = 'GenerateLink';
  static String routePath = 'generateLink';

  @override
  State<GenerateLinkWidget> createState() => _GenerateLinkWidgetState();
}

class _GenerateLinkWidgetState extends State<GenerateLinkWidget> {
  late GenerateLinkModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  List<ProductStruct> _products = [];
  bool _isLoadingProducts = false;
  ProductStruct? _selectedProduct;
  String? _generatedLink;
  bool _isGeneratingLink = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GenerateLinkModel());
    _model.searchController ??= TextEditingController();
    _model.searchFocusNode ??= FocusNode();
    
    _loadProducts();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // Load products from API
  Future<void> _loadProducts() async {
    setState(() {
      _isLoadingProducts = true;
    });

    try {
      print('🔍 Loading products for affiliate link generation...');
      final response = await ApiService.getAllProducts(
        page: 1,
        pageSize: 50,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<ProductStruct> products = [];

        if (data['products'] != null) {
          for (var productJson in data['products']) {
            try {
              final product = ProductStruct.fromMap(productJson);
              products.add(product);
            } catch (e) {
              print('❌ Error parsing product: $e');
            }
          }
        }

        setState(() {
          _products = products;
          _isLoadingProducts = false;
        });

        print('✅ Loaded ${products.length} products');
      } else {
        print('❌ Failed to load products: ${response.statusCode}');
        setState(() {
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      print('❌ Error loading products: $e');
      setState(() {
        _isLoadingProducts = false;
      });
    }
  }

  // Track affiliate click manually (for testing purposes)
  Future<void> _testTrackClick() async {
    if (_generatedLink != null) {
      try {
        // Extract referral code from link
        final uri = Uri.parse(_generatedLink!);
        final referralCode = uri.queryParameters['ref'] ?? 
                           uri.queryParameters['referralCode'] ?? 
                           uri.queryParameters['affiliate_id'];
        
        if (referralCode != null && referralCode.isNotEmpty) {
          final token = FFAppState().token; // Lấy token từ FFAppState
          
          if (token.isEmpty) {
            throw Exception('User not authenticated');
          }
          
          final response = await ApiService.trackAffiliateClick(
            referralCode: referralCode,
            token: token, // Truyền token
          );
          
          print('🔍 Track Click Response: ${response.statusCode} - ${response.body}');
          
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            
            if (data['success'] == true || data['Success'] == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ Click đã được track thành công!'),
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                  duration: Duration(seconds: 2),
                ),
              );
              print('✅ Click tracked successfully for referral: $referralCode');
              
              // Auto refresh dashboard stats by triggering a global app state update
              FFAppState().update(() {
                FFAppState().lastClickTrackedAt = DateTime.now().millisecondsSinceEpoch;
              });
            } else {
              throw Exception(data['message'] ?? data['Message'] ?? 'Unknown error from API');
            }
          } else {
            final errorData = jsonDecode(response.body);
            throw Exception('Failed to track click: ${errorData['message'] ?? errorData['Message'] ?? response.statusCode}');
          }
        } else {
          throw Exception('No referral code found in link');
        }
      } catch (e) {
        print('❌ Error tracking click: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi track click: $e'),
            backgroundColor: FlutterFlowTheme.of(context).error,
          ),
        );
      }
    }
  }

  // Generate affiliate link for selected product
  Future<void> _generateAffiliateLink(ProductStruct product) async {
    setState(() {
      _isGeneratingLink = true;
    });

    try {
      final token = FFAppState().token;
      if (token.isEmpty) {
        throw Exception('User not authenticated');
      }

      print('🔗 Generating affiliate link for product: ${product.productId}');
      
      final response = await ApiService.generateAffiliateLink(
        productId: product.productId,
        token: token,
        customParams: {
          'utm_source': 'affiliate',
          'utm_medium': 'mobile_app',
          'utm_campaign': 'product_share',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('🔍 API Response: $data');
        
        String? affiliateLink;
        
        // Try different response formats
        if (data['success'] == true && data['data'] != null) {
          final linkData = data['data'];
          
          // If data is a string (direct link)
          if (linkData is String) {
            affiliateLink = linkData;
          }
          // If data is an object with link property
          else if (linkData is Map<String, dynamic>) {
            affiliateLink = linkData['affiliateProductUrl']?.toString() ?? 
                          linkData['affiliateLink']?.toString() ?? 
                          linkData['link']?.toString() ?? 
                          linkData['url']?.toString();
          }
        }
        
        if (affiliateLink != null && affiliateLink.isNotEmpty) {
          setState(() {
            _selectedProduct = product;
            _generatedLink = affiliateLink;
            _isGeneratingLink = false;
          });

          print('✅ Generated affiliate link: $affiliateLink');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã tạo affiliate link thành công!'),
              backgroundColor: FlutterFlowTheme.of(context).primary,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          throw Exception('Invalid affiliate link received from server');
        }
      } else {
        // Fallback to mock link if API fails
        print('⚠️ API failed (${response.statusCode}), using fallback link generation');
        
        // Generate a referral code similar to backend format (8chars-6chars)
        final randomSuffix = DateTime.now().millisecondsSinceEpoch.toString().substring(7); // Last 6 digits
        final fallbackReferralCode = 'FALLBACK-$randomSuffix';
        final baseUrl = 'http://10.0.2.2:5192/api/Product/affiliate';
        final fallbackLink = '$baseUrl/${product.productId}?ref=$fallbackReferralCode&utm_source=affiliate&utm_medium=share&t=${DateTime.now().millisecondsSinceEpoch}';
        
        setState(() {
          _selectedProduct = product;
          _generatedLink = fallbackLink;
          _isGeneratingLink = false;
        });

        print('✅ Generated fallback affiliate link: $fallbackLink');
      }
    } catch (e) {
      print('❌ Error generating affiliate link: $e');
      setState(() {
        _isGeneratingLink = false;
      });
      
      // Still try to create a fallback link for better UX
      try {
        // Generate a referral code similar to backend format (8chars-6chars)
        final randomSuffix = DateTime.now().millisecondsSinceEpoch.toString().substring(7); // Last 6 digits
        final fallbackReferralCode = 'OFFLINE-$randomSuffix';
        final baseUrl = 'http://10.0.2.2:5192/api/Product/affiliate';
        final fallbackLink = '$baseUrl/${product.productId}?ref=$fallbackReferralCode&utm_source=affiliate&utm_medium=share&t=${DateTime.now().millisecondsSinceEpoch}';
        
        setState(() {
          _selectedProduct = product;
          _generatedLink = fallbackLink;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã tạo link affiliate offline. Vui lòng kết nối internet để sync.'),
            backgroundColor: FlutterFlowTheme.of(context).warning,
            duration: Duration(seconds: 3),
          ),
        );
      } catch (fallbackError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tạo link affiliate: $e'),
            backgroundColor: FlutterFlowTheme.of(context).error,
          ),
        );
      }
    }
  }

  // Copy link to clipboard
  Future<void> _copyToClipboard() async {
    if (_generatedLink != null) {
      await Clipboard.setData(ClipboardData(text: _generatedLink!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã sao chép link vào clipboard!'),
          backgroundColor: FlutterFlowTheme.of(context).primary,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Share link via social media
  Future<void> _shareLink() async {
    if (_generatedLink != null && _selectedProduct != null) {
      final shareText = 'Khám phá sản phẩm tuyệt vời: ${_selectedProduct!.name}\n\n'
          'Giá chỉ từ ${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(_selectedProduct!.price)}₫\n\n'
          'Xem ngay: $_generatedLink';
      
      await Share.share(shareText, subject: 'Sản phẩm từ Cosmotopia');
    }
  }

  // Filter products based on search
  List<ProductStruct> get _filteredProducts {
    if (_model.searchController?.text.isEmpty ?? true) {
      return _products;
    }
    
    final query = _model.searchController!.text.toLowerCase();
    return _products.where((product) => 
      product.name.toLowerCase().contains(query) ||
      (product.description?.toLowerCase().contains(query) ?? false)
    ).toList();
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
            children: [
              // AppBar
              wrapWithModel(
                model: _model.appbarModel,
                updateCallback: () => safeSetState(() {}),
                child: AppbarWidget(
                  title: 'Tạo Link Affiliate',
                ),
              ),

              // Content
              Expanded(
                child: Column(
                  children: [
                    // Search Bar
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 16.0),
                      child: TextFormField(
                        controller: _model.searchController,
                        focusNode: _model.searchFocusNode,
                        autofocus: false,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          labelText: 'Tìm kiếm sản phẩm...',
                          labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                            fontFamily: 'SF Pro Text',
                            letterSpacing: 0.0,
                          ),
                          hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                            fontFamily: 'SF Pro Text',
                            letterSpacing: 0.0,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).borderColor,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).primary,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          contentPadding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 12.0),
                          prefixIcon: Icon(
                            Icons.search,
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'SF Pro Text',
                          letterSpacing: 0.0,
                        ),
                        onChanged: (value) => setState(() {}),
                      ),
                    ),

                    // Products List
                    Expanded(
                      child: _isLoadingProducts
                          ? Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  FlutterFlowTheme.of(context).primary,
                                ),
                              ),
                            )
                          : _filteredProducts.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.search_off,
                                        size: 64.0,
                                        color: FlutterFlowTheme.of(context).secondaryText,
                                      ),
                                      SizedBox(height: 16.0),
                                      Text(
                                        'Không tìm thấy sản phẩm',
                                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                                          fontFamily: 'SF Pro Text',
                                          color: FlutterFlowTheme.of(context).secondaryText,
                                          letterSpacing: 0.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: _loadProducts,
                                  child: ListView.builder(
                                    padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 20.0),
                                    itemCount: _filteredProducts.length,
                                    itemBuilder: (context, index) {
                                      final product = _filteredProducts[index];
                                      final isSelected = _selectedProduct?.productId == product.productId;

                                      return Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
                                        child: InkWell(
                                          onTap: () => _generateAffiliateLink(product),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: FlutterFlowTheme.of(context).secondaryBackground,
                                              borderRadius: BorderRadius.circular(12.0),
                                              border: Border.all(
                                                color: isSelected
                                                    ? FlutterFlowTheme.of(context).primary
                                                    : FlutterFlowTheme.of(context).borderColor,
                                                width: isSelected ? 2.0 : 1.0,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  blurRadius: 4.0,
                                                  color: Color(0x1A000000),
                                                  offset: Offset(0.0, 2.0),
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding: EdgeInsetsDirectional.fromSTEB(12.0, 12.0, 12.0, 12.0),
                                              child: Row(
                                                children: [
                                                  // Product Image
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(8.0),
                                                    child: Image.network(
                                                      product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
                                                      width: 60.0,
                                                      height: 60.0,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return Container(
                                                          width: 60.0,
                                                          height: 60.0,
                                                          color: FlutterFlowTheme.of(context).accent1,
                                                          child: Icon(
                                                            Icons.image_not_supported,
                                                            color: FlutterFlowTheme.of(context).secondaryText,
                                                            size: 24.0,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),

                                                  SizedBox(width: 12.0),

                                                  // Product Info
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          product.name,
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                            fontFamily: 'SF Pro Text',
                                                            fontSize: 16.0,
                                                            letterSpacing: 0.0,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                        SizedBox(height: 4.0),
                                                        Text(
                                                          NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0)
                                                              .format(product.price) + '₫',
                                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                            fontFamily: 'SF Pro Text',
                                                            color: FlutterFlowTheme.of(context).primary,
                                                            fontSize: 14.0,
                                                            letterSpacing: 0.0,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        SizedBox(height: 4.0),
                                                        Text(
                                                          'Commission: ${product.commissionRate}%',
                                                          style: FlutterFlowTheme.of(context).bodySmall.override(
                                                            fontFamily: 'SF Pro Text',
                                                            color: FlutterFlowTheme.of(context).secondaryText,
                                                            fontSize: 12.0,
                                                            letterSpacing: 0.0,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  // Generate Link Button
                                                  if (_isGeneratingLink && isSelected)
                                                    SizedBox(
                                                      width: 24.0,
                                                      height: 24.0,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2.0,
                                                        valueColor: AlwaysStoppedAnimation<Color>(
                                                          FlutterFlowTheme.of(context).primary,
                                                        ),
                                                      ),
                                                    )
                                                  else if (isSelected && _generatedLink != null)
                                                    Icon(
                                                      Icons.check_circle,
                                                      color: FlutterFlowTheme.of(context).primary,
                                                      size: 24.0,
                                                    )
                                                  else
                                                    Icon(
                                                      Icons.link,
                                                      color: FlutterFlowTheme.of(context).secondaryText,
                                                      size: 24.0,
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                    ),
                  ],
                ),
              ),

              // Generated Link Section
              if (_generatedLink != null && _selectedProduct != null) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 20.0),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8.0,
                        color: Color(0x1A000000),
                        offset: Offset(0.0, -2.0),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Link Affiliate đã tạo',
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                          fontFamily: 'SF Pro Text',
                          fontSize: 18.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 12.0),

                      // Link Display
                      Container(
                        width: double.infinity,
                        padding: EdgeInsetsDirectional.fromSTEB(12.0, 12.0, 12.0, 12.0),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).accent1,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: FlutterFlowTheme.of(context).primary.withOpacity(0.3),
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          _generatedLink!,
                          style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: 'monospace',
                            fontSize: 12.0,
                            letterSpacing: 0.0,
                          ),
                        ),
                      ),

                      SizedBox(height: 16.0),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: FFButtonWidget(
                              onPressed: _copyToClipboard,
                              text: 'Sao chép',
                              icon: Icon(Icons.copy, size: 18.0),
                              options: FFButtonOptions(
                                height: 44.0,
                                color: FlutterFlowTheme.of(context).secondaryBackground,
                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                  fontFamily: 'SF Pro Text',
                                  color: FlutterFlowTheme.of(context).primaryText,
                                  fontSize: 14.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w500,
                                ),
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).primary,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),

                          SizedBox(width: 12.0),

                          Expanded(
                            child: FFButtonWidget(
                              onPressed: _shareLink,
                              text: 'Chia sẻ',
                              icon: Icon(Icons.share, size: 18.0),
                              options: FFButtonOptions(
                                height: 44.0,
                                color: FlutterFlowTheme.of(context).primary,
                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                  fontFamily: 'SF Pro Text',
                                  color: Colors.white,
                                  fontSize: 14.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w500,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12.0),

                      // Test Click Tracking Button
                      SizedBox(
                        width: double.infinity,
                        child: FFButtonWidget(
                          onPressed: _testTrackClick,
                          text: 'Test Track Click',
                          icon: Icon(Icons.analytics, size: 18.0),
                          options: FFButtonOptions(
                            height: 40.0,
                            color: FlutterFlowTheme.of(context).accent2,
                            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                              fontFamily: 'SF Pro Text',
                              color: FlutterFlowTheme.of(context).secondaryText,
                              fontSize: 13.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w500,
                            ),
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).secondaryText.withOpacity(0.3),
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 