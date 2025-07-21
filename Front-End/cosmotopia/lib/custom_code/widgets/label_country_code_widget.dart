// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:flutter/services.dart';

class LabelCountryCodeWidget extends StatefulWidget {
  const LabelCountryCodeWidget({
    super.key,
    this.width,
    this.height,
    this.initialValue,
  });

  final double? width;
  final double? height;
  final String? initialValue;

  @override
  State<LabelCountryCodeWidget> createState() => _LabelCountryCodeWidgetState();
}

class _LabelCountryCodeWidgetState extends State<LabelCountryCodeWidget> {
  @override
  Widget build(BuildContext context) {
    return IntlPhoneField(
      autofocus: false,
      showCountryFlag: false,
      dropdownIcon: Icon(
        Icons.keyboard_arrow_down,
        size: 24,
        color: FlutterFlowTheme.of(context).primaryText,
      ),
      style: FlutterFlowTheme.of(context).bodyMedium.override(
            fontFamily: 'SF Pro Text',
            color: FlutterFlowTheme.of(context).primaryText,
            fontSize: 17,
            fontWeight: FontWeight.normal,
            useGoogleFonts: false,
            lineHeight: 1.5,
          ),
      dropdownIconPosition: IconPosition.trailing,
      dropdownTextStyle: FlutterFlowTheme.of(context).bodyMedium.override(
            fontFamily: 'SF Pro Text',
            color: FlutterFlowTheme.of(context).primaryText,
            fontSize: 17,
            fontWeight: FontWeight.w400,
            useGoogleFonts: false,
            lineHeight: 1.5,
          ),
      dropdownDecoration:
          BoxDecoration(borderRadius: BorderRadius.circular(10)),
      initialValue: widget.initialValue,
      flagsButtonMargin: EdgeInsets.only(left: 16),
      keyboardType: TextInputType.phone,
      cursorColor: FlutterFlowTheme.of(context).primaryText,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9]'))],
      decoration: InputDecoration(
        // labelText: "Phone number",
        // labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
        //       fontFamily: 'SF Pro Display',
        //       color: FlutterFlowTheme.of(context).grey400,
        //       fontSize: 13,
        //       useGoogleFonts: false,
        //     ),
        alignLabelWithHint: false,
        label: Text(
          "Phone number",
          style: FlutterFlowTheme.of(context).labelMedium.override(
                fontFamily: 'SF Pro Text',
                color: FlutterFlowTheme.of(context).primaryText,
                fontSize: 15,
                useGoogleFonts: false,
                lineHeight: 1.2,
              ),
        ),
        hintText: 'Phone number',
        hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
              fontFamily: 'SF Pro Text',
              color: FlutterFlowTheme.of(context).black40,
              fontSize: 16,
              fontWeight: FontWeight.normal,
              useGoogleFonts: false,
              lineHeight: 1.5,
            ),

        counterText: '',
        contentPadding:
            EdgeInsets.only(right: 16, top: 16, bottom: 16, left: 16),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: FlutterFlowTheme.of(context).error, width: 1.5)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: FlutterFlowTheme.of(context).primaryText, width: 1.5)),
        disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: FlutterFlowTheme.of(context).black20, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: FlutterFlowTheme.of(context).black20, width: 1.5)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: FlutterFlowTheme.of(context).black20, width: 1.5)),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: FlutterFlowTheme.of(context).black20, width: 1.5)),
      ),
      initialCountryCode: 'VN',
      autovalidateMode: AutovalidateMode.disabled,
      disableLengthCheck: true,
      onChanged: (value) {
        FFAppState().update(() {
          FFAppState().phone = value.completeNumber;
        });
      },
      onCountryChanged: (value) {
        FFAppState().update(() {
          FFAppState().countryCode = value.dialCode.toString();
        });
      },
    );
  }
}
