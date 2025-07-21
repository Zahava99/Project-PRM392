import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'admin_page_model.dart';
export 'admin_page_model.dart';

class AdminPageWidget extends StatefulWidget {
  const AdminPageWidget({super.key});

  static String routeName = 'AdminPage';
  static String routePath = 'adminPage';

  @override
  State<AdminPageWidget> createState() => _AdminPageWidgetState();
}

class _AdminPageWidgetState extends State<AdminPageWidget>
    with TickerProviderStateMixin {
  late AdminPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminPageModel());

    animationsMap.addAll({
      'containerOnPageLoadAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 100.0.ms,
            duration: 600.0.ms,
            begin: Offset(100.0, 0.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
      'containerOnPageLoadAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 200.0.ms,
            duration: 600.0.ms,
            begin: Offset(100.0, 0.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
      'containerOnPageLoadAnimation3': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 300.0.ms,
            duration: 600.0.ms,
            begin: Offset(100.0, 0.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
      'containerOnPageLoadAnimation4': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 400.0.ms,
            duration: 600.0.ms,
            begin: Offset(100.0, 0.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
      'containerOnPageLoadAnimation5': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 500.0.ms,
            duration: 600.0.ms,
            begin: Offset(100.0, 0.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
      'containerOnPageLoadAnimation6': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 600.0.ms,
            duration: 600.0.ms,
            begin: Offset(100.0, 0.0),
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

  Widget _buildManagementCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required String animationKey,
    Color? iconColor,
  }) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 16.0),
      child: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: onTap,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            boxShadow: [
              BoxShadow(
                blurRadius: 16.0,
                color: Color(0x14000000),
                offset: Offset(0.0, 4.0),
                spreadRadius: 0.0,
              )
            ],
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: 48.0,
                  height: 48.0,
                  decoration: BoxDecoration(
                    color: (iconColor ?? FlutterFlowTheme.of(context).primary).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? FlutterFlowTheme.of(context).primary,
                    size: 24.0,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 0.0, 0.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'SF Pro Text',
                            fontSize: 17.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                            lineHeight: 1.5,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'SF Pro Text',
                            fontSize: 14.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.normal,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            lineHeight: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: FlutterFlowTheme.of(context).primaryText,
                  size: 20.0,
                ),
              ],
            ),
          ),
        ),
      ).animateOnPageLoad(animationsMap[animationKey]!),
    );
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
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 25.0, 0.0, 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 0.0, 0.0),
                      child: InkWell(
                        onTap: () async {
                          context.safePop();
                        },
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: FlutterFlowTheme.of(context).primaryText,
                          size: 24.0,
                        ),
                      ),
                    ),
                    Text(
                      'Administrator',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'SF  pro display',
                        fontSize: 24.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                        lineHeight: 1.5,
                      ),
                    ),
                    SizedBox(width: 44.0), // To balance the back button
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(0, 45.0, 0, 24.0),
                  scrollDirection: Axis.vertical,
                  children: [
                    // Admin Profile Section
                    Icon(
                      Icons.admin_panel_settings,
                      size: 87.0,
                      color: FlutterFlowTheme.of(context).primary,
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                      child: Text(
                        FFAppState().firstname.isNotEmpty ? FFAppState().firstname : 'Administrator',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'SF Pro Text',
                          fontSize: 18.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                          lineHeight: 1.5,
                        ),
                      ),
                    ),
                    Text(
                      'Quản lý hệ thống',
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'SF Pro Text',
                        fontSize: 17.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.normal,
                        lineHeight: 1.2,
                      ),
                    ),
                    
                    // Management Cards Section
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0.0, 32.0, 0.0, 0.0),
                      child: Column(
                        children: [
                          // Product Management
                          _buildManagementCard(
                            icon: Icons.inventory_2,
                            title: 'Product Management',
                            subtitle: 'Quản lý sản phẩm, danh mục, thương hiệu',
                            onTap: () async {
                              context.pushNamed('ProductManagementPage');
                            },
                            animationKey: 'containerOnPageLoadAnimation1',
                          ),
                          
                          // User Management
                          _buildManagementCard(
                            icon: Icons.people,
                            title: 'User Management',
                            subtitle: 'Quản lý người dùng, phân quyền tài khoản',
                            onTap: () async {
                              context.pushNamed('UserManagementPage');
                            },
                            animationKey: 'containerOnPageLoadAnimation2',
                            iconColor: Colors.green,
                          ),
                          
                          // Order Management
                          _buildManagementCard(
                            icon: Icons.receipt_long,
                            title: 'Order Management',
                            subtitle: 'Quản lý đơn hàng, trạng thái giao hàng',
                            onTap: () async {
                              context.pushNamed('OrderManagementPage');
                            },
                            animationKey: 'containerOnPageLoadAnimation3',
                            iconColor: Colors.orange,
                          ),
                          
                          // Payment Management
                          _buildManagementCard(
                            icon: Icons.payment,
                            title: 'Payment Management',
                            subtitle: 'Quản lý thanh toán, giao dịch',
                            onTap: () async {
                              context.pushNamed('PaymentManagementPage');
                            },
                            animationKey: 'containerOnPageLoadAnimation4',
                            iconColor: Colors.blue,
                          ),
                          
                          // Affiliate Management
                          // _buildManagementCard(
                          //   icon: Icons.link,
                          //   title: 'Affiliate Management',
                          //   subtitle: 'Quản lý affiliate, hoa hồng, rút tiền',
                          //   onTap: () async {
                          //     // TODO: Navigate to Affiliate Management page
                          //     ScaffoldMessenger.of(context).showSnackBar(
                          //       SnackBar(content: Text('Affiliate Management - Coming Soon')),
                          //     );
                          //   },
                          //   animationKey: 'containerOnPageLoadAnimation5',
                          //   iconColor: Colors.purple,
                          // ),
                          
                          // Analytics & Reports
                          _buildManagementCard(
                            icon: Icons.analytics,
                            title: 'Analytics & Reports',
                            subtitle: 'Thống kê, báo cáo hệ thống',
                            onTap: () async {
                              context.pushNamed('AnalyticsReportsPage');
                            },
                            animationKey: 'containerOnPageLoadAnimation6',
                            iconColor: Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 