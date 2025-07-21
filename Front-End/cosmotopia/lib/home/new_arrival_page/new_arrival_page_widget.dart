import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'new_arrival_page_model.dart';
import 'package:cosmotopia/backend/api_service.dart';
import 'package:cosmotopia/backend/schema/structs/product_struct.dart';
import 'package:cosmotopia/backend/schema/structs/detail_struct.dart';
import 'dart:math';
export 'new_arrival_page_model.dart';

class NewArrivalPageWidget extends StatefulWidget {
  const NewArrivalPageWidget({super.key});

  static String routeName = 'NewArrivalPage';
  static String routePath = 'newArrivalPage';

  @override
  State<NewArrivalPageWidget> createState() => _NewArrivalPageWidgetState();
}

class _NewArrivalPageWidgetState extends State<NewArrivalPageWidget>
    with TickerProviderStateMixin {
  late NewArrivalPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  // Thêm các biến cho products
  List<ProductStruct> _newArrivalProducts = [];
  bool _isLoadingProducts = true;
  String? _productsError;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NewArrivalPageModel());

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

    _loadNewArrivalProducts();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  Future<void> _loadNewArrivalProducts() async {
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
            // Lấy random products cho New Arrivals
            _newArrivalProducts = _getRandomProducts(products, 20);
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
      print('ERROR in _loadNewArrivalProducts: $e');
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

  String _formatPrice(String priceString) {
    final priceValue = int.tryParse(priceString.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(priceValue);
  }

  Widget _buildProductImage(String imageUrl, {double? width, double? height, BoxFit? fit}) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: width ?? double.infinity,
        height: height,
        fit: fit ?? BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/placeholder.png',
            width: width ?? double.infinity,
            height: height,
            fit: fit ?? BoxFit.cover,
          );
        },
      );
    } else {
      return Image.asset(
        imageUrl.isNotEmpty ? imageUrl : 'assets/images/placeholder.png',
        width: width ?? double.infinity,
        height: height,
        fit: fit ?? BoxFit.cover,
      );
    }
  }

  DetailStruct _convertProductToDetail(ProductStruct product) {
    return DetailStruct(
      productId: product.productId,
      id: product.productId.hashCode, // Use hashCode as numeric ID
      image: product.imageUrls.isNotEmpty ? product.imageUrls.first : 'assets/images/placeholder.png',
      title: product.name,
      price: product.price.toString(), // Keep as number string for formatting
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
                    Padding(
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
                    Expanded(
                      child: Text(
                        'New Arrivals',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'SF  pro display',
                              fontSize: 24.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                              lineHeight: 1.5,
                            ),
                      ).animateOnPageLoad(
                          animationsMap['textOnPageLoadAnimation']!),
                    ),
                    Padding(
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
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
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

                      final newlist = _newArrivalProducts;

                      return ListView.separated(
                        padding: EdgeInsets.fromLTRB(
                          0,
                          16.0,
                          0,
                          24.0,
                        ),
                        scrollDirection: Axis.vertical,
                        itemCount: newlist.length,
                        separatorBuilder: (_, __) => SizedBox(height: 16.0),
                        itemBuilder: (context, newlistIndex) {
                          final newlistItem = newlist[newlistIndex];
                          
                          // Convert ProductStruct to DetailStruct for compatibility
                          final detailItem = _convertProductToDetail(newlistItem);
                          
                          return InkWell(
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
                            child: Container(
                              width: 364.0,
                              height: 210.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 3.0,
                                    color: Color(0x33000000),
                                    offset: Offset(
                                      0.0,
                                      3.0,
                                    ),
                                    spreadRadius: 0.0,
                                  )
                                ],
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(8.0),
                                  bottomRight: Radius.circular(8.0),
                                  topLeft: Radius.circular(8.0),
                                  topRight: Radius.circular(8.0),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    alignment: AlignmentDirectional(1.0, -1.0),
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(0.0),
                                          bottomRight: Radius.circular(0.0),
                                          topLeft: Radius.circular(8.0),
                                          topRight: Radius.circular(8.0),
                                        ),
                                        child: _buildProductImage(
                                          detailItem.image,
                                          width: double.infinity,
                                          height: 131.0,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 12.0, 12.0, 0.0),
                                        child: InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            if (FFAppState().isProductFavorite(newlistItem.productId)) {
                                              FFAppState().removeFromFavoriteProductIds(newlistItem.productId);
                                            } else {
                                              FFAppState().addToFavoriteProductIds(newlistItem.productId);
                                            }
                                            safeSetState(() {});
                                          },
                                          child: Container(
                                            width: 24.0,
                                            height: 24.0,
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Builder(
                                              builder: (context) {
                                                if (detailItem.isFav == true) {
                                                  return Icon(
                                                    Icons.favorite,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .error,
                                                    size: 16.0,
                                                  );
                                                } else {
                                                  return Icon(
                                                    Icons.favorite_border,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    size: 16.0,
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Flexible(
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          12.0, 8.0, 8.0, 0.0),
                                      child: Text(
                                        detailItem.title,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'SF Pro Text',
                                              fontSize: 17.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.normal,
                                              lineHeight: 1.5,
                                            ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        12.0, 4.0, 0.0, 0.0),
                                    child: Text(
                                      _formatPrice(detailItem.price),
                                      maxLines: 1,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'SF Pro Text',
                                            fontSize: 14.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                            lineHeight: 1.5,
                                          ),
                                    ),
                                  ),
                                ],
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
