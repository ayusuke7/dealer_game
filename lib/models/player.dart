import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_truco/models/card.dart';

class Player {

  final String name;
  final int number;
  final bool auto;
  final String? asset;

  List<CardModel> _cards = [];

  Player({  
    required this.name,
    required this.number,
    this.auto = false,
    this.asset,
  });

  List<CardModel> get cards => _cards;

  Color get color {

    if(number == 1 || number == 3) return Colors.blue;

    return Colors.red;
  }
  
  void printCards(){
    _cards.forEach((e) => print("${e.detail}"));
  }

  void setCards(List<CardModel> newCards, [CardModel? vira]){
    this._cards = newCards.map((e){
      
      var card = CardModel(
        naipe: e.naipe, 
        value: e.value,
        player: number,
      );

      if(vira != null){
        var manil =  vira.value == 13 ? 4 : vira.value + 1;
        card.manil = e.value == manil;
      }

      return card;
    }).toList();
  }
  
  void removeCard(CardModel card){
    this._cards.removeWhere((c) => c.uui == card.uui);
  }
  
  void addCard(CardModel card){
    this._cards.insert(0, CardModel(
      naipe: card.naipe, 
      value: card.value,
      player: number
    ));
  }
  
  void addCards(List<CardModel> newCards){
    this._cards.insertAll(0, newCards.map((e) => CardModel(
      naipe: e.naipe, 
      value: e.value,
      player: number
    )));
  }

  void clearCards(){
    this._cards.clear();
  }

  CardModel randomCard({ List<CardModel>? jogadas }){
    
    if(cards.length == 1) return _cards[0];
    var i = Random.secure().nextInt(_cards.length);
    return _cards[i];
  }

  factory Player.fromJson(Map<String, dynamic> json) => Player(
      name: json["name"],
      number: json["number"],
      auto: json["auto"],
      asset: json["asset"],
  );

  Map<String, dynamic> toJson() => {
      "name": name,
      "number": number,
      "auto": auto,
      "asset": asset,
  };

}