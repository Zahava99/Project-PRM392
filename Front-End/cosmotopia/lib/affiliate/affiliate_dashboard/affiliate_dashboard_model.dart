import '/all_component/appbar/appbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'affiliate_dashboard_widget.dart' show AffiliateDashboardWidget;
import 'package:flutter/material.dart';

class AffiliateDashboardModel extends FlutterFlowModel<AffiliateDashboardWidget> {
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