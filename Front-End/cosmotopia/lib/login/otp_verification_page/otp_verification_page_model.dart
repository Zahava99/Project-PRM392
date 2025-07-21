import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'otp_verification_page_widget.dart' show OtpVerificationPageWidget;
import 'package:flutter/material.dart';

class OtpVerificationPageModel extends FlutterFlowModel<OtpVerificationPageWidget> {
  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  String? _textControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Please enter OTP code';
    }

    if (val.length != 6) {
      return 'OTP code must be 6 digits';
    }

    return null;
  }

  @override
  void initState(BuildContext context) {
    textControllerValidator = _textControllerValidator;
  }

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
} 