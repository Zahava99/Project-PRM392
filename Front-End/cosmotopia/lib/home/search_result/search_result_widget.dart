import '/all_component/appbar/appbar_widget.dart';
import '/all_component/product_contanier/product_contanier_widget.dart';
import '/all_component/search_empty/search_empty_widget.dart';
import '/backend/api_service.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'search_result_model.dart';
export 'search_result_model.dart';

class SearchResultWidget extends StatefulWidget {
  const SearchResultWidget({
    super.key,
    this.searchQuery,
  });

  final String? searchQuery;

  static String routeName = 'SearchResult';
  static String routePath = 'searchResult';

  @override
  State<SearchResultWidget> createState() => _SearchResultWidgetState();
}

class _SearchResultWidgetState extends State<SearchResultWidget> {
  late SearchResultModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  List<ProductStruct> _searchResults = [];
  bool _isLoading = false;
  String _currentQuery = '';
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SearchResultModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    // Initialize with search query if provided
    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      _currentQuery = widget.searchQuery!;
      _model.textController?.text = _currentQuery;
      _performSearch(_currentQuery);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // Convert ProductStruct to DetailStruct for ProductContanierWidget
  DetailStruct _convertProductToDetail(ProductStruct product) {
    return DetailStruct(
      productId: product.productId,
      title: product.name,
      price: product.price.toString() + '₫',
      image: product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
      description: product.description,
      catetype: product.category['name']?.toString() ?? '',
      brandName: product.brand['name']?.toString() ?? '',
      stockQuantity: product.stockQuantity.toString(),
      isFav: false, // Default value, can be updated based on user favorites
      isJust: false,
      isNew: false,
      isCart: false,
      isColor: false,
      itsResult: true,
      id: product.productId.hashCode, // Generate a simple ID from productId
    );
  }

  // Perform search API call
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _currentQuery = query.trim();
    });

    try {
      print('🔍 Searching for: $query');
      final response = await ApiService.getAllProducts(
        search: query.trim(),
        page: 1,
        pageSize: 50,
      );

      print('📊 Search API Response Status: ${response.statusCode}');
      print('📄 Search Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<ProductStruct> products = [];

        // Parse products from API response
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
          _searchResults = products;
          _isLoading = false;
        });

        print('✅ Found ${products.length} products for "$query"');
      } else {
        print('❌ Search API failed with status: ${response.statusCode}');
        setState(() {
          _searchResults = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Search API error: $e');
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
    }
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
                  title: 'Kết quả tìm kiếm',
                ),
              ),
              // Search Bar
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 0.0),
                child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                            child: TextFormField(
                              controller: _model.textController,
                              focusNode: _model.textFieldFocusNode,
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
                          hintText: 'Tìm kiếm sản phẩm...',
                                hintStyle: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .override(
                                      fontFamily: 'SF Pro Text',
                                color: FlutterFlowTheme.of(context).secondaryText,
                                      fontSize: 17.0,
                                      letterSpacing: 0.0,
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
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).error,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).error,
                              width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                          contentPadding: EdgeInsetsDirectional.fromSTEB(16.0, 13.0, 16.0, 12.0),
                                prefixIcon: Icon(
                                  Icons.search_sharp,
                            color: FlutterFlowTheme.of(context).primaryText,
                                  size: 24.0,
                                ),
                          suffixIcon: _model.textController?.text.isNotEmpty == true
                              ? InkWell(
                                  onTap: () {
                                    _model.textController?.clear();
                                    setState(() {
                                      _searchResults = [];
                                      _hasSearched = false;
                                      _currentQuery = '';
                                    });
                                  },
                                  child: Icon(
                                    Icons.clear,
                                    color: FlutterFlowTheme.of(context).secondaryText,
                                    size: 20.0,
                                ),
                                )
                              : null,
                              ),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'SF Pro Text',
                                    fontSize: 17.0,
                                    letterSpacing: 0.0,
                                  ),
                              cursorColor: FlutterFlowTheme.of(context).primary,
                        validator: _model.textControllerValidator.asValidator(context),
                            ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 0.0, 0.0),
                      child: InkWell(
                        onTap: () {
                          context.pop();
                        },
                        child: Text(
                          'Hủy',
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'SF Pro Text',
                            color: FlutterFlowTheme.of(context).primary,
                            fontSize: 16.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                            lineHeight: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Results Section
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (_isLoading) {
                      // Loading State
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                FlutterFlowTheme.of(context).primary,
                          ),
                        ),
                        Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                          child: Text(
                                'Đang tìm kiếm...',
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: 'SF Pro Text',
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (!_hasSearched) {
                      // Initial State - No search performed yet
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search,
                              size: 64.0,
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                              child: Text(
                                'Nhập từ khóa để tìm kiếm sản phẩm',
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: 'SF Pro Text',
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (_searchResults.isEmpty) {
                      // Empty Results
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64.0,
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                              child: Text(
                                'Không tìm thấy sản phẩm nào',
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: 'SF Pro Text',
                                  fontSize: 18.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                              child: Text(
                                'Thử tìm kiếm với từ khóa khác',
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: 'SF Pro Text',
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                  fontSize: 14.0,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                          ],
                        ),
                      );
                    } else {
                      // Search Results
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Results Header
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 0.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Tìm thấy ${_searchResults.length} sản phẩm',
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'SF Pro Text',
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    // TODO: Implement filter functionality
                                    context.pushNamed('FilterPage');
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.tune,
                                        color: FlutterFlowTheme.of(context).primary,
                                        size: 20.0,
                    ),
                    Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 0.0, 0.0),
                                        child: Text(
                                          'Lọc',
                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
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
                              ],
                            ),
                          ),

                          // Products Grid
                          Expanded(
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(12.0, 8.0, 12.0, 0.0),
                              child: GridView.builder(
                                padding: EdgeInsets.fromLTRB(0, 16.0, 0, 24.0),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: () {
                                    if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                                  return 2;
                                    } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
                                  return 4;
                                    } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
                                  return 6;
                                } else {
                                  return 8;
                                }
                              }(),
                                  crossAxisSpacing: 8.0,
                              mainAxisSpacing: 16.0,
                                  childAspectRatio: 0.75,
                            ),
                                itemCount: _searchResults.length,
                                itemBuilder: (context, index) {
                                  final product = _searchResults[index];
                                  final detailProduct = _convertProductToDetail(product);
                                  
                              return Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                      onTap: () {
                                    context.pushNamed(
                                      ProducutDetailPageWidget.routeName,
                                      queryParameters: {
                                            'detail': serializeParam(detailProduct, ParamType.DataStruct),
                                      }.withoutNulls,
                                    );
                                  },
                                  child: wrapWithModel(
                                        model: _model.productContanierModels.getModel(
                                          index.toString(),
                                          index,
                                    ),
                                    updateCallback: () => safeSetState(() {}),
                                    child: ProductContanierWidget(
                                          key: Key('SearchResult_${index.toString()}'),
                                          colordata: detailProduct,
                                      onTapFav: () async {
                                            // TODO: Implement favorite functionality
                                            print('💖 Favorite tapped for product: ${product.name}');
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                              ),
                      ),
                    ),
                  ],
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
