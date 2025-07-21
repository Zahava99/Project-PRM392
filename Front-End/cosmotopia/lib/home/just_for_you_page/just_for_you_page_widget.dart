import '/all_component/product_contanier/product_contanier_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'just_for_you_page_model.dart';
import 'package:cosmotopia/backend/api_service.dart';
import 'package:cosmotopia/backend/schema/structs/product_struct.dart';
import 'package:cosmotopia/backend/schema/structs/detail_struct.dart';
import 'dart:math';
export 'just_for_you_page_model.dart';

class JustForYouPageWidget extends StatefulWidget {
  const JustForYouPageWidget({super.key});

  static String routeName = 'JustForYouPage';
  static String routePath = 'justForYouPage';

  @override
  State<JustForYouPageWidget> createState() => _JustForYouPageWidgetState();
}

class _JustForYouPageWidgetState extends State<JustForYouPageWidget>
    with TickerProviderStateMixin {
  late JustForYouPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  // Thêm các biến cho products
  List<ProductStruct> _justForYouProducts = [];
  bool _isLoadingProducts = true;
  String? _productsError;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => JustForYouPageModel());

    animationsMap.addAll({
      'textOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          MoveEffect(
            curve: Curves.linear,
            delay: 100.0.ms,
            duration: 400.0.ms,
            begin: Offset(0.0, -20.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
    });

    _loadJustForYouProducts();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  Future<void> _loadJustForYouProducts() async {
    setState(() {
      _isLoadingProducts = true;
      _productsError = null;
    });

    try {
      // Load all products từ API
      final response = await ApiService.getAllProducts(page: 1, pageSize: 50);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['products'] != null) {
          final List<ProductStruct> products = [];
          for (var e in data['products']) {
            try {
              final product = ProductStruct.fromMap(e);
              products.add(product);
            } catch (err) {
              print('Error mapping product: $err');
            }
          }
          
          setState(() {
            // Lấy random products cho Just for you
            _justForYouProducts = _getRandomProducts(products, 20);
            _isLoadingProducts = false;
          });
        } else {
          setState(() {
            _productsError = data['message'] ?? 'Không có dữ liệu sản phẩm';
            _isLoadingProducts = false;
          });
        }
      } else {
        setState(() {
          _productsError = 'Lỗi API: ${response.statusCode}';
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      print('ERROR in _loadJustForYouProducts: $e');
      setState(() {
        _productsError = 'Lỗi kết nối: $e';
        _isLoadingProducts = false;
      });
    }
  }

  List<ProductStruct> _getRandomProducts(List<ProductStruct> products, int count) {
    if (products.isEmpty) return [];
    final random = Random();
    final shuffled = List<ProductStruct>.from(products);
    shuffled.shuffle(random);
    return shuffled.take(count).toList();
  }

  DetailStruct _convertProductToDetail(ProductStruct product) {
    return DetailStruct(
      productId: product.productId,
      id: product.productId.hashCode, // Use hashCode as numeric ID
      image: product.imageUrls.isNotEmpty ? product.imageUrls.first : 'assets/images/placeholder.png',
      title: product.name,
      price: product.price.toString(), // Keep as number string for ProductContanierWidget to format
      catetype: product.category['name'] ?? '',
      stockQuantity: product.stockQuantity.toString(),
      description: product.description,
      brandName: product.brand['name'] ?? '',
      isFav: FFAppState().isProductFavorite(product.productId),
      isJust: false,
      isNew: false,
      isCart: false,
      isColor: false,
      isResult: '',
      itsResult: false,
    );
  }

  @override
  void dispose() {
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
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: AlignmentDirectional(-1.0, -1.0),
                      child: Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(4.0, 4.0, 4.0, 4.0),
                        child: InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            context.safePop();
                          },
                          child: Container(
                            width: 40.0,
                            height: 40.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).lightGray,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_sharp,
                              color: FlutterFlowTheme.of(context).primaryText,
                              size: 20.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Just for you',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'SF  pro display',
                              fontSize: 20.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                              lineHeight: 1.5,
                            ),
                      ).animateOnPageLoad(
                          animationsMap['textOnPageLoadAnimation']!),
                    ),
                    Align(
                      alignment: AlignmentDirectional(1.0, -1.0),
                      child: Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(4.0, 4.0, 4.0, 4.0),
                        child: InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            context.pushNamed(FilterPageWidget.routeName);
                          },
                          child: Container(
                            width: 40.0,
                            height: 40.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).lightGray,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.tune,
                              color: FlutterFlowTheme.of(context).primaryText,
                              size: 20.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                  child: Builder(
                    builder: (context) {
                      if (_isLoadingProducts) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      
                      if (_productsError != null) {
                        return Center(
                          child: Text('Error: $_productsError'),
                        );
                      }

                      final justlist = _justForYouProducts;

                      return GridView.builder(
                        padding: EdgeInsets.fromLTRB(
                          0,
                          16.0,
                          0,
                          24.0,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: () {
                            if (MediaQuery.sizeOf(context).width <
                                kBreakpointSmall) {
                              return 2;
                            } else if (MediaQuery.sizeOf(context).width <
                                kBreakpointMedium) {
                              return 4;
                            } else if (MediaQuery.sizeOf(context).width <
                                kBreakpointLarge) {
                              return 6;
                            } else {
                              return 8;
                            }
                          }(),
                          crossAxisSpacing: 0.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio: 1.0,
                        ),
                        primary: false,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: justlist.length,
                        itemBuilder: (context, justlistIndex) {
                          final justlistItem = justlist[justlistIndex];
                          
                          // Convert ProductStruct to DetailStruct for compatibility
                          final detailItem = _convertProductToDetail(justlistItem);
                          
                          return Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                8.0, 0.0, 8.0, 0.0),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                context.pushNamed(
                                  ProducutDetailPageWidget.routeName,
                                  queryParameters: {
                                    'detail': serializeParam(
                                      detailItem,
                                      ParamType.DataStruct,
                                    ),
                                  }.withoutNulls,
                                );
                              },
                              child: wrapWithModel(
                                model: _model.productContanierModels.getModel(
                                  justlistItem.productId,
                                  justlistIndex,
                                ),
                                updateCallback: () => safeSetState(() {}),
                                child: ProductContanierWidget(
                                  key: Key(
                                    'Keyume_${justlistItem.productId}',
                                  ),
                                  colordata: detailItem,
                                  onTapFav: () async {
                                    if (FFAppState().isProductFavorite(justlistItem.productId)) {
                                      FFAppState().removeFromFavoriteProductIds(justlistItem.productId);
                                    } else {
                                      FFAppState().addToFavoriteProductIds(justlistItem.productId);
                                    }
                                    safeSetState(() {});
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
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
