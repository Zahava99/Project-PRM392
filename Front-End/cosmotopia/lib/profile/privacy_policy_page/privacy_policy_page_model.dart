import '/all_component/appbar/appbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'privacy_policy_page_widget.dart' show PrivacyPolicyPageWidget;
import 'package:flutter/material.dart';

class PrivacyPolicyPageModel extends FlutterFlowModel<PrivacyPolicyPageWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for Appbar component.
  late AppbarModel appbarModel;

  @override
  void initState(BuildContext context) {
    appbarModel = createModel(context, () => AppbarModel());
  }

  @override
  void dispose() {
    appbarModel.dispose();
  }
}
