import '/all_component/product_contanier/product_contanier_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'water_color_page_widget.dart' show WaterColorPageWidget;
import 'package:flutter/material.dart';

class WaterColorPageModel extends FlutterFlowModel<WaterColorPageWidget> {
  ///  State fields for stateful widgets in this page.

  // Models for ProductContanier dynamic component.
  late FlutterFlowDynamicModels<ProductContanierModel> productContanierModels;

  @override
  void initState(BuildContext context) {
    productContanierModels =
        FlutterFlowDynamicModels(() => ProductContanierModel());
  }

  @override
  void dispose() {
    productContanierModels.dispose();
  }
}
