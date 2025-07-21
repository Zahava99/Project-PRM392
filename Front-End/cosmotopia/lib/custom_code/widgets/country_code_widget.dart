// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:country_code_picker/country_code_picker.dart';

class CountryCodeWidget extends StatefulWidget {
  const CountryCodeWidget({
    super.key,
    this.width,
    this.height,
    required this.radius,
  });

  final double? width;
  final double? height;
  final double radius;

  @override
  State<CountryCodeWidget> createState() => _CountryCodeWidgetState();
}

class _CountryCodeWidgetState extends State<CountryCodeWidget> {
  @override
  Widget build(BuildContext context) => Center(
          child: Container(
        height: widget.height,
        width: widget.width,
        // padding: EdgeInsets.all(1),
        // margin: EdgeInsets.only(left: 12),
        decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(widget.radius),
              bottomLeft: Radius.circular(widget.radius),
            )),
        child: CountryCodePicker(
          onChanged: print,
          backgroundColor: Colors.transparent,
          // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
          initialSelection: 'IN',
          favorite: ['+91', 'IN'],
          padding: EdgeInsets.zero,

          // optional. Shows only country name and flag
          showCountryOnly: true,
          showFlag: false,

          showDropDownButton: true,
          // optional. Shows only country name and flag when popup is closed.
          showOnlyCountryWhenClosed: false,
          // optional. aligns the flag and the Text left
          alignLeft: false,
        ),
      ));
}
