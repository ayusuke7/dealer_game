import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_truco/models/card.dart';

class CardGame extends StatelessWidget {

  final CardModel? card;
  final double width;
  final bool mark;
  final bool visible;
  final bool disabled;
  final EdgeInsets? margin;

  final Function()? onTap;

  const CardGame({ 
    Key? key,
    this.card,
    this.onTap,
    this.width = 150,
    this.mark = false,
    this.visible = true,
    this.disabled = false,
    this.margin
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    var height = width + 50.0;
    var size = (height / 10) + 5;
    var emptySize = size + 15;
    var flip = (card?.flip ?? card == null) || !visible;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedSwitcher(
        child: Opacity(
          opacity: disabled ? 0.5 : 1.0,
          child: flip ? _cardFliped(emptySize) : _cardNormal(size)
        ),
        duration: Duration(milliseconds: 600),
        transitionBuilder: (widget, animation){
          final rotateAnimate = Tween(begin: pi, end: 0.0).animate(animation);
          return AnimatedBuilder(
            child: widget,
            animation: rotateAnimate,
            builder: (context, widget) {
              //final isUnder = ValueKey(123) != widget?.key;
              final value = min(rotateAnimate.value, pi / 2);
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

  Widget _cardNormal(double size){
    var widget = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("${card?.label}", style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.bold,
          color: card?.color
        )),
        Image.asset(
          "assets/images/${card?.asset}", 
          width: size, 
          height: size
        )
      ],
    );

    return Card(
      key: ValueKey(321),
      elevation: 5.0,
      margin: margin,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: width,
          maxHeight: width + 50,
        ),
        decoration: BoxDecoration(
          color: mark ? Colors.yellow[100] : Colors.white,
          borderRadius: BorderRadius.circular(8)
          //border: Border.all(width: 2.5, color: card!.color),
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
    );
  }

  Widget _cardFliped(double size) {
    return Card(
      key: ValueKey(123),
      elevation: 5.0,
      margin: margin,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: width,
          maxHeight: width + 50,
        ),
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
                  width: size, 
                  height: size
                ),
                Image.asset(
                  "assets/images/heart.png", 
                  width: size, 
                  height: size
                ),

              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Image.asset(
                  "assets/images/spades.png", 
                  width: size, 
                  height: size
                ),
                Image.asset(
                  "assets/images/diamond.png", 
                  width: size, 
                  height: size
                )
              ],
            )
          ],
        ),
      ),
    );
  }

}