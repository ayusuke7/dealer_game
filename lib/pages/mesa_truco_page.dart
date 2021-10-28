import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_truco/components/card_game.dart';
import 'package:flutter_truco/components/player_truco.dart';
import 'package:flutter_truco/models/card.dart';
import 'package:flutter_truco/models/player.dart';
import 'package:flutter_truco/utils/dealer.dart';

class GameTruco extends StatefulWidget {

  const GameTruco({ Key? key }) : super(key: key);

  @override
  _GameTrucoState createState() => _GameTrucoState();
}

class _GameTrucoState extends State<GameTruco> {
  
  Player player1 = new Player(name: "Player 1", number: 1);
  Player player2 = new Player(name: "Player 2", number: 2, auto: true);
  Player player3 = new Player(name: "Player 3", number: 3, auto: true);
  Player player4 = new Player(name: "Player 4", number: 4, auto: true);

  List<CardModel> jogadas = [];
  List<int> victorys = [], rounds = [];

  CardModel? vira, winner;
  int vez = 1, mao = 1, eqp1 = 0, eqp2 = 0, vale = 1;
  bool visible = false;

  void _checkVictory() async {
    if(jogadas.length == 4){

      CardModel? win = Dealer.checkWinTruco(jogadas);

      setState(() { winner = win; });

      await Future.delayed(Duration(seconds: 1));
      
      var vict = win?.player ?? 0;
      
      if(vict > 0){ vict = vict % 2 == 0 ? 2 : 1; }

      setState(() {
        jogadas.clear();
        victorys.add(vict);
        vez = win?.player ?? vez;
        mao = 1;
      });

      print(victorys);

      var finish = Dealer.checkRounds(victorys);

      if(finish != null){
        setState(() {
          rounds.add(finish);
          if(finish == 1) eqp1 += vale;
          if(finish == 2) eqp2 += vale;
        });
        
        _distribuition();
      }

    }else{
      setState(() {
        vez = vez < 4 ? vez + 1 : 1;
        mao = mao < 3 ? mao + 1 : 1;
      });
    }

    _randomCardPlay();
  }

  void _distribuition() async {
    var cards = Dealer.dealerDeck(13);
    var tmpVira = CardModel(
      value: cards.last.value, 
      naipe: cards.last.naipe,
    );

    setState(() {
      
      mao = 1;
      vale = 1;
      vira = tmpVira;
      jogadas.clear();
      victorys.clear();

      player1.setCards(cards.getRange(0, 3).toList(), tmpVira);
      player2.setCards(cards.getRange(3, 6).toList(), tmpVira);
      player3.setCards(cards.getRange(6, 9).toList(), tmpVira);
      player4.setCards(cards.getRange(9, 12).toList(), tmpVira);

      if(eqp1 >= 12 || eqp2 >= 12){
        eqp1 = 0;
        eqp2 = 0;
      }
      
    });

    Future.delayed(Duration(seconds: 1), (){
      setState(() => visible = true);
    });

  }

  void _onClickCard(CardModel card) {

    if(card.player == vez && visible){

      setState(() {

        jogadas.add(card);

        if(card.player == 1){
          player1.removeCard(card);
        }else 
        if(card.player == 2){
          player2.removeCard(card);
        }else 
        if(card.player == 3){
          player3.removeCard(card);
        }else 
        if(card.player == 4){
          player4.removeCard(card);
        }
      });

      Future.delayed(Duration(milliseconds: 800), (){
        _checkVictory();
      });
      
    }

  }

  void _onClickTruco(Player play){
    var name = vale == 1 
      ? "Truco" : vale == 3 
      ? "Seis" : vale == 6 
      ? "Nove" 
      : "Doze";
    
    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (context) {
        return SimpleDialog(
          backgroundColor: Colors.transparent,
          title: CircleAvatar(
            backgroundColor: Colors.blue,
            radius: 45.0,
            child: Icon(
              Icons.bolt, 
              size: 50, 
              color: Colors.white
            )
          ),
          children: [
            Container(
              margin: EdgeInsets.only(top: 10, bottom: 20),
              child: Text("!! ${play.name} Pediu $name !!", style: TextStyle(
                fontSize: 40.0,
                fontWeight: FontWeight.bold,
                color: Colors.white
              )),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(10),
                    fixedSize: Size(150, 40),
                  ),
                  child: Text("Aceitar", style: TextStyle(
                    fontSize: 20.0
                  )),
                  onPressed: (){
                    Navigator.pop(context);
                    setState(() {
                      vale = vale == 1 ? 3 : vale + 3;
                    });
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                    padding: EdgeInsets.all(10),
                    fixedSize: Size(150, 40)
                  ),
                  child: Text("Correr", style: TextStyle(
                    fontSize: 20.0
                  )),
                  onPressed: (){},
                )
              ],
            )
          ],
        );
      }
    );
  }

  void _randomCardPlay(){

    if(vez == 1 && player1.auto){
      _onClickCard(player1.randomCard());
    }else 
    if(vez == 2 && player2.auto){
      _onClickCard(player2.randomCard());
    }else 
    if(vez == 3 && player2.auto){
      _onClickCard(player3.randomCard());
    }else 
    if(vez == 4 && player4.auto){
      _onClickCard(player4.randomCard());
    }
  }

  @override
  void initState() {
    super.initState();
    _distribuition();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var maoOnze = visible && eqp1 != 11 && eqp2 != 11;

    return Scaffold(
      backgroundColor: Colors.green[600],
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                alignment: AlignmentDirectional.center,
                children: [
                  Positioned(
                    top: 10,
                    child: PlayerTruco(
                      vez: vez == 3,
                      player: player3,
                      visible: false,
                    )
                  ),
                  Positioned(
                    left: 10,
                    child: PlayerTruco(
                      rotate: 1,
                      vez: vez == 2,
                      player: player2,
                      visible: false,
                    )
                  ), 
                  Positioned(
                    right: 10,
                    child: PlayerTruco(
                      rotate: 3,
                      vez: vez == 4,
                      player: player4,
                      visible: false,
                    )
                  ), 
                  Positioned(
                    bottom: 10,
                    child: PlayerTruco(
                      vez: vez == 1,
                      player: player1,
                      visible: maoOnze,
                      onTapCard: _onClickCard,
                      onTapTruco: _onClickTruco,
                    )
                  ),
                  ...jogadas.map((jogada) {
                    return TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 250),
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      builder: (context, value, child) {
                        var rotate = 0;
                        if(jogada.player == 2) rotate = 1;
                        if(jogada.player == 4) rotate = 3;

                        return Positioned(
                          bottom: jogada.player == 1 ? value : null,
                          left: jogada.player == 2 ? value : null,
                          top: jogada.player == 3 ? value : null,
                          right: jogada.player == 4 ? value : null,
                          child: RotatedBox(
                            quarterTurns: rotate,
                            child: CardGame(
                              mark: jogada.uui == winner?.uui,
                              card: jogada,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList()
                ],
              ),
            ),
            Container(
              width: 280,
              color: Colors.green[800],
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: [
                  CardGame(
                    card: vira, 
                    visible: visible,
                    margin: EdgeInsets.only(top: 10, bottom: 20),
                  ),
                  Divider(color: Colors.white),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.all(10),
                      children: [
                        Card(
                          color: player1.color,
                          child: ListTile(
                            title: Text("${player1.name}", 
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14
                              )
                            ),
                            subtitle: Text("${player3.name}", 
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14
                              )
                            ),
                            trailing: Text("$eqp1", style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                            )),
                          ),
                        ),
                        Card(
                          color: player2.color,
                          child: ListTile(
                            title: Text("${player2.name}", 
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14
                              )
                            ),
                            subtitle: Text("${player4.name}", 
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14
                              )
                            ),
                            trailing: Text("$eqp2", style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                            )),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Divider(color: Colors.white),
                        const SizedBox(height: 10),
                        ListTile(
                          title: Text("Valendo", 
                            style: TextStyle(
                              color: Colors.white,
                            )
                          ),
                          trailing: Text("$vale Ponto${vale > 1 ? "s": ""}", style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                          )),
                        ),
                        ListTile(
                          title: Text("Rodadas", 
                            style: TextStyle(color: Colors.white)
                          ),
                          trailing: SizedBox(
                            width: 60,
                            child: _buildBulletsVictory()
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    child: Text("SAIR DO JOGO", style: TextStyle(
                      color: Colors.white
                    )),
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(size.width * 0.3, 50),
                      primary: Colors.red,
                    ),
                    onPressed: (){
                      Navigator.of(context).pop();
                    }, 
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletsVictory(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: List.generate(3, (i){
        var icon = Icons.circle_outlined;
        var color = Colors.white;

        if(victorys.length > i && victorys[i] == 1){
          icon = Icons.circle;
          color = player1.color;
        }else 
        if(victorys.length > i && victorys[i] == 2){
          icon = Icons.circle;
          color = player2.color;
        }
        
        return Icon(icon, color: color, size: 20);
      }),
    );
  }



}