import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_truco/models/card.dart';

class CardGame extends StatelessWidget {

  final CardModel? card;
  final bool mark;
  final bool visible;
  final bool disabled;
  final bool selected;

  final double width;
  final double fontSize;
  final EdgeInsets? margin;
  final Function()? onTap;

  const CardGame({ 
    Key? key,
    this.card,
    this.onTap,
    this.margin,
    this.width = 100.0,
    this.fontSize = 20.0,
    this.mark = false,
    this.visible = true,
    this.disabled = false,
    this.selected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    var sWidth = selected ? (width+20) : width;
    var sHeight = selected ? (width+80) : (width+60);

    var flip = (card?.flip ?? card == null) || !visible;
    var size = Size(sWidth, sHeight);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedSwitcher(
        child: flip ? _cardFliped(size) : _cardNormal(size),
        duration: Duration(milliseconds: 600),
        transitionBuilder: (widget, animation){
          final rotateAnimate = Tween(begin: pi, end: 0.0).animate(animation);
          return AnimatedBuilder(
            child: widget,
            animation: rotateAnimate,
            builder: (context, widget) {
              final isUnder = ValueKey(flip) != widget?.key;
              final value = isUnder 
                ? min(rotateAnimate.value, pi / 2) 
                : rotateAnimate.value;
              return Transform(
                child: widget,
                transform: Matrix4.rotationY(value),
                alignment: Alignment.center,
              );
            },
          );
        },
      ),
    );
  }

  Widget _cardNormal(Size size){
    var widget = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("${card?.label}", style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: card?.color
        )),
        Image.asset(
          "assets/images/${card?.asset}", 
          width: fontSize, 
          height: fontSize
        )
      ],
    );

    return Card(
      key: ValueKey(true),
      elevation: 5.0,
      margin: margin,
      child: Opacity(
        opacity: disabled ? 0.5 : 1.0,
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            color: mark ? Colors.yellow[100] : Colors.white,
            borderRadius: BorderRadius.circular(8)
          ),
          child: Stack(
            children: [
              Positioned(
                top: 5.0,
                left: 5.0,
                child: widget,
              ),
              Positioned(
                bottom: 5.0,
                right: 5.0,
                child: RotatedBox(
                  quarterTurns: 2,
                  child: widget,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardFliped(Size size) {
    return Card(
      key: ValueKey(false),
      elevation: 5.0,
      margin: margin,
      child: Opacity(
        opacity: disabled ? 0.5 : 1.0,
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            color: Colors.blueGrey[400],
            border: Border.all(width: 2.5, color: Colors.white),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Image.asset(
                    "assets/images/club.png", 
                    width: 40.0, 
                    height: 30.0
                  ),
                  Image.asset(
                    "assets/images/heart.png", 
                    width: 30.0, 
                    height: 30.0
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Image.asset(
                    "assets/images/spades.png", 
                    width: 30.0, 
                    height: 30.0
                  ),
                  Image.asset(
                    "assets/images/diamond.png", 
                    width: 30.0, 
                    height: 30.0
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

}