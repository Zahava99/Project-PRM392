import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '/all_component/category_contain/category_contain_widget.dart';
import '/all_component/product_contanier/product_contanier_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:cosmotopia/backend/schema/structs/product_struct.dart';
import 'data_loader_mixin.dart';
import 'bottom_page_helpers.dart';
import '../bottom_page_model.dart';

class HomeTabWidget extends StatelessWidget {
  final BottomPageModel model;
  final Map<String, AnimationInfo> animationsMap;
  final List<dynamic> categories;
  final bool isLoadingCategory;
  final String? categoryError;
  final List<ProductStruct> justForYouProducts;
  final List<ProductStruct> newArrivalProducts;
  final bool isLoadingProducts;
  final String? productsError;
  final String userName;
  final bool isLoadingUser;
  final VoidCallback onReloadFavorites;

  const HomeTabWidget({
    super.key,
    required this.model,
    required this.animationsMap,
    required this.categories,
    required this.isLoadingCategory,
    this.categoryError,
    required this.justForYouProducts,
    required this.newArrivalProducts,
    required this.isLoadingProducts,
    this.productsError,
    required this.userName,
    required this.isLoadingUser,
    required this.onReloadFavorites,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        // Header
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(20.0, 63.0, 20.0, 16.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello👋',
                    maxLines: 1,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'SF Pro Text',
                          letterSpacing: 0.0,
                        ),
                  ),
                  isLoadingUser
                      ? SizedBox(
                          width: 80,
                          height: 18,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.grey[300],
                            color: FlutterFlowTheme.of(context).primary,
                          ),
                        )
                      : Text(
                          userName,
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'SF Pro Text',
                                fontSize: 18.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.bold,
                                lineHeight: 1.5,
                              ),
                        ),
                ],
              ),
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional(1.0, 0.0),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(2.0, 2.0, 16.0, 2.0),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        context.pushNamed(NotificationPageWidget.routeName);
                      },
                      child: Container(
                        width: 44.0,
                        height: 44.0,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).lightGray,
                          shape: BoxShape.circle,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(0.0),
                          child: SvgPicture.asset(
                            'assets/images/notification.svg',
                            width: 300.0,
                            height: 200.0,
                            fit: BoxFit.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional(1.0, 0.0),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(2.0, 2.0, 2.0, 2.0),
                  child: Container(
                    width: 44.0,
                    height: 44.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).lightGray,
                      shape: BoxShape.circle,
                    ),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        context.pushNamed(CartPageWidget.routeName);
                      },
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        color: FlutterFlowTheme.of(context).primaryText,
                        size: 24.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Search Bar
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 12.0),
          child: InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              context.pushNamed(SearchPageWidget.routeName);
            },
            child: Container(
              width: double.infinity,
              height: 54.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: FlutterFlowTheme.of(context).borderColor,
                ),
              ),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 15.0, 16.0, 15.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(
                      Icons.search_sharp,
                      color: FlutterFlowTheme.of(context).primaryText,
                      size: 24.0,
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 0.0, 0.0),
                      child: Text(
                        'Tìm kiếm sản phẩm...',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'SF Pro Text',
                              color: FlutterFlowTheme.of(context).secondaryText,
                              fontSize: 17.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.normal,
                            ),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: AlignmentDirectional(1.0, -1.0),
                        child: Icon(
                          Icons.tune,
                          color: FlutterFlowTheme.of(context).primaryText,
                          size: 24.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // Content
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(0, 12.0, 0, 16.0),
            scrollDirection: Axis.vertical,
            children: [
              // AI Chatbot Banner
              Stack(
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.asset(
                        'assets/images/AI-Chatbot-Banner.jpg',
                        width: double.infinity,
                        height: 150.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(38.0, 24.0, 0.0, 0.0),
                    child: Text(
                      'AI Chatbot',
                      maxLines: 1,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'SF Pro Text',
                            color: Color(0xFF3F4F75),
                            letterSpacing: 0.0,
                            shadows: [
                              Shadow(
                                color: Colors.white.withOpacity(0.6),
                                offset: Offset(1, 1),
                                blurRadius: 1,
                              ),
                            ],
                          ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(38.0, 48.0, 0.0, 0.0),
                    child: Text(
                      'Available Now',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'SF Pro Text',
                            color: Color(0xFF1A1F71),
                            fontSize: 20.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold,
                            lineHeight: 1.5,
                            shadows: [
                              Shadow(
                                color: Colors.white.withOpacity(0.8),
                                offset: Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(40.0, 96.0, 0.0, 0.0),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        context.pushNamed(ChatPageWidget.routeName);
                      },
                      child: Container(
                        width: 116.0,
                        height: 30.0,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: Text(
                            'Try Now',
                            textAlign: TextAlign.start,
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: 'SF Pro Text',
                                  fontSize: 14.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w500,
                                  lineHeight: 1.5,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              // Categories Section
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20.0, 24.0, 20.0, 0.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Categories',
                      maxLines: 1,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'SF Pro Text',
                            fontSize: 18.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold,
                            lineHeight: 1.5,
                          ),
                    ),
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        context.pushNamed(CategoriesPageWidget.routeName);
                      },
                      child: Text(
                        'See All',
                        maxLines: 1,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'SF Pro Text',
                              letterSpacing: 0.0,
                              lineHeight: 1.5,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Categories List
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 16.0),
                child: Builder(
                  builder: (context) {
                    if (isLoadingCategory) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (categoryError != null) {
                      return Center(child: Text('Error: ${categoryError}'));
                    }
                    final category = FFAppState().categorylist;
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: List.generate(category.length, (categoryIndex) {
                          final categoryItem = category[categoryIndex];
                          return InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              context.pushNamed(
                                WaterColorPageWidget.routeName,
                                queryParameters: {
                                  'title': categoryItem.name,
                                  'categoryId': categoryItem.id,
                                }.withoutNulls,
                              );
                            },
                            child: CategoryContainWidget(
                              key: Key('Key5q1_${categoryItem.id}'),
                              tiltle: categoryItem.name,
                              image: categoryItem.image,
                            ),
                          ).animateOnPageLoad(animationsMap['categoryContainOnPageLoadAnimation']!);
                        })
                            .divide(SizedBox(width: 9.0))
                            .addToStart(SizedBox(width: 20.0))
                            .addToEnd(SizedBox(width: 20.0)),
                      ),
                    );
                  },
                ),
              ),
              
              // Just for you Section
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Just for you',
                      maxLines: 1,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'SF Pro Text',
                            fontSize: 18.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold,
                            lineHeight: 1.5,
                          ),
                    ),
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        context.pushNamed(JustForYouPageWidget.routeName);
                      },
                      child: Text(
                        'See All',
                        maxLines: 1,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'SF Pro Text',
                              letterSpacing: 0.0,
                              lineHeight: 1.5,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Just for you Products Grid
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                child: Builder(
                  builder: (context) {
                    if (isLoadingProducts) {
                      return Center(child: CircularProgressIndicator());
                    }
                    
                    if (productsError != null) {
                      return Center(child: Text('Error: $productsError'));
                    }

                    final justlist = justForYouProducts.take(4).toList();

                    return GridView.builder(
                      padding: EdgeInsets.fromLTRB(0, 12.0, 0, 0),
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
                        final detailItem = BottomPageHelpers.convertProductToDetail(justlistItem);
                        
                        return Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
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
                              model: model.productContanierModels1.getModel(
                                justlistItem.productId,
                                justlistIndex,
                              ),
                              updateCallback: () => {},
                              child: ProductContanierWidget(
                                key: Key('Key24s_${justlistItem.productId}'),
                                colordata: detailItem,
                                onTapFav: () async {
                                  if (FFAppState().isProductFavorite(justlistItem.productId)) {
                                    FFAppState().removeFromFavoriteProductIds(justlistItem.productId);
                                  } else {
                                    FFAppState().addToFavoriteProductIds(justlistItem.productId);
                                  }
                                  onReloadFavorites();
                                },
                              ),
                            ),
                          ).animateOnPageLoad(animationsMap['productContanierOnPageLoadAnimation']!),
                        );
                      },
                    );
                  },
                ),
              ),
              
              // New Arrivals Section
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20.0, 24.0, 20.0, 0.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'New Arrivals',
                      maxLines: 1,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'SF Pro Text',
                            fontSize: 18.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold,
                            lineHeight: 1.5,
                          ),
                    ),
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        context.pushNamed(NewArrivalPageWidget.routeName);
                      },
                      child: Text(
                        'See All',
                        maxLines: 1,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'SF Pro Text',
                              letterSpacing: 0.0,
                              lineHeight: 1.5,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // New Arrivals Horizontal List
              Container(
                width: double.infinity,
                height: 280.0,
                decoration: BoxDecoration(),
                child: Builder(
                  builder: (context) {
                    if (isLoadingProducts) {
                      return Center(child: CircularProgressIndicator());
                    }
                    
                    if (productsError != null) {
                      return Center(child: Text('Error: $productsError'));
                    }

                    final newlist = newArrivalProducts.take(6).toList();

                    return ListView.separated(
                      padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                      primary: false,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: newlist.length,
                      separatorBuilder: (_, __) => SizedBox(width: 16.0),
                      itemBuilder: (context, newlistIndex) {
                        final newlistItem = newlist[newlistIndex];
                        final detailItem = BottomPageHelpers.convertProductToDetail(newlistItem);
                        
                        return Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 12.0),
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
                            child: Container(
                              width: 364.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).secondaryBackground,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 3.0,
                                    color: Color(0x33000000),
                                    offset: Offset(0.0, 3.0),
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
                                        child: BottomPageHelpers.buildProductImage(
                                          detailItem.image,
                                          width: double.infinity,
                                          height: 131.0,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 12.0, 0.0),
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
                                            onReloadFavorites();
                                          },
                                          child: Container(
                                            width: 24.0,
                                            height: 24.0,
                                            decoration: BoxDecoration(
                                              color: FlutterFlowTheme.of(context).secondaryBackground,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Builder(
                                              builder: (context) {
                                                if (detailItem.isFav == true) {
                                                  return Icon(
                                                    Icons.favorite,
                                                    color: FlutterFlowTheme.of(context).error,
                                                    size: 16.0,
                                                  );
                                                } else {
                                                  return Icon(
                                                    Icons.favorite_border,
                                                    color: FlutterFlowTheme.of(context).primaryText,
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
                                      padding: EdgeInsetsDirectional.fromSTEB(12.0, 8.0, 8.0, 0.0),
                                      child: Text(
                                        detailItem.title,
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
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
                                    padding: EdgeInsetsDirectional.fromSTEB(12.0, 4.0, 0.0, 0.0),
                                    child: Text(
                                      BottomPageHelpers.formatPrice(detailItem.price),
                                      maxLines: 1,
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                            fontFamily: 'SF Pro Text',
                                            fontSize: 16.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                            lineHeight: 1.5,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).animateOnPageLoad(animationsMap['containerOnPageLoadAnimation']!),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 