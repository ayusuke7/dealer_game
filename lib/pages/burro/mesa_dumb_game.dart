import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_truco/commons/strings.dart';
import 'package:flutter_truco/components/card_game.dart';
import 'package:flutter_truco/io/message.dart';
import 'package:flutter_truco/io/server.dart';
import 'package:flutter_truco/models/card.dart';
import 'package:flutter_truco/models/mesa.dart';
import 'package:flutter_truco/models/player.dart';
import 'package:flutter_truco/utils/dealer.dart';
import 'package:flutter_truco/utils/helper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:network_info_plus/network_info_plus.dart';

class MesaDumbGame extends StatefulWidget {
  const MesaDumbGame({ Key? key }) : super(key: key);
  @override
  _MesaDumbGameState createState() => _MesaDumbGameState();
}

class _MesaDumbGameState extends State<MesaDumbGame> {
  
  final edit = TextEditingController();
  final network = NetworkInfo();

  MesaModel mesa = MesaModel();

  List<CardModel> deck = [], jogadas = [];
  List<Player> players = [];
  List<String> logs = [];

  Server? server;
  String? host;
  
  int ini = 0;
  bool win = false;

  void _createLog(String log){
    print(log);
    var time = DateTime.now().toString().substring(11, 19);
    logs.insert(0, "$time => $log");
    if(logs.length > 50) logs.removeAt(50);
  }
  
  void _sendBroadcastMesa([bool delay = false]) async {
    
    if(delay) await Future.delayed(Duration(seconds: 2));

    mesa.jogadas = jogadas.length;
    var message = Message(type: "mesa",  data: mesa.toJson());

    server?.broadcast(message);
    _createLog(message.toJson().toString());
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
        win = false;
      });

      _sendBroadcastMesa(true);
  }

  void _checkWinPartida(int index){
    if(!win && players[index].cards.isEmpty){
      setState(() {
        players[index].placar.addWinner();
        win = true;
      });
    }
  }

  void _checkWinRound(){
    
    var playComCartas = players.where((p){
      return p.cards.isNotEmpty;
    }).toList();

    if(playComCartas.length == 1){
      var next = ini == players.length - 1 ? 0 : ini + 1;
      var burro = playComCartas.first;
      setState(() {
        ini = next;
        mesa.burro = burro.number;
        burro.placar.addLooser();
      });
    } else {
      var jogComCartas = Dealer.filterJogadas(jogadas, playComCartas);
      if(playComCartas.length == jogComCartas.length){
        var win = Dealer.checkWinDumb(jogComCartas);
        setState(() {
          mesa.vez = win.player;
          mesa.naipe = null;
          jogadas.clear();
        });
        _createLog("Jogadas: ${listCardToJson(jogComCartas)}");
      }else{
        var i = players.indexWhere((p) => p.number == mesa.vez);
        var nextPlayer = Dealer.nextPlayerComCartas(players, i);
        setState(() {
          mesa.vez = nextPlayer.number; 
        });
      }
    }
    
    _sendBroadcastMesa();
  }

  void _showInputIpServer() async {
    final text = await showTextInputDialog(
      context: context,
      title: "IP do Servidor!",
      message: "Não foi possivel configurar o IP do Servidor!\nPor favor, Informe manualmente!",
      textFields: [
        DialogTextField(
          hintText: "Ex: 192.169.1.2", 
          keyboardType: TextInputType.number,
          validator: (value){
            var valid = Helper.isIpv4(value);
            return valid ? null : "IP Inválido";
          }
        ),
      ],
    );

    if(text != null && text.isNotEmpty){
      _createServer(text.first);
    }
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

  void _showLogPartida(){
    showDialog(
      context: context, 
      builder: (ctx){
        return AlertDialog(
          scrollable: true,
          title: Text("Logs das Partidas"),
          content: Container(
            width: MediaQuery.of(context).size.width / 2,
            child: Column(
              children: logs.map((log) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: Text("$log"),
              )).toList(),
            ),
          ),
        );
      }
    );
  }

  void _exitServer() async {
    if(server != null){
      server?.broadcast(Message(
        type: "disconect", 
        data: null
      ));
      await server?.stop();
    }
    
    Navigator.pop(context);
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
    _createLog(message.toJson().toString());

    switch (message.type) {
      case "connect":
        if(!mesa.running){
          var player = Player.fromJson(message.data);
          setState(() {
            players.add(player);
          });
        }
        break;
      case "disconect":
        if(mounted){
          var player = Player.fromJson(message.data);
          setState(() {
            players.removeWhere((p) => p.number == player.number);
          });
        }
        break;
      case "card":
        var card = CardModel.fromJson(message.data);
        var i = players.indexWhere((p) => p.number == card.player);
        if(i > -1){
          setState(() {
            jogadas.add(card);
            mesa.naipe = card.naipe;
            players[i].removeCard(card);
          });
          _checkWinPartida(i);
          
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
      case "restart":
        _distribuitionDeck();
        break;
      default:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _createServer();
  }

  @override
  void dispose() {
    edit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var widthOpt = size.width * 0.3;

    var style = TextStyle(
      fontSize: 16,
      color: Colors.white,
      fontWeight: FontWeight.bold
    );

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
                    top: size.height / 2 - 50,
                    child: Text("Aguardando mais de\n2 Jogadores",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white,fontSize: 16)
                    ),
                  ),

                  for (var i = 0; i < jogadas.length; i++)
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: 50, 
                        end: size.height / 2
                      ),
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      builder: (context, value, child) => Positioned(
                        bottom: value,
                        left: (i+1) * 120,
                        child: CardGame(card: jogadas[i]),
                      )),
                  
                  Positioned(
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      width: size.width - 250,
                      child: Wrap(
                        spacing: 10.0,
                        runSpacing: 10.0,
                        alignment: WrapAlignment.center,
                        children: players.map((p) {
                          var overlay, select;
                          if(mesa.running && p.cards.isEmpty){
                            overlay = Container(
                              width: 65, height: 65, 
                              decoration: BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                                backgroundBlendMode: BlendMode.saturation
                              ),
                            );
                          }
                          if(p.number == mesa.vez){
                            select = Colors.yellow;
                          }
                          return Column(
                            children: [
                              Text("${p.name} (${p.cards.length})",
                                style: TextStyle(
                                  color: Colors.white,
                                )
                              ),
                              CircleAvatar(
                                maxRadius: 35,
                                child: overlay,
                                backgroundColor: select,
                                backgroundImage: AssetImage("${p.asset}"),
                              ),
                            ],
                          );
                        }).toList(),
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
                          ListTile(
                            title: Text("Servidor", style: style),
                            subtitle: server != null 
                              ? Text("$host", style: TextStyle(
                                color: Colors.white,
                              )) : null,
                            trailing: Icon(
                              Icons.circle, 
                              size: 20,
                              color: mesa.running ? Colors.blue : Colors.yellow,
                            ),
                            onTap: _showLogPartida,
                          ),
                          Divider(color: Colors.white),
                          ListTile(
                            title: Text("Regras", style: style),
                            trailing: Icon(Icons.info_outline, color: Colors.white),
                            onTap: _showDialogRegras,
                          ),
                          ListTile(
                            title: Text("Baralho", style: style),
                            trailing: Text(mesa.running ? "${deck.length}" : "40", 
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold
                              )
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 15.0),
                            color: Colors.white.withOpacity(.3),
                            child: Column(
                              children: [
                                 _buildLineRow("Jogad", "Venced", "Burro", border: false),
                                for (var player in players) 
                                  _buildLineRow(
                                    "${player.name}", 
                                    "${player.placar.winner}",
                                    "${player.placar.looser}",
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    players.length > 1 
                    ? ElevatedButton(
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
                        onPressed: _distribuitionDeck, 
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                          fixedSize: Size(widthOpt, 40),
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 16
                          ),
                        ),
                        child: Text("Sair da Partida"),
                        onPressed: _exitServer, 
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

  Widget _buildLineRow(String col1, String col2, String col3, {
    bool border = true
  }){
    var style = TextStyle(
      fontSize: 16,
      color: Colors.white,
      fontWeight: FontWeight.bold
    );
    return  Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10.0
      ),
      decoration: border ? BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white))
      ) : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text("$col1", style: style, 
            textAlign: TextAlign.center,
            softWrap: false,
          )),
          Expanded(child: Text("$col2", style: style, 
            textAlign: TextAlign.center,
            softWrap: false,
          )),
          Expanded(child: Text("$col3", style: style, 
            textAlign: TextAlign.center,
            softWrap: false,
          )),
        ],
      ),
    );
  }

}