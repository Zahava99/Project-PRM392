import '/all_component/appbar/appbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'filter_page_widget.dart' show FilterPageWidget;
import 'package:flutter/material.dart';

class FilterPageModel extends FlutterFlowModel<FilterPageWidget> {
  ///  Local state fields for this page.

  int? filterindex;

  ///  State fields for stateful widgets in this page.

  // Model for Appbar component.
  late AppbarModel appbarModel;
  // State field(s) for Slider widget.
  double? sliderValue;

  @override
  void initState(BuildContext context) {
    appbarModel = createModel(context, () => AppbarModel());
  }

  @override
  void dispose() {
    appbarModel.dispose();
  }
}
