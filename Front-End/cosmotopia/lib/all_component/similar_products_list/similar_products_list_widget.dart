import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'similar_products_list_model.dart';
export 'similar_products_list_model.dart';

class SimilarProductsListWidget extends StatefulWidget {
  const SimilarProductsListWidget({
    super.key,
    required this.similarProducts,
  });

  final List<Map<String, dynamic>> similarProducts;

  @override
  State<SimilarProductsListWidget> createState() => _SimilarProductsListWidgetState();
}

class _SimilarProductsListWidgetState extends State<SimilarProductsListWidget> {
  late SimilarProductsListModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SimilarProductsListModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    print('🔗 Attempting to launch URL: $url');
    
    if (url.isEmpty) {
      print('❌ URL is empty');
      _showErrorSnackBar('Link không hợp lệ');
      return;
    }

    try {
      final uri = Uri.parse(url);
      print('✅ Parsed URI: $uri');
      
      if (await canLaunchUrl(uri)) {
        print('🚀 Launching URL...');
        await launchUrl(
          uri, 
          mode: LaunchMode.externalApplication,
        );
        print('✅ URL launched successfully');
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đang chuyển đến trang sản phẩm...'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        print('❌ Cannot launch URL: $url');
        _showErrorSnackBar('Không thể mở link này. Hãy thử copy link và mở thủ công.');
      }
    } catch (e) {
      print('💥 Error launching URL: $e');
      _showErrorSnackBar('Lỗi khi mở link. Hãy kiểm tra kết nối internet.');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).lightGray,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: FlutterFlowTheme.of(context).primary.withOpacity(0.2),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.search,
                color: FlutterFlowTheme.of(context).primary,
                size: 20.0,
              ),
              SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  'Sản phẩm tương tự từ Google',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'SF Pro Text',
                    color: FlutterFlowTheme.of(context).primaryText,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  'Google',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                    fontFamily: 'SF Pro Text',
                    color: FlutterFlowTheme.of(context).primary,
                    fontSize: 10.0,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.0,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.0),
          
          // Products list
          Container(
            height: 220.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.similarProducts.length,
              itemBuilder: (context, index) {
                final product = widget.similarProducts[index];
                final isVerified = product['isVerified'] as bool? ?? false;
                final similarity = product['similarity'] as double? ?? 0.0;
                
                return Container(
                  width: 180.0,
                  margin: EdgeInsets.only(right: 12.0),
                  child: InkWell(
                    onTap: () => _launchUrl(product['link'] as String? ?? ''),
                    child: Container(
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 4.0,
                            color: Color(0x1A000000),
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with verification badge
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: isVerified 
                                ? FlutterFlowTheme.of(context).primary.withOpacity(0.05)
                                : FlutterFlowTheme.of(context).secondaryBackground,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12.0),
                                topRight: Radius.circular(12.0),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isVerified ? Icons.verified : Icons.info_outline,
                                  size: 16.0,
                                  color: isVerified 
                                    ? FlutterFlowTheme.of(context).primary
                                    : FlutterFlowTheme.of(context).secondaryText,
                                ),
                                SizedBox(width: 4.0),
                                Expanded(
                                  child: Text(
                                    product['source'] as String? ?? 'Unknown',
                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                      fontFamily: 'SF Pro Text',
                                      fontSize: 11.0,
                                      fontWeight: FontWeight.w500,
                                      color: isVerified 
                                        ? FlutterFlowTheme.of(context).primary
                                        : FlutterFlowTheme.of(context).secondaryText,
                                      letterSpacing: 0.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Product info
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product name
                                  Text(
                                    product['name'] as String? ?? 'Sản phẩm tương tự',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      fontFamily: 'SF Pro Text',
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.0,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  
                                  // Description
                                  Expanded(
                                    child: Text(
                                      product['description'] as String? ?? 'Thông tin sản phẩm',
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                      style: FlutterFlowTheme.of(context).bodySmall.override(
                                        fontFamily: 'SF Pro Text',
                                        fontSize: 11.0,
                                        color: FlutterFlowTheme.of(context).secondaryText,
                                        letterSpacing: 0.0,
                                        lineHeight: 1.3,
                                      ),
                                    ),
                                  ),
                                  
                                  // Similarity indicator
                                  if (similarity > 0.7) ...[
                                    SizedBox(height: 8.0),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                      decoration: BoxDecoration(
                                        color: similarity > 0.8 
                                          ? FlutterFlowTheme.of(context).primary.withOpacity(0.1)
                                          : FlutterFlowTheme.of(context).secondaryText.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.star,
                                            size: 12.0,
                                            color: similarity > 0.8 
                                              ? FlutterFlowTheme.of(context).primary
                                              : FlutterFlowTheme.of(context).secondaryText,
                                          ),
                                          SizedBox(width: 2.0),
                                          Text(
                                            similarity > 0.8 ? 'Tương tự cao' : 'Tương tự',
                                            style: FlutterFlowTheme.of(context).bodySmall.override(
                                              fontFamily: 'SF Pro Text',
                                              fontSize: 9.0,
                                              fontWeight: FontWeight.w500,
                                              color: similarity > 0.8 
                                                ? FlutterFlowTheme.of(context).primary
                                                : FlutterFlowTheme.of(context).secondaryText,
                                              letterSpacing: 0.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          
                          // Footer with external link indicator
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).lightGray,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(12.0),
                                bottomRight: Radius.circular(12.0),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.open_in_new,
                                  size: 12.0,
                                  color: FlutterFlowTheme.of(context).primary,
                                ),
                                SizedBox(width: 4.0),
                                Text(
                                  'Xem chi tiết',
                                  style: FlutterFlowTheme.of(context).bodySmall.override(
                                    fontFamily: 'SF Pro Text',
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w500,
                                    color: FlutterFlowTheme.of(context).primary,
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
                );
              },
            ),
          ),
          
          // Footer note
          SizedBox(height: 8.0),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 14.0,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
              SizedBox(width: 4.0),
              Expanded(
                child: Text(
                  'Nhấn để xem thông tin chi tiết từ nguồn gốc',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                    fontFamily: 'SF Pro Text',
                    fontSize: 10.0,
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 