import '/all_component/appbar/appbar_widget.dart';
import '/all_component/category_contain/category_contain_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'categories_page_model.dart';
export 'categories_page_model.dart';

class CategoriesPageWidget extends StatefulWidget {
  const CategoriesPageWidget({super.key});

  static String routeName = 'CategoriesPage';
  static String routePath = 'categoriesPage';

  @override
  State<CategoriesPageWidget> createState() => _CategoriesPageWidgetState();
}

class _CategoriesPageWidgetState extends State<CategoriesPageWidget>
    with TickerProviderStateMixin {
  late CategoriesPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CategoriesPageModel());

    animationsMap.addAll({
      'categoryContainOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 150.0.ms,
            duration: 200.0.ms,
            begin: Offset(0.0, 100.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
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
              wrapWithModel(
                model: _model.appbarModel,
                updateCallback: () => safeSetState(() {}),
                child: AppbarWidget(
                  title: 'Category',
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                  child: Builder(
                    builder: (context) {
                      final category = FFAppState().categorylist.toList();

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
                              return 4;
                            } else if (MediaQuery.sizeOf(context).width <
                                kBreakpointMedium) {
                              return 8;
                            } else if (MediaQuery.sizeOf(context).width <
                                kBreakpointLarge) {
                              return 8;
                            } else {
                              return 12;
                            }
                          }(),
                          crossAxisSpacing: 16.0,
                          childAspectRatio: 0.56,
                        ),
                        scrollDirection: Axis.vertical,
                        itemCount: category.length,
                        itemBuilder: (context, categoryIndex) {
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
                                  'title': serializeParam(
                                    categoryItem.name,
                                    ParamType.String,
                                  ),
                                }.withoutNulls,
                              );
                            },
                            child: wrapWithModel(
                              model: _model.categoryContainModels.getModel(
                                categoryItem.id.toString(),
                                categoryIndex,
                              ),
                              updateCallback: () => safeSetState(() {}),
                              child: CategoryContainWidget(
                                key: Key(
                                  'Keysnl_${categoryItem.id.toString()}',
                                ),
                                tiltle: categoryItem.name,
                                image: categoryItem.image,
                              ),
                            ),
                          ).animateOnPageLoad(animationsMap[
                              'categoryContainOnPageLoadAnimation']!);
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
