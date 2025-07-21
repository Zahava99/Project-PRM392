import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '../bottom_page_model.dart';

class BottomNavigationWidget extends StatelessWidget {
  final BottomPageModel model;
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigationWidget({
    super.key,
    required this.model,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        boxShadow: [
          BoxShadow(
            blurRadius: 16.0,
            color: FlutterFlowTheme.of(context).shadowColor,
            offset: Offset(0.0, 4.0),
          )
        ],
      ),
      alignment: AlignmentDirectional(0.0, -1.0),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(12.0, 15.0, 12.0, 15.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Home Tab
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 2.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () => onTap(0),
                      child: Container(
                        width: 59.0,
                        height: 32.0,
                        decoration: BoxDecoration(
                          color: currentIndex == 0
                              ? FlutterFlowTheme.of(context).primaryLight
                              : FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(17.0),
                        ),
                        child: Builder(
                          builder: (context) {
                            if (currentIndex == 0) {
                              return Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(0.0),
                                  child: SvgPicture.asset(
                                    'assets/images/home_bottom_fill.svg',
                                    width: 24.0,
                                    height: 24.0,
                                    fit: BoxFit.contain,
                                    alignment: Alignment(0.0, 0.0),
                                  ),
                                ),
                              );
                            } else {
                              return Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(0.0),
                                  child: SvgPicture.asset(
                                    'assets/images/home_bottom.svg',
                                    width: 24.0,
                                    height: 24.0,
                                    fit: BoxFit.contain,
                                    alignment: Alignment(0.0, 0.0),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    Text(
                      'Home',
                      maxLines: 1,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'SF Pro Text',
                            color: currentIndex == 0
                                ? FlutterFlowTheme.of(context).primary
                                : FlutterFlowTheme.of(context).black40,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ]
                      .divide(SizedBox(height: 8.0))
                      .addToStart(SizedBox(height: 5.0)),
                ),
              ),
            ),
            
            // Order Tab
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 2.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () => onTap(1),
                      child: Container(
                        width: 59.0,
                        height: 32.0,
                        decoration: BoxDecoration(
                          color: currentIndex == 1
                              ? FlutterFlowTheme.of(context).primaryLight
                              : FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(17.0),
                        ),
                        child: Builder(
                          builder: (context) {
                            if (currentIndex == 1) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(0.0),
                                child: SvgPicture.asset(
                                  'assets/images/order_bottom_fill.svg',
                                  width: 24.0,
                                  height: 24.0,
                                  fit: BoxFit.contain,
                                ),
                              );
                            } else {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(0.0),
                                child: SvgPicture.asset(
                                  'assets/images/order_bottom.svg',
                                  width: 24.0,
                                  height: 24.0,
                                  fit: BoxFit.contain,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: Text(
                        'Order',
                        maxLines: 1,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'SF Pro Text',
                              color: currentIndex == 1
                                  ? FlutterFlowTheme.of(context).primary
                                  : FlutterFlowTheme.of(context).black40,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ),
                  ]
                      .divide(SizedBox(height: 8.0))
                      .addToStart(SizedBox(height: 5.0)),
                ),
              ),
            ),
            
            // Camera Button (Scanner)
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      context.pushNamed(AiBeautyScannerWidget.routeName);
                    },
                    child: Container(
                      width: 56.0,
                      height: 56.0,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
                          stops: [0.0, 1.0],
                          begin: AlignmentDirectional(0.0, -1.0),
                          end: AlignmentDirectional(0, 1.0),
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8.0,
                            color: Color(0xFF8B5CF6).withOpacity(0.3),
                            offset: Offset(0.0, 4.0),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 28.0,
                      ),
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    'Scanner',
                    maxLines: 1,
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: 'SF Pro Text',
                          color: FlutterFlowTheme.of(context).primaryText,
                          fontSize: 12.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
            
            // Favorite Tab
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 2.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () => onTap(2),
                      child: Container(
                        width: 59.0,
                        height: 32.0,
                        decoration: BoxDecoration(
                          color: currentIndex == 2
                              ? FlutterFlowTheme.of(context).primaryLight
                              : FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(17.0),
                        ),
                        child: Builder(
                          builder: (context) {
                            if (currentIndex == 2) {
                              return Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(0.0),
                                  child: SvgPicture.asset(
                                    'assets/images/favourite_fill_bottom.svg',
                                    width: 24.0,
                                    height: 24.0,
                                    fit: BoxFit.contain,
                                    alignment: Alignment(0.0, 0.0),
                                  ),
                                ),
                              );
                            } else {
                              return Icon(
                                Icons.favorite_border,
                                color: FlutterFlowTheme.of(context).secondaryText,
                                size: 24.0,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    AutoSizeText(
                      'Favourite',
                      maxLines: 1,
                      minFontSize: 13.0,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'SF Pro Text',
                            color: currentIndex == 2
                                ? FlutterFlowTheme.of(context).primary
                                : FlutterFlowTheme.of(context).black40,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ]
                      .divide(SizedBox(height: 8.0))
                      .addToStart(SizedBox(height: 5.0)),
                ),
              ),
            ),
            
            // Profile Tab
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 2.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () => onTap(3),
                      child: Container(
                        width: 59.0,
                        height: 32.0,
                        decoration: BoxDecoration(
                          color: currentIndex == 3
                              ? FlutterFlowTheme.of(context).primaryLight
                              : FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(17.0),
                        ),
                        child: Builder(
                          builder: (context) {
                            if (currentIndex == 3) {
                              return Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(0.0),
                                  child: SvgPicture.asset(
                                    'assets/images/profile_fill_bottom.svg',
                                    width: 24.0,
                                    height: 24.0,
                                    fit: BoxFit.contain,
                                    alignment: Alignment(0.0, 0.0),
                                  ),
                                ),
                              );
                            } else {
                              return Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(0.0),
                                  child: SvgPicture.asset(
                                    'assets/images/basket_profile.svg',
                                    width: 24.0,
                                    height: 24.0,
                                    fit: BoxFit.contain,
                                    alignment: Alignment(0.0, 0.0),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    Text(
                      'Profile',
                      maxLines: 1,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'SF Pro Text',
                            color: currentIndex == 3
                                ? FlutterFlowTheme.of(context).primaryText
                                : FlutterFlowTheme.of(context).black40,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ]
                      .divide(SizedBox(height: 8.0))
                      .addToStart(SizedBox(height: 5.0)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 