import 'package:flutter_truco/models/card.dart';
import 'package:flutter_truco/models/player.dart';

class Dealer {

  static List<CardModel> surfleDeck([int length = 40]){

    List<CardModel> tmpDeck = [];

    var naipe = 0;

    for(var i=0; i<length; i++){
      var value = i % 10;
      var number = value + 1;

      if (number == 1) number = 11;
      if (number == 2) number = 12;
      if (number == 3) number = 13;

      tmpDeck.add(CardModel(value: number, naipe: naipe ));

      if(value == 9) naipe += 1;
    }
    
    tmpDeck.shuffle();

    return tmpDeck;

  }

  static List<CardModel> dealerDeck(int max){
    return surfleDeck().getRange(0, max).toList();
  }

  static CardModel checkWinDumb(List<CardModel> jogadas){
    jogadas.sort((a, b) => b.value.compareTo(a.value));

    jogadas.forEach((e) { print(e.detail); });

    return jogadas.first;
  }

  static List<CardModel> filterJogadas(List<CardModel> jogadas, List<Player> players){

    if(players.isEmpty) return jogadas;

    return jogadas.where((jog) {
      var i = players.indexWhere((p) => p.number == jog.player);
      return i > -1;
    }).toList();
  }
  
  static Player nextPlayerComCartas(List<Player> players, int initial){
    int i = initial == players.length - 1 ? 0 : initial + 1;

    while (players[i].cards.isEmpty) {
      if (i == players.length - 1) {
        i = 0;
      } else {
        i++;
      }
    }

    return players[i];
  }
}