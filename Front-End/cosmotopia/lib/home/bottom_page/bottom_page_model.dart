import '/all_component/category_contain/category_contain_widget.dart';
import '/all_component/order_empty/order_empty_widget.dart';
import '/all_component/product_contanier/product_contanier_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'bottom_page_widget.dart' show BottomPageWidget;
import 'package:flutter/material.dart';

class BottomPageModel extends FlutterFlowModel<BottomPageWidget> {
  ///  Local state fields for this page.

  int bottomadded = 0;

  bool aorder = false;

  bool corder = false;

  bool canorder = false;

  ///  State fields for stateful widgets in this page.

  // State field(s) for PageView widget.
  PageController? pageViewController;

  int get pageViewCurrentIndex => pageViewController != null &&
          pageViewController!.hasClients &&
          pageViewController!.page != null
      ? pageViewController!.page!.round()
      : 0;
  // Models for CategoryContain dynamic component.
  late FlutterFlowDynamicModels<CategoryContainModel> categoryContainModels;
  // Models for ProductContanier dynamic component.
  late FlutterFlowDynamicModels<ProductContanierModel> productContanierModels1;
  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  // Model for OrderEmpty component.
  late OrderEmptyModel orderEmptyModel1;
  // Model for OrderEmpty component.
  late OrderEmptyModel orderEmptyModel2;
  // Model for OrderEmpty component.
  late OrderEmptyModel orderEmptyModel3;
  // Models for ProductContanier dynamic component.
  late FlutterFlowDynamicModels<ProductContanierModel> productContanierModels2;

  @override
  void initState(BuildContext context) {
    categoryContainModels =
        FlutterFlowDynamicModels(() => CategoryContainModel());
    productContanierModels1 =
        FlutterFlowDynamicModels(() => ProductContanierModel());
    orderEmptyModel1 = createModel(context, () => OrderEmptyModel());
    orderEmptyModel2 = createModel(context, () => OrderEmptyModel());
    orderEmptyModel3 = createModel(context, () => OrderEmptyModel());
    productContanierModels2 =
        FlutterFlowDynamicModels(() => ProductContanierModel());
  }

  @override
  void dispose() {
    categoryContainModels.dispose();
    productContanierModels1.dispose();
    tabBarController?.dispose();
    orderEmptyModel1.dispose();
    orderEmptyModel2.dispose();
    orderEmptyModel3.dispose();
    productContanierModels2.dispose();
  }
}
