import 'package:flutter/material.dart';

class MarkerWithTooltip extends StatefulWidget {
  final Widget child;
  final String tooltip;
  final Function onTap;

  MarkerWithTooltip({
    required this.child,
    required this.tooltip,
    required this.onTap,
  });

  @override
  _MapMarkerState createState() => _MapMarkerState();
}

class _MapMarkerState extends State<MarkerWithTooltip> {
  final key = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          final dynamic tooltip = key.currentState;
          tooltip.ensureTooltipVisible();
          widget.onTap();
        },
        child: Tooltip(
          key: key,
          message: widget.tooltip,
          preferBelow:
              false, // Ini akan menampilkan tooltip di atas elemen target.
          // preferTop:
          //     true, // Ini akan menampilkan tooltip di atas elemen target jika preferBelow adalah false.
          // verticalOffset: 20,
          // margin: EdgeInsets.only(left: 50),
          child: widget.child,
        ));
  }
}
