import '/all_component/product_contanier/product_contanier_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/backend/api_service.dart';
import '/backend/schema/structs/product_struct.dart';
import '/backend/schema/structs/detail_struct.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'water_color_page_model.dart';
export 'water_color_page_model.dart';

class WaterColorPageWidget extends StatefulWidget {
  const WaterColorPageWidget({
    super.key,
    required this.title,
    this.categoryId,
  });

  final String? title;
  final String? categoryId;

  static String routeName = 'WaterColorPage';
  static String routePath = 'waterColorPage';

  @override
  State<WaterColorPageWidget> createState() => _WaterColorPageWidgetState();
}

class _WaterColorPageWidgetState extends State<WaterColorPageWidget>
    with TickerProviderStateMixin {
  late WaterColorPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    print('--- initState CALLED ---');
    _model = createModel(context, () => WaterColorPageModel());

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

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    print('--- _loadProducts CALLED ---');
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('--- Before API call ---');
      final response = await ApiService.getAllProducts(
        page: 1,
        pageSize: 20,
        categoryId: widget.categoryId,
      );
      print('--- After API call ---');
      print('API response: ${response.body}');
      print('categoryId: ${widget.categoryId}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['products'] != null) {
          final products = <ProductStruct>[];
          for (var e in data['products']) {
            try {
              print('Product JSON: $e');
              final p = ProductStruct.fromMap(e);
              print('ProductStruct: $p');
              products.add(p);
            } catch (err) {
              print('Error mapping product: $err');
            }
          }
          FFAppState().productlist = products;
          print('FFAppState().productlist: ${FFAppState().productlist}');
          _error = null;
        } else {
          _error = data['message'] ?? 'Không có dữ liệu sản phẩm';
        }
      } else {
        _error = 'Lỗi API: ${response.statusCode}';
      }
    } catch (e) {
      print('ERROR in _loadProducts: $e');
      _error = 'Lỗi kết nối: $e';
    }

    setState(() {
      _isLoading = false;
    });
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
                padding: EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: AlignmentDirectional(-1.0, -1.0),
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
                        valueOrDefault<String>(
                          widget.title,
                          'Sản phẩm',
                        ),
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
                    Align(
                      alignment: AlignmentDirectional(1.0, -1.0),
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
                  padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                  child: Builder(
                    builder: (context) {
                      if (_isLoading) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (_error != null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Lỗi',
                                style: FlutterFlowTheme.of(context).bodyLarge,
                              ),
                              Text(
                                _error!,
                                style: FlutterFlowTheme.of(context).bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadProducts,
                                child: Text('Thử lại'),
                              ),
                            ],
                          ),
                        );
                      }

                      final productList = FFAppState().productlist;

                      if (productList.isEmpty) {
                        return Center(
                          child: Text(
                            'Không có sản phẩm nào',
                            style: FlutterFlowTheme.of(context).bodyLarge,
                          ),
                        );
                      }

                      return GridView.builder(
                        padding: EdgeInsets.fromLTRB(
                          0,
                          16.0,
                          0,
                          24.0,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 0.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio: 1.0,
                        ),
                        primary: false,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: productList.length,
                        itemBuilder: (context, productIndex) {
                          final productItem = productList[productIndex];
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
                                      DetailStruct(
                                        productId: productItem.productId ?? '',
                                        prid: productIndex,
                                        id: productIndex,
                                        image: productItem.imageUrls.isNotEmpty 
                                            ? productItem.imageUrls.first 
                                            : 'https://via.placeholder.com/200',
                                        title: productItem.name,
                                        price: productItem.price.toString(),
                                        description: productItem.description ?? '',
                                        catetype: productItem.category['name'] ?? '',
                                        stockQuantity: productItem.stockQuantity.toString() ?? '',
                                        brandName: productItem.brand != null ? productItem.brand['name'] ?? '' : '',
                                        isFav: false,
                                        isJust: false,
                                        isNew: false,
                                        isCart: false,
                                        isColor: false,
                                      ),
                                      ParamType.DataStruct,
                                    ),
                                  }.withoutNulls,
                                );
                              },
                              child: wrapWithModel(
                                model: _model.productContanierModels.getModel(
                                  productIndex.toString(),
                                  productIndex,
                                ),
                                updateCallback: () => safeSetState(() {}),
                                child: ProductContanierWidget(
                                  key: Key(
                                    'Key8qw_${productIndex.toString()}',
                                  ),
                                  colordata: DetailStruct(
                                    productId: productItem.productId ?? '',
                                    prid: productIndex,
                                    id: productIndex,
                                    image: productItem.imageUrls.isNotEmpty 
                                        ? productItem.imageUrls.first 
                                        : 'https://via.placeholder.com/200',
                                    title: productItem.name,
                                    price: '₫${productItem.price.toString()}',
                                    description: productItem.description ?? '',
                                    catetype: productItem.category['name'] ?? '',
                                    stockQuantity: productItem.stockQuantity.toString() ?? '',
                                    brandName: productItem.brand != null ? productItem.brand['name'] ?? '' : '',
                                    isFav: false,
                                    isJust: false,
                                    isNew: false,
                                    isCart: false,
                                    isColor: false,
                                  ),
                                  onTapFav: () async {
                                    // TODO: Implement favorite functionality
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
