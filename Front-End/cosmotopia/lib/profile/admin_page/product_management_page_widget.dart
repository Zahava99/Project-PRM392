import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/backend/api_service.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'product_management_page_model.dart';
export 'product_management_page_model.dart';

class ProductManagementPageWidget extends StatefulWidget {
  const ProductManagementPageWidget({super.key});

  static String routeName = 'ProductManagementPage';
  static String routePath = 'productManagementPage';

  @override
  State<ProductManagementPageWidget> createState() => _ProductManagementPageWidgetState();
}

class _ProductManagementPageWidgetState extends State<ProductManagementPageWidget>
    with TickerProviderStateMixin {
  late ProductManagementPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProductManagementPageModel());
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _loadCategories();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  Future<void> _loadCategories() async {
    setState(() {
      _model.isLoading = true;
      _model.errorMessage = '';
    });

    try {
      print('🏷️ Loading categories...');
      
      final response = await ApiService.getAllCategory(pageSize: 100);
      
      print('📡 Categories API Response status: ${response.statusCode}');
      print('📄 Categories API Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Kiểm tra cấu trúc response cho categories
        List<Map<String, dynamic>> categories = [];
        
        if (data['categories'] != null) {
          // API trả về với field "categories"
          categories = List<Map<String, dynamic>>.from(data['categories']);
        } else if (data['success'] == true && data['data'] != null) {
          // Nếu API trả về với success flag
          categories = List<Map<String, dynamic>>.from(data['data']);
        } else if (data is List) {
          // Nếu API trả về trực tiếp là array
          categories = List<Map<String, dynamic>>.from(data);
        } else if (data['data'] != null) {
          // Nếu có data field
          categories = List<Map<String, dynamic>>.from(data['data']);
        }
        
        print('📂 Found ${categories.length} categories');
        
        setState(() {
          _model.categories = categories;
          _model.isLoading = false;
        });
        
        // Log chi tiết category để debug
        if (categories.isNotEmpty) {
          print('📝 First category sample: ${categories.first}');
        }
        
      } else {
        print('❌ Categories API Error: ${response.statusCode} - ${response.body}');
        setState(() {
          _model.isLoading = false;
          _model.errorMessage = 'Không thể tải danh sách category (${response.statusCode})';
        });
      }
    } catch (e) {
      print('💥 Exception loading categories: $e');
      setState(() {
        _model.isLoading = false;
        _model.errorMessage = 'Lỗi kết nối: $e';
      });
    }
  }

  Future<void> _loadProductsByCategory(String categoryId) async {
    setState(() {
      _model.isLoadingProducts = true;
      _model.selectedCategoryId = categoryId;
      _model.errorMessage = '';
    });

    try {
      print('🔍 Loading products for category ID: $categoryId');
      
      // Gọi API với categoryId parameter
      final response = await ApiService.getAllProducts(
        categoryId: categoryId.toString(),
        pageSize: 100, // Lấy nhiều sản phẩm hơn để hiển thị đầy đủ
      );
      
      print('📡 API Response status: ${response.statusCode}');
      print('📄 API Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Kiểm tra cấu trúc response
        List<Map<String, dynamic>> products = [];
        
        if (data['products'] != null) {
          // API trả về với field "products"
          products = List<Map<String, dynamic>>.from(data['products']);
        } else if (data['success'] == true && data['data'] != null) {
          // Nếu API trả về với success flag
          products = List<Map<String, dynamic>>.from(data['data']);
        } else if (data is List) {
          // Nếu API trả về trực tiếp là array
          products = List<Map<String, dynamic>>.from(data);
        } else if (data['data'] != null) {
          // Nếu có data field
          products = List<Map<String, dynamic>>.from(data['data']);
        }
        
        print('📦 Found ${products.length} products');
        
        setState(() {
          _model.products = products;
          _model.isLoadingProducts = false;
          _model.showProducts = true;
          _model.selectedProducts.clear();
          _model.isSelectionMode = false;
        });
        
        // Log chi tiết sản phẩm để debug
        if (products.isNotEmpty) {
          print('📝 First product sample: ${products.first}');
        }
        
      } else {
        print('❌ API Error: ${response.statusCode} - ${response.body}');
        setState(() {
          _model.isLoadingProducts = false;
          _model.errorMessage = 'Không thể tải danh sách sản phẩm (${response.statusCode})';
        });
      }
    } catch (e) {
      print('💥 Exception loading products: $e');
      setState(() {
        _model.isLoadingProducts = false;
        _model.errorMessage = 'Lỗi kết nối: $e';
      });
    }
  }

  void _toggleSelectionMode() {
    setState(() {
      _model.isSelectionMode = !_model.isSelectionMode;
      if (!_model.isSelectionMode) {
        _model.selectedProducts.clear();
      }
    });
    
    if (_model.isSelectionMode) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _toggleProductSelection(Map<String, dynamic> product) {
    setState(() {
      final productId = _getProductId(product);
      if (productId.isNotEmpty) {
        if (_model.selectedProducts.contains(productId)) {
          _model.selectedProducts.remove(productId);
        } else {
          _model.selectedProducts.add(productId);
        }
      }
    });
  }

  void _selectAllProducts() {
    setState(() {
      if (_model.selectedProducts.length == _model.products.length) {
        _model.selectedProducts.clear();
      } else {
        _model.selectedProducts = _model.products
            .map((product) => _getProductId(product))
            .where((id) => id.isNotEmpty)
            .toSet();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
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
            children: [
              _buildHeader(),
              _model.showProducts ? _buildActionButtons() : SizedBox.shrink(),
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(20.0, 25.0, 20.0, 20.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        boxShadow: [
          BoxShadow(
            blurRadius: 4.0,
            color: Color(0x0F000000),
            offset: Offset(0.0, 2.0),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () async {
              if (_model.showProducts) {
                setState(() {
                  _model.showProducts = false;
                  _model.selectedCategoryId = null;
                  _model.isSelectionMode = false;
                  _model.selectedProducts.clear();
                });
                _animationController.reset();
              } else {
                context.safePop();
              }
            },
            child: Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).accent4.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: FlutterFlowTheme.of(context).primaryText,
                size: 20.0,
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  _model.showProducts ? 'Quản lý sản phẩm' : 'Danh mục sản phẩm',
                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                    fontFamily: 'SF Pro Display',
                    fontSize: 24.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_model.showProducts && _model.selectedProducts.isNotEmpty)
                  Text(
                    '${_model.selectedProducts.length} sản phẩm đã chọn',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: 'SF Pro Text',
                      color: FlutterFlowTheme.of(context).primary,
                      fontSize: 14.0,
                      letterSpacing: 0.0,
                    ),
                  ),
              ],
            ),
          ),
          if (_model.showProducts)
            InkWell(
              onTap: _toggleSelectionMode,
              child: Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  color: _model.isSelectionMode
                      ? FlutterFlowTheme.of(context).primary
                      : FlutterFlowTheme.of(context).accent4.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(
                  _model.isSelectionMode ? Icons.close : Icons.checklist,
                  color: _model.isSelectionMode
                      ? Colors.white
                      : FlutterFlowTheme.of(context).primaryText,
                  size: 20.0,
                ),
              ),
            )
          else
            SizedBox(width: 40.0),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          height: _model.isSelectionMode ? 140.0 : 80.0,
          padding: EdgeInsetsDirectional.fromSTEB(20.0, 10.0, 20.0, 10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Main action buttons row
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.add_circle_outline,
                      label: 'Thêm mới',
                      color: FlutterFlowTheme.of(context).success,
                      onTap: () => _showCreateProductDialog(),
                    ),
                  ),
                  SizedBox(width: 12.0),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.edit_outlined,
                      label: 'Cập nhật',
                      color: FlutterFlowTheme.of(context).warning,
                      onTap: () => _updateProducts(),
                      isEnabled: _model.selectedProducts.isNotEmpty || !_model.isSelectionMode,
                    ),
                  ),
                  SizedBox(width: 12.0),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.delete_outline,
                      label: 'Xóa',
                      color: FlutterFlowTheme.of(context).error,
                      onTap: () => _deleteProducts(),
                      isEnabled: _model.selectedProducts.isNotEmpty || !_model.isSelectionMode,
                    ),
                  ),
                ],
              ),
              // Selection mode controls
              if (_model.isSelectionMode) ...[
                SizedBox(height: 12.0),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selectAllProducts,
                        icon: Icon(
                          _model.selectedProducts.length == _model.products.length
                              ? Icons.deselect
                              : Icons.select_all,
                          size: 18.0,
                        ),
                        label: Text(
                          _model.selectedProducts.length == _model.products.length
                              ? 'Bỏ chọn tất cả'
                              : 'Chọn tất cả',
                          style: TextStyle(fontSize: 14.0),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: FlutterFlowTheme.of(context).primaryText,
                          side: BorderSide(
                            color: FlutterFlowTheme.of(context).alternate,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isEnabled = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          height: 48.0,
          decoration: BoxDecoration(
            color: isEnabled ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: isEnabled ? color.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isEnabled ? color : Colors.grey,
                size: 20.0,
              ),
              SizedBox(width: 8.0),
              Text(
                label,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'SF Pro Text',
                  color: isEnabled ? color : Colors.grey,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_model.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                FlutterFlowTheme.of(context).primary,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Đang tải dữ liệu...',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'SF Pro Text',
                color: FlutterFlowTheme.of(context).secondaryText,
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
      );
    }

    if (_model.errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Icon(
                Icons.error_outline,
                size: 64.0,
                color: FlutterFlowTheme.of(context).error,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              _model.errorMessage,
              style: FlutterFlowTheme.of(context).bodyLarge.override(
                fontFamily: 'SF Pro Text',
                letterSpacing: 0.0,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.0),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _model.errorMessage = '';
                });
                _loadCategories();
              },
              icon: Icon(Icons.refresh),
              label: Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: FlutterFlowTheme.of(context).primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return _model.showProducts ? _buildProductsList() : _buildCategoriesList();
  }

  Widget _buildCategoriesList() {
    if (_model.categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).accent4.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Icon(
                Icons.category_outlined,
                size: 64.0,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Chưa có danh mục nào',
              style: FlutterFlowTheme.of(context).headlineSmall.override(
                fontFamily: 'SF Pro Text',
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(20.0),
      itemCount: _model.categories.length,
      itemBuilder: (context, index) {
        final category = _model.categories[index];
        return Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _loadProductsByCategory(category['categoryId']),
              borderRadius: BorderRadius.circular(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: FlutterFlowTheme.of(context).alternate,
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8.0,
                      color: Color(0x0A000000),
                      offset: Offset(0.0, 2.0),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      // Container(
                      //   width: 60.0,
                      //   height: 60.0,
                      //   decoration: BoxDecoration(
                      //     color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                      //     borderRadius: BorderRadius.circular(16.0),
                      //   ),
                      //   child: Icon(
                      //     Icons.category,
                      //     color: FlutterFlowTheme.of(context).primary,
                      //     size: 28.0,
                      //   ),
                      // ),
                      // SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category['name'] ?? 'Unknown Category',
                              style: FlutterFlowTheme.of(context).headlineSmall.override(
                                fontFamily: 'SF Pro Text',
                                fontSize: 18.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (category['description'] != null && 
                                category['description'].toString().isNotEmpty) ...[
                              SizedBox(height: 4.0),
                              Text(
                                category['description'],
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: 'SF Pro Text',
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                  letterSpacing: 0.0,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: FlutterFlowTheme.of(context).secondaryText,
                        size: 20.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductsList() {
    if (_model.isLoadingProducts) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                FlutterFlowTheme.of(context).primary,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Đang tải sản phẩm...',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'SF Pro Text',
                color: FlutterFlowTheme.of(context).secondaryText,
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
      );
    }

    if (_model.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).accent4.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 64.0,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Chưa có sản phẩm nào',
              style: FlutterFlowTheme.of(context).headlineSmall.override(
                fontFamily: 'SF Pro Text',
                letterSpacing: 0.0,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Nhấn "Thêm mới" để tạo sản phẩm đầu tiên',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'SF Pro Text',
                color: FlutterFlowTheme.of(context).secondaryText,
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      itemCount: _model.products.length,
      itemBuilder: (context, index) {
        final product = _model.products[index];
        final productId = _getProductId(product);
        final isSelected = _model.selectedProducts.contains(productId);

        return Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (_model.isSelectionMode) {
                  _toggleProductSelection(product);
                } else {
                  _showProductDetails(product);
                }
              },
              borderRadius: BorderRadius.circular(16.0),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? FlutterFlowTheme.of(context).primary.withOpacity(0.1)
                      : FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: isSelected
                        ? FlutterFlowTheme.of(context).primary
                        : FlutterFlowTheme.of(context).alternate,
                    width: isSelected ? 2.0 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: isSelected ? 12.0 : 8.0,
                      color: isSelected 
                          ? FlutterFlowTheme.of(context).primary.withOpacity(0.2)
                          : Color(0x0A000000),
                      offset: Offset(0.0, 2.0),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Selection checkbox
                      if (_model.isSelectionMode) ...[
                        Container(
                          width: 24.0,
                          height: 24.0,
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? FlutterFlowTheme.of(context).primary
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? FlutterFlowTheme.of(context).primary
                                  : FlutterFlowTheme.of(context).alternate,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16.0,
                                )
                              : null,
                        ),
                        SizedBox(width: 12.0),
                      ],
                      // Product image
                      Container(
                        width: 80.0,
                        height: 80.0,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).accent1.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: _buildProductImage(product),
                      ),
                      SizedBox(width: 16.0),
                      // Product info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getProductName(product),
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                                color: FlutterFlowTheme.of(context).primaryText,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              _getProductPrice(product),
                              style: FlutterFlowTheme.of(context).bodyLarge.override(
                                fontFamily: 'Inter',
                                color: FlutterFlowTheme.of(context).primary,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.0,
                              ),
                            ),
                            if (_getProductDescription(product).isNotEmpty) ...[
                              SizedBox(height: 4.0),
                              Builder(
                                builder: (context) {
                                  String description = _getProductDescription(product);
                                  return Text(
                                    description,
                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                      fontFamily: 'Inter',
                                      color: FlutterFlowTheme.of(context).secondaryText,
                                      letterSpacing: 0.0,
                                    ).copyWith(
                                      height: 1.2, // Line height để text hiển thị tốt hơn
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                  );
                                },
                              ),
                            ],
                            // Hiển thị ID và Category ID để debug
                            /* 
                            SizedBox(height: 2.0),
                            Text(
                              'ID: ${_getProductId(product)} | Cat: ${product['categoryId'] ?? 'N/A'}',
                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                fontFamily: 'SF Pro Text',
                                color: FlutterFlowTheme.of(context).secondaryText,
                                fontSize: 10.0,
                                letterSpacing: 0.0,
                              ),
                            ),
                            */
                          ],
                        ),
                      ),
                      // Action menu
                      if (!_model.isSelectionMode) ...[
                        SizedBox(width: 8.0),
                        PopupMenuButton<String>(
                          onSelected: (value) => _handleProductAction(value, product),
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem<String>(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 18),
                                  SizedBox(width: 8),
                                  Text('Sửa'),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 18, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Xóa', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                          child: Container(
                            width: 32.0,
                            height: 32.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).accent4.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Icon(
                              Icons.more_vert,
                              color: FlutterFlowTheme.of(context).primaryText,
                              size: 18.0,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _addNewProduct() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info, color: Colors.white),
            SizedBox(width: 8),
            Text('Chức năng thêm sản phẩm sẽ được cập nhật'),
          ],
        ),
        backgroundColor: FlutterFlowTheme.of(context).primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _updateProducts() {
    if (_model.selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng chọn ít nhất một sản phẩm để cập nhật'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    if (_model.selectedProducts.length == 1) {
      // Single product edit
      final productId = _model.selectedProducts.first;
      final product = _model.products.firstWhere(
        (p) => _getProductId(p) == productId,
        orElse: () => {},
      );
      
      if (product.isNotEmpty) {
        _showEditProductDialog(product);
      }
    } else {
      // Multiple products - show info message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Chỉ có thể cập nhật từng sản phẩm một. Vui lòng chọn 1 sản phẩm.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _deleteProducts() {
    if (_model.selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng chọn ít nhất một sản phẩm để xóa'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    _showDeleteSelectedConfirmDialog();
  }

  void _handleProductAction(String action, Map<String, dynamic> product) {
    switch (action) {
      case 'edit':
        _showEditProductDialog(product);
        break;
      case 'delete':
        final productId = _getProductId(product);
        final productName = _getProductName(product);
        _showDeleteConfirmDialog(productId, productName);
        break;
    }
  }

  void _showProductDetails(Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).alternate,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              product['productName'] ?? 'Unknown Product',
              style: FlutterFlowTheme.of(context).headlineMedium,
            ),
            SizedBox(height: 8),
            if (product['price'] != null)
              Text(
                '${product['price']}đ',
                style: FlutterFlowTheme.of(context).headlineSmall.override(
                  color: FlutterFlowTheme.of(context).primary,
                ),
              ),
            SizedBox(height: 12),
            if (product['description'] != null)
              Text(
                product['description'],
                style: FlutterFlowTheme.of(context).bodyMedium,
              ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showSingleDeleteDialog(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận xóa'),
          content: Text('Bạn có chắc chắn muốn xóa sản phẩm "${product['productName']}" không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Chức năng xóa sản phẩm sẽ được cập nhật'),
                    backgroundColor: FlutterFlowTheme.of(context).error,
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  void _showBulkDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xóa nhiều sản phẩm'),
          content: Text('Bạn có chắc chắn muốn xóa ${_model.selectedProducts.length} sản phẩm đã chọn không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _model.selectedProducts.clear();
                  _model.isSelectionMode = false;
                });
                _animationController.reverse();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Chức năng xóa hàng loạt sẽ được cập nhật'),
                    backgroundColor: FlutterFlowTheme.of(context).error,
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Xóa tất cả'),
            ),
          ],
        );
      },
    );
  }

  void _showBulkUpdateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cập nhật nhiều sản phẩm'),
          content: Text('Bạn muốn cập nhật ${_model.selectedProducts.length} sản phẩm đã chọn?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _model.selectedProducts.clear();
                  _model.isSelectionMode = false;
                });
                _animationController.reverse();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Chức năng cập nhật hàng loạt sẽ được cập nhật'),
                    backgroundColor: FlutterFlowTheme.of(context).warning,
                  ),
                );
              },
              child: Text('Cập nhật'),
            ),
          ],
        );
      },
    );
  }

  // Helper methods để xử lý dữ liệu product
  Widget _buildProductImage(Map<String, dynamic> product) {
    // Debug log để kiểm tra dữ liệu
    String productName = _getProductName(product);
    if (productName.contains('Sữa rửa mặt')) {
      print('🔍 Debug product data for "$productName":');
      print('   - Full product data: $product');
      print('   - imageUrls: ${product['imageUrls']}');
      print('   - imageUrl: ${product['imageUrl']}');
    }
    
    // Thử nhiều field name có thể có cho image
    String? imageUrl;
    
    // Xử lý imageUrls array từ API
    if (product['imageUrls'] != null && product['imageUrls'] is List) {
      List imageUrls = product['imageUrls'];
      if (imageUrls.isNotEmpty) {
        imageUrl = imageUrls[0]?.toString();
        print('🖼️ Found image in imageUrls array: $imageUrl');
      }
    }
    
    // Fallback to other fields
    imageUrl ??= product['imageUrl'] ?? 
                product['image'] ?? 
                product['productImage'] ?? 
                product['thumbnail'];
    
    if (productName.contains('Sữa rửa mặt')) {
      print('🖼️ Final imageUrl for "$productName": $imageUrl');
    }
    
    if (imageUrl != null && imageUrl.isNotEmpty && imageUrl != 'null') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Image.network(
          imageUrl,
          width: 80.0,
          height: 80.0,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 80.0,
              height: 80.0,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2.0,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print('🖼️ Image load error for URL: $imageUrl - Error: $error');
            return Container(
              width: 80.0,
              height: 80.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).accent1.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(
                Icons.inventory_2,
                color: FlutterFlowTheme.of(context).primary,
                size: 32.0,
              ),
            );
          },
        ),
      );
    }
    
    return Container(
      width: 80.0,
      height: 80.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).accent1.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Icon(
        Icons.inventory_2,
        color: FlutterFlowTheme.of(context).primary,
        size: 32.0,
      ),
    );
  }

  String _getProductName(Map<String, dynamic> product) {
    String name = product['productName'] ?? 
                 product['name'] ?? 
                 product['title'] ?? 
                 'Sản phẩm không tên';
    
    // Debug log để xem text gốc từ API
    if (name.contains('Sữa rửa mặt') || name.contains('cao cấp') || name.contains('Chanel')) {
      print('🔍 Debug product name:');
      print('   - Raw from API: "$name"');
      print('   - Length: ${name.length}');
      print('   - Bytes: ${name.codeUnits}');
      print('   - Runes: ${name.runes.toList()}');
    }
    
    // Xử lý đơn giản - chỉ trim và giới hạn độ dài
    try {
      // Không filter ký tự nữa, giữ nguyên text gốc
      name = name.trim();
      
      // Xử lý tên quá dài
      if (name.length > 50) {
        name = name.substring(0, 47) + '...';
      }
      
      return name;
    } catch (e) {
      print('⚠️ Error processing product name: $e');
      return 'Sản phẩm không tên';
    }
  }

  String _getProductPrice(Map<String, dynamic> product) {
    var price = product['price'] ?? product['cost'] ?? product['amount'];
    
    if (price == null) return 'Chưa có giá';
    
    // Xử lý nếu price là string
    if (price is String) {
      try {
        price = double.parse(price);
      } catch (e) {
        return price; // Trả về string gốc nếu không parse được
      }
    }
    
    // Format number với dấu phẩy
    if (price is num) {
      return '${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ';
    }
    
    return '$price đ';
  }

  String _getProductDescription(Map<String, dynamic> product) {
    String description = product['description'] ?? 
                        product['desc'] ?? 
                        product['summary'] ?? 
                        '';
    
    // Debug log cho descriptions có vấn đề
    if (description.contains('Sản phẩm làm sạch') || description.contains('Gently cleanses')) {
      print('🔍 Debug description before processing: "$description"');
      print('   - Length: ${description.length}');
      print('   - Bytes: ${description.codeUnits}');
    }
    
    // Xử lý đơn giản - chỉ trim và giới hạn độ dài
    try {
      if (description.isNotEmpty) {
        String originalDescription = description;
        
        // Không filter ký tự nữa, giữ nguyên text gốc
        description = description.trim();
        
        // Xử lý description quá dài
        if (description.length > 100) {
          description = description.substring(0, 97) + '...';
        }
        
        // Debug log sau khi xử lý
        if (originalDescription.contains('Sản phẩm làm sạch') || originalDescription.contains('Gently cleanses')) {
          print('🔍 Debug description after processing: "$description"');
        }
      }
      return description;
    } catch (e) {
      print('⚠️ Error processing product description: $e');
      return '';
    }
  }

  String _getProductId(Map<String, dynamic> product) {
    return product['productId']?.toString() ?? 
           product['id']?.toString() ?? 
           product['_id']?.toString() ?? 
           '';
  }

  String _getProductImageUrl(Map<String, dynamic> product) {
    // Xử lý imageUrls array từ API
    if (product['imageUrls'] != null && product['imageUrls'] is List) {
      List imageUrls = product['imageUrls'];
      if (imageUrls.isNotEmpty) {
        return imageUrls[0]?.toString() ?? '';
      }
    }
    
    // Fallback to other fields
    return product['imageUrl']?.toString() ?? 
           product['image']?.toString() ?? 
           product['productImage']?.toString() ?? 
           product['thumbnail']?.toString() ?? 
           '';
  }

  String _getProductRawPrice(Map<String, dynamic> product) {
    // Trả về giá thuần không format để dùng trong edit form
    var price = product['price'] ?? product['cost'] ?? product['amount'];
    
    if (price == null) return '';
    
    // Xử lý nếu price là string
    if (price is String) {
      try {
        price = double.parse(price);
      } catch (e) {
        // Nếu là string đã format, thử extract số
        String cleaned = price.replaceAll(RegExp(r'[^\d.]'), '');
        try {
          return cleaned.isNotEmpty ? cleaned : '';
        } catch (e2) {
          return '';
        }
      }
    }
    
    // Trả về số thuần
    if (price is num) {
      return price.toStringAsFixed(0);
    }
    
    return '';
  }

  // ============ CRUD OPERATIONS ============

  void _showCreateProductDialog() {
    _showProductFormDialog(
      title: 'Thêm sản phẩm mới',
      isEdit: false,
    );
  }

  void _showEditProductDialog(Map<String, dynamic> product) {
    _showProductFormDialog(
      title: 'Cập nhật sản phẩm',
      isEdit: true,
      product: product,
    );
  }

  void _showProductFormDialog({
    required String title,
    required bool isEdit,
    Map<String, dynamic>? product,
  }) {
    // Debug log để xem cấu trúc product khi edit
    if (isEdit && product != null) {
      print('🔍 Debug product data for edit dialog:');
      print('   - product: $product');
      print('   - brand field type: ${product['brand']?.runtimeType}');
      print('   - brand field value: ${product['brand']}');
      print('   - price field type: ${product['price']?.runtimeType}');
      print('   - price field value: ${product['price']}');
      print('   - raw price for edit: ${_getProductRawPrice(product)}');
    }
    final nameController = TextEditingController(
      text: isEdit ? _getProductName(product!) : '',
    );
    final descriptionController = TextEditingController(
      text: isEdit ? _getProductDescription(product!) : '',
    );
    final priceController = TextEditingController(
      text: isEdit ? _getProductRawPrice(product!) : '',
    );
    final imageUrlController = TextEditingController(
      text: isEdit ? _getProductImageUrl(product!) : '',
    );
    final stockController = TextEditingController(
      text: isEdit ? (product!['stockQuantity']?.toString() ?? '0') : '0',
    );

    // Initialize dropdowns
    String? selectedCategoryId = isEdit 
        ? (product!['categoryId'] ?? _model.selectedCategoryId)
        : _model.selectedCategoryId;
    
    // Xử lý brand field - có thể là string hoặc object
    String? selectedBrandName = '';
    if (isEdit && product!['brand'] != null) {
      var brandField = product['brand'];
      if (brandField is String) {
        selectedBrandName = brandField;
      } else if (brandField is Map<String, dynamic>) {
        selectedBrandName = brandField['name'] ?? brandField['brandName'] ?? '';
      } else {
        selectedBrandName = brandField.toString();
      }
    }
    
    // State for dropdowns 
    List<Map<String, dynamic>> brands = [];
    bool isLoadingBrands = false;
    
    // Image upload state
    File? selectedImage;
    String? imageUrl;
    bool isUploadingImage = false;
    String imageSourceType = 'url'; // 'url' or 'upload'

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Load brands if not loaded
            if (brands.isEmpty && !isLoadingBrands) {
              isLoadingBrands = true;
              _loadBrands().then((loadedBrands) {
                setDialogState(() {
                  brands = loadedBrands;
                  isLoadingBrands = false;
                });
              }).catchError((e) {
                setDialogState(() {
                  isLoadingBrands = false;
                });
                print('Error loading brands: $e');
              });
            }

            // Image picker functions
            Future<void> pickImageFromGallery() async {
              try {
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setDialogState(() {
                    selectedImage = File(image.path);
                    imageSourceType = 'upload';
                  });
                }
              } catch (e) {
                print('Error picking image: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi chọn ảnh: $e'), backgroundColor: Colors.red),
                );
              }
            }

            Future<void> pickImageFromCamera() async {
              try {
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  setDialogState(() {
                    selectedImage = File(image.path);
                    imageSourceType = 'upload';
                  });
                }
              } catch (e) {
                print('Error taking photo: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi chụp ảnh: $e'), backgroundColor: Colors.red),
                );
              }
            }

            return AlertDialog(
              title: Text(title),
              content: Container(
                width: double.maxFinite,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7, // Limit to 70% of screen height
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Product Name
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Tên sản phẩm *',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      SizedBox(height: 12),
                      
                      // Category Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedCategoryId,
                        decoration: InputDecoration(
                          labelText: 'Danh mục *',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _model.categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category['categoryId'],
                            child: Text(category['name'] ?? 'Unknown Category'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedCategoryId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng chọn danh mục';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12),
                      
                      // Description
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Mô tả *',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        maxLines: 2, // Reduced from 3 to 2
                      ),
                      SizedBox(height: 12),
                      
                      // Price
                      TextField(
                        controller: priceController,
                        decoration: InputDecoration(
                          labelText: 'Giá *',
                          border: OutlineInputBorder(),
                          suffix: Text('VNĐ'),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 12),
                      
                      // Brand Dropdown
                      isLoadingBrands
                          ? Container(
                              height: 48, // Reduced height
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    SizedBox(width: 8),
                                    Text('Đang tải thương hiệu...'),
                                  ],
                                ),
                              ),
                            )
                          : DropdownButtonFormField<String>(
                              value: selectedBrandName?.isNotEmpty == true ? selectedBrandName : null,
                              decoration: InputDecoration(
                                labelText: 'Thương hiệu',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: [
                                DropdownMenuItem<String>(
                                  value: '',
                                  child: Text('-- Không chọn --'),
                                ),
                                ...brands.map((brand) {
                                  return DropdownMenuItem<String>(
                                    value: brand['name'],
                                    child: Text(brand['name'] ?? 'Unknown Brand'),
                                  );
                                }).toList(),
                              ],
                              onChanged: (value) {
                                setDialogState(() {
                                  selectedBrandName = value;
                                });
                              },
                            ),
                      SizedBox(height: 12),
                      
                      // Stock Quantity
                      TextField(
                        controller: stockController,
                        decoration: InputDecoration(
                          labelText: 'Số lượng tồn kho',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 12),
                      
                      // Image Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hình ảnh sản phẩm',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 6),
                          
                          // Image source type selector - made more compact
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                            children: [
                              Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      setDialogState(() {
                                        imageSourceType = 'url';
                                        selectedImage = null;
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: imageSourceType == 'url' ? Colors.blue.shade50 : null,
                                        borderRadius: BorderRadius.horizontal(left: Radius.circular(8)),
                                        border: imageSourceType == 'url' ? Border.all(color: Colors.blue) : null,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Radio<String>(
                                  value: 'url',
                                  groupValue: imageSourceType,
                                  onChanged: (value) {
                                    setDialogState(() {
                                      imageSourceType = value!;
                                      selectedImage = null;
                                    });
                                  },
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          Text('URL', style: TextStyle(fontSize: 14)),
                                        ],
                                      ),
                                    ),
                                ),
                              ),
                              Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      setDialogState(() {
                                        imageSourceType = 'upload';
                                        imageUrlController.clear();
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: imageSourceType == 'upload' ? Colors.blue.shade50 : null,
                                        borderRadius: BorderRadius.horizontal(right: Radius.circular(8)),
                                        border: imageSourceType == 'upload' ? Border.all(color: Colors.blue) : null,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Radio<String>(
                                  value: 'upload',
                                  groupValue: imageSourceType,
                                  onChanged: (value) {
                                    setDialogState(() {
                                      imageSourceType = value!;
                                      imageUrlController.clear();
                                    });
                                  },
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          Text('Tải lên', style: TextStyle(fontSize: 14)),
                                        ],
                                      ),
                                    ),
                                ),
                              ),
                            ],
                            ),
                          ),
                          
                          // URL input field (when URL selected)
                          if (imageSourceType == 'url') ...[
                            SizedBox(height: 8),
                            TextField(
                              controller: imageUrlController,
                              decoration: InputDecoration(
                                labelText: 'Nhập URL hình ảnh',
                                border: OutlineInputBorder(),
                                hintText: 'https://example.com/image.jpg',
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ],
                          
                          // Image upload section (when Upload selected)
                          if (imageSourceType == 'upload') ...[
                            SizedBox(height: 8),
                            // Upload buttons - more compact
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: pickImageFromGallery,
                                    icon: Icon(Icons.photo_library, size: 16),
                                    label: Text('Thư viện', style: TextStyle(fontSize: 12)),
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                      minimumSize: Size(0, 32),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: pickImageFromCamera,
                                    icon: Icon(Icons.camera_alt, size: 16),
                                    label: Text('Chụp ảnh', style: TextStyle(fontSize: 12)),
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                      minimumSize: Size(0, 32),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            // Image preview - more compact
                            if (selectedImage != null) ...[
                              SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                height: 100, // Reduced from 150
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Ảnh đã chọn',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green.shade600,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setDialogState(() {
                                        selectedImage = null;
                                      });
                                    },
                                    child: Text('Xóa', style: TextStyle(color: Colors.red, fontSize: 12)),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      minimumSize: Size(0, 24),
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              SizedBox(height: 8),
                              // Empty state - more compact
                              Container(
                                width: double.infinity,
                                height: 60, // Reduced from 80
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                    width: 1,
                                    style: BorderStyle.solid,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey.shade50,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.cloud_upload_outlined,
                                      size: 24, // Reduced from 32
                                      color: Colors.grey.shade600,
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Chọn ảnh từ thư viện hoặc chụp ảnh mới',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 10, // Reduced from 12
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: isUploadingImage ? null : () async {
                    // Validate required fields
                    if (nameController.text.trim().isEmpty ||
                        descriptionController.text.trim().isEmpty ||
                        priceController.text.trim().isEmpty ||
                        selectedCategoryId == null ||
                        selectedCategoryId!.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Vui lòng điền đầy đủ thông tin bắt buộc'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    try {
                      final price = double.parse(priceController.text.trim());
                      final stock = int.tryParse(stockController.text.trim()) ?? 0;
                      
                      String? finalImageUrl;
                      
                      // Handle image upload or URL
                      if (imageSourceType == 'upload' && selectedImage != null) {
                        setDialogState(() {
                          isUploadingImage = true;
                        });
                        
                        try {
                          finalImageUrl = await _uploadImage(selectedImage!);
                        } catch (e) {
                          setDialogState(() {
                            isUploadingImage = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Lỗi upload ảnh: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        
                        setDialogState(() {
                          isUploadingImage = false;
                        });
                      } else if (imageSourceType == 'url' && imageUrlController.text.trim().isNotEmpty) {
                        finalImageUrl = imageUrlController.text.trim();
                      }

                      Navigator.of(context).pop(); // Close dialog first

                      if (isEdit && product != null) {
                        // Find brand ID from selected brand name  
                        String? selectedBrandId;
                        if (selectedBrandName?.isNotEmpty == true) {
                          final selectedBrand = brands.firstWhere(
                            (brand) => brand['name'] == selectedBrandName,
                            orElse: () => {},
                          );
                          selectedBrandId = selectedBrand['brandId'];
                        }

                        await _updateProduct(
                          productId: _getProductId(product),
                          productName: nameController.text.trim(),
                          description: descriptionController.text.trim(),
                          price: price,
                          categoryId: selectedCategoryId!,
                          imageUrl: finalImageUrl,
                          stockQuantity: stock,
                          brand: selectedBrandId,
                        );
                      } else {
                        // Find brand ID from selected brand name
                        String? selectedBrandId;
                        if (selectedBrandName?.isNotEmpty == true) {
                          final selectedBrand = brands.firstWhere(
                            (brand) => brand['name'] == selectedBrandName,
                            orElse: () => {},
                          );
                          selectedBrandId = selectedBrand['brandId'];
                        }

                        await _createProduct(
                          productName: nameController.text.trim(),
                          description: descriptionController.text.trim(),
                          price: price,
                          categoryId: selectedCategoryId!,
                          imageUrl: finalImageUrl,
                          stockQuantity: stock,
                          brand: selectedBrandId,
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Lỗi dữ liệu: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: isUploadingImage 
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Đang upload...'),
                          ],
                        )
                      : Text(isEdit ? 'Cập nhật' : 'Tạo mới'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmDialog(String productId, String productName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận xóa'),
          content: Text('Bạn có chắc chắn muốn xóa sản phẩm "$productName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteProduct(productId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteSelectedConfirmDialog() {
    if (_model.selectedProducts.isEmpty) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận xóa'),
          content: Text('Bạn có chắc chắn muốn xóa ${_model.selectedProducts.length} sản phẩm đã chọn?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteSelectedProducts();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Xóa tất cả'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createProduct({
    required String productName,
    required String description,
    required double price,
    required String categoryId,
    String? brand,
    int? stockQuantity,
    String? imageUrl,
  }) async {
    try {
      print('📝 Creating product: $productName');
      
      final response = await ApiService.createProduct(
        productName: productName,
        description: description,
        price: price,
        categoryId: categoryId,
        token: FFAppState().token,
        brand: brand,
        stockQuantity: stockQuantity,
        imageUrl: imageUrl,
      );

      print('📡 Create product response status: ${response.statusCode}');
      print('📄 Create product response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Thêm sản phẩm thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Refresh product list
        await _loadProductsByCategory(categoryId);
      } else {
        throw Exception('API returned status ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error creating product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Lỗi khi thêm sản phẩm: $e'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    }
  }

  Future<void> _updateProduct({
    required String productId,
    required String productName,
    required String description,
    required double price,
    required String categoryId,
    String? imageUrl,
    int? stockQuantity,
    String? brand,
  }) async {
    try {
      print('🔄 Updating product: $productId');
      
      final response = await ApiService.updateProduct(
        productId: productId,
        productName: productName,
        description: description,
        price: price,
        categoryId: categoryId,
        token: FFAppState().token,
        imageUrl: imageUrl,
        stockQuantity: stockQuantity,
        brand: brand,
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('✅ Product updated successfully');
        // Refresh products list
        if (_model.selectedCategoryId != null) {
          await _loadProductsByCategory(_model.selectedCategoryId!);
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sản phẩm "$productName" đã được cập nhật!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('API returned status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error updating product: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi cập nhật sản phẩm: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      print('🗑️ Deleting product: $productId');
      
      final response = await ApiService.deleteProduct(
        productId,
        token: FFAppState().token,
      );
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('✅ Product deleted successfully');
        // Refresh products list
        if (_model.selectedCategoryId != null) {
          await _loadProductsByCategory(_model.selectedCategoryId!);
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sản phẩm đã được xóa!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('API returned status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error deleting product: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi xóa sản phẩm: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteSelectedProducts() async {
    if (_model.selectedProducts.isEmpty) return;
    
    final selectedCount = _model.selectedProducts.length;
    
    try {
      print('🗑️ Deleting $selectedCount selected products...');
      
      final responses = await ApiService.deleteMultipleProducts(
        _model.selectedProducts.toList(),
        token: FFAppState().token,
      );
      
      // Count successful deletions
      int successCount = 0;
      for (var response in responses) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          successCount++;
        }
      }
      
      print('✅ $successCount/$selectedCount products deleted successfully');
      
      // Clear selection and refresh
      setState(() {
        _model.selectedProducts.clear();
        _model.isSelectionMode = false;
      });
      
      // Refresh products list
      if (_model.selectedCategoryId != null) {
        await _loadProductsByCategory(_model.selectedCategoryId!);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa $successCount/$selectedCount sản phẩm!'),
            backgroundColor: successCount == selectedCount ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('❌ Error deleting selected products: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi xóa sản phẩm: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<List<Map<String, dynamic>>> _loadBrands() async {
    try {
      print('🏷️ Loading brands...');
      
      final response = await ApiService.getAllBrands();
      
      print('📡 Brands API Response status: ${response.statusCode}');
      print('📄 Brands API Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Kiểm tra cấu trúc response cho brands
        List<Map<String, dynamic>> brands = [];
        
        if (data['brands'] != null) {
          // API trả về với field "brands"
          brands = List<Map<String, dynamic>>.from(data['brands']);
        } else if (data['success'] == true && data['data'] != null) {
          // Nếu API trả về với success flag
          brands = List<Map<String, dynamic>>.from(data['data']);
        } else if (data is List) {
          // Nếu API trả về trực tiếp là array
          brands = List<Map<String, dynamic>>.from(data);
        } else if (data['data'] != null) {
          // Nếu có data field
          brands = List<Map<String, dynamic>>.from(data['data']);
        }
        
        print('🏷️ Found ${brands.length} brands');
        if (brands.isNotEmpty) {
          print('📝 First brand sample: ${brands.first}');
        }
        
        return brands;
      } else {
        throw Exception('API returned status ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error loading brands: $e');
      return [];
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      print('📤 Uploading image...');
      
      // Convert image to base64
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      
      // Here you can implement actual image upload to your server
      // For now, we'll simulate by returning a mock URL
      // In real implementation, you would call an upload API
      
      // Mock delay to simulate upload
      await Future.delayed(Duration(seconds: 1));
      
      // Return mock URL (replace with actual uploaded URL from your API)
      String mockImageUrl = 'https://example.com/uploads/product_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      print('✅ Image uploaded successfully: $mockImageUrl');
      return mockImageUrl;
      
      /* Real implementation example:
      final response = await http.post(
        Uri.parse('$baseUrl/api/upload/image'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${FFAppState().token}',
        },
        body: jsonEncode({
          'image': base64Image,
          'fileName': 'product_${DateTime.now().millisecondsSinceEpoch}.jpg',
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['imageUrl'];
      } else {
        throw Exception('Upload failed: ${response.body}');
      }
      */
      
    } catch (e) {
      print('❌ Error uploading image: $e');
      throw Exception('Lỗi upload ảnh: $e');
    }
  }
} 
