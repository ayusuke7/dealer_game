import 'package:flutter/material.dart';
import 'package:flutter_truco/components/card_game.dart';
import 'package:flutter_truco/components/custom_button.dart';
import 'package:flutter_truco/components/message_screen.dart';
import 'package:flutter_truco/io/client.dart';
import 'package:flutter_truco/io/message.dart';
import 'package:flutter_truco/models/card.dart';
import 'package:flutter_truco/models/create_player.dart';
import 'package:flutter_truco/models/mesa.dart';
import 'package:flutter_truco/models/player.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PlayerTrucoGame extends StatefulWidget {
  
  final CreatePlayerModel? model;

  const PlayerTrucoGame({ 
    Key? key, 
    required this.model 
  }) : super(key: key);

  @override
  _PlayerTrucoGameState createState() => _PlayerTrucoGameState();
}

class _PlayerTrucoGameState extends State<PlayerTrucoGame> {
  
  MesaModel mesa = MesaModel();
  
  CardModel? select;
  Client? client;
  Player? player;

  bool vez = false;
  bool running = false;
  bool loading = false;
  bool truco = false;
  bool visible = false;

  void _onTapVirar(){
    setState(() {
      select!.flip = !select!.flip;
    });
  }
 
  void _onTapTruco(){
    var message = Message(
      type: "truco", 
      data: player?.toJson()
    );

    client?.sendMessage(message);

  }

  void _onTapCard(){

    var card = CardModel(
      value: select!.value, 
      naipe: select!.naipe
    );

    card.player = select!.player;
    card.manil = select!.manil;
    card.flip = select!.flip;

    var message = Message(
      type: "card", 
      data: card.toJson()
    );

    client?.sendMessage(message);
    
    setState(() {
      player?.removeCard(card);
      mesa.vez = null;
      select = null;
    });

  }

  void _conectServer() async {
   
      client = Client(
        port: 4545,
        host: "${widget.model?.host}", 
        onData: _onDataReceive, 
        onError: (error) {
          Fluttertoast.showToast(
            msg: "Op's ocorreu um erro!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red
          );
        }
      );

      setState(() => loading = true);
      client?.connect().then((_){
        if(client!.connected){
          var play = Player(
            number: client.hashCode,
            asset: "${widget.model?.avatar}",
            name: "${widget.model?.name}",
          );
          var message = Message(
            type: "connect", 
            data: play.toJson()
          );
          client?.sendMessage(message);
          setState(() { 
            player = play;
            loading = false;
          });
        }else{
          Navigator.of(context).pop();
        }
      });

  }

  void _disconectServer() async {
    if(client != null && client!.connected){
      var message = Message(
        type: "disconect", 
        data: player?.toJson() ?? {}
      );
      client?.sendMessage(message);
      await client?.disconnect();
    }
  }

  void _onDataReceive(Message message){
    print(message.toJson());

    switch (message.type) {
      case "cards":
        var cards = listCardFromJson(message.data);
        setState(() {
          running = true;
          player?.number = cards.first.player;
          player?.setCards(cards);
        });
        break;
      case "mesa": 
        var tmp = MesaModel.fromJson(message.data);
        setState(() { mesa = tmp; });
        break;
      case "truco": 
        print(message.data);
        break;
      case "disconect":
        setState(() { client = null; });
        Navigator.of(context).pop();
        break;
      default:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _conectServer();
  }

  @override
  void dispose() {
    _disconectServer();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    var cards = player?.cards ?? [];
    var vez = mesa.vez == player?.number;

    var component;

    if(loading){
      component = MessageScreen(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
             Colors.yellow
          ),
        ),
        message: "Procurando Servidor, aguarde!",
      );
    }else {
      component = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(7.0),
            color: Colors.green[800],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 30,
                      child: Image.asset("${player?.getAsset}", 
                        fit: BoxFit.contain
                      ),
                    ),
                    title: Text("${player?.name}",style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                    )),
                  ),
                ),
                TextButton.icon(
                  onPressed: (){
                    Navigator.of(context).pop();
                  }, 
                  icon: Icon(Icons.exit_to_app), 
                  label: Text("Sair"),
                  style: TextButton.styleFrom(
                    primary: Colors.white
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: cards.map((card) {
                var sel = select?.uui == card.uui;
                return CardGame(
                  selected: sel,
                  card: card,
                  onTap: () {
                    setState(() {
                      select = card;
                    });
                  },
                );
              }).toList()
            ),
          ),
          Container(
            padding: EdgeInsets.all(7.0),
            color: Colors.green[800],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomButton(
                  disable: !vez || mesa.escuro,
                  onPressed: _onTapTruco, 
                  icon: Icons.bolt,
                  label: mesa.labelValor,
                  backgroundColor: Colors.red[400],
                ),
                const SizedBox(width: 15),
                CustomButton(
                  disable: !vez,
                  onPressed: _onTapCard, 
                  icon: Icons.arrow_circle_up,
                  label: "Jogar",
                  backgroundColor: Colors.blue[400],
                ),
                const SizedBox(width: 15),
                CustomButton(
                  disable: select == null || mesa.escuro || mesa.mao == 1,
                  onPressed: _onTapVirar, 
                  icon: Icons.rotate_left,
                  label: "Vira",
                  backgroundColor: Colors.purple[400],
                ),
              ],
            ),
          )
        ],
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.green[600],
      body: SafeArea(child: component)
    );
  }
}