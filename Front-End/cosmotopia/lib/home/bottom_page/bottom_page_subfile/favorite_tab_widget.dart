import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '/all_component/favourite_empty/favourite_empty_widget.dart';
import '/all_component/product_contanier/product_contanier_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:cosmotopia/backend/schema/structs/product_struct.dart';
import 'bottom_page_helpers.dart';
import '../bottom_page_model.dart';

class FavoriteTabWidget extends StatelessWidget {
  final BottomPageModel model;
  final Map<String, AnimationInfo> animationsMap;
  final List<ProductStruct> favoriteProducts;
  final bool isLoadingFavorites;
  final String? favoritesError;
  final VoidCallback onReloadFavorites;

  const FavoriteTabWidget({
    super.key,
    required this.model,
    required this.animationsMap,
    required this.favoriteProducts,
    required this.isLoadingFavorites,
    this.favoritesError,
    required this.onReloadFavorites,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 63.0, 0.0, 16.0),
          child: Text(
            'Favorite',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'SF Pro Text',
                  fontSize: 24.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                  lineHeight: 1.5,
                ),
          ).animateOnPageLoad(animationsMap['textOnPageLoadAnimation2']!),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
            child: Builder(
              builder: (context) {
                if (isLoadingFavorites) {
                  return Center(child: CircularProgressIndicator());
                }
                
                if (favoritesError != null) {
                  return Center(child: Text('Error: $favoritesError'));
                }

                if (favoriteProducts.isEmpty) {
                  return Container(
                    width: 388.0,
                    height: 214.0,
                    child: FavouriteEmptyWidget(),
                  );
                }

                final waterlist = favoriteProducts;

                return GridView.builder(
                  padding: EdgeInsets.fromLTRB(0, 25.0, 0, 24.0),
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
                  itemCount: waterlist.length,
                  itemBuilder: (context, waterlistIndex) {
                    final waterlistItem = waterlist[waterlistIndex];
                    final detailItem = BottomPageHelpers.convertProductToDetail(waterlistItem);
                    
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
                          model: model.productContanierModels2.getModel(
                            waterlistItem.productId,
                            waterlistIndex,
                          ),
                          updateCallback: () => {},
                          child: ProductContanierWidget(
                            key: Key('Keyshl_${waterlistItem.productId}'),
                            colordata: detailItem,
                            onTapFav: () async {
                              // Remove from favorites (since we're in favorites page)
                              FFAppState().removeFromFavoriteProductIds(waterlistItem.productId);
                              // Reload favorites to update UI
                              onReloadFavorites();
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
    );
  }
} 