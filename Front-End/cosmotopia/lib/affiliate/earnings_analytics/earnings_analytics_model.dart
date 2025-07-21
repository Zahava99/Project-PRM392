import '/all_component/appbar/appbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'earnings_analytics_widget.dart' show EarningsAnalyticsWidget;
import 'package:flutter/material.dart';

class EarningsAnalyticsModel extends FlutterFlowModel<EarningsAnalyticsWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for appbar component.
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