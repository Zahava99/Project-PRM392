import '/all_component/appbar/appbar_widget.dart';
import '/all_component/product_contanier/product_contanier_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'search_result_widget.dart' show SearchResultWidget;
import 'package:flutter/material.dart';

class SearchResultModel extends FlutterFlowModel<SearchResultWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for Appbar component.
  late AppbarModel appbarModel;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Models for ProductContanier dynamic component.
  late FlutterFlowDynamicModels<ProductContanierModel> productContanierModels;

  @override
  void initState(BuildContext context) {
    appbarModel = createModel(context, () => AppbarModel());
    productContanierModels =
        FlutterFlowDynamicModels(() => ProductContanierModel());
  }

  @override
  void dispose() {
    appbarModel.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();

    productContanierModels.dispose();
  }
}
