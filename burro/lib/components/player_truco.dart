import 'package:flutter/material.dart';
import 'package:flutter_truco/models/card.dart';
import 'package:flutter_truco/models/player.dart';
import 'card_game.dart';
class PlayerTruco extends StatefulWidget {

  final Player player;
  final int rotate;
  final bool vez;
  final bool visible;

  final Function(Player)? onTapTruco;
  final Function(CardModel)? onTapCard;

  PlayerTruco({ 
    required this.player,
    this.onTapCard,
    this.onTapTruco,
    this.rotate = 0,
    this.vez = false,
    this.visible = true,
  });

  @override
  State<PlayerTruco> createState() => _PlayerTrucoState();
}

class _PlayerTrucoState extends State<PlayerTruco> {

  CardModel? _select;

  void _onTapVirar(){
    setState(() {
      _select!.flip = !_select!.flip;
    });
  }

  void _onTapCard(){

    var card = CardModel(
      value: _select!.value, 
      naipe: _select!.naipe
    );

    card.player = _select!.player;
    card.manil = _select!.manil;
    card.flip = _select!.flip;

    setState(() => _select = null);

    return widget.onTapCard!(card);

  }
  
  void _onTapTrucar(){
    return widget.onTapTruco!(widget.player);
  }

  @override
  Widget build(BuildContext context) {
    var showOpt = widget.vez && _select != null;
    var size = MediaQuery.of(context).size;
    return RotatedBox(
      quarterTurns: widget.rotate, 
      child: Container(
        padding: EdgeInsets.all(7.0),
        decoration: widget.vez ? BoxDecoration(
          color: widget.player.color.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.white, width: 2.0)
        ) : null,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 7.0),
              child: showOpt 
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: _onTapCard,
                        label: Text("Jogar", style: TextStyle(color: Colors.white)),
                        icon: Icon(Icons.arrow_circle_up, color: Colors.white)
                      ),
                      TextButton.icon(
                        onPressed: _onTapVirar,
                        label: Text("Virar", style: TextStyle(color: Colors.white)),
                        icon: Icon(Icons.rotate_left, color: Colors.white)
                      ),
                      TextButton.icon(
                        onPressed: _onTapTrucar,
                        label: Text("Trucar", style: TextStyle(color: Colors.white)),
                        icon: Icon(Icons.bolt, color: Colors.white)
                      )
                    ],
                  )
                : Text("${widget.player.name}", style: TextStyle(
                    fontSize: 16, 
                    color: Colors.white
                  )),
            ),
            Container(
              height: size.height / 4.0,
              constraints: BoxConstraints(
                maxHeight: showOpt ? 140.0 : 120.0
              ),
              child: widget.player.cards.isEmpty ? null : FittedBox(
                child: Row(
                  children: widget.player.cards.map((card) => CardGame(
                    card: card,
                    visible: widget.visible,
                    selected: widget.vez && _select?.uui == card.uui,
                    onTap: () {
                      setState(() => _select = card);
                    },
                  )).toList()
                ),
              ),
            ),
          ],
        )
      )
    );
  }
}