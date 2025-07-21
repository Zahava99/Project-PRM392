import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'analytics_reports_page_model.dart';
export 'analytics_reports_page_model.dart';

class AnalyticsReportsPageWidget extends StatefulWidget {
  const AnalyticsReportsPageWidget({super.key});

  static String routeName = 'AnalyticsReportsPage';
  static String routePath = 'analyticsReportsPage';

  @override
  State<AnalyticsReportsPageWidget> createState() => _AnalyticsReportsPageWidgetState();
}

class _AnalyticsReportsPageWidgetState extends State<AnalyticsReportsPageWidget>
    with TickerProviderStateMixin {
  late AnalyticsReportsPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = AnalyticsReportsPageModel();

    animationsMap.addAll({
      'containerOnPageLoadAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
      'containerOnPageLoadAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 300.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            blurRadius: 8.0,
            color: Color(0x1A000000),
            offset: Offset(0.0, 2.0),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44.0,
            height: 44.0,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22.0,
            ),
          ),
          SizedBox(height: 12.0),
          Text(
            value,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'SF Pro Text',
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
              color: FlutterFlowTheme.of(context).primaryText,
            ),
          ),
          SizedBox(height: 4.0),
          Text(
            title,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'SF Pro Text',
              fontSize: 14.0,
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 4.0),
            Text(
              subtitle,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'SF Pro Text',
                fontSize: 12.0,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
          ],
        ],
      ),
    ).animateOnPageLoad(animationsMap['containerOnPageLoadAnimation1']!);
  }

  Widget _buildSimpleBarChart(Map<String, int> data, List<Color> colors) {
    if (data.isEmpty) {
          return Container(
      height: 140.0,
      child: Center(
        child: Text(
          'No data available',
          style: FlutterFlowTheme.of(context).bodyMedium.override(
            fontFamily: 'SF Pro Text',
            color: FlutterFlowTheme.of(context).secondaryText,
          ),
        ),
      ),
    );
    }

    final maxValue = data.values.reduce((a, b) => a > b ? a : b).toDouble();
    final entries = data.entries.toList();

    return Container(
      height: 140.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: entries.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final color = colors[index % colors.length];
          final height = maxValue > 0 ? (item.value / maxValue) * 100.0 : 0.0;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    item.value.toString(),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'SF Pro Text',
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Container(
                    width: double.infinity,
                    height: height,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    item.key,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'SF Pro Text',
                      fontSize: 11.0,
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentActivityItem(Map<String, dynamic> activity) {
    return Container(
      padding: EdgeInsets.all(12.0),
      margin: EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).accent4.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: _model.getActivityColor(activity['type']).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(
              _model.getActivityIcon(activity['type']),
              color: _model.getActivityColor(activity['type']),
              size: 20.0,
            ),
          ),
          SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['message'] ?? '',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'SF Pro Text',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.0),
                Text(
                  _model.getFormattedTime(activity['time'] ?? ''),
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'SF Pro Text',
                    fontSize: 12.0,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    // Format number with comma separators
    String numStr = amount.toStringAsFixed(0);
    if (numStr.length <= 3) return numStr;
    
    String result = '';
    int count = 0;
    for (int i = numStr.length - 1; i >= 0; i--) {
      if (count == 3) {
        result = ',' + result;
        count = 0;
      }
      result = numStr[i] + result;
      count++;
    }
    return result;
  }

  String _formatNumber(int number) {
    // Format integer with comma separators
    String numStr = number.toString();
    if (numStr.length <= 3) return numStr;
    
    String result = '';
    int count = 0;
    for (int i = numStr.length - 1; i >= 0; i--) {
      if (count == 3) {
        result = ',' + result;
        count = 0;
      }
      result = numStr[i] + result;
      count++;
    }
    return result;
  }

  Widget _buildTopSellingProductsChart() {
    if (_model.topSellingProducts.isEmpty) {
      return Container(
        height: 200.0,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.trending_up,
                size: 48.0,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
              SizedBox(height: 16.0),
              Text(
                'No sales data available',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'SF Pro Text',
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 320.0,
      child: ListView.builder(
        itemCount: _model.topSellingProducts.length,
        itemBuilder: (context, index) {
          final product = _model.topSellingProducts[index];
          final productName = product['name']?.toString() ?? 'Unknown Product';
          final stockQuantity = product['stockQuantity'] ?? 0;
          final price = product['price'] ?? 0.0;
          final description = product['description']?.toString() ?? '';
          
          // Create a ranking indicator
          final rank = index + 1;
          Color rankColor = Colors.amber;
          if (rank == 1) rankColor = Colors.amber;
          else if (rank == 2) rankColor = Colors.grey[400]!;
          else if (rank == 3) rankColor = Colors.orange[300]!;
          else rankColor = Colors.blue[300]!;
          
          return Container(
            margin: EdgeInsets.only(bottom: 12.0),
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primaryBackground,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: FlutterFlowTheme.of(context).alternate,
                width: 1.0,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rank indicator
                Container(
                  width: 32.0,
                  height: 32.0,
                  decoration: BoxDecoration(
                    color: rankColor,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Center(
                    child: Text(
                      '$rank',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'SF Pro Text',
                        color: Colors.white,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.0),
                
                // Product info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'SF Pro Text',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.0),
                      if (description.isNotEmpty)
                        Text(
                          description,
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'SF Pro Text',
                            fontSize: 13.0,
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Stock: ${_formatNumber(stockQuantity)}',
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'SF Pro Text',
                              fontSize: 13.0,
                              color: stockQuantity > 0 ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '₫${_formatCurrency(price)}',
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'SF Pro Text',
                              fontSize: 15.0,
                              color: FlutterFlowTheme.of(context).primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Header
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
                      'Analytics & Reports',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'SF pro display',
                        fontSize: 24.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                        lineHeight: 1.5,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 20.0, 0.0),
                      child: InkWell(
                        onTap: () async {
                          await _model.loadAnalytics(refresh: true);
                        },
                        child: Icon(
                          Icons.refresh,
                          color: FlutterFlowTheme.of(context).primaryText,
                          size: 24.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: ListenableBuilder(
                  listenable: _model,
                  builder: (context, child) {
                    if (_model.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64.0,
                              color: Colors.red,
                            ),
                            SizedBox(height: 16.0),
                            Text(
                              'Failed to load analytics',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'SF Pro Text',
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 16.0),
                            ElevatedButton(
                              onPressed: () => _model.loadAnalytics(refresh: true),
                              child: Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    if (_model.isLoading) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16.0),
                            Text(
                              'Loading analytics...',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'SF Pro Text',
                                color: FlutterFlowTheme.of(context).secondaryText,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return SingleChildScrollView(
                      controller: _scrollController,
                      padding: EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Summary Cards Grid
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                            childAspectRatio: 1.0,
                            children: [
                              _buildSummaryCard(
                                title: 'Total Users',
                                value: '${_model.totalUsers}',
                                icon: Icons.people,
                                color: Colors.blue,
                                subtitle: '${_model.activeUsers} active',
                              ),
                              _buildSummaryCard(
                                title: 'Total Products',
                                value: '${_model.totalProducts}',
                                icon: Icons.inventory_2,
                                color: Colors.green,
                                subtitle: '${_model.totalCategories} categories',
                              ),
                              _buildSummaryCard(
                                title: 'Categories',
                                value: '${_model.totalCategories}',
                                icon: Icons.category,
                                color: Colors.orange,
                                subtitle: 'Product categories',
                              ),
                              _buildSummaryCard(
                                title: 'Brands',
                                value: '${_model.totalBrands}',
                                icon: Icons.store,
                                color: Colors.purple,
                                subtitle: 'Available brands',
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 20.0),
                          
                          // User Status Chart
                          Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).secondaryBackground,
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 8.0,
                                  color: Color(0x1A000000),
                                  offset: Offset(0.0, 2.0),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'User Status Distribution',
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'SF Pro Text',
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 16.0),
                                _buildSimpleBarChart(
                                  _model.userStatusDistribution,
                                  [Colors.green, Colors.orange, Colors.red],
                                ),
                              ],
                            ),
                          ).animateOnPageLoad(animationsMap['containerOnPageLoadAnimation2']!),
                          
                          SizedBox(height: 14.0),
                          
                          // User Role Chart
                          Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).secondaryBackground,
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 8.0,
                                  color: Color(0x1A000000),
                                  offset: Offset(0.0, 2.0),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'User Role Distribution',
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'SF Pro Text',
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 16.0),
                                _buildSimpleBarChart(
                                  _model.userRoleDistribution,
                                  [Colors.blue, Colors.purple, Colors.teal],
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: 14.0),
                          
                          // Product Categories Chart
                          Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).secondaryBackground,
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 8.0,
                                  color: Color(0x1A000000),
                                  offset: Offset(0.0, 2.0),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Top Product Categories',
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'SF Pro Text',
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 16.0),
                                _buildSimpleBarChart(
                                  Map.fromEntries(_model.getTopCategories()),
                                  [Colors.indigo, Colors.cyan, Colors.amber, Colors.pink, Colors.lime],
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: 20.0),
                          
                          // Top Selling Products Chart
                          Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).secondaryBackground,
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 8.0,
                                  color: Color(0x1A000000),
                                  offset: Offset(0.0, 2.0),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Top Selling Products',
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'SF Pro Text',
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 16.0),
                                _buildTopSellingProductsChart(),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: 20.0),
                          
                          // Recent Activity Section
                          Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).secondaryBackground,
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 8.0,
                                  color: Color(0x1A000000),
                                  offset: Offset(0.0, 2.0),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Recent Activity',
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'SF Pro Text',
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 16.0),
                                if (_model.recentActivity.isEmpty)
                                  Container(
                                    height: 100.0,
                                    child: Center(
                                      child: Text(
                                        'No recent activity',
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                          fontFamily: 'SF Pro Text',
                                          color: FlutterFlowTheme.of(context).secondaryText,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  Column(
                                    children: _model.recentActivity
                                        .map((activity) => _buildRecentActivityItem(activity))
                                        .toList(),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 