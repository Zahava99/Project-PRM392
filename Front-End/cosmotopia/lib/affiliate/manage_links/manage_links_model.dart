import '/flutter_flow/flutter_flow_util.dart';
import '/all_component/appbar/appbar_widget.dart';
import 'manage_links_widget.dart' show ManageLinksWidget;
import 'package:flutter/material.dart';

class ManageLinksModel extends FlutterFlowModel<ManageLinksWidget> {
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