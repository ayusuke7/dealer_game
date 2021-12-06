import 'package:flutter/material.dart';
import 'package:flutter_truco/components/card_game.dart';
import 'package:flutter_truco/models/card.dart';
import 'package:flutter_truco/models/player.dart';

class PlayerDumb extends StatelessWidget {

  final Player? player;
  final bool vez;
  final bool isGet;
  final bool isDeck;

  final Function(CardModel) onTapCard;
  final Function() onTapDeck;
  final Function()? onTapGetCard;

  const PlayerDumb({
    Key? key,
    required this.onTapCard,
    required this.player,
    required this.onTapDeck,
    this.onTapGetCard,
    this.isGet = false,
    this.isDeck = true,
    this.vez = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    var width = 120.0;
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: width / 3,
                child: Image.asset("${player?.asset}", 
                  fit: BoxFit.contain
                ),
              ),
              
              if(isGet) TextButton.icon(
                onPressed: onTapGetCard, 
                icon: Icon(Icons.download),
                label: Text("Pegar Cartas"),
                style: TextButton.styleFrom(
                  fixedSize: Size(150, 50),
                  backgroundColor: Colors.blue,
                  primary: Colors.white
                ),
              )
            ],
          ),

          Flexible(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 15),
              scrollDirection: Axis.horizontal,
              children: (player?.cards ?? []).map((card) {
                return CardGame(
                  card: card,
                  onTap: () {
                    onTapCard(card);
                  },
                );
              }).toList()
            ),
          ),
          
          if(isDeck) CardGame(
            onTap: onTapDeck
          )
        ],
      ),
    );
  }
}