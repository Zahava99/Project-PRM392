import '/all_component/appbar/appbar_widget.dart';
import '/all_component/category_contain/category_contain_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'categories_page_widget.dart' show CategoriesPageWidget;
import 'package:flutter/material.dart';

class CategoriesPageModel extends FlutterFlowModel<CategoriesPageWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for Appbar component.
  late AppbarModel appbarModel;
  // Models for CategoryContain dynamic component.
  late FlutterFlowDynamicModels<CategoryContainModel> categoryContainModels;

  @override
  void initState(BuildContext context) {
    appbarModel = createModel(context, () => AppbarModel());
    categoryContainModels =
        FlutterFlowDynamicModels(() => CategoryContainModel());
  }

  @override
  void dispose() {
    appbarModel.dispose();
    categoryContainModels.dispose();
  }
}
