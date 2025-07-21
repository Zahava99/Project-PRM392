import '/all_component/appbar/appbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'terms_condition_page_model.dart';
export 'terms_condition_page_model.dart';

class TermsConditionPageWidget extends StatefulWidget {
  const TermsConditionPageWidget({super.key});

  static String routeName = 'TermsConditionPage';
  static String routePath = 'termsConditionPage';

  @override
  State<TermsConditionPageWidget> createState() =>
      _TermsConditionPageWidgetState();
}

class _TermsConditionPageWidgetState extends State<TermsConditionPageWidget> {
  late TermsConditionPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TermsConditionPageModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  title: 'Terms & Condition',
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      0,
                      16.0,
                      0,
                      24.0,
                    ),
                    scrollDirection: Axis.vertical,
                    children: [
                      Text(
                        '1. Agreement of terms',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'SF Pro Text',
                              fontSize: 20.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                              lineHeight: 1.5,
                            ),
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 16.0),
                        child: Text(
                          'Duis tristique diam nunc. Sed at tincidunt orci. Mauris eget congue leo. Cras varius at ante vitae convallis. Duis semper magna nec tortor tincidunt, id tincidunt quam blandit. Vivamus vehicula dictum magna quis eleifend. ',
                          textAlign: TextAlign.justify,
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'SF Pro Text',
                                    fontSize: 17.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.normal,
                                    lineHeight: 1.5,
                                  ),
                        ),
                      ),
                      Text(
                        '2. Terms of services',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'SF Pro Text',
                              fontSize: 20.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                              lineHeight: 1.5,
                            ),
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 16.0),
                        child: Text(
                          'Sed sollicitudin nisi mollis libero consectetur rutrum. Nam maximus mollis nisl quis facilisis. Integer fermentum commodo nibh. Ut mollis tincidunt hendrerit. Duis ipsum velit, maximus sed commodo imperdiet, dapibus id velit. Nullam in maximus enim. Pellentesque vulputate nisi sit amet lacus pulvinar finibus.',
                          textAlign: TextAlign.justify,
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'SF Pro Text',
                                    fontSize: 17.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.normal,
                                    lineHeight: 1.5,
                                  ),
                        ),
                      ),
                      Text(
                        '3.Condition of use',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'SF Pro Text',
                              fontSize: 20.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                              lineHeight: 1.5,
                            ),
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                        child: Text(
                          'Sed sollicitudin nisi mollis libero consectetur rutrum. Nam maximus mollis nisl quis facilisis. Integer fermentum commodo nibh. Ut mollis tincidunt hendrerit. Duis ipsum velit, maximus sed commodo imperdiet, dapibus id velit. Nullam in maximus enim. Pellentesque vulputate nisi sit amet lacus pulvinar finibus. Nullam sit amet enim id nibh volutpat gravida vitae in orci. ',
                          textAlign: TextAlign.justify,
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'SF Pro Text',
                                    fontSize: 17.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.normal,
                                    lineHeight: 1.5,
                                  ),
                        ),
                      ),
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
