import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/all_component/appbar/appbar_widget.dart';
import '/backend/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'manage_links_model.dart';
export 'manage_links_model.dart';

class ManageLinksWidget extends StatefulWidget {
  const ManageLinksWidget({super.key});

  static String routeName = 'ManageLinks';
  static String routePath = 'manageLinks';

  @override
  State<ManageLinksWidget> createState() => _ManageLinksWidgetState();
}

class _ManageLinksWidgetState extends State<ManageLinksWidget> {
  late ManageLinksModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = false;
  List<Map<String, dynamic>> _affiliateLinks = [];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ManageLinksModel());
    _loadAffiliateLinks();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // Load affiliate links created by user
  Future<void> _loadAffiliateLinks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = FFAppState().token;
      if (token.isEmpty) {
        throw Exception('User not authenticated');
      }

      print('🔗 Loading affiliate links...');
      final response = await ApiService.getMyAffiliateLinks(token: token);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('🔍 API Response: $data');
        
        if (data['success'] == true) {
          final List<dynamic> linksData = data['data'] ?? [];
          
          // Debug each link
          for (int i = 0; i < linksData.length; i++) {
            final link = linksData[i];
            print('📊 Link $i: ProductName=${link['productName']}, Clicks=${link['totalClicks']}, Earnings=${link['totalEarnings']}, ReferralCode=${link['referralCode']}');
          }
          
          setState(() {
            _affiliateLinks = linksData.cast<Map<String, dynamic>>();
            _isLoading = false;
          });
          print('✅ Loaded ${_affiliateLinks.length} affiliate links');
        } else {
          throw Exception(data['message'] ?? 'Failed to load links');
        }
      } else {
        final errorBody = response.body;
        print('❌ HTTP Error ${response.statusCode}: $errorBody');
        throw Exception('HTTP ${response.statusCode}: $errorBody');
      }
    } catch (e) {
      print('❌ Error loading affiliate links: $e');
      setState(() {
        _affiliateLinks = [];
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tải danh sách link: $e'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    }
  }

  // Copy link to clipboard
  Future<void> _copyToClipboard(String link) async {
    try {
      print('🔗 Copying to clipboard: $link');
      
      // Ensure link is not empty
      if (link.isEmpty) {
        throw Exception('Link is empty');
      }
      
      await Clipboard.setData(ClipboardData(text: link));
      
      // Verify clipboard content
      final clipboardData = await Clipboard.getData('text/plain');
      if (clipboardData?.text == link) {
        print('✅ Successfully copied to clipboard and verified');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã sao chép link vào clipboard!'),
            backgroundColor: FlutterFlowTheme.of(context).primary,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        throw Exception('Clipboard verification failed');
      }
    } catch (e) {
      print('❌ Error copying to clipboard: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi sao chép link: $e\nVui lòng thử lại hoặc sao chép thủ công'),
          backgroundColor: FlutterFlowTheme.of(context).error,
          duration: Duration(seconds: 4),
        ),
      );
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
                  title: 'Quản lý Link Affiliate',
                ),
              ),

              // Content
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            FlutterFlowTheme.of(context).primary,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadAffiliateLinks,
                        child: _affiliateLinks.isEmpty
                            ? _buildEmptyState()
                            : _buildLinksList(),
                      ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.pushNamed('GenerateLink');
          },
          backgroundColor: FlutterFlowTheme.of(context).primary,
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 24.0,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(20.0, 40.0, 20.0, 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.link_off,
              size: 80.0,
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
            SizedBox(height: 16.0),
            Text(
              'Chưa có link nào',
              style: FlutterFlowTheme.of(context).headlineSmall.override(
                fontFamily: 'SF Pro Text',
                fontSize: 20.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Tạo link affiliate đầu tiên để bắt đầu kiếm tiền!',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'SF Pro Text',
                color: FlutterFlowTheme.of(context).secondaryText,
                fontSize: 16.0,
                letterSpacing: 0.0,
              ),
            ),
            SizedBox(height: 24.0),
            FFButtonWidget(
              onPressed: () {
                context.pushNamed('GenerateLink');
              },
              text: 'Tạo Link Đầu Tiên',
              icon: Icon(Icons.add_link, size: 18.0),
              options: FFButtonOptions(
                width: double.infinity,
                height: 48.0,
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
      ),
    );
  }

  Widget _buildLinksList() {
    return ListView.builder(
      padding: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 20.0),
      itemCount: _affiliateLinks.length,
      itemBuilder: (context, index) {
        final link = _affiliateLinks[index];
        final productName = link['productName'] ?? 'Unknown Product';
        final referralCode = link['referralCode'] ?? '';
        final createdAt = link['createdAt'] ?? '';
        
        // 🔥 FIX: Use correct property names from backend
        final affiliateUrl = link['affiliateProductUrl'] ?? 
                            link['affiliateLink'] ?? 
                            'http://10.0.2.2:5192/api/Product/affiliate/${link['productId']}?ref=$referralCode';
        
        // 🔥 FIX: Get click count and earnings from API response  
        final clicks = link['totalClicks'] ?? 0;
        final earnings = (link['totalEarnings'] ?? 0.0).toDouble();
        final price = (link['price'] ?? 0.0).toDouble();
        final commissionRate = (link['commissionRate'] ?? 0.0).toDouble();

        return Container(
          margin: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
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
              // Product Name & Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      productName,
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                        fontFamily: 'SF Pro Text',
                        fontSize: 16.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      // 🔥 Click Count Display  
                      Icon(
                        Icons.mouse,
                        size: 16.0,
                        color: FlutterFlowTheme.of(context).primary,
                      ),
                      SizedBox(width: 4.0),
                      Text(
                        clicks.toString(),
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: 'SF Pro Text',
                          color: FlutterFlowTheme.of(context).primary,
                          fontSize: 12.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 16.0),
                      // 🔥 Earnings Display
                      Icon(
                        Icons.attach_money,
                        size: 16.0,
                        color: Colors.green,
                      ),
                      SizedBox(width: 4.0),
                      Text(
                        '${earnings.toStringAsFixed(0)}₫',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: 'SF Pro Text',
                          color: Colors.green,
                          fontSize: 12.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 8.0),

              // Product Info Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Giá: ${price.toStringAsFixed(0)}₫',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'SF Pro Text',
                      color: FlutterFlowTheme.of(context).primaryText,
                      fontSize: 14.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Hoa hồng: ${commissionRate.toStringAsFixed(1)}%',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'SF Pro Text',
                      color: FlutterFlowTheme.of(context).primary,
                      fontSize: 14.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8.0),

              // Referral Code
              Row(
                children: [
                  Text(
                    'Mã giới thiệu: ',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: 'SF Pro Text',
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 12.0,
                      letterSpacing: 0.0,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      referralCode,
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily: 'monospace',
                        color: FlutterFlowTheme.of(context).primary,
                        fontSize: 12.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8.0),

              // Created Date
              Text(
                'Tạo ngày: ${_formatDate(createdAt)}',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                  fontFamily: 'SF Pro Text',
                  color: FlutterFlowTheme.of(context).secondaryText,
                  fontSize: 12.0,
                  letterSpacing: 0.0,
                ),
              ),

              SizedBox(height: 16.0),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: FFButtonWidget(
                      onPressed: () => _copyToClipboard(affiliateUrl),
                      text: 'Sao chép Link',
                      icon: Icon(Icons.copy, size: 16.0),
                      options: FFButtonOptions(
                        height: 36.0,
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
                  ),
                  SizedBox(width: 12.0),
                  FFButtonWidget(
                    onPressed: () {
                      // TODO: Share functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Tính năng chia sẻ sắp ra mắt!'),
                          backgroundColor: FlutterFlowTheme.of(context).primary,
                        ),
                      );
                    },
                    text: 'Chia sẻ',
                    icon: Icon(Icons.share, size: 16.0),
                    options: FFButtonOptions(
                      width: 100.0,
                      height: 36.0,
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                        fontFamily: 'SF Pro Text',
                        color: FlutterFlowTheme.of(context).primaryText,
                        fontSize: 14.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w500,
                      ),
                      borderSide: BorderSide(
                        color: FlutterFlowTheme.of(context).primary,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
} 