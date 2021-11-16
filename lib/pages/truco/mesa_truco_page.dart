import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_truco/components/card_game.dart';
import 'package:flutter_truco/components/player_truco.dart';
import 'package:flutter_truco/io/message.dart';
import 'package:flutter_truco/io/server.dart';
import 'package:flutter_truco/models/card.dart';
import 'package:flutter_truco/models/mesa.dart';
import 'package:flutter_truco/models/player.dart';
import 'package:flutter_truco/utils/dealer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:network_info_plus/network_info_plus.dart';

class GameTruco extends StatefulWidget {

  const GameTruco({ Key? key }) : super(key: key);

  @override
  _GameTrucoState createState() => _GameTrucoState();
}

class _GameTrucoState extends State<GameTruco> {
  final network = NetworkInfo();
  TextEditingController edit = TextEditingController();

  MesaModel mesa = MesaModel();
  
  List<Player> players = [];
  List<CardModel> jogadas = [];
  List<int> victorys = [], rounds = [];

  Server? server;
  String? host;

  CardModel? vira, winner;
  int vez = 1, mao = 1, eqp1 = 0, eqp2 = 0, vale = 1;
  bool visible = false;

  void _sendBroadcastMesa([bool delay = false]) async {
    
    if(delay) await Future.delayed(Duration(seconds: 2));

    mesa.jogadas = jogadas.length;

    server?.broadcast(Message(
      type: "mesa", 
      data: mesa.toJson()
    ));
  }

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
    var tmpDeck = Dealer.dealerDeck(13);
    
    var tmpVira = CardModel(
      value: tmpDeck.last.value, 
      naipe: tmpDeck.last.naipe,
    );

    for(var i=0; i<players.length; i++){

      var pos = i*3;
      var cards = tmpDeck.getRange(pos, pos + 3).toList();
      
      setState(() { players[i].setCards(cards); });

      if(!players[i].auto){
        server?.sendIndex(i, Message(
          type: "cards", 
          data: listCardToJson(players[i].cards)
        ));
      }
    }

    setState(() {
      
      mao = 1;
      vale = 1;
      vira = tmpVira;
      jogadas.clear();
      victorys.clear();

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
          players[0].removeCard(card);
        }else 
        if(card.player == 2){
          players[1].removeCard(card);
        }else 
        if(card.player == 3){
          players[2].removeCard(card);
        }else 
        if(card.player == 4){
          players[3].removeCard(card);
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

    if(vez == 1 && players[0].auto){
      _onClickCard(players[0].randomCard());
    }else 
    if(vez == 2 && players[1].auto){
      _onClickCard(players[1].randomCard());
    }else 
    if(vez == 3 && players[2].auto){
      _onClickCard(players[2].randomCard());
    }else 
    if(vez == 4 && players[3].auto){
      _onClickCard(players[3].randomCard());
    }
  }

  void _createServer([String? ip]) async {
    
    var ipServer = ip ?? await network.getWifiIP();

    if(ipServer != null){
      server = Server(
        host: ipServer,
        port: 4545,
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

  void _onDataReceive(Message message){
    print(message.toJson());

    switch (message.type) {
      case "connect":
        var player = Player.fromJson(message.data);
        setState(() {
          players.addAll([
            player,
            new Player(name: "BOT 2", number: 2, auto: true),
            new Player(name: "BOT 3", number: 3, auto: true),
            new Player(name: "BOT 4", number: 4, auto: true),
          ]);

        });
        break;
      case "disconect":
        var player = Player.fromJson(message.data);
        setState(() {
          players.removeWhere((p) => p.number == player.number);
        });
        break;
      case "card":
        var card = CardModel.fromJson(message.data);
        var i = players.indexWhere((p) => p.number == card.player);
        if(i > -1){
          setState(() {
            jogadas.add(card);
            players[i].removeCard(card);
          });
        }
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
    if(server != null){
      server?.stop();
    }
    edit.dispose();
    super.dispose();
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
                  ..._buildListPlayers(),
                  ..._buildListJogadas()
                ],
              ),
            ),
            Container(
              width: size.width / 4,
              constraints: BoxConstraints(
                maxWidth: 250
              ),
              color: Colors.green[800],
              padding: EdgeInsets.all(10.0),
              child: ListView(
                children: [
                  CardGame(
                    card: vira, 
                    visible: visible,
                    margin: EdgeInsets.only(top: 10, bottom: 20),
                  ),
                  Divider(color: Colors.white),
                  if(mesa.running) ListTile(
                    title: Text("${players[0].name}", 
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14
                      )
                    ),
                    subtitle: Text("${players[2].name}", 
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
                  if(mesa.running) ListTile(
                    title: Text("${players[1].name}", 
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14
                      )
                    ),
                    subtitle: Text("${players[3].name}", 
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
                  const SizedBox(height: 10),
                  Divider(color: Colors.white),
                  const SizedBox(height: 10),
                  ListTile(
                    title: Text("Valendo", 
                      style: TextStyle(
                        color: Colors.white,
                      )
                    ),
                    trailing: Text("$vale Ponto${vale > 1 ? "s": ""}", 
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      )
                    ),
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
                  const SizedBox(height: 30),
                  ElevatedButton(
                    child: Text("Iniciar Partida", style: TextStyle(
                      color: Colors.white
                    )),
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(size.width * 0.3, 50),
                      primary: Colors.blue[600],
                    ),
                    onPressed: _distribuition, 
                  ),
                  const SizedBox(height: 10),
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
          color = players[0].color;
        }else 
        if(victorys.length > i && victorys[i] == 2){
          icon = Icons.circle;
          color = players[1].color;
        }
        
        return Icon(icon, color: color, size: 20);
      }),
    );
  }

  List<Widget> _buildListPlayers(){
    return players.map((player) {
      var index = players.indexOf(player);
      return Positioned(
        bottom: index == 0 ? 10 : null,
        left: index == 1 ? 10 : null,
        top: index == 2 ? 10 : null,
        right: index == 3 ? 10 : null,
        child: Column(
          children: [
            Text("${player.name} (${player.cards.length})", 
              style: TextStyle(
                color: Colors.white
              )
            ),
            CircleAvatar(
              maxRadius: 40,
              child: Image.asset("${player.getAsset}", 
                fit: BoxFit.contain
              ),
            ),
          ],
        )
      );
      }).toList();
  }

  List<Widget> _buildListJogadas(){
    return jogadas.map((jogada){
      return TweenAnimationBuilder<double>(
        curve: Curves.easeInOut,
        duration: Duration(milliseconds: 500),
        tween: Tween<double>(begin: 0, end: 250),
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
                card: jogada,
                mark: jogada.uui == winner?.uui,
              ),
            ),
          );
        },
      );
    }).toList();
  }

}