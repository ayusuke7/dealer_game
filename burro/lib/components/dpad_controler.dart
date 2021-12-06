import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class FocusContainer extends StatefulWidget {
  final Function(bool) onFocus;
  final VoidCallback? onClick;
  final bool autofocus;
  final Widget child;

  const FocusContainer({
    Key? key,
    required this.onFocus,
    required this.child,
    this.onClick,
    this.autofocus = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FocusContainerState();
  }
}

class FocusContainerState extends State<FocusContainer> {
  FocusNode _node = FocusNode();
  bool _focused = false;

  void _handleFocusChange(){
    if(_node.hasFocus != _focused){
      setState(() {
        _focused = _node.hasFocus;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _node.addListener(_handleFocusChange);
  }
  
  @override
  void dispose() {
    _node.removeListener(_handleFocusChange);
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _node,
      child: widget.child,
      autofocus: widget.autofocus,
      onKey: (RawKeyEvent event) {

        setState(() => _focused = !_focused);
        widget.onFocus(_focused);

        if (
          widget.onClick != null &&
          event is RawKeyDownEvent && 
          event.data is RawKeyEventDataAndroid
        ) {
            switch (event.logicalKey.keyLabel) {
              case "Select":
                widget.onClick!();
                break;
              case "Arrow Up":
                break;
              case "Arrow Down":
                break;
              default:
                break;
            }
        }
      },
    );
  }
}
