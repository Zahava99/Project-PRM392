import '/all_component/appbar/appbar_widget.dart';
import '/backend/api_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:math';
import 'earnings_analytics_model.dart';
export 'earnings_analytics_model.dart';

class EarningsAnalyticsWidget extends StatefulWidget {
  const EarningsAnalyticsWidget({super.key});

  static String routeName = 'EarningsAnalytics';
  static String routePath = 'earningsAnalytics';

  @override
  State<EarningsAnalyticsWidget> createState() => _EarningsAnalyticsWidgetState();
}

class _EarningsAnalyticsWidgetState extends State<EarningsAnalyticsWidget>
    with TickerProviderStateMixin {
  late EarningsAnalyticsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  Map<String, dynamic> _earningsData = {};
  Map<String, dynamic> _performanceData = {};
  List<Map<String, dynamic>> _commissionHistory = [];
  bool _isLoadingEarnings = false;
  bool _isLoadingPerformance = false;
  bool _isLoadingCommissions = false;
  String _selectedPeriod = 'month';
  
  // Track data source for UI indication
  bool _isEarningsFromAPI = false;
  bool _isPerformanceFromAPI = false;
  bool _isCommissionsFromAPI = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EarningsAnalyticsModel());
    _tabController = TabController(length: 3, vsync: this);
    
    _initializeAffiliateData();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  // Initialize affiliate data with registration check
  Future<void> _initializeAffiliateData() async {
    try {
      final token = FFAppState().token;
      if (token.isEmpty) {
        print('❌ User not authenticated');
        return;
      }

      print('🔍 Checking affiliate registration status...');
      
      // Check if user is already registered as affiliate
      final statusResponse = await ApiService.checkAffiliateStatus(token: token);
      print('📥 Affiliate Status Response: ${statusResponse.statusCode} - ${statusResponse.body}');
      
      if (statusResponse.statusCode == 404) {
        // User is not registered as affiliate, register them
        print('📝 User not registered as affiliate, registering...');
        final registerResponse = await ApiService.registerAffiliate(token: token);
        print('📥 Affiliate Registration Response: ${registerResponse.statusCode} - ${registerResponse.body}');
        
        if (registerResponse.statusCode == 200 || registerResponse.statusCode == 201) {
          print('✅ Successfully registered user as affiliate');
        } else {
          print('⚠️ Failed to register affiliate: ${registerResponse.body}');
        }
      } else if (statusResponse.statusCode == 200) {
        print('✅ User is already registered as affiliate');
      }
      
      // Load all data after ensuring affiliate registration
      _loadAllData();
      
    } catch (e) {
      print('❌ Error initializing affiliate data: $e');
      // Still try to load data even if registration check fails
      _loadAllData();
    }
  }

  @override
  void dispose() {
    _model.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // Load all analytics data
  Future<void> _loadAllData() async {
    await Future.wait([
      _loadEarningsData(),
      _loadPerformanceData(),
      _loadCommissionHistory(),
    ]);
    
    // Sync earnings data with performance data after both are loaded
    _syncEarningsWithPerformance();
  }

  // Sync earnings data with performance data for more accurate display
  void _syncEarningsWithPerformance() {
    if (_performanceData.isNotEmpty && _earningsData.isNotEmpty) {
      final weeklyEarnings = _performanceData['weeklyEarnings'] ?? 0.0;
      final performanceClicks = _performanceData['totalClicks'] ?? 0;
      final performanceConversions = _performanceData['conversions'] ?? 0;
      
      // Update earnings data with performance insights
      if (weeklyEarnings > 0 && _earningsData['totalEarnings'] == 0) {
        setState(() {
          _earningsData = {
            ..._earningsData,
            'totalEarnings': weeklyEarnings,
            'currentPeriodEarnings': weeklyEarnings,
            'previousPeriodEarnings': weeklyEarnings * 0.8, // Estimate previous period
            'growthRate': 20.0, // Estimate growth rate
                         'averageDailyEarnings': weeklyEarnings / 7, // Weekly to daily
             'totalClicks': performanceClicks,
             'conversions': performanceConversions,
             'chartData': _generateChartDataFromWeeklyEarnings(weeklyEarnings),
          };
        });
        print('🔄 Synced earnings data with performance data');
        print('💰 Updated totalEarnings: ${weeklyEarnings}₫');
      }
    }
  }

  // Load earnings analytics
  Future<void> _loadEarningsData() async {
    setState(() {
      _isLoadingEarnings = true;
    });

    try {
      final token = FFAppState().token;
      if (token.isEmpty) {
        throw Exception('User not authenticated');
      }

      print('📊 Loading earnings analytics for period: $_selectedPeriod');
      final response = await ApiService.getAffiliateEarnings(
        token: token,
        period: _selectedPeriod,
      );

      print('📥 Earnings API Response Status: ${response.statusCode}');
      print('📥 Earnings API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Check if API returns successful response structure
        // Handle different response formats: with/without success wrapper
        bool isSuccessful = false;
        Map<String, dynamic> apiData = {};
        
        if (data['isSuccess'] == true || data['success'] == true) {
          // Response with success wrapper
          isSuccessful = true;
          apiData = data['data'] ?? data['result'] ?? {};
        } else if (data.containsKey('totalEarnings') || data.containsKey('totalClicks')) {
          // Direct response without wrapper (earnings API format)
          isSuccessful = true;
          apiData = data;
        }
        
        if (isSuccessful) {
          final processedData = _processEarningsData(apiData);
          setState(() {
            _earningsData = processedData;
            _isLoadingEarnings = false;
            _isEarningsFromAPI = true;
          });
          print('✅ Loaded real earnings data successfully');
          print('📊 Processed earnings data: ${processedData.toString()}');
        } else {
          print('⚠️ API returned unsuccessful response: ${data['message'] ?? 'Unknown error'}');
          _loadMockEarningsData();
        }
      } else {
        print('⚠️ Earnings API failed with status ${response.statusCode}, using mock data');
        _loadMockEarningsData();
      }
    } catch (e) {
      print('❌ Error loading earnings: $e');
      _loadMockEarningsData();
    }
  }

  // Process earnings data from API to match expected format
  Map<String, dynamic> _processEarningsData(Map<String, dynamic> apiData) {
    final totalEarnings = apiData['totalEarnings'] ?? apiData['total'] ?? 0;
    final totalClicks = apiData['totalClicks'] ?? apiData['clicks'] ?? 0;
    
    // Calculate derived values when not provided by API
    final currentPeriodEarnings = apiData['currentPeriodEarnings'] ?? apiData['currentPeriod'] ?? totalEarnings;
    final previousPeriodEarnings = apiData['previousPeriodEarnings'] ?? apiData['previousPeriod'] ?? (totalEarnings * 0.8);
    final growthRate = previousPeriodEarnings > 0 
        ? ((currentPeriodEarnings - previousPeriodEarnings) / previousPeriodEarnings * 100)
        : 0.0;
    
    // Calculate average daily earnings based on period
    final daysInPeriod = _getDaysInCurrentPeriod();
    final averageDailyEarnings = daysInPeriod > 0 ? (currentPeriodEarnings / daysInPeriod) : 0;
    
    return {
      'totalEarnings': totalEarnings,
      'currentPeriodEarnings': currentPeriodEarnings,
      'previousPeriodEarnings': previousPeriodEarnings,
      'growthRate': growthRate,
      'averageDailyEarnings': averageDailyEarnings,
      'totalClicks': totalClicks,
      'chartData': _processChartData(apiData['chartData'] ?? apiData['chart'] ?? []),
    };
  }

  // Get number of days in current selected period
  int _getDaysInCurrentPeriod() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'day':
        return 1;
      case 'week':
        return 7;
      case 'year':
        return DateTime(now.year, 12, 31).difference(DateTime(now.year, 1, 1)).inDays + 1;
      case 'month':
      default:
        return DateTime(now.year, now.month + 1, 0).day; // Days in current month
    }
  }

  // Generate chart data from weekly earnings for better visualization
  List<Map<String, dynamic>> _generateChartDataFromWeeklyEarnings(double weeklyEarnings) {
    if (weeklyEarnings <= 0) return [];
    
    // Generate realistic daily distribution for the week
    final dailyAverage = weeklyEarnings / 7;
    return [
      {'period': 'T1', 'earnings': (dailyAverage * 0.8).round()},
      {'period': 'T2', 'earnings': (dailyAverage * 1.2).round()},
      {'period': 'T3', 'earnings': (dailyAverage * 0.9).round()},
      {'period': 'T4', 'earnings': (dailyAverage * 1.5).round()},
      {'period': 'T5', 'earnings': (dailyAverage * 1.1).round()},
      {'period': 'T6', 'earnings': (dailyAverage * 1.3).round()},
      {'period': 'T7', 'earnings': (dailyAverage * 1.2).round()},
    ];
  }

  // Process chart data from API
  List<Map<String, dynamic>> _processChartData(dynamic chartData) {
    if (chartData is List) {
      return chartData.map((item) => {
        'period': item['period'] ?? item['label'] ?? '',
        'earnings': item['earnings'] ?? item['value'] ?? item['amount'] ?? 0,
      }).toList().cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Load performance metrics
  Future<void> _loadPerformanceData() async {
    setState(() {
      _isLoadingPerformance = true;
    });

    try {
      final token = FFAppState().token;
      if (token.isEmpty) {
        throw Exception('User not authenticated');
      }

      print('📈 Loading performance metrics for period: $_selectedPeriod');
      final response = await ApiService.getAffiliatePerformance(
        token: token,
        period: _selectedPeriod,
      );

      print('📥 Performance API Response Status: ${response.statusCode}');
      print('📥 Performance API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Check if API returns successful response structure
        if (data['isSuccess'] == true || data['success'] == true) {
          final apiData = data['data'] ?? data['result'] ?? {};
          final processedData = _processPerformanceData(apiData);
          setState(() {
            _performanceData = processedData;
            _isLoadingPerformance = false;
            _isPerformanceFromAPI = true;
          });
          print('✅ Loaded real performance data successfully');
          print('📈 Processed performance data: ${processedData.toString()}');
        } else {
          print('⚠️ Performance API returned unsuccessful response: ${data['message'] ?? 'Unknown error'}');
          _loadMockPerformanceData();
        }
      } else {
        print('⚠️ Performance API failed with status ${response.statusCode}, using mock data');
        _loadMockPerformanceData();
      }
    } catch (e) {
      print('❌ Error loading performance: $e');
      _loadMockPerformanceData();
    }
  }

  // Process performance data from API to match expected format
  Map<String, dynamic> _processPerformanceData(Map<String, dynamic> apiData) {
    // Handle the actual API response format
    final totalClicks = apiData['count'] ?? apiData['totalClicks'] ?? apiData['clicks'] ?? 0;
    final conversions = apiData['conversionCount'] ?? apiData['conversions'] ?? apiData['orders'] ?? 0;
    final rawConversionRate = apiData['conversionRate'] ?? 
        (totalClicks > 0 ? (conversions / totalClicks) : 0.0);
    // Convert to percentage and round to 2 decimal places
    final conversionRate = double.parse((rawConversionRate * 100).toStringAsFixed(2));
    final weeklyEarnings = apiData['weeklyEarnings'] ?? 0.0;
    
    return {
      'totalClicks': totalClicks,
      'conversions': conversions,
      'conversionRate': conversionRate,
      'weeklyEarnings': weeklyEarnings,
      'topProducts': _processTopProducts(apiData['topProducts'] ?? apiData['products'] ?? []),
      'dailyStats': _processDailyStats(apiData['dailyStats'] ?? apiData['daily'] ?? []),
    };
  }

  // Process top products data from API
  List<Map<String, dynamic>> _processTopProducts(dynamic topProducts) {
    if (topProducts is List) {
      return topProducts.map((product) => {
        'name': product['name'] ?? product['productName'] ?? 'Unknown Product',
        'clicks': product['clicks'] ?? 0,
        'conversions': product['conversions'] ?? product['orders'] ?? 0,
        'earnings': product['earnings'] ?? product['commission'] ?? 0,
      }).toList().cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Process daily stats data from API
  List<Map<String, dynamic>> _processDailyStats(dynamic dailyStats) {
    if (dailyStats is List) {
      return dailyStats.map((stat) => {
        'date': stat['date'] ?? DateTime.now().toIso8601String(),
        'clicks': stat['clicks'] ?? 0,
        'conversions': stat['conversions'] ?? stat['orders'] ?? 0,
      }).toList().cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Load commission history
  Future<void> _loadCommissionHistory() async {
    setState(() {
      _isLoadingCommissions = true;
    });

    try {
      final token = FFAppState().token;
      if (token.isEmpty) {
        throw Exception('User not authenticated');
      }

      print('💰 Loading commission history');
      
      // Try to load from commissions endpoint first
      final commissionResponse = await ApiService.getAffiliateCommissions(
        token: token,
        page: 1,
        pageSize: 50,
      );

      print('📥 Commission API Response Status: ${commissionResponse.statusCode}');
      print('📥 Commission API Response Body: ${commissionResponse.body}');

      if (commissionResponse.statusCode == 200) {
        final data = jsonDecode(commissionResponse.body);
        
        if (data['isSuccess'] == true || data['success'] == true) {
          final apiData = data['data'] ?? data['result'] ?? [];
          setState(() {
            _commissionHistory = _processCommissionData(apiData);
            _isLoadingCommissions = false;
            _isCommissionsFromAPI = true;
          });
          print('✅ Loaded ${_commissionHistory.length} commission records from API');
          return;
        }
      }

      // If commission API fails, try withdrawals endpoint as backup
      print('💳 Trying withdrawals endpoint as fallback');
      final withdrawalResponse = await ApiService.getAffiliateWithdrawals(
        token: token,
        page: 1,
        pageSize: 50,
      );

      print('📥 Withdrawal API Response Status: ${withdrawalResponse.statusCode}');
      print('📥 Withdrawal API Response Body: ${withdrawalResponse.body}');

      if (withdrawalResponse.statusCode == 200) {
        final data = jsonDecode(withdrawalResponse.body);
        
        if (data['isSuccess'] == true || data['success'] == true) {
          final apiData = data['data'] ?? data['result'] ?? [];
          setState(() {
            _commissionHistory = _processWithdrawalData(apiData);
            _isLoadingCommissions = false;
            _isCommissionsFromAPI = true;
          });
          print('✅ Loaded ${_commissionHistory.length} withdrawal records from API');
          return;
        }
      }

      // If both APIs fail, use mock data
      print('⚠️ Both Commission and Withdrawal APIs failed, using mock data');
      _loadMockCommissionHistory();
      
    } catch (e) {
      print('❌ Error loading commission history: $e');
      _loadMockCommissionHistory();
    }
  }

  // Process commission data from API
  List<Map<String, dynamic>> _processCommissionData(dynamic apiData) {
    if (apiData is List) {
      return apiData.map((commission) => {
        'id': commission['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'productName': commission['productName'] ?? commission['product']?['name'] ?? 'Unknown Product',
        'orderValue': commission['orderValue'] ?? commission['orderAmount'] ?? 0,
        'commissionRate': commission['commissionRate'] ?? commission['rate'] ?? 0,
        'commissionAmount': commission['commissionAmount'] ?? commission['amount'] ?? 0,
        'date': commission['date'] ?? commission['createdAt'] ?? DateTime.now().toIso8601String(),
        'status': commission['status'] ?? 'pending',
      }).toList().cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Process withdrawal data from API
  List<Map<String, dynamic>> _processWithdrawalData(dynamic apiData) {
    if (apiData is List) {
      return apiData.map((withdrawal) => {
        'id': withdrawal['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'productName': 'Rút tiền hoa hồng',
        'orderValue': withdrawal['amount'] ?? 0,
        'commissionRate': 100,
        'commissionAmount': withdrawal['amount'] ?? 0,
        'date': withdrawal['requestDate'] ?? withdrawal['createdAt'] ?? DateTime.now().toIso8601String(),
        'status': withdrawal['status'] ?? 'pending',
      }).toList().cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Mock data fallbacks
  void _loadMockEarningsData() {
    setState(() {
      _earningsData = {
        'totalEarnings': 2450000,
        'currentPeriodEarnings': 450000,
        'previousPeriodEarnings': 380000,
        'growthRate': 18.4,
        'averageDailyEarnings': 15000,
        'chartData': [
          {'period': 'T1', 'earnings': 320000},
          {'period': 'T2', 'earnings': 450000},
          {'period': 'T3', 'earnings': 280000},
          {'period': 'T4', 'earnings': 520000},
          {'period': 'T5', 'earnings': 380000},
          {'period': 'T6', 'earnings': 650000},
          {'period': 'T7', 'earnings': 450000},
        ],
      };
      _isLoadingEarnings = false;
      _isEarningsFromAPI = false;
    });
  }

  void _loadMockPerformanceData() {
    setState(() {
      _performanceData = {
        'totalClicks': 1245,
        'conversions': 89,
        'conversionRate': 7.1,
        'topProducts': [
          {'name': 'Serum Vitamin C', 'clicks': 245, 'conversions': 18, 'earnings': 180000},
          {'name': 'Moisturizer Pro', 'clicks': 189, 'conversions': 12, 'earnings': 120000},
          {'name': 'Cleanser Active', 'clicks': 156, 'conversions': 9, 'earnings': 90000},
        ],
        'dailyStats': [
          {'date': '2024-01-01', 'clicks': 45, 'conversions': 3},
          {'date': '2024-01-02', 'clicks': 38, 'conversions': 2},
          {'date': '2024-01-03', 'clicks': 52, 'conversions': 4},
          {'date': '2024-01-04', 'clicks': 41, 'conversions': 3},
          {'date': '2024-01-05', 'clicks': 49, 'conversions': 5},
          {'date': '2024-01-06', 'clicks': 56, 'conversions': 4},
          {'date': '2024-01-07', 'clicks': 43, 'conversions': 3},
        ],
      };
      _isLoadingPerformance = false;
      _isPerformanceFromAPI = false;
    });
  }

  void _loadMockCommissionHistory() {
    setState(() {
      _commissionHistory = [
        {
          'id': '1',
          'productName': 'Serum Vitamin C Premium',
          'orderValue': 500000,
          'commissionRate': 10,
          'commissionAmount': 50000,
          'date': '2024-01-15T10:30:00Z',
          'status': 'paid',
        },
        {
          'id': '2',
          'productName': 'Moisturizer Daily Glow',
          'orderValue': 350000,
          'commissionRate': 8,
          'commissionAmount': 28000,
          'date': '2024-01-14T15:20:00Z',
          'status': 'pending',
        },
        {
          'id': '3',
          'productName': 'Cleanser Gentle Care',
          'orderValue': 250000,
          'commissionRate': 12,
          'commissionAmount': 30000,
          'date': '2024-01-13T09:45:00Z',
          'status': 'paid',
        },
        {
          'id': '4',
          'productName': 'Foundation Perfect Match',
          'orderValue': 800000,
          'commissionRate': 15,
          'commissionAmount': 120000,
          'date': '2024-01-12T14:10:00Z',
          'status': 'paid',
        },
        {
          'id': '5',
          'productName': 'Lipstick Matte Pro',
          'orderValue': 300000,
          'commissionRate': 10,
          'commissionAmount': 30000,
          'date': '2024-01-11T11:30:00Z',
          'status': 'pending',
        },
      ];
      _isLoadingCommissions = false;
      _isCommissionsFromAPI = false;
    });
  }

  // Change period filter
  void _changePeriod(String period) {
    if (_selectedPeriod != period) {
      setState(() {
        _selectedPeriod = period;
        // Reset data source flags when changing period
        _isEarningsFromAPI = false;
        _isPerformanceFromAPI = false;
        _isCommissionsFromAPI = false;
      });
      _loadAllData();
    }
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
                  title: 'Thống kê Thu nhập',
                ),
              ),

              // Period Filter
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 16.0),
                child: Row(
                  children: [
                    Text(
                      'Thời gian:',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'SF Pro Text',
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 12.0),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildPeriodChip('day', 'Ngày'),
                            SizedBox(width: 8.0),
                            _buildPeriodChip('week', 'Tuần'),
                            SizedBox(width: 8.0),
                            _buildPeriodChip('month', 'Tháng'),
                            SizedBox(width: 8.0),
                            _buildPeriodChip('year', 'Năm'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Tab Bar
              Container(
                width: double.infinity,
                child: TabBar(
                  controller: _tabController,
                  labelColor: FlutterFlowTheme.of(context).primary,
                  unselectedLabelColor: FlutterFlowTheme.of(context).secondaryText,
                  labelStyle: FlutterFlowTheme.of(context).titleMedium.override(
                    fontFamily: 'SF Pro Text',
                    fontSize: 14.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w500,
                  ),
                  unselectedLabelStyle: FlutterFlowTheme.of(context).titleMedium.override(
                    fontFamily: 'SF Pro Text',
                    fontSize: 14.0,
                    letterSpacing: 0.0,
                  ),
                  indicatorColor: FlutterFlowTheme.of(context).primary,
                  indicatorWeight: 2.0,
                  tabs: [
                    Tab(text: 'Thu nhập'),
                    Tab(text: 'Hiệu suất'),
                    Tab(text: 'Hoa hồng'),
                  ],
                ),
              ),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildEarningsTab(),
                    _buildPerformanceTab(),
                    _buildCommissionsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Period filter chip
  Widget _buildPeriodChip(String value, String label) {
    final isSelected = _selectedPeriod == value;
    return InkWell(
      onTap: () => _changePeriod(value),
      child: Container(
        padding: EdgeInsetsDirectional.fromSTEB(12.0, 6.0, 12.0, 6.0),
        decoration: BoxDecoration(
          color: isSelected 
              ? FlutterFlowTheme.of(context).primary 
              : FlutterFlowTheme.of(context).accent1,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: isSelected 
                ? FlutterFlowTheme.of(context).primary 
                : FlutterFlowTheme.of(context).borderColor,
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: FlutterFlowTheme.of(context).bodySmall.override(
            fontFamily: 'SF Pro Text',
            color: isSelected 
                ? Colors.white 
                : FlutterFlowTheme.of(context).primaryText,
            fontSize: 12.0,
            letterSpacing: 0.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Earnings tab content
  Widget _buildEarningsTab() {
    if (_isLoadingEarnings) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            FlutterFlowTheme.of(context).primary,
          ),
        ),
      );
    }

    final totalEarnings = _earningsData['totalEarnings'] ?? 0;
    final currentEarnings = _earningsData['currentPeriodEarnings'] ?? 0;
    final growthRate = _earningsData['growthRate'] ?? 0;
    final chartData = _earningsData['chartData'] as List<dynamic>? ?? [];

    return RefreshIndicator(
      onRefresh: _loadEarningsData,
      child: SingleChildScrollView(
        padding: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Data Source Indicator
            if (!_isEarningsFromAPI)
              Container(
                margin: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                padding: EdgeInsetsDirectional.fromSTEB(12.0, 8.0, 12.0, 8.0),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: FlutterFlowTheme.of(context).warning,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: FlutterFlowTheme.of(context).warning,
                      size: 16.0,
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      'Hiển thị dữ liệu mẫu (chưa kết nối API)',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily: 'SF Pro Text',
                        color: FlutterFlowTheme.of(context).warning,
                        fontSize: 12.0,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ],
                ),
              ),

            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Tổng thu nhập',
                    value: NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0)
                        .format(totalEarnings) + '₫',
                    icon: Icons.account_balance_wallet,
                    color: FlutterFlowTheme.of(context).primary,
                  ),
                ),
                SizedBox(width: 12.0),
                Expanded(
                  child: _buildStatCard(
                    title: 'Thu nhập kỳ này',
                    value: NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0)
                        .format(currentEarnings) + '₫',
                    icon: Icons.trending_up,
                    color: Color(0xFF10B981),
                    subtitle: '${growthRate > 0 ? '+' : ''}${growthRate.toStringAsFixed(1)}%',
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.0),

            // Earnings Chart
            Text(
              'Biểu đồ thu nhập',
              style: FlutterFlowTheme.of(context).headlineSmall.override(
                fontFamily: 'SF Pro Text',
                fontSize: 18.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 16.0),

            Container(
              width: double.infinity,
              height: 200.0,
              padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: FlutterFlowTheme.of(context).borderColor,
                  width: 1.0,
                ),
              ),
              child: chartData.isEmpty
                  ? Center(
                      child: Text(
                        'Chưa có dữ liệu biểu đồ',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'SF Pro Text',
                          color: FlutterFlowTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
                        ),
                      ),
                    )
                  : _buildSimpleBarChart(chartData),
            ),

            SizedBox(height: 24.0),

            // Earnings Breakdown
            Text(
              'Chi tiết thu nhập',
              style: FlutterFlowTheme.of(context).headlineSmall.override(
                fontFamily: 'SF Pro Text',
                fontSize: 18.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 16.0),

            _buildBreakdownCard('Thu nhập trung bình/ngày', 
              NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0)
                  .format(_earningsData['averageDailyEarnings'] ?? 0) + '₫'),

            _buildBreakdownCard('Kỳ trước', 
              NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0)
                  .format(_earningsData['previousPeriodEarnings'] ?? 0) + '₫'),

            _buildBreakdownCard('Tăng trưởng', 
              '${growthRate > 0 ? '+' : ''}${growthRate.toStringAsFixed(1)}%',
              color: growthRate >= 0 ? Color(0xFF10B981) : FlutterFlowTheme.of(context).error),

            // Show total clicks if available from earnings API
            if (_earningsData['totalClicks'] != null && _earningsData['totalClicks'] > 0)
              _buildBreakdownCard('Tổng lượt click', 
                _earningsData['totalClicks'].toString()),

            // Show conversions if available
            if (_earningsData['conversions'] != null && _earningsData['conversions'] > 0)
              _buildBreakdownCard('Chuyển đổi thành công', 
                _earningsData['conversions'].toString()),
          ],
        ),
      ),
    );
  }

  // Performance tab content  
  Widget _buildPerformanceTab() {
    if (_isLoadingPerformance) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            FlutterFlowTheme.of(context).primary,
          ),
        ),
      );
    }

    final totalClicks = _performanceData['totalClicks'] ?? 0;
    final conversions = _performanceData['conversions'] ?? 0;
    final conversionRate = _performanceData['conversionRate'] ?? 0.0;
    final topProducts = _performanceData['topProducts'] as List<dynamic>? ?? [];

    return RefreshIndicator(
      onRefresh: _loadPerformanceData,
      child: SingleChildScrollView(
        padding: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Data Source Indicator
            if (!_isPerformanceFromAPI)
              Container(
                margin: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                padding: EdgeInsetsDirectional.fromSTEB(12.0, 8.0, 12.0, 8.0),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: FlutterFlowTheme.of(context).warning,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: FlutterFlowTheme.of(context).warning,
                      size: 16.0,
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      'Hiển thị dữ liệu mẫu (chưa kết nối API)',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily: 'SF Pro Text',
                        color: FlutterFlowTheme.of(context).warning,
                        fontSize: 12.0,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ],
                ),
              ),

            // Performance Summary
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Tổng lượt click',
                    value: totalClicks.toString(),
                    icon: Icons.mouse,
                    color: Color(0xFF3B82F6),
                  ),
                ),
                SizedBox(width: 12.0),
                Expanded(
                  child: _buildStatCard(
                    title: 'Chuyển đổi',
                    value: conversions.toString(),
                    icon: Icons.shopping_cart,
                    color: Color(0xFF10B981),
                    subtitle: '${conversionRate.toStringAsFixed(1)}%',
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.0),

            // Top Products
            Text(
              'Sản phẩm hiệu quả nhất',
              style: FlutterFlowTheme.of(context).headlineSmall.override(
                fontFamily: 'SF Pro Text',
                fontSize: 18.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 16.0),

            ...topProducts.map((product) => _buildTopProductCard(
              product['name']?.toString() ?? 'Unknown Product',
              product['clicks'] ?? 0,
              product['conversions'] ?? 0,
              product['earnings'] ?? 0,
            )).toList(),
          ],
        ),
      ),
    );
  }

  // Commissions tab content
  Widget _buildCommissionsTab() {
    if (_isLoadingCommissions) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            FlutterFlowTheme.of(context).primary,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCommissionHistory,
      child: _commissionHistory.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 64.0,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Chưa có lịch sử hoa hồng',
                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                      fontFamily: 'SF Pro Text',
                      color: FlutterFlowTheme.of(context).secondaryText,
                      letterSpacing: 0.0,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Data Source Indicator
                if (!_isCommissionsFromAPI)
                  Container(
                    margin: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 0.0),
                    padding: EdgeInsetsDirectional.fromSTEB(12.0, 8.0, 12.0, 8.0),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: FlutterFlowTheme.of(context).warning,
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: FlutterFlowTheme.of(context).warning,
                          size: 16.0,
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          'Hiển thị dữ liệu mẫu (chưa kết nối API)',
                          style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: 'SF Pro Text',
                            color: FlutterFlowTheme.of(context).warning,
                            fontSize: 12.0,
                            letterSpacing: 0.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Commission List
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 20.0),
                    itemCount: _commissionHistory.length,
                    itemBuilder: (context, index) {
                      final commission = _commissionHistory[index];
                      return _buildCommissionCard(commission);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  // Helper widgets
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
        border: Border.all(
          color: FlutterFlowTheme.of(context).borderColor,
          width: 1.0,
        ),
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
            ],
          ),
          SizedBox(height: 12.0),
          Text(
            title,
            style: FlutterFlowTheme.of(context).bodySmall.override(
              fontFamily: 'SF Pro Text',
              color: FlutterFlowTheme.of(context).secondaryText,
              fontSize: 12.0,
              letterSpacing: 0.0,
            ),
          ),
          SizedBox(height: 4.0),
          Text(
            value,
            style: FlutterFlowTheme.of(context).headlineSmall.override(
              fontFamily: 'SF Pro Text',
              fontSize: 18.0,
              letterSpacing: 0.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 4.0),
            Text(
              subtitle,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                fontFamily: 'SF Pro Text',
                color: FlutterFlowTheme.of(context).secondary,
                fontSize: 11.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBreakdownCard(String title, String value, {Color? color}) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 12.0),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).accent1,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'SF Pro Text',
                letterSpacing: 0.0,
              ),
            ),
            Text(
              value,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'SF Pro Text',
                color: color ?? FlutterFlowTheme.of(context).primaryText,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProductCard(String name, int clicks, int conversions, int earnings) {
    final conversionRate = clicks > 0 ? (conversions / clicks * 100) : 0;
    
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: FlutterFlowTheme.of(context).borderColor,
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'SF Pro Text',
                fontSize: 16.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Clicks',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: 'SF Pro Text',
                          color: FlutterFlowTheme.of(context).secondaryText,
                          fontSize: 12.0,
                          letterSpacing: 0.0,
                        ),
                      ),
                      Text(
                        clicks.toString(),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'SF Pro Text',
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chuyển đổi',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: 'SF Pro Text',
                          color: FlutterFlowTheme.of(context).secondaryText,
                          fontSize: 12.0,
                          letterSpacing: 0.0,
                        ),
                      ),
                      Text(
                        '$conversions (${conversionRate.toStringAsFixed(1)}%)',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'SF Pro Text',
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thu nhập',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: 'SF Pro Text',
                          color: FlutterFlowTheme.of(context).secondaryText,
                          fontSize: 12.0,
                          letterSpacing: 0.0,
                        ),
                      ),
                      Text(
                        NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0)
                            .format(earnings) + '₫',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'SF Pro Text',
                          color: FlutterFlowTheme.of(context).primary,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommissionCard(Map<String, dynamic> commission) {
    final productName = commission['productName']?.toString() ?? 'Unknown Product';
    final orderValue = commission['orderValue'] ?? 0;
    final commissionRate = commission['commissionRate'] ?? 0;
    final commissionAmount = commission['commissionAmount'] ?? 0;
    final dateStr = commission['date']?.toString() ?? '';
    final status = commission['status']?.toString() ?? 'unknown';

    DateTime? date;
    try {
      date = DateTime.parse(dateStr);
    } catch (e) {
      date = DateTime.now();
    }

    Color statusColor;
    String statusText;
    switch (status.toLowerCase()) {
      case 'paid':
        statusColor = Color(0xFF10B981);
        statusText = 'Đã thanh toán';
        break;
      case 'pending':
        statusColor = Color(0xFFF59E0B);
        statusText = 'Đang xử lý';
        break;
      case 'cancelled':
        statusColor = FlutterFlowTheme.of(context).error;
        statusText = 'Đã hủy';
        break;
      default:
        statusColor = FlutterFlowTheme.of(context).secondaryText;
        statusText = 'Không rõ';
    }

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: FlutterFlowTheme.of(context).borderColor,
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    productName,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'SF Pro Text',
                      fontSize: 16.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    statusText,
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: 'SF Pro Text',
                      color: statusColor,
                      fontSize: 11.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Giá trị đơn hàng',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: 'SF Pro Text',
                          color: FlutterFlowTheme.of(context).secondaryText,
                          fontSize: 12.0,
                          letterSpacing: 0.0,
                        ),
                      ),
                      Text(
                        NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0)
                            .format(orderValue) + '₫',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'SF Pro Text',
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hoa hồng',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: 'SF Pro Text',
                          color: FlutterFlowTheme.of(context).secondaryText,
                          fontSize: 12.0,
                          letterSpacing: 0.0,
                        ),
                      ),
                      Text(
                        NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0)
                            .format(commissionAmount) + '₫ ($commissionRate%)',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'SF Pro Text',
                          color: FlutterFlowTheme.of(context).primary,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Text(
              DateFormat('dd/MM/yyyy HH:mm').format(date),
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
    );
  }

  // Simple bar chart widget
  Widget _buildSimpleBarChart(List<dynamic> chartData) {
    if (chartData.isEmpty) return Container();

    // Find max value for scaling
    double maxValue = 0;
    for (var item in chartData) {
      final value = (item['earnings'] ?? 0).toDouble();
      if (value > maxValue) maxValue = value;
    }

    if (maxValue == 0) return Container();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: chartData.map((item) {
        final period = item['period']?.toString() ?? '';
        final earnings = (item['earnings'] ?? 0).toDouble();
        final height = (earnings / maxValue * 120).clamp(4.0, 120.0);

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 20.0,
              height: height,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primary,
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              period,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                fontFamily: 'SF Pro Text',
                fontSize: 10.0,
                letterSpacing: 0.0,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
} 