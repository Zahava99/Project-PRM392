import '/flutter_flow/flutter_flow_util.dart';
import 'product_management_page_widget.dart' show ProductManagementPageWidget;
import 'package:flutter/material.dart';

class ProductManagementPageModel extends FlutterFlowModel<ProductManagementPageWidget> {
  // State fields
  bool isLoading = false;
  bool isLoadingProducts = false;
  bool showProducts = false;
  bool isSelectionMode = false;
  String? selectedCategoryId;
  String errorMessage = '';
  
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> products = [];
  Set<String> selectedProducts = {};

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
} 