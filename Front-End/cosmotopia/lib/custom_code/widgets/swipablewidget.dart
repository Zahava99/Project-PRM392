// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter_slidable/flutter_slidable.dart';

class Swipablewidget extends StatefulWidget {
  const Swipablewidget({
    super.key,
    this.width,
    this.height,
    this.action,
    required this.data,
    this.ontapcontainer,
    this.quantity = 1,
    this.onIncrease,
    this.onDecrease,
  });

  final double? width;
  final double? height;
  final Future Function()? action;
  final DetailStruct data;
  final Future Function()? ontapcontainer;
  final int quantity;
  final Future Function()? onIncrease;
  final Future Function()? onDecrease;

  @override
  State<Swipablewidget> createState() => _SwipablewidgetState();
}

class _SwipablewidgetState extends State<Swipablewidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        top: 16.0,
        right: 16.0,
      ),
      child: Slidable(
        endActionPane: ActionPane(
          extentRatio: 0.15,
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              borderRadius: BorderRadius.circular(16),
              onPressed: (context) async {
                await widget.action?.call();
              },
              backgroundColor: Colors.red,
              icon: Icons.delete,
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            setState(() async {
              await widget.ontapcontainer?.call();
            });
          },
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              boxShadow: [
                BoxShadow(
                  blurRadius: 16,
                  color: FlutterFlowTheme.of(context).shadowColor,
                  offset: Offset(
                    0,
                    4,
                  ),
                )
              ],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 1),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8)),
                    child: Image.network(
                      widget.data.image,
                      width: 120,
                      height: 126,
                      fit: BoxFit.fill,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/placeholder.png',
                          width: 120,
                          height: 126,
                          fit: BoxFit.fill,
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.data.title,
                            maxLines: 2,
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'SF  pro display',
                                  fontSize: 16,
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.w600,
                                  useGoogleFonts: false,
                                  lineHeight: 1.5,
                                ),
                          ),
                          Text(
                            widget.data.price,
                            maxLines: 1,
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'SF  pro display',
                                  fontSize: 16,
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.w500,
                                  useGoogleFonts: false,
                                  lineHeight: 1.5,
                                ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: Text(
                                  'Qty:${widget.quantity}',
                                  maxLines: 1,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'SF  pro display',
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        fontSize: 14,
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.normal,
                                        useGoogleFonts: false,
                                        lineHeight: 1.5,
                                      ),
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional(0, 0),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0, 0, 12, 0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .lightGray,
                                          shape: BoxShape.circle,
                                        ),
                                        child: InkWell(
                                          onTap: widget.onDecrease,
                                          child: Icon(
                                            Icons.remove,
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                            size: 13,
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: AlignmentDirectional(0, 1),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  8, 0, 8, 0),
                                          child: Text(
                                            '${widget.quantity}',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'SF  pro display',
                                                  fontSize: 16,
                                                  letterSpacing: 0,
                                                  fontWeight: FontWeight.normal,
                                                  useGoogleFonts: false,
                                                  lineHeight: 1.5,
                                                ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .lightGray,
                                          shape: BoxShape.circle,
                                        ),
                                        child: InkWell(
                                          onTap: widget.onIncrease,
                                          child: Icon(
                                            Icons.add,
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                            size: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // child: Container(
        //   padding: EdgeInsets.only(right: 20, left: 20),
        //   height: 89,
        //   width: double.infinity,
        //   decoration: BoxDecoration(
        //     borderRadius: BorderRadius.circular(16.0),
        //     color: Colors.white,
        //   ),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.start,
        //     crossAxisAlignment: CrossAxisAlignment.center,
        //     children: [
        //       ClipRRect(
        //         borderRadius: BorderRadius.circular(10.0),
        //         child: Image.network(
        //           widget.data.image,
        //           width: 100.0,
        //           height: 100.0,
        //           fit: BoxFit.cover,
        //         ),
        //       ),
        //       const SizedBox(width: 10.0),
        //       Expanded(
        //         child: Column(
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           crossAxisAlignment: CrossAxisAlignment.start,
        //           children: [
        //             Text(
        //               widget.data.title,
        //               maxLines: 1,
        //               style: const TextStyle(
        //                 fontSize: 18.0,
        //                 fontWeight: FontWeight.bold,
        //               ),
        //             ),
        //             const SizedBox(height: 10.0),
        //             Text(
        //               widget.data.price,
        //               style: const TextStyle(
        //                 fontSize: 14.0,
        //                 color: Colors.grey,
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //       const SizedBox(width: 10.0),
        //       Row(
        //         crossAxisAlignment: CrossAxisAlignment.center,
        //         children: [
        //           GestureDetector(
        //               onTap: () {
        //                 if (count > 0) count--;
        //               },
        //               child: CircleAvatar(
        //                   radius: 15,
        //                   backgroundColor: Color(0xffF8F8F8),
        //                   child: Icon(
        //                     color: Colors.black,
        //                     Icons.remove,
        //                     size: 15,
        //                   ))),
        //           Padding(
        //             padding: EdgeInsets.only(left: 8, right: 8),
        //             child: Text(
        //               '$count',
        //               style: TextStyle(
        //                 fontSize: 14,
        //                 fontWeight: FontWeight.w700,
        //                 color: Colors.black,
        //               ),
        //             ),
        //           ),
        //           GestureDetector(
        //               onTap: () {
        //                 count++;
        //               },
        //               child: CircleAvatar(
        //                   radius: 15,
        //                   backgroundColor: Color(0xffF8F8F8),
        //                   child: Icon(
        //                     color: Colors.black,
        //                     Icons.add,
        //                     size: 15,
        //                   ))),
        //         ],
        //       ),
        //     ],
        //   ),
        // ),
      ),
    );
  }
}
