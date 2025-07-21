import '/all_component/appbar/appbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'withdrawal_widget.dart' show WithdrawalWidget;
import 'package:flutter/material.dart';

class WithdrawalModel extends FlutterFlowModel<WithdrawalWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for appbar component.
  late AppbarModel appbarModel;
  // State field(s) for amount widget.
  FocusNode? amountFocusNode;
  TextEditingController? amountController;
  String? Function(BuildContext, String?)? amountControllerValidator;
  // State field(s) for bankAccount widget.
  FocusNode? bankAccountFocusNode;
  TextEditingController? bankAccountController;
  String? Function(BuildContext, String?)? bankAccountControllerValidator;
  // State field(s) for bankName widget.
  String? bankNameValue;
  // State field(s) for notes widget.
  FocusNode? notesFocusNode;
  TextEditingController? notesController;
  String? Function(BuildContext, String?)? notesControllerValidator;

  @override
  void initState(BuildContext context) {
    appbarModel = createModel(context, () => AppbarModel());
  }

  @override
  void dispose() {
    appbarModel.dispose();
    amountFocusNode?.dispose();
    amountController?.dispose();
    bankAccountFocusNode?.dispose();
    bankAccountController?.dispose();
    notesFocusNode?.dispose();
    notesController?.dispose();
  }
} 