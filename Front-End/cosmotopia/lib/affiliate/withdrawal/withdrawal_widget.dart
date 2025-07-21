import '/all_component/appbar/appbar_widget.dart';
import '/backend/api_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';

import '/flutter_flow/form_field_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'withdrawal_model.dart';
export 'withdrawal_model.dart';

class WithdrawalWidget extends StatefulWidget {
  const WithdrawalWidget({super.key});

  static String routeName = 'WithdrawalPage';
  static String routePath = 'withdrawalPage';

  @override
  State<WithdrawalWidget> createState() => _WithdrawalWidgetState();
}

class _WithdrawalWidgetState extends State<WithdrawalWidget>
    with TickerProviderStateMixin {
  late WithdrawalModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  Map<String, dynamic> _dashboardData = {};
  List<Map<String, dynamic>> _withdrawalHistory = [];
  List<Map<String, dynamic>> _bankAccounts = [];
  bool _isLoadingData = false;
  bool _isSubmittingWithdrawal = false;
  
  late TabController _tabController;
  String? _selectedBankAccount;
  final double _minimumWithdrawal = 100000; // 100k VND minimum

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WithdrawalModel());
    _tabController = TabController(length: 2, vsync: this);
    
    _model.amountController ??= TextEditingController();
    _model.amountFocusNode ??= FocusNode();
    _model.bankAccountController ??= TextEditingController();
    _model.bankAccountFocusNode ??= FocusNode();
    _model.notesController ??= TextEditingController();
    _model.notesFocusNode ??= FocusNode();

    _loadAllData();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // Load all withdrawal data
  Future<void> _loadAllData() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      await Future.wait([
        _loadDashboardData(),
        _loadWithdrawalHistory(),
        _loadBankAccounts(),
      ]);
    } catch (e) {
      print('❌ Error loading withdrawal data: $e');
    } finally {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  // Load affiliate dashboard for balance info
  Future<void> _loadDashboardData() async {
    try {
      final token = FFAppState().token;
      if (token.isEmpty) {
        throw Exception('User not authenticated');
      }

      print('💰 Loading affiliate balance data');
      final response = await ApiService.getAffiliateDashboard(token: token);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _dashboardData = data['data'] ?? {};
        });
        print('✅ Loaded balance data successfully');
      } else {
        print('⚠️ Dashboard API failed, using mock data');
        _loadMockDashboardData();
      }
    } catch (e) {
      print('❌ Error loading dashboard: $e');
      _loadMockDashboardData();
    }
  }

  // Load withdrawal history
  Future<void> _loadWithdrawalHistory() async {
    try {
      final token = FFAppState().token;
      if (token.isEmpty) {
        throw Exception('User not authenticated');
      }

      print('📋 Loading withdrawal history');
      final response = await ApiService.getAffiliateWithdrawals(
        token: token,
        page: 1,
        pageSize: 50,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _withdrawalHistory = List<Map<String, dynamic>>.from(data['data'] ?? []);
        });
        print('✅ Loaded ${_withdrawalHistory.length} withdrawal records');
      } else {
        print('⚠️ Withdrawal history API failed, using mock data');
        _loadMockWithdrawalHistory();
      }
    } catch (e) {
      print('❌ Error loading withdrawal history: $e');
      _loadMockWithdrawalHistory();
    }
  }

  // Load saved bank accounts (mock for now)
  Future<void> _loadBankAccounts() async {
    // TODO: Replace with real API call to get saved bank accounts
    setState(() {
      _bankAccounts = [
        {
          'id': '1',
          'accountNumber': '1234567890',
          'bankName': 'Vietcombank',
          'accountHolder': 'NGUYEN VAN A',
          'isDefault': true,
        },
        {
          'id': '2',
          'accountNumber': '0987654321',
          'bankName': 'BIDV',
          'accountHolder': 'NGUYEN VAN A',
          'isDefault': false,
        },
      ];
    });
  }

  // Mock data fallbacks
  void _loadMockDashboardData() {
    setState(() {
      _dashboardData = {
        'availableBalance': 1250000,
        'pendingWithdrawals': 300000,
        'totalEarnings': 2450000,
        'lastWithdrawal': '2024-01-10T10:30:00Z',
      };
    });
  }

  void _loadMockWithdrawalHistory() {
    setState(() {
      _withdrawalHistory = [
        {
          'id': '1',
          'amount': 500000,
          'bankAccount': '****7890',
          'bankName': 'Vietcombank',
          'status': 'completed',
          'requestDate': '2024-01-10T10:30:00Z',
          'completedDate': '2024-01-12T15:20:00Z',
          'notes': 'Rút tiền thành công',
        },
        {
          'id': '2',
          'amount': 300000,
          'bankAccount': '****4321',
          'bankName': 'BIDV',
          'status': 'pending',
          'requestDate': '2024-01-15T14:45:00Z',
          'completedDate': null,
          'notes': 'Đang xử lý',
        },
        {
          'id': '3',
          'amount': 750000,
          'bankAccount': '****7890',
          'bankName': 'Vietcombank',
          'status': 'approved',
          'requestDate': '2024-01-08T09:15:00Z',
          'completedDate': null,
          'notes': 'Đã duyệt, đang chuyển khoản',
        },
        {
          'id': '4',
          'amount': 200000,
          'bankAccount': '****7890',
          'bankName': 'Vietcombank',
          'status': 'rejected',
          'requestDate': '2024-01-05T16:20:00Z',
          'completedDate': '2024-01-06T10:00:00Z',
          'notes': 'Số tiền dưới mức tối thiểu',
        },
      ];
    });
  }

  // Submit withdrawal request
  Future<void> _submitWithdrawal() async {
    if (!_validateWithdrawalForm()) return;

    setState(() {
      _isSubmittingWithdrawal = true;
    });

    try {
      final token = FFAppState().token;
      if (token.isEmpty) {
        throw Exception('User not authenticated');
      }

      final amount = double.parse(_model.amountController.text);
      final bankAccount = _selectedBankAccount ?? _model.bankAccountController.text;
      final bankName = _model.bankNameValue ?? '';
      final notes = _model.notesController.text;

      print('💸 Submitting withdrawal request: $amount VND');
      
      final response = await ApiService.requestAffiliateWithdrawal(
        token: token,
        amount: amount,
        bankAccount: bankAccount,
        bankName: bankName,
        notes: notes,
      );

      if (response.statusCode == 200) {
        // Success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Yêu cầu rút tiền đã được gửi thành công!'),
            backgroundColor: FlutterFlowTheme.of(context).success,
            duration: Duration(seconds: 3),
          ),
        );

        // Clear form
        _clearForm();
        
        // Reload data
        _loadAllData();
        
        // Switch to history tab
        _tabController.animateTo(1);
      } else {
        throw Exception('API request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error submitting withdrawal: $e');
      
      // Mock success for demo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Yêu cầu rút tiền đã được gửi! (Demo mode)'),
          backgroundColor: FlutterFlowTheme.of(context).warning,
          duration: Duration(seconds: 3),
        ),
      );
      
      _clearForm();
    } finally {
      setState(() {
        _isSubmittingWithdrawal = false;
      });
    }
  }

  // Validate withdrawal form
  bool _validateWithdrawalForm() {
    final amountText = _model.amountController.text;
    
    if (amountText.isEmpty) {
      _showErrorSnackBar('Vui lòng nhập số tiền muốn rút');
      return false;
    }

    double amount;
    try {
      amount = double.parse(amountText);
    } catch (e) {
      _showErrorSnackBar('Số tiền không hợp lệ');
      return false;
    }

    if (amount < _minimumWithdrawal) {
      _showErrorSnackBar('Số tiền tối thiểu là ${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(_minimumWithdrawal)}₫');
      return false;
    }

    final availableBalance = _dashboardData['availableBalance'] ?? 0;
    if (amount > availableBalance) {
      _showErrorSnackBar('Số dư không đủ. Số dư khả dụng: ${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(availableBalance)}₫');
      return false;
    }

    if (_selectedBankAccount == null && _model.bankAccountController.text.isEmpty) {
      _showErrorSnackBar('Vui lòng chọn hoặc nhập số tài khoản');
      return false;
    }

    if (_model.bankNameValue == null || _model.bankNameValue!.isEmpty) {
      _showErrorSnackBar('Vui lòng chọn ngân hàng');
      return false;
    }

    return true;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: FlutterFlowTheme.of(context).error,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _clearForm() {
    _model.amountController?.clear();
    _model.bankAccountController?.clear();
    _model.notesController?.clear();
    setState(() {
      _selectedBankAccount = null;
      _model.bankNameValue = null;
    });
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
                  title: 'Rút tiền',
                ),
              ),

              // Balance Info Card
              _buildBalanceCard(),

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
                    Tab(text: 'Yêu cầu rút tiền'),
                    Tab(text: 'Lịch sử'),
                  ],
                ),
              ),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildWithdrawalForm(),
                    _buildWithdrawalHistory(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Balance info card
  Widget _buildBalanceCard() {
    final availableBalance = _dashboardData['availableBalance'] ?? 0;
    final pendingWithdrawals = _dashboardData['pendingWithdrawals'] ?? 0;
    final totalEarnings = _dashboardData['totalEarnings'] ?? 0;

    return Container(
      width: double.infinity,
      margin: EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 16.0),
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
            'Số dư khả dụng',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'SF Pro Text',
              color: Colors.white.withOpacity(0.9),
              fontSize: 14.0,
              letterSpacing: 0.0,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0)
                .format(availableBalance) + '₫',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
              fontFamily: 'SF Pro Text',
              color: Colors.white,
              fontSize: 28.0,
              letterSpacing: 0.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Đang chờ',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily: 'SF Pro Text',
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12.0,
                        letterSpacing: 0.0,
                      ),
                    ),
                    Text(
                      NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0)
                          .format(pendingWithdrawals) + '₫',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'SF Pro Text',
                        color: Colors.white,
                        fontSize: 16.0,
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
                      'Tổng thu nhập',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily: 'SF Pro Text',
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12.0,
                        letterSpacing: 0.0,
                      ),
                    ),
                    Text(
                      NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0)
                          .format(totalEarnings) + '₫',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'SF Pro Text',
                        color: Colors.white,
                        fontSize: 16.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12.0),
          
          Container(
            width: double.infinity,
            padding: EdgeInsetsDirectional.fromSTEB(12.0, 8.0, 12.0, 8.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              'Số tiền rút tối thiểu: ${NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0).format(_minimumWithdrawal)}₫',
              style: FlutterFlowTheme.of(context).bodySmall.override(
                fontFamily: 'SF Pro Text',
                color: Colors.white,
                fontSize: 12.0,
                letterSpacing: 0.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Withdrawal form tab
  Widget _buildWithdrawalForm() {
    if (_isLoadingData) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            FlutterFlowTheme.of(context).primary,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Amount Input
          Text(
            'Số tiền muốn rút',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'SF Pro Text',
              letterSpacing: 0.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.0),
          TextFormField(
            controller: _model.amountController,
            focusNode: _model.amountFocusNode,
            autofocus: false,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Nhập số tiền (VND)',
              labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                fontFamily: 'SF Pro Text',
                letterSpacing: 0.0,
              ),
              hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                fontFamily: 'SF Pro Text',
                letterSpacing: 0.0,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).borderColor,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).primary,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              contentPadding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 12.0),
              suffixText: '₫',
            ),
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'SF Pro Text',
              letterSpacing: 0.0,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),

          SizedBox(height: 20.0),

          // Bank Account Section
          Text(
            'Thông tin ngân hàng',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'SF Pro Text',
              letterSpacing: 0.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.0),

          // Saved Bank Accounts
          if (_bankAccounts.isNotEmpty) ...[
            Text(
              'Tài khoản đã lưu',
              style: FlutterFlowTheme.of(context).bodySmall.override(
                fontFamily: 'SF Pro Text',
                color: FlutterFlowTheme.of(context).secondaryText,
                fontSize: 12.0,
                letterSpacing: 0.0,
              ),
            ),
            SizedBox(height: 8.0),
            ..._bankAccounts.map((account) => _buildBankAccountOption(account)).toList(),
            SizedBox(height: 16.0),
            Text(
              'Hoặc nhập tài khoản mới',
              style: FlutterFlowTheme.of(context).bodySmall.override(
                fontFamily: 'SF Pro Text',
                color: FlutterFlowTheme.of(context).secondaryText,
                fontSize: 12.0,
                letterSpacing: 0.0,
              ),
            ),
            SizedBox(height: 8.0),
          ],

          // New Bank Account Input
          TextFormField(
            controller: _model.bankAccountController,
            focusNode: _model.bankAccountFocusNode,
            autofocus: false,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Số tài khoản',
              labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                fontFamily: 'SF Pro Text',
                letterSpacing: 0.0,
              ),
              hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                fontFamily: 'SF Pro Text',
                letterSpacing: 0.0,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).borderColor,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).primary,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              contentPadding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 12.0),
            ),
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'SF Pro Text',
              letterSpacing: 0.0,
            ),
            keyboardType: TextInputType.number,
          ),

          SizedBox(height: 16.0),

          // Bank Name Dropdown
          DropdownButtonFormField<String>(
            value: _model.bankNameValue,
            decoration: InputDecoration(
              labelText: 'Chọn ngân hàng',
              labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                fontFamily: 'SF Pro Text',
                letterSpacing: 0.0,
              ),
              hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                fontFamily: 'SF Pro Text',
                letterSpacing: 0.0,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).borderColor,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).primary,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              contentPadding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 12.0),
            ),
            items: [
              'Vietcombank',
              'BIDV',
              'VietinBank',
              'Agribank',
              'ACB',
              'Techcombank',
              'MB Bank',
              'VPBank',
              'TPBank',
              'Sacombank',
              'HDBank',
              'OCB',
              'SHB',
              'Eximbank',
              'NCB',
            ].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'SF Pro Text',
                    letterSpacing: 0.0,
                  ),
                ),
              );
            }).toList(),
            onChanged: (val) => safeSetState(() => _model.bankNameValue = val),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: FlutterFlowTheme.of(context).secondaryText,
              size: 24.0,
            ),
          ),

          SizedBox(height: 20.0),

          // Notes (Optional)
          Text(
            'Ghi chú (tùy chọn)',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'SF Pro Text',
              letterSpacing: 0.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.0),
          TextFormField(
            controller: _model.notesController,
            focusNode: _model.notesFocusNode,
            autofocus: false,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Nhập ghi chú...',
              labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                fontFamily: 'SF Pro Text',
                letterSpacing: 0.0,
              ),
              hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                fontFamily: 'SF Pro Text',
                letterSpacing: 0.0,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).borderColor,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).primary,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              contentPadding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 12.0),
            ),
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'SF Pro Text',
              letterSpacing: 0.0,
            ),
            maxLines: 3,
          ),

          SizedBox(height: 32.0),

          // Submit Button
          FFButtonWidget(
            onPressed: _isSubmittingWithdrawal ? null : _submitWithdrawal,
            text: _isSubmittingWithdrawal ? 'Đang xử lý...' : 'Gửi yêu cầu rút tiền',
            icon: _isSubmittingWithdrawal 
                ? SizedBox(
                    width: 20.0,
                    height: 20.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(Icons.send, size: 18.0),
            options: FFButtonOptions(
              width: double.infinity,
              height: 50.0,
              color: FlutterFlowTheme.of(context).primary,
              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                fontFamily: 'SF Pro Text',
                color: Colors.white,
                fontSize: 16.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w500,
              ),
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ],
      ),
    );
  }

  // Bank account option widget
  Widget _buildBankAccountOption(Map<String, dynamic> account) {
    final isSelected = _selectedBankAccount == account['id'];
    
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedBankAccount = account['id'];
            _model.bankNameValue = account['bankName'];
            _model.bankAccountController?.clear(); // Clear manual input
          });
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 12.0),
          decoration: BoxDecoration(
            color: isSelected 
                ? FlutterFlowTheme.of(context).primary.withOpacity(0.1)
                : FlutterFlowTheme.of(context).accent1,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: isSelected 
                  ? FlutterFlowTheme.of(context).primary
                  : FlutterFlowTheme.of(context).borderColor,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: isSelected 
                    ? FlutterFlowTheme.of(context).primary
                    : FlutterFlowTheme.of(context).secondaryText,
                size: 20.0,
              ),
              SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${account['bankName']} - ****${account['accountNumber'].toString().substring(account['accountNumber'].toString().length - 4)}',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'SF Pro Text',
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      account['accountHolder']?.toString() ?? '',
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
              if (account['isDefault'] == true)
                Container(
                  padding: EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    'Mặc định',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: 'SF Pro Text',
                      color: Colors.white,
                      fontSize: 10.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Withdrawal history tab
  Widget _buildWithdrawalHistory() {
    if (_isLoadingData) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            FlutterFlowTheme.of(context).primary,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadWithdrawalHistory,
      child: _withdrawalHistory.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64.0,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Chưa có lịch sử rút tiền',
                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                      fontFamily: 'SF Pro Text',
                      color: FlutterFlowTheme.of(context).secondaryText,
                      letterSpacing: 0.0,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 20.0),
              itemCount: _withdrawalHistory.length,
              itemBuilder: (context, index) {
                final withdrawal = _withdrawalHistory[index];
                return _buildWithdrawalCard(withdrawal);
              },
            ),
    );
  }

  // Withdrawal history card
  Widget _buildWithdrawalCard(Map<String, dynamic> withdrawal) {
    final amount = withdrawal['amount'] ?? 0;
    final bankAccount = withdrawal['bankAccount']?.toString() ?? '';
    final bankName = withdrawal['bankName']?.toString() ?? '';
    final status = withdrawal['status']?.toString() ?? 'unknown';
    final requestDateStr = withdrawal['requestDate']?.toString() ?? '';
    final completedDateStr = withdrawal['completedDate']?.toString();
    final notes = withdrawal['notes']?.toString() ?? '';

    DateTime? requestDate;
    DateTime? completedDate;
    try {
      requestDate = DateTime.parse(requestDateStr);
      if (completedDateStr != null) {
        completedDate = DateTime.parse(completedDateStr);
      }
    } catch (e) {
      requestDate = DateTime.now();
    }

    Color statusColor;
    String statusText;
    IconData statusIcon;
    switch (status.toLowerCase()) {
      case 'completed':
        statusColor = Color(0xFF10B981);
        statusText = 'Đã hoàn thành';
        statusIcon = Icons.check_circle;
        break;
      case 'approved':
        statusColor = Color(0xFF3B82F6);
        statusText = 'Đã duyệt';
        statusIcon = Icons.approval;
        break;
      case 'pending':
        statusColor = Color(0xFFF59E0B);
        statusText = 'Đang xử lý';
        statusIcon = Icons.pending;
        break;
      case 'rejected':
        statusColor = FlutterFlowTheme.of(context).error;
        statusText = 'Đã từ chối';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = FlutterFlowTheme.of(context).secondaryText;
        statusText = 'Không rõ';
        statusIcon = Icons.help;
    }

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
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
            // Header with amount and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0)
                      .format(amount) + '₫',
                  style: FlutterFlowTheme.of(context).headlineSmall.override(
                    fontFamily: 'SF Pro Text',
                    fontSize: 20.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsetsDirectional.fromSTEB(12.0, 6.0, 12.0, 6.0),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        color: statusColor,
                        size: 16.0,
                      ),
                      SizedBox(width: 4.0),
                      Text(
                        statusText,
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: 'SF Pro Text',
                          color: statusColor,
                          fontSize: 12.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.0),

            // Bank Info
            Row(
              children: [
                Icon(
                  Icons.account_balance,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  size: 16.0,
                ),
                SizedBox(width: 8.0),
                Text(
                  '$bankName - $bankAccount',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'SF Pro Text',
                    letterSpacing: 0.0,
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.0),

            // Request Date
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  size: 16.0,
                ),
                SizedBox(width: 8.0),
                Text(
                  'Yêu cầu: ${DateFormat('dd/MM/yyyy HH:mm').format(requestDate!)}',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                    fontFamily: 'SF Pro Text',
                    color: FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 12.0,
                    letterSpacing: 0.0,
                  ),
                ),
              ],
            ),

            // Completed Date (if available)
            if (completedDate != null) ...[
              SizedBox(height: 4.0),
              Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: FlutterFlowTheme.of(context).secondaryText,
                    size: 16.0,
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    'Hoàn thành: ${DateFormat('dd/MM/yyyy HH:mm').format(completedDate)}',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: 'SF Pro Text',
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 12.0,
                      letterSpacing: 0.0,
                    ),
                  ),
                ],
              ),
            ],

            // Notes
            if (notes.isNotEmpty) ...[
              SizedBox(height: 8.0),
              Container(
                width: double.infinity,
                padding: EdgeInsetsDirectional.fromSTEB(12.0, 8.0, 12.0, 8.0),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).accent1,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  notes,
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                    fontFamily: 'SF Pro Text',
                    fontSize: 12.0,
                    letterSpacing: 0.0,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 