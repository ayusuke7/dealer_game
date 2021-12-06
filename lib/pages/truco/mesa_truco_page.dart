import 'dart:async';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_truco/components/card_game.dart';
import 'package:flutter_truco/components/custom_avatar.dart';
import 'package:flutter_truco/components/custom_button.dart';
import 'package:flutter_truco/io/message.dart';
import 'package:flutter_truco/io/server.dart';
import 'package:flutter_truco/models/card.dart';
import 'package:flutter_truco/models/mesa.dart';
import 'package:flutter_truco/models/player.dart';
import 'package:flutter_truco/utils/dealer.dart';
import 'package:flutter_truco/utils/helper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:network_info_plus/network_info_plus.dart';

class GameTruco extends StatefulWidget {
  const GameTruco({Key? key}) : super(key: key);

  @override
  _GameTrucoState createState() => _GameTrucoState();
}

class _GameTrucoState extends State<GameTruco> {
  final network = NetworkInfo();
  final edit = TextEditingController();

  MesaModel mesa = MesaModel(vez: 0);

  List<Player> players = [];
  List<CardModel> jogadas = [];
  List<int> victorys = [], rounds = [];

  Server? server;
  String? host;

  CardModel? vira, winner;
  int eqp1 = 0, eqp2 = 0, vale = 1, ini = 0;
  bool visible = false, playing = false;

  void _startGame(){
    setState(() {
      for (var i = 0; i < players.length; i++) {
        players[i].number = i;
      }
    });

    _distribuition();
  }

  void _sendBroadcastMesa({bool delay = false}) async {
    if (delay) await Future.delayed(Duration(seconds: 2));

    mesa.jogadas = jogadas.length;

    server?.broadcast(Message(type: "mesa", data: mesa.toJson()));
  }

  void _executePlayerOrBot({bool delay = false}) {
    var vez = mesa.vez;
    if (vez != null && players[vez].auto) {
      var card = players[vez].randomCard();
      setState(() {
        jogadas.add(card);
        players[card.player].removeCard(card);
      });

      _checkVictory();
    } else {
      _sendBroadcastMesa(delay: delay);
    }
  }

  void _sendMessageTruco(Player player) {
    var target1 = 0, target2 = 2;

    if (player.number == 0 || player.number == 2) {
      target1 = 1;
      target2 = 3;
    }

    var message = Message(type: "truco", data: "teste de string");

    if (!players[target1].auto) server?.sendIndex(target1, message);

    if (!players[target2].auto) server?.sendIndex(target2, message);

    _showMessageTruco(player);
  }

  void _checkVictory() async {
    await Future.delayed(Duration(milliseconds: 500));

    if (jogadas.length == 4) {
     
      CardModel? win = Dealer.checkWinTruco(jogadas);

      print("winner => ${win?.toJson()}");

      setState(() { winner = win; });

      await Future.delayed(Duration(seconds: 1));

      var equipe = win == null ? 0 : win.player % 2 + 1;

      setState(() {
        jogadas.clear();
        victorys.add(equipe);
        mesa.vez = win?.player ?? mesa.vez;
        mesa.mao = 1;
      });

      print("victorys => $victorys");

      _checkFinishRounds();
    } else {
       setState(() {
        mesa.vez = mesa.vez == 3 ? 0 : mesa.vez! + 1;
        mesa.mao = mesa.mao == 3 ? 1 : mesa.mao! + 1;
      });
      _executePlayerOrBot();
    }

    print("next => ${mesa.vez}");
  }

  void _checkFinishRounds() {
    var finish = Dealer.checkRounds(victorys);
    print("finish => $finish");

    if (finish != null) {
      var vez = ini == 3 ? 0 : ini + 1;
      setState(() {
        rounds.add(finish);
        ini = vez;
        mesa.vez = vez;

        if (finish == 1) eqp1 += vale;
        if (finish == 2) eqp2 += vale;
      });

      if(eqp1 < 12 && eqp1 < 12){
        _distribuition();
      }

    } else {
      _executePlayerOrBot();
    }
  }

  void _distribuition() async {
    var tmpDeck = Dealer.dealerDeck(13);
    var tmpVira = CardModel(
      value: tmpDeck.last.value,
      naipe: tmpDeck.last.naipe,
    );

    for (var i = 0; i < players.length; i++) {
      var pos = i * 3;
      var cards = tmpDeck.getRange(pos, pos + 3).toList();

      setState(() {
        players[i].setCards(cards, vira: tmpVira);
      });

      if (!players[i].auto) {
        var data = List.of(players[i].cards);
        /* Flip all card with black round */
        if(eqp1 == 11 && eqp2 == 11) {
          data.forEach((c) => c.flip = true);
        }
        var host = players[i].host;
        server?.sendTo("$host", Message(
          type: "cards", 
          data: listCardToJson(data)
        ));
      }
    }

    setState(() {
      jogadas.clear();
      victorys.clear();

      vale = 1;
      vira = tmpVira;

      mesa.mao = 1;
      mesa.running = true;

      if (eqp1 >= 12 || eqp2 >= 12) {
        eqp1 = 0;
        eqp2 = 0;
      }
    });

    _executePlayerOrBot(delay: true);
  }

  void _showMessageTruco(Player play) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return SimpleDialog(
            backgroundColor: Colors.transparent,
            title: CircleAvatar(
                backgroundColor: Colors.blue,
                radius: 45.0,
                child: Icon(Icons.bolt, size: 50, color: Colors.white)),
            children: [
              Text("${play.name} pediu",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              Text("${mesa.labelValor}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ],
          );
        });
  }

  void _createServer([String? ip]) async {
    var ipServer = ip ?? await network.getWifiIP();

    if (ipServer != null) {
      server = Server(
        host: ipServer,
        port: 4545,
        onData: _onDataReceive,
        onError: (error) {
          Fluttertoast.showToast(
            msg: error,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER);
        });
      await server?.start();
      setState(() {
        host = server?.server?.address.host;
      });
    } else {
      _showInputIpServer();
    }
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

  void _onDataReceive(Message message) {
    print(message.toJson());

    switch (message.type) {
      case "connect":
        if (players.length < 4) {
          var player = Player.fromJson(message.data);
          player.host = message.host;
          setState(() {
            players.add(player);
          });
        }
        break;
      case "disconect":
        var player = Player.fromJson(message.data);
        var i = players.indexWhere((p) => p.name == player.name);
        if(i > -1){
          setState(() {
            players[i].auto = true;
            players[i].name = null;
          });
        }
        break;
      case "card":
        var card = CardModel.fromJson(message.data);
        setState(() {
          jogadas.add(card);
          players[card.player].removeCard(card);
        });
        _checkVictory();
        break;
      case "truco":
        var player = Player.fromJson(message.data);
        _sendMessageTruco(player);
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
    if (server != null) {
      server?.stop();
    }
    edit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var style = TextStyle(
      fontSize: 16, 
      color: Colors.white, 
      fontWeight: FontWeight.bold
    );
    return Scaffold(
      backgroundColor: Colors.green[600],
      body: SafeArea(
        child: mesa.running
          ? Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Stack(
                    fit: StackFit.expand,
                    alignment: AlignmentDirectional.center,
                    children: [
                      for (var i = 0; i < players.length; i++)
                        Positioned(
                          bottom: i == 0 ? 10 : null,
                          left: i == 1 ? 10 : null,
                          top: i == 2 ? 10 : null,
                          right: i == 3 ? 10 : null,
                          child: CustomAvatar(
                            name: "${players[i].getName} (${players[i].cards.length})",
                            backgroundColor: mesa.vez == i ? Colors.yellow : null,
                            backgroundNameColor: players[i].color,
                            asset: Image.asset("${players[i].getAsset}"),
                          )
                        ),
                      
                      for (var i = 0; i < jogadas.length; i++)
                        TweenAnimationBuilder<double>(
                          curve: Curves.easeInOut,
                          duration: Duration(milliseconds: 500),
                          tween: Tween<double>(begin: 0, end: 200),
                          builder: (context, value, child) {
                            var jogada = jogadas[i];
                            return Positioned(
                              bottom: jogada.player == 0 ? value : null,
                              left: jogada.player == 1 ? value : null,
                              top: jogada.player == 2 ? value : null,
                              right: jogada.player == 3 ? value : null,
                              child: RotatedBox(
                                quarterTurns: jogada.player,
                                child: CardGame(
                                  mark: jogada.uui == winner?.uui,
                                  card: jogada,
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  )
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.green[800],
                    padding: EdgeInsets.all(10.0),
                    child: ListView(
                      children: [
                        CardGame(
                          card: vira,
                          onTap: _showInputIpServer,
                          margin: EdgeInsets.only(top: 10, bottom: 20),
                        ),
                        ListTile(
                          title: Text("Servidor", style: style),
                          subtitle: server != null
                              ? Text("$host", style: TextStyle(color: Colors.white))
                              : null,
                          trailing: Icon(Icons.circle,
                              size: 20,
                              color: mesa.running ? Colors.blue : Colors.yellow),
                        ),
                        const SizedBox(height: 10),
                        ListTile(
                          title: Text("Valendo", style: TextStyle(
                            color: Colors.white,
                          )),
                          trailing: Text("$vale Ponto${vale > 1 ? "s" : ""}",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold
                            )
                          ),
                        ),
                        _buildBulletsVictory(),
                        const SizedBox(height: 10),
                        _buildPlacarPlayers(),
                        const SizedBox(height: 10),
                        
                        CustomButton(
                          disable: playing,
                          icon: Icons.exit_to_app,
                          label: "Sair",
                          backgroundColor: Colors.red,
                          margin: EdgeInsets.only(bottom: 5.0),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ) 
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                ListTile(
                  title: Text("Aguardando Jogadores", 
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontFamily: "Gameria",
                      color: Colors.yellow
                    )
                  ),
                  subtitle: server != null ? Text("Servidor: $host",
                    textAlign: TextAlign.center, 
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16
                    )
                  ) : null,
                ),

                Container(
                  margin: const EdgeInsets.all(30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [

                      for(var i=0; i<4; i++)
                        i < players.length
                        ? CustomAvatar(
                            onTap: (){
                              if(players.length == 4){
                                setState(() {
                                  var tmp = players.removeAt(i);
                                  var index = i < 3 ? i+1 : 0;
                                  players.insert(index, tmp);
                                });
                              }
                            },
                            name: "${players[i].getName}",
                            backgroundNameColor: i % 2 == 0 ? Colors.red : Colors.blue,
                            asset: Image.asset("${players[i].getAsset}"),
                          )
                        : CustomAvatar(
                            asset: Icon(Icons.add, color: Colors.white),
                            onTap: (){
                              setState(() {
                                players.add(new Player(
                                  number: players.length,
                                  auto: true
                                ));
                              });
                            },
                          ),
                    ],
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    
                    CustomButton(
                      disable: players.length != 4,
                      icon: Icons.play_circle,
                      label: "Iniciar Partida",
                      size: Size(180, 40),
                      backgroundColor: Colors.blue,
                      onPressed: _startGame,
                    ),
                    
                    const SizedBox(width: 15),

                    CustomButton(
                      disable: players.length == 4,
                      icon: Icons.add_circle,
                      label: "Adicionar BOT",
                      size: Size(180, 40),
                      backgroundColor: Colors.cyan,
                      onPressed: (){
                        setState(() {
                          players.add(new Player(
                            number: players.length,
                            auto: true
                          ));
                        });
                      },
                    ),
                  
                  ],
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildBulletsVictory() {
    return ListTile(
      title: Text("Rodadas", style: TextStyle(color: Colors.white)),
      trailing: SizedBox(
        width: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: List.generate(3, (i) {
            var icon = Icons.circle_outlined;
            var color = Colors.white;

            if (victorys.length > i && victorys[i] == 1) {
              icon = Icons.circle;
              color = players[0].color;
            } else if (victorys.length > i && victorys[i] == 2) {
              icon = Icons.circle;
              color = players[1].color;
            }

            return Icon(icon, color: color, size: 20);
          }),
        ),
      ));
  }

  Widget _buildPlacarPlayers() {
    if (players.length < 4) return SizedBox();

    return Column(
      children: [
        ListTile(
          title: Text("${players[0].getName}",
              style: TextStyle(color: Colors.white, fontSize: 14)),
          subtitle: Text("${players[2].getName}",
              style: TextStyle(color: Colors.white, fontSize: 14)),
          trailing: Text("$eqp1",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ),
        ListTile(
          title: Text("${players[1].getName}",
              style: TextStyle(color: Colors.white, fontSize: 14)),
          subtitle: Text("${players[3].getName}",
              style: TextStyle(color: Colors.white, fontSize: 14)),
          trailing: Text("$eqp2",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

}
