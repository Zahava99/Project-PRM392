import '/all_component/appbar/appbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'security_page_widget.dart' show SecurityPageWidget;
import 'package:flutter/material.dart';

class SecurityPageModel extends FlutterFlowModel<SecurityPageWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for Appbar component.
  late AppbarModel appbarModel;
  // State field(s) for Switch widget.
  bool? switchValue1;
  // State field(s) for Switch widget.
  bool? switchValue2;

  @override
  void initState(BuildContext context) {
    appbarModel = createModel(context, () => AppbarModel());
  }

  @override
  void dispose() {
    appbarModel.dispose();
  }
}
