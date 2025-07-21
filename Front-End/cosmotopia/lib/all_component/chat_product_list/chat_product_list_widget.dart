import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/backend/schema/structs/index.dart';
import 'package:flutter/material.dart';
import 'chat_product_list_model.dart';
export 'chat_product_list_model.dart';

class ChatProductListWidget extends StatefulWidget {
  const ChatProductListWidget({
    super.key,
    required this.products,
  });

  final List<ProductStruct> products;

  @override
  State<ChatProductListWidget> createState() => _ChatProductListWidgetState();
}

class _ChatProductListWidgetState extends State<ChatProductListWidget> {
  late ChatProductListModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChatProductListModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
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
                Icons.shopping_bag,
                color: FlutterFlowTheme.of(context).primary,
                size: 20.0,
              ),
              SizedBox(width: 8.0),
              Text(
                'Sản phẩm gợi ý',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'SF Pro Text',
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.0,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.0),
          
          // Product list
          Container(
            height: 200.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.products.length,
              itemBuilder: (context, index) {
                final product = widget.products[index];
                return Container(
                  width: 160.0,
                  margin: EdgeInsets.only(right: 12.0),
                  child: InkWell(
                    onTap: () {
                      // Navigate to product detail
                      context.pushNamed(
                        'ProducutDetailPage',
                        queryParameters: {
                          'detail': serializeParam(
                            DetailStruct(
                              productId: product.productId ?? '',
                              prid: index,
                              id: index,
                              image: product.imageUrls.isNotEmpty 
                                  ? product.imageUrls.first 
                                  : 'https://via.placeholder.com/200',
                              title: product.name,
                              price: product.price.toString(),
                              description: product.description ?? '',
                              catetype: product.category['name'] ?? '',
                              stockQuantity: product.stockQuantity.toString() ?? '',
                              brandName: product.brand != null ? product.brand['name'] ?? '' : '',
                              isFav: false,
                              isJust: false,
                              isNew: false,
                              isCart: false,
                              isColor: false,
                            ),
                            ParamType.DataStruct,
                          ),
                        }.withoutNulls,
                      );
                    },
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
                          // Product image
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12.0),
                              topRight: Radius.circular(12.0),
                            ),
                            child: Image.network(
                              product.imageUrls.isNotEmpty 
                                  ? product.imageUrls.first 
                                  : 'https://via.placeholder.com/160x120',
                              width: double.infinity,
                              height: 120.0,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: double.infinity,
                                  height: 120.0,
                                  color: FlutterFlowTheme.of(context).lightGray,
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: FlutterFlowTheme.of(context).secondaryText,
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          // Product info
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product name
                                Text(
                                  product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: FlutterFlowTheme.of(context).bodySmall.override(
                                    fontFamily: 'SF Pro Text',
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                                SizedBox(height: 4.0),
                                
                                // Price
                                Text(
                                  NumberFormat('#,###', 'vi_VN').format(product.price) + ' ₫',
                                  style: FlutterFlowTheme.of(context).bodySmall.override(
                                    fontFamily: 'SF Pro Text',
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.w600,
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
        ],
      ),
    );
  }
} 