import '/all_component/appbar/appbar_widget.dart';
import '/backend/api_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/affiliate/generate_link/generate_link_widget.dart';
// import '/affiliate/earnings_analytics/earnings_analytics_widget.dart';
import '/affiliate/withdrawal/withdrawal_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:async';
import 'affiliate_dashboard_model.dart';
export 'affiliate_dashboard_model.dart';

class AffiliateDashboardWidget extends StatefulWidget {
  const AffiliateDashboardWidget({super.key});

  static String routeName = 'AffiliateDashboard';
  static String routePath = 'affiliateDashboard';

  @override
  State<AffiliateDashboardWidget> createState() => _AffiliateDashboardWidgetState();
}

class _AffiliateDashboardWidgetState extends State<AffiliateDashboardWidget> {
  late AffiliateDashboardModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoadingStats = false;
  Map<String, dynamic> _affiliateStats = {};
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AffiliateDashboardModel());
    _loadAffiliateStats();
    
    // Listen for app state changes to auto-refresh
    WidgetsBinding.instance.addPostFrameCallback((_) {
      safeSetState(() {});
      _listenForClickUpdates();
    });
  }

  void _listenForClickUpdates() {
    _refreshTimer?.cancel(); // Cancel any existing timer
    
    // Check periodically if there are new clicks tracked
    _refreshTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      // Auto refresh if user is on dashboard and new clicks were tracked
      final now = DateTime.now().millisecondsSinceEpoch;
      final lastClickTime = FFAppState().lastClickTrackedAt ?? 0;
      
      if (lastClickTime > 0 && (now - lastClickTime) < 5000) { // Within 5 seconds
        print('🔄 Auto refreshing dashboard due to recent click tracking');
        _loadAffiliateStats();
        FFAppState().lastClickTrackedAt = 0; // Reset to prevent continuous refresh
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _model.dispose();
    super.dispose();
  }

  // Load affiliate statistics
  Future<void> _loadAffiliateStats() async {
    setState(() {
      _isLoadingStats = true;
    });

    try {
      final token = FFAppState().token;
      if (token.isEmpty) {
        throw Exception('User not authenticated');
      }
      
      print('🔍 Loading affiliate stats with token: $token');
      
      final startDate = DateTime.now().subtract(Duration(days: 30));
      final endDate = DateTime.now().add(Duration(days: 1));
      print('📅 Date range: $startDate to $endDate');
      
      // Load data from multiple APIs
      final futures = await Future.wait([
        ApiService.getAffiliateProfile(token: token),
        ApiService.getAffiliateStats(
          token: token, 
          startDate: startDate,
          endDate: endDate
        ),
        ApiService.getAffiliateEarnings(token: token, period: 'month'),
      ]);
      
      final profileResponse = futures[0];
      final statsResponse = futures[1]; 
      final earningsResponse = futures[2];
      
      Map<String, dynamic> profileData = {};
      Map<String, dynamic> statsData = {};
      Map<String, dynamic> earningsData = {};
      
      // Parse profile data
      if (profileResponse.statusCode == 200) {
        final profileJson = jsonDecode(profileResponse.body);
        if (profileJson['success'] == true) {
          profileData = profileJson['data'] ?? {};
        }
      }
      
      // Parse stats data
      if (statsResponse.statusCode == 200) {
        final statsJson = jsonDecode(statsResponse.body);
        if (statsJson['success'] == true) {
          statsData = statsJson['data'] ?? {};
          print('🔍 Stats Data: $statsData'); // Debug logging
        }
      }
      
      // Parse earnings data
      if (earningsResponse.statusCode == 200) {
        final earningsJson = jsonDecode(earningsResponse.body);
        if (earningsJson['success'] == true) {
          earningsData = earningsJson['data'] ?? {};
        }
      }
      
      setState(() {
        _affiliateStats = {
          'totalEarnings': profileData['totalEarnings'] ?? 0,
          'monthlyEarnings': statsData['weeklyEarnings'] ?? 0,
          'totalClicks': statsData['count'] ?? 0,  // ✅ Fixed: Get clicks from stats API
          'conversions': statsData['conversionCount'] ?? 0,
          'conversionRate': (statsData['conversionRate'] ?? 0.0).toDouble(),
          'pendingCommission': profileData['pendingAmount'] ?? 0,
          'availableBalance': profileData['balance'] ?? 0,
        };
        _isLoadingStats = false;
      });
      
      print('✅ Loaded real affiliate stats successfully');
      print('📊 Final stats: ${_affiliateStats}');
    } catch (e) {
      print('❌ Error loading affiliate stats: $e');
      setState(() {
        // Fallback to empty data instead of mock data
        _affiliateStats = {
          'totalEarnings': 0,
          'monthlyEarnings': 0,
          'totalClicks': 0,
          'conversions': 0,
          'conversionRate': 0.0,
          'pendingCommission': 0,
          'availableBalance': 0,
        };
        _isLoadingStats = false;
      });
    }
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            blurRadius: 4.0,
            color: Color(0x1A000000),
            offset: Offset(0.0, 2.0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20.0,
                ),
              ),
              Spacer(),
            ],
          ),
          SizedBox(height: 12.0),
          Text(
            value,
            style: FlutterFlowTheme.of(context).headlineSmall.override(
              fontFamily: 'SF Pro Text',
              fontSize: 24.0,
              letterSpacing: 0.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.0),
          Text(
            title,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'SF Pro Text',
              color: FlutterFlowTheme.of(context).secondaryText,
              fontSize: 14.0,
              letterSpacing: 0.0,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 4.0),
            Text(
              subtitle,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                fontFamily: 'SF Pro Text',
                color: FlutterFlowTheme.of(context).primary,
                fontSize: 12.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
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
            children: [
              // AppBar
              wrapWithModel(
                model: _model.appbarModel,
                updateCallback: () => safeSetState(() {}),
                child: AppbarWidget(
                  title: 'Affiliate Dashboard',
                ),
              ),

              // Content
              Expanded(
                child: _isLoadingStats
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            FlutterFlowTheme.of(context).primary,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadAffiliateStats,
                        child: ListView(
                          padding: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 40.0),
                          children: [
                            // Welcome Section
                            Container(
                              width: double.infinity,
                              padding: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 20.0),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    FlutterFlowTheme.of(context).primary,
                                    FlutterFlowTheme.of(context).primary.withOpacity(0.8),
                                  ],
                                  stops: [0.0, 1.0],
                                  begin: AlignmentDirectional(-1.0, -1.0),
                                  end: AlignmentDirectional(1.0, 1.0),
                                ),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Chào mừng đến với\nAffiliate Dashboard! 🚀',
                                    style: FlutterFlowTheme.of(context).headlineMedium.override(
                                      fontFamily: 'SF Pro Text',
                                      color: Colors.white,
                                      fontSize: 20.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    'Kiếm tiền bằng cách chia sẻ sản phẩm yêu thích của bạn',
                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      fontFamily: 'SF Pro Text',
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14.0,
                                      letterSpacing: 0.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 24.0),

                            // Quick Stats Grid
                            GridView.count(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              crossAxisSpacing: 16.0,
                              mainAxisSpacing: 16.0,
                              childAspectRatio: 1.0,
                              children: [
                                _buildStatCard(
                                  title: 'Tổng thu nhập',
                                  value: NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0)
                                      .format(_affiliateStats['totalEarnings'] ?? 0) + '₫',
                                  icon: Icons.account_balance_wallet,
                                  color: FlutterFlowTheme.of(context).primary,
                                ),
                                _buildStatCard(
                                  title: 'Thu nhập tháng này',
                                  value: NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0)
                                      .format(_affiliateStats['monthlyEarnings'] ?? 0) + '₫',
                                  icon: Icons.trending_up,
                                  color: Color(0xFF10B981),
                                ),
                                _buildStatCard(
                                  title: 'Tổng lượt click',
                                  value: (_affiliateStats['totalClicks'] ?? 0).toString(),
                                  icon: Icons.mouse,
                                  color: Color(0xFF3B82F6),
                                ),
                                _buildStatCard(
                                  title: 'Tỷ lệ chuyển đổi',
                                  value: '${((_affiliateStats['conversionRate'] ?? 0.0) * 100).toStringAsFixed(2)}%',
                                  icon: Icons.analytics,
                                  color: Color(0xFF8B5CF6),
                                  subtitle: '${_affiliateStats['conversions'] ?? 0} đơn hàng',
                                ),
                              ],
                            ),

                            SizedBox(height: 20.0),

                            // Quick Actions
                            Text(
                              'Hành động nhanh',
                              style: FlutterFlowTheme.of(context).headlineSmall.override(
                                fontFamily: 'SF Pro Text',
                                fontSize: 18.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 12.0),

                            // Action Buttons Grid
                            GridView.count(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              crossAxisSpacing: 12.0,
                              mainAxisSpacing: 12.0,
                              childAspectRatio: 2.5,
                              children: [
                                FFButtonWidget(
                                  onPressed: () {
                                    context.pushNamed('GenerateLink');
                                  },
                                  text: 'Tạo Link',
                                  icon: Icon(Icons.link, size: 18.0),
                                  options: FFButtonOptions(
                                    width: double.infinity,
                                    height: 48.0,
                                    color: FlutterFlowTheme.of(context).primary,
                                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                      fontFamily: 'SF Pro Text',
                                      color: Colors.white,
                                      fontSize: 14.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                // FFButtonWidget(
                                //   onPressed: () {
                                //     context.pushNamed(EarningsAnalyticsWidget.routeName);
                                //   },
                                //   text: 'Thống kê',
                                //   icon: Icon(Icons.bar_chart, size: 18.0),
                                //   options: FFButtonOptions(
                                //     width: double.infinity,
                                //     height: 48.0,
                                //     color: FlutterFlowTheme.of(context).secondaryBackground,
                                //     textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                //       fontFamily: 'SF Pro Text',
                                //       color: FlutterFlowTheme.of(context).primaryText,
                                //       fontSize: 14.0,
                                //       letterSpacing: 0.0,
                                //       fontWeight: FontWeight.w500,
                                //     ),
                                //     borderSide: BorderSide(
                                //       color: FlutterFlowTheme.of(context).primary,
                                //       width: 1.0,
                                //     ),
                                //     borderRadius: BorderRadius.circular(8.0),
                                //   ),
                                // ),
                                FFButtonWidget(
                                  onPressed: () {
                                    context.pushNamed(WithdrawalWidget.routeName);
                                  },
                                  text: 'Rút tiền',
                                  icon: Icon(Icons.account_balance, size: 18.0),
                                  options: FFButtonOptions(
                                    width: double.infinity,
                                    height: 48.0,
                                    color: Color(0xFF10B981),
                                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                      fontFamily: 'SF Pro Text',
                                      color: Colors.white,
                                      fontSize: 14.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                FFButtonWidget(
                                  onPressed: () {
                                    context.pushNamed('ManageLinks');
                                  },
                                  text: 'Quản lý Link',
                                  icon: Icon(Icons.manage_search, size: 18.0),
                                  options: FFButtonOptions(
                                    width: double.infinity,
                                    height: 48.0,
                                    color: FlutterFlowTheme.of(context).secondaryBackground,
                                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                      fontFamily: 'SF Pro Text',
                                      color: FlutterFlowTheme.of(context).primaryText,
                                      fontSize: 14.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).secondaryText,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 16.0),

                            // Balance Card
                            Container(
                              width: double.infinity,
                              padding: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 20.0),
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).secondaryBackground,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.2),
                                  width: 1.0,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.account_balance_wallet,
                                        color: FlutterFlowTheme.of(context).primary,
                                        size: 24.0,
                                      ),
                                      SizedBox(width: 8.0),
                                      Text(
                                        'Số dư khả dụng',
                                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                                          fontFamily: 'SF Pro Text',
                                          fontSize: 16.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0)
                                        .format(_affiliateStats['availableBalance'] ?? 0) + '₫',
                                    style: FlutterFlowTheme.of(context).headlineLarge.override(
                                      fontFamily: 'SF Pro Text',
                                      color: FlutterFlowTheme.of(context).primary,
                                      fontSize: 28.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    'Hoa hồng chờ duyệt: ${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(_affiliateStats['pendingCommission'] ?? 0)}₫',
                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                      fontFamily: 'SF Pro Text',
                                      color: FlutterFlowTheme.of(context).secondaryText,
                                      fontSize: 12.0,
                                      letterSpacing: 0.0,
                                    ),
                                  ),
                                ],
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