import '/all_component/appbar/appbar_widget.dart';
import '/all_component/search_empty/search_empty_widget.dart';
import '/backend/api_service.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:math';
import 'search_page_model.dart';
export 'search_page_model.dart';

class SearchPageWidget extends StatefulWidget {
  const SearchPageWidget({super.key});

  static String routeName = 'SearchPage';
  static String routePath = 'searchPage';

  @override
  State<SearchPageWidget> createState() => _SearchPageWidgetState();
}

class _SearchPageWidgetState extends State<SearchPageWidget> {
  late SearchPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isListening = false;
  List<ProductStruct> _popularProducts = [];
  bool _isLoadingProducts = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SearchPageModel());

    // Initialize search controller
    _model.searchController ??= TextEditingController();
    _model.searchFocusNode ??= FocusNode();

    // Listen to text changes for real-time UI updates
    _model.searchController?.addListener(() {
      setState(() {});
    });

    // Load random popular products
    _loadPopularProducts();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // Load random popular products from API
  Future<void> _loadPopularProducts() async {
    setState(() {
      _isLoadingProducts = true;
    });

    try {
      print('🔍 Loading popular products...');
      final response = await ApiService.getAllProducts(
        page: 1,
        pageSize: 20, // Get more products to randomize
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<ProductStruct> allProducts = [];

        // Parse products from API response
        if (data['products'] != null) {
          for (var productJson in data['products']) {
            try {
              final product = ProductStruct.fromMap(productJson);
              allProducts.add(product);
            } catch (e) {
              print('❌ Error parsing product: $e');
            }
          }
        }

        // Shuffle and take 6 random products
        allProducts.shuffle(Random());
        final randomProducts = allProducts.take(6).toList();

        setState(() {
          _popularProducts = randomProducts;
          _isLoadingProducts = false;
        });

        print('✅ Loaded ${randomProducts.length} popular products');
      } else {
        print('❌ Failed to load products: ${response.statusCode}');
        setState(() {
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      print('❌ Error loading popular products: $e');
      setState(() {
        _isLoadingProducts = false;
      });
    }
  }

  // Convert ProductStruct to DetailStruct for navigation
  DetailStruct _convertProductToDetail(ProductStruct product) {
    return DetailStruct(
      productId: product.productId,
      title: product.name,
      price: product.price.toString(),
      image: product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
      description: product.description,
      catetype: product.category['name']?.toString() ?? '',
      brandName: product.brand['name']?.toString() ?? '',
      stockQuantity: product.stockQuantity.toString(),
      isFav: false,
      isJust: false,
      isNew: false,
      isCart: false,
      isColor: false,
      itsResult: true,
      id: product.productId.hashCode,
    );
  }

  // Function to perform search
  void _performSearch(String query) {
    if (query.trim().isEmpty) return;
    
    // Add to search history
    if (!FFAppState().searchlist.contains(query.trim())) {
      FFAppState().addToSearchlist(query.trim());
      // Keep only last 10 searches
      if (FFAppState().searchlist.length > 10) {
        FFAppState().removeAtIndexFromSearchlist(0);
      }
    }

    // Navigate to search result with query
    context.pushNamed(
      SearchResultWidget.routeName,
      queryParameters: {
        'searchQuery': serializeParam(query.trim(), ParamType.String),
      }.withoutNulls,
    );
  }

  // Navigate to product detail page
  void _navigateToProductDetail(ProductStruct product) {
    final detailProduct = _convertProductToDetail(product);
    context.pushNamed(
      ProducutDetailPageWidget.routeName,
      queryParameters: {
        'detail': serializeParam(detailProduct, ParamType.DataStruct),
      }.withoutNulls,
    );
  }

  // Voice search functionality (placeholder)
  void _startVoiceSearch() async {
    setState(() {
      _isListening = true;
    });

    // Simulate voice recognition (in real app, you'd use speech_to_text package)
    await Future.delayed(Duration(seconds: 2));
    
    // Mock voice search result
    final mockVoiceResult = [
      'kem dưỡng ẩm',
      'son môi',
      'kem chống nắng',
      'nước hoa',
      'phấn nền'
    ];
    
    final randomResult = mockVoiceResult[DateTime.now().millisecond % mockVoiceResult.length];
    
    setState(() {
      _isListening = false;
      _model.searchController?.text = randomResult;
    });

    // Show result and perform search
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tìm kiếm bằng giọng nói: "$randomResult"'),
        backgroundColor: FlutterFlowTheme.of(context).primary,
        duration: Duration(seconds: 2),
      ),
    );

    _performSearch(randomResult);
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
                child: AppbarWidget(
                  title: 'Tìm kiếm',
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                        child: ListView(
                    padding: EdgeInsets.fromLTRB(0, 16.0, 0, 24.0),
                          scrollDirection: Axis.vertical,
                          children: [
                      // Enhanced Search Box with Voice Search
                      Container(
                        width: double.infinity,
                        child: TextFormField(
                          controller: _model.searchController,
                          focusNode: _model.searchFocusNode,
                          autofocus: false,
                          textInputAction: TextInputAction.search,
                          onFieldSubmitted: (value) => _performSearch(value),
                          obscureText: false,
                          decoration: InputDecoration(
                            labelStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                  fontFamily: 'SF Pro Text',
                                  color: FlutterFlowTheme.of(context).primaryText,
                                  fontSize: 14.0,
                                  letterSpacing: 0.0,
                                ),
                            hintText: _isListening ? 'Đang nghe...' : 'Tìm kiếm sản phẩm...',
                            hintStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                  fontFamily: 'SF Pro Text',
                                  color: _isListening 
                                      ? FlutterFlowTheme.of(context).primary
                                      : FlutterFlowTheme.of(context).secondaryText,
                                  fontSize: 17.0,
                                  letterSpacing: 0.0,
                                  fontStyle: _isListening ? FontStyle.italic : FontStyle.normal,
                                ),
                            errorStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'SF Pro Text',
                                  color: FlutterFlowTheme.of(context).error,
                                  fontSize: 15.0,
                                  letterSpacing: 0.0,
                                  lineHeight: 1.2,
                                ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: _isListening 
                                    ? FlutterFlowTheme.of(context).primary
                                    : FlutterFlowTheme.of(context).borderColor,
                                width: _isListening ? 2.0 : 1.0,
                              ),
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).primary,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            contentPadding: EdgeInsetsDirectional.fromSTEB(16.0, 15.0, 16.0, 15.0),
                            prefixIcon: Icon(
                              Icons.search_sharp,
                              color: FlutterFlowTheme.of(context).primaryText,
                              size: 24.0,
                            ),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Voice Search Button
                            InkWell(
                                  onTap: _isListening ? null : _startVoiceSearch,
                              child: Container(
                                    padding: EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 8.0),
                                    child: Icon(
                                      _isListening ? Icons.mic : Icons.mic_none,
                                      color: _isListening 
                                          ? FlutterFlowTheme.of(context).primary
                                          : FlutterFlowTheme.of(context).secondaryText,
                                      size: 20.0,
                                    ),
                                  ),
                                ),
                                // Clear Button (show when there's text)
                                if (_model.searchController?.text.isNotEmpty == true) ...[
                                  InkWell(
                                    onTap: () {
                                      _model.searchController?.clear();
                                      safeSetState(() {});
                                    },
                                    child: Container(
                                      padding: EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 16.0, 8.0),
                                      child: Icon(
                                        Icons.clear,
                                        color: FlutterFlowTheme.of(context).secondaryText,
                                        size: 20.0,
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                  // Filter Button (show when no text)
                                  InkWell(
                                    onTap: () {
                                      context.pushNamed('FilterPage');
                                    },
                                    child: Container(
                                      padding: EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 16.0, 8.0),
                                      child: Icon(
                                        Icons.tune,
                                        color: FlutterFlowTheme.of(context).primaryText,
                                        size: 20.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                fontFamily: 'SF Pro Text',
                                                fontSize: 17.0,
                                                letterSpacing: 0.0,
                              ),
                          cursorColor: FlutterFlowTheme.of(context).primary,
                        ),
                      ),

                      // Voice Search Status (show when listening)
                      if (_isListening) ...[
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 12.0),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).accent1,
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: FlutterFlowTheme.of(context).primary,
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.mic,
                                  color: FlutterFlowTheme.of(context).primary,
                                  size: 20.0,
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                                  child: Text(
                                    'Đang nghe... Hãy nói tên sản phẩm bạn muốn tìm',
                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                      fontFamily: 'SF Pro Text',
                                      color: FlutterFlowTheme.of(context).primary,
                                      fontSize: 14.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ],

                      // Popular Products Section
                      if (_model.searchController?.text.isEmpty ?? true) ...[
                            Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 12.0),
                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                'Sản phẩm phổ biến',
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                          fontFamily: 'SF Pro Text',
                                          fontSize: 18.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.bold,
                                          lineHeight: 1.5,
                                        ),
                                  ),
                              InkWell(
                                onTap: _loadPopularProducts,
                                child: Icon(
                                  Icons.refresh,
                                  color: FlutterFlowTheme.of(context).primary,
                                  size: 20.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Popular Products Grid
                        Builder(
                          builder: (context) {
                            if (_isLoadingProducts) {
                              return Container(
                                height: 200,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      FlutterFlowTheme.of(context).primary,
                                    ),
                                  ),
                                ),
                              );
                            } else if (_popularProducts.isEmpty) {
                              return Container(
                                height: 100,
                                child: Center(
                                  child: Text(
                                    'Không có sản phẩm phổ biến',
                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                          fontFamily: 'SF Pro Text',
                                      color: FlutterFlowTheme.of(context).secondaryText,
                                      fontSize: 14.0,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ),
                              );
                            } else {
                              return Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: _popularProducts.map((product) => InkWell(
                                  onTap: () => _navigateToProductDetail(product),
                                  child: Container(
                                    padding: EdgeInsetsDirectional.fromSTEB(12.0, 8.0, 12.0, 8.0),
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context).accent1,
                                      borderRadius: BorderRadius.circular(20.0),
                                      border: Border.all(
                                        color: FlutterFlowTheme.of(context).primary,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Text(
                                      product.name,
                                      style: FlutterFlowTheme.of(context).bodySmall.override(
                                        fontFamily: 'SF Pro Text',
                                        color: FlutterFlowTheme.of(context).primary,
                                        fontSize: 14.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                )).toList(),
                              );
                            }
                          },
                        ),
                      ],

                      // Recently Searches
                      if (FFAppState().searchlist.isNotEmpty) ...[
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tìm kiếm gần đây',
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: 'SF Pro Text',
                                  fontSize: 18.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.bold,
                                  lineHeight: 1.5,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  FFAppState().searchlist = [];
                                  safeSetState(() {});
                                },
                                child: Text(
                                  'Xóa tất cả',
                                  maxLines: 1,
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'SF Pro Text',
                                    color: FlutterFlowTheme.of(context).primary,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                  ),
                                ],
                              ),
                            ),
                            Builder(
                              builder: (context) {
                            final slist = FFAppState().searchlist.reversed.toList();

                                return ListView.separated(
                              padding: EdgeInsets.fromLTRB(0, 12.0, 0, 24.0),
                                  primary: false,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemCount: slist.length,
                              separatorBuilder: (_, __) => SizedBox(height: 12.0),
                                  itemBuilder: (context, slistIndex) {
                                    final slistItem = slist[slistIndex];
                                return InkWell(
                                  onTap: () => _performSearch(slistItem),
                                  child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                      Icon(
                                        Icons.history,
                                        color: FlutterFlowTheme.of(context).secondaryText,
                                        size: 20.0,
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 0.0, 0.0),
                                          child: Text(
                                          slistItem,
                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                fontFamily: 'SF Pro Text',
                                              fontSize: 16.0,
                                                letterSpacing: 0.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          FFAppState().removeFromSearchlist(slistItem);
                                          safeSetState(() {});
                                        },
                                        child: Icon(
                                          Icons.close,
                                          color: FlutterFlowTheme.of(context).secondaryText,
                                          size: 18.0,
                                        ),
                                        ),
                                      ],
                                  ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                    ],
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
