import 'package:flutter/material.dart';
import 'package:flutter_truco/components/card_game.dart';
import 'package:flutter_truco/io/message.dart';
import 'package:flutter_truco/io/server.dart';
import 'package:flutter_truco/models/card.dart';
import 'package:flutter_truco/models/mesa.dart';
import 'package:flutter_truco/models/player.dart';
import 'package:flutter_truco/utils/dealer.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DumbGame extends StatefulWidget {
  const DumbGame({ Key? key }) : super(key: key);
  @override
  _DumbGameState createState() => _DumbGameState();
}

class _DumbGameState extends State<DumbGame> {

  MesaModel mesa = MesaModel();

  List<Player> players = [], winners = [];
  List<CardModel> deck = [], jogadas = [];

  Server? server;
  String? host;

  Player? burro, winner;

  void _sendBroadcastMesa([bool delay = false]) async {
    
    if(delay) await Future.delayed(Duration(seconds: 2));

    server?.broadcast(Message(
      type: "mesa", 
      data: mesa.toJson()
    ));
  }

  void _distribuitionDeck() async {
      var tmpDeck = Dealer.surfleDeck();
      
      for(var i=0; i<players.length; i++){
        var pos = i*3;
        var cards = tmpDeck.getRange(pos, pos + 3).toList();
        
        setState(() {
          jogadas.clear();
          players[i].setCards(cards);
          tmpDeck.removeRange(pos, pos + 3);
          deck = tmpDeck;
        });
        
        server?.sendIndex(i, Message(
          type: "cards", 
          data: listCardToJson(players[i].cards)
        ));
      }

      setState(() {
        mesa.burro = null;
        mesa.naipe = null;
        mesa.running = true;
        mesa.deck = deck.length;
        mesa.vez = players[0].number;
      });

      _sendBroadcastMesa(true);
  }

  void _checkWinRound(){

    var emptys = players.where((p) => p.cards.isNotEmpty).toList();
    if(emptys.length == 1){
      setState(() {
        mesa.burro = emptys.first.number;
        burro = emptys.first;
      });
    }else
    if(jogadas.length == players.length){
      var win = Dealer.checkWinDumb(jogadas);
      setState(() {
        mesa.vez = win.player;
        mesa.naipe = null;
        jogadas.clear();
      });
    }else{
      var i = emptys.indexWhere((p) => p.number == mesa.vez);
      var next = i < emptys.length - 1 ? emptys[i+1] : emptys.first;
      setState(() { 
        mesa.vez = next.number; 
      });
    }

    _sendBroadcastMesa();
  }

  void _createServer() async {
    server = Server(
      onData: _onDataReceive,
      onError: (error){
        Fluttertoast.showToast(
          msg: error,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER
        );
      }
    );

    await server?.start();

    setState(() => host = server?.server?.address.host);
  }

  void _onDataReceive(Message message){
    print(message.toJson());

    switch (message.type) {
      case "connect":
        var player = Player.fromJson(message.data);
        setState(() {
          players.add(player);
        });
        break;
      case "disconect":
        var player = Player.fromJson(message.data);
        setState(() {
          players.removeWhere((p) => p.number == player.number);
        });
        if(players.length == 1){
          _restartGame();
        }
        break;
      case "card":
        var card = CardModel.fromJson(message.data);
        var i = players.indexWhere((p) => p.number == card.player);
        if(i > -1){
          setState(() {
            jogadas.add(card);
            players[i].removeCard(card);
            mesa.naipe = card.naipe;
          });
          Future.delayed(Duration(milliseconds: 800), (){
            _checkWinRound();
          });
        }
        break;
      case "deck":
        if(deck.isNotEmpty){
          var card = deck[0];
          var play = Player.fromJson(message.data);
          var i = players.indexWhere((p) => p.number == play.number);
          if(i > -1){
            setState(() {
              players[i].addCard(card);
              deck.removeAt(0);
            });
            server?.sendIndex(i, Message(
              type: "deck", 
              data: card.toJson()
            ));
          }
          if(deck.isEmpty){
            setState(() => mesa.deck = 0);
            _sendBroadcastMesa(true);
          }
        }
        break;
      case "table":
        if(jogadas.isNotEmpty){
          var play = Player.fromJson(message.data);
          var i = players.indexWhere((p) => p.number == play.number);
          if(i > -1){
            setState(() {
              players[i].addCards(jogadas);
              jogadas.clear();
              mesa.naipe = null;
            });
            server?.sendIndex(i, Message(
              type: "table", 
              data: listCardToJson(players[i].cards)
            ));
          }
        }
        break;
      default:
        break;
    }
  }
  
  void _restartGame(){
    setState(() {
      mesa = MesaModel();
      jogadas.clear();
      deck.clear();
    });

    server?.broadcast(Message(
      type: "disconect", 
      data: null
    ));

  }
  
  @override
  void initState() {
    super.initState();
     _createServer();
  }

  @override
  void dispose() {
    if(server != null){
      server?.stop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var notEmptys = mesa.running 
      ? players.where((e) => e.cards.isNotEmpty) 
      : players;

    return Scaffold(
      backgroundColor: Colors.green[600],
      body: SafeArea(
        child: Row(
          children: [
            Container(
              width: size.width - 250,
              child: Stack(
                fit: StackFit.expand,
                alignment: AlignmentDirectional.center,
                children: [
                  if(!mesa.running) Positioned(
                    top: 100,
                    child: Column(
                      children: [
                        Text("Aguardando Jogadores",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white,fontSize: 16)
                        ),
                        const SizedBox(height: 10),
                        Text("Servidor $host",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white,fontSize: 16)
                        ),
                      ],
                    ),
                  ),

                  ...jogadas.map((jogada) {
                    var index = jogadas.indexOf(jogada);
                    return TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 50, end: size.height / 2),
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      builder: (context, value, child) => Positioned(
                        bottom: value,
                        left: (index+1) * 120,
                        child: CardGame(
                          card: jogada, 
                          width: 100
                        ),
                      ));
                  }).toList(),             
                  
                  Positioned(
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      width: size.width - 250,
                      child: Wrap(
                        spacing: 10.0,
                        runSpacing: 10.0,
                        alignment: WrapAlignment.center,
                        children: notEmptys.map((p) => GestureDetector(
                          child: Column(
                            children: [
                              Text("${p.name} (${p.cards.length})", style: TextStyle(
                                color: Colors.white
                              )),
                              CircleAvatar(
                                maxRadius: 40,
                                backgroundColor: p.number == mesa.vez ? Colors.yellow : null,
                                child: Image.asset("${p.asset}", 
                                  fit: BoxFit.contain
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ),
                    )
                  ),
                  
                ],
              ),
            ),
            Container(
              width: 250,
              color: Colors.green[800],
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: [
                  CardGame(
                    width: 130,
                    disabled: deck.isEmpty,
                    margin: EdgeInsets.only(top: 10, bottom: 30),
                  ),
                  
                  Divider(color: Colors.white),
                  
                  Expanded(
                    child: ListView(
                      children: [
                        ListTile(
                          title: Text("Servidor", 
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold
                            )
                          ),
                          subtitle: server != null 
                            ? Text("$host", style: TextStyle(
                              color: Colors.white,
                            )) : null,
                          trailing: Icon(
                            Icons.circle, 
                            size: 20,
                            color: mesa.running ? Colors.yellow : Colors.red,
                          ),
                        ),
                        ListTile(
                          title: Text("Baralho", 
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold
                            )
                          ),
                          trailing: Text("${deck.length}", style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                          )),
                        ),
                      ],
                    ),
                  ),
                  
                  if(players.length > 1) ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      fixedSize: Size(200, 40),
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 16
                      ),
                    ),
                    child: Text(mesa.running 
                      ? "Reiniciar Partida" 
                      : "Iniciar Partida"
                    ),
                    onPressed: _distribuitionDeck, 
                  ),

                  if(!mesa.running) ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      fixedSize: Size(200, 40),
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 18
                      ),
                    ),
                    child: Text("Sair"),
                    onPressed: (){
                      Navigator.pop(context);
                    }, 
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

}