import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:xournalpp/layer_contents/XppStroke.dart';
import 'package:xournalpp/src/XppLayer.dart';
import 'package:xournalpp/widgets/ToolBoxBottomSheet.dart';

class PointerListener extends StatefulWidget {
  @required
  final Function(XppContent) onNewContent;
  @required
  final Function({int device, PointerDeviceKind kind}) onDeviceChange;
  @required
  final Widget child;
  @required
  final Map<PointerDeviceKind, EditingTool> toolData;
  @required
  final Matrix4 translationMatrix;
  @required
  final double strokeWidth;
  @required
  final Color color;
  @required
  final Function({Offset coordinates, double radius}) filterEraser;

  const PointerListener(
      {Key key,
      this.onNewContent,
      this.child,
      this.toolData = const {},
      this.translationMatrix,
      this.onDeviceChange,
      this.strokeWidth,
      this.color,
      this.filterEraser})
      : super(key: key);

  @override
  PointerListenerState createState() => PointerListenerState();
}

class PointerListenerState extends State<PointerListener> {
  bool drawingEnabled;

  List<XppStrokePoint> points = [];

  XppStrokeTool tool;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        widget.onDeviceChange(device: event.device, kind: event.kind);
      },
      opaque: false,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerMove: (data) {
          widget.onDeviceChange(device: data.device, kind: data.kind);
          if (!drawingEnabled) return;
          if (tool == XppStrokeTool.PEN || tool == XppStrokeTool.HIGHLIGHTER) {
            double width = (data.pressure == 0
                ? widget.strokeWidth
                : data.pressure * widget.strokeWidth);
            if (tool == XppStrokeTool.HIGHLIGHTER) width *= 5;
            points.add(XppStrokePoint(
                x: data.localPosition.dx,
                y: data.localPosition.dy,
                width: width));
            setState(() {});
          }

          if (isEraser(data))
            widget.filterEraser(
                coordinates:
                    Offset(data.localPosition.dx, data.localPosition.dy),
                radius: widget.strokeWidth);
        },
        onPointerDown: (data) {
          setState(() {
            tool = getToolFromPointer(data);
          });
          widget.onDeviceChange(device: data.device, kind: data.kind);
        },
        onPointerUp: (data) {
          saveStroke(tool);
          points.clear();
        },
        onPointerCancel: (data) {
          points.clear();
        },
        onPointerSignal: (data) {
          setState(() {
            tool = getToolFromPointer(data);
          });
          widget.onDeviceChange(device: data.device, kind: data.kind);
        },
        child: Stack(
          children: [
            widget.child,
            if (points.length > 0)
              CustomPaint(
                /*size: Size(
        bottomRight.dx - getOffset().dx, bottomRight.dy - getOffset().dy),*/
                foregroundPainter: XppStrokePainter(
                    points: points,
                    color: widget.color,
                    topLeft: Offset(0, 0),
                    smoothPressure: tool == XppStrokeTool.PEN),
              ),
          ],
        ),
      ),
    );
  }

  // clearPoints method used to reset the canvas
  // method can be called using
  //   key.currentState.clearPoints();

  void clearPoints() {
    setState(() {
      points.clear();
    });
  }

  void saveStroke(XppStrokeTool tool) {
    if (points.isNotEmpty) {
      XppStroke stroke =
          XppStroke(tool: tool, color: widget.color, points: List.from(points));
      widget.onNewContent(stroke);
    }
  }

  bool isPen(PointerEvent data) {
    return (widget.toolData.keys.contains(data.kind) &&
            widget.toolData[data.kind] == EditingTool.STYLUS) ||
        (!widget.toolData.keys.contains(data.kind) &&
            data.kind == PointerDeviceKind.stylus);
  }

  bool isHighlighter(PointerEvent data) {
    return (widget.toolData.keys.contains(data.kind) &&
        widget.toolData[data.kind] == EditingTool.HIGHLIGHT);
  }

  bool isEraser(PointerEvent data) {
    return (widget.toolData.keys.contains(data.kind) &&
            widget.toolData[data.kind] == EditingTool.ERASER) ||
        (!widget.toolData.keys.contains(data.kind) &&
            data.kind == PointerDeviceKind.invertedStylus);
  }

  XppStrokeTool getToolFromPointer(PointerEvent data) {
    XppStrokeTool tool = XppStrokeTool.PEN;
    if (isHighlighter(data))
      tool = XppStrokeTool.HIGHLIGHTER;
    else if (isEraser(data)) tool = XppStrokeTool.ERASER;
    return tool;
  }
}
