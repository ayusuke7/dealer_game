import 'package:flutter/material.dart';
import 'package:flutter_truco/commons/strings.dart';
import 'package:flutter_truco/components/card_game.dart';
import 'package:flutter_truco/io/message.dart';
import 'package:flutter_truco/io/server.dart';
import 'package:flutter_truco/models/card.dart';
import 'package:flutter_truco/models/mesa.dart';
import 'package:flutter_truco/models/player.dart';
import 'package:flutter_truco/utils/dealer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:network_info_plus/network_info_plus.dart';

class MesaDumbGame extends StatefulWidget {
  const MesaDumbGame({ Key? key }) : super(key: key);
  @override
  _MesaDumbGameState createState() => _MesaDumbGameState();
}

class _MesaDumbGameState extends State<MesaDumbGame> {
  final network = NetworkInfo();
  TextEditingController edit = TextEditingController();

  MesaModel mesa = MesaModel();

  List<Player> players = [], winners = [];
  List<CardModel> deck = [], jogadas = [];

  Server? server;
  String? host;

  int ini = 0;
  
  void _sendBroadcastMesa([bool delay = false]) async {
    
    if(delay) await Future.delayed(Duration(seconds: 2));

    mesa.jogadas = jogadas.length;

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
        mesa.vez = players[ini].number;
      });

      _sendBroadcastMesa(true);
  }

  void _checkWinRound(){

    var notEmptys = players.where((p) => p.cards.isNotEmpty).toList();

    if(notEmptys.length == 1){
      setState(() {
        mesa.burro = notEmptys.first.number;
        ini = ini == players.length - 1 ? 0 : ini + 1;
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
      var i = notEmptys.indexWhere((p) => p.number == mesa.vez);
      var next = i < notEmptys.length - 1 ? notEmptys[i+1] : notEmptys.first;
      setState(() { 
        mesa.vez = next.number; 
      });
    }

    _sendBroadcastMesa();
  }

  void _createServer([String? ip]) async {
    
    var ipServer = ip ?? await network.getWifiIP();

    if(ipServer != null){
      server = Server(
        host: ipServer,
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
      setState(() {
        host = server?.server?.address.host;
      });
    }else{
      _showInputIpServer();
    }
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
          var tmp = List.of(jogadas);
          if(i > -1){
            setState(() {
              players[i].addCards(tmp);
              jogadas.clear();
              mesa.naipe = null;
              mesa.vez = play.number;
            });
            server?.sendIndex(i, Message(
              type: "table", 
              data: listCardToJson(tmp)
            ));
            _sendBroadcastMesa();
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
  
  void _showInputIpServer(){
    showDialog(
      barrierDismissible: false,
      context: context, 
      builder: (ctx){
        return SimpleDialog(
          contentPadding: EdgeInsets.all(20),
          children: [
            Text("Não foi possivel configurar o IP do Servidor!\nPor favor, Informe manualmente!",
              style: TextStyle(fontSize: 18, height: 1.4),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 20),
              child: TextFormField(
                controller: edit,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  focusColor: Colors.white,
                  filled: true,
                  hintText: "Ex: 192.169.1.2",
                  border: OutlineInputBorder()
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                fixedSize: Size(200, 60),
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 18
                ),
              ),
              child: Text("Iniciar Servidor"),
              onPressed: (){
                if(edit.text.isNotEmpty){
                  Navigator.of(ctx).pop();
                  _createServer(edit.text.trim());
                }
              }, 
            )
          ],
        );
      }
    );
  }

  void _showDialogRegras(){
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        contentPadding: EdgeInsets.all(20.0),
        title: Text("Regras", textAlign: TextAlign.center),
        children: BURRO_RULES.map((text) {
          return Text(text, style: TextStyle(
            fontSize: 16.0
          ));
        }).toList(),
      )
    );
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
    edit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var widthOpt = size.width * 0.3;

    var notEmptys = mesa.running 
      ? players.where((e) => e.cards.isNotEmpty) 
      : players;

    return Scaffold(
      backgroundColor: Colors.green[600],
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                alignment: AlignmentDirectional.center,
                children: [
                  if(!mesa.running) Positioned(
                    top: 100,
                    child: Text("Aguardando 2+ Jogadores",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white,fontSize: 16)
                    ),
                  ),

                  ..._buildListJogadas(size),             
                  
                  Positioned(
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      width: size.width - 250,
                      child: Wrap(
                        spacing: 10.0,
                        runSpacing: 10.0,
                        alignment: WrapAlignment.center,
                        children: notEmptys.map((p) => Column(
                          children: [
                            Text("${p.name} (${p.cards.length})", style: TextStyle(
                              color: Colors.white
                            )),
                            CircleAvatar(
                              maxRadius: 35,
                              backgroundColor: p.number == mesa.vez ? Colors.yellow : null,
                              child: Image.asset("${p.asset}", 
                                fit: BoxFit.contain
                              ),
                            ),
                          ],
                        )).toList(),
                      ),
                    )
                  ),
                  
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.green[800],
                padding: EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          TextButton.icon(
                            icon: Icon(Icons.info_outline), 
                            label: Text("Regras"),
                            style: TextButton.styleFrom(
                              primary: Colors.white
                            ),
                            onPressed: _showDialogRegras, 
                          ),
                          CardGame(
                            disabled: deck.isEmpty,
                            margin: EdgeInsets.only(top: 10, bottom: 20),
                          ),
                          Divider(color: Colors.white),
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
                              color: mesa.running ? Colors.blue : Colors.yellow,
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
                          Divider(color: Colors.white),
                          /* ...players.map((p) {
                            return ListTile(
                              title: Text(p.name, 
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                )
                              ),
                            );
                          }).toList() */
                          const SizedBox(height: 5.0),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        fixedSize: Size(widthOpt, 40),
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 16
                        ),
                      ),
                      child: Text(mesa.running 
                        ? "Reiniciar Partida" 
                        : "Iniciar Partida"
                      ),
                      onPressed: (){
                        if(players.length > 1){
                          _distribuitionDeck();
                        }
                      }, 
                    ),
                    const SizedBox(height: 5.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                        fixedSize: Size(widthOpt, 40),
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 16
                        ),
                      ),
                      child: Text("Sair da Partida"),
                      onPressed: (){
                        if(!mesa.running){
                          Navigator.pop(context);
                        }
                      }, 
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _buildListJogadas(Size size){
    return jogadas.map((jogada) {
      var index = jogadas.indexOf(jogada);
      return TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 50, end: size.height / 2),
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        builder: (context, value, child) => Positioned(
          bottom: value,
          left: (index+1) * 120,
          child: CardGame(card: jogada),
        ));
    }).toList();
  }

}