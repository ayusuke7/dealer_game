import 'package:flutter/material.dart';
import 'package:flutter_truco/components/card_game.dart';
import 'package:flutter_truco/components/message_screen.dart';
import 'package:flutter_truco/io/client.dart';
import 'package:flutter_truco/io/message.dart';
import 'package:flutter_truco/models/card.dart';
import 'package:flutter_truco/models/create_player.dart';
import 'package:flutter_truco/models/mesa.dart';
import 'package:flutter_truco/models/player.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PlayerDumbPage extends StatefulWidget {

  final CreatePlayerModel? model;

  const PlayerDumbPage({ 
    Key? key,  
    required this.model 
  }) : super(key: key);

  @override
  _PlayerDumbPageState createState() => _PlayerDumbPageState();
}

class _PlayerDumbPageState extends State<PlayerDumbPage> {

  MesaModel _mesa = MesaModel();
  
  Client? _client;
  Player? _player;

  bool _running = false;
  bool _loading = false;

  void _onTapCard(CardModel card){
    if(_mesa.naipe == null || _mesa.naipe == card.naipe) {
      var message = Message(
        type: "card", 
        data: card.toJson()
      );
      _client?.sendMessage(message);
      setState(() {
        _player?.removeCard(card);
        _mesa.vez = 0;
      });
    }
  }

  void _onTapDeck(){
    var message = Message(
      type: "deck",
      data: _player?.toJson()
    );
    _client?.sendMessage(message);
  }

  void _onTapTable(){
    var message = Message(
      type: "table", 
      data: _player?.toJson()
    );
    _client?.sendMessage(message);
  }
  
  void _onTapRestart(){
    var message = Message(
      type: "restart", 
      data: _player?.toJson()
    );
    _client?.sendMessage(message);
  }

  void _conectServer() async {
    
      _client = Client(
        port: 4444,
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

      setState(() => _loading = true);

      _client?.connect().then((_){
        if(_client!.connected){
          var play = Player(
            number: _client.hashCode,
            asset: widget.model?.avatar,
            name: "${widget.model?.name}",
          );
          var message = Message(
            type: "connect", 
            data: play.toJson()
          );
          _client?.sendMessage(message);
          setState(() { 
            _player = play; 
            _loading = false;
          });
        }else{
          Navigator.of(context).pop();
        }
      });

  }
  
  void _disconectServer() async {
    if(_client != null && _client!.connected){
      var message = Message(
        type: "disconect", 
        data: _player?.toJson() ?? {}
      );
      _client?.sendMessage(message);
      await _client?.disconnect();
    }
  }

  void _onDataReceive(Message message){
    print(message.toJson());

    switch (message.type) {
      case "cards":
        var cards = listCardFromJson(message.data);
        setState(() {
          _player?.setCards(cards);
          _running = true;
          _mesa.naipe = null;
        });
        break;
      case "table":
        var cards = listCardFromJson(message.data);
        setState(() {
          _player?.addCards(cards);
          _mesa.naipe = null;
          _mesa.jogadas = 0;
        });
        break;
      case "deck": 
        var card = CardModel.fromJson(message.data);
        setState(() {
          _player?.addCard(card);
        });
        break;
      case "mesa": 
        var tmp = MesaModel.fromJson(message.data);
        setState(() { _mesa = tmp; });
        break;
      case "disconect": 
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
    
    var cards = _player?.cards ?? [];
    var vez = _mesa.vez == _player?.number;
    
    var tapMonte = vez && _mesa.running && _mesa.deck > 0;
    var tapMesa = _mesa.running && _mesa.jogadas > 0 && _mesa.deck == 0;

    var component;

    if(_loading){
      component = MessageScreen(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
             Colors.yellow
          ),
        ),
        message: "Procurando Servidor, aguarde!",
      );
    }else
    if(_running && cards.isEmpty){
      component = MessageScreen(
        avatar: _player?.asset,
        title: "!! Parabéns !!",
        message: "Você não é BURRO !"
      );
    }else 
    if(_running && _mesa.burro == _player?.number){
      component = MessageScreen(
        avatar: _player?.asset,
        title: "!! Parabéns !!",
        message: "Você conseguiu ser o mais BURRO da sua turma.",
        onRestart: _onTapRestart,
      );
    }else{
      component = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(10.0),
            color: Colors.green[800],
            child: Row(
              children: [
                Flexible(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 30,
                      child: Image.asset("${widget.model?.avatar}", 
                        fit: BoxFit.contain
                      ),
                    ),
                    title: Text("${widget.model?.name}",style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                    )),
                  ),
                ),
                Text("Cartas: ${_player?.cards.length ?? "0"}", 
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                  )
                ),
                const SizedBox(width: 40),
                Text("Jogada: ",style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold
                )),
                _mesa.naipeAsset != null
                  ? Image.asset("assets/images/${_mesa.naipeAsset}", width: 25)
                  : Icon(Icons.help_outline, color: Colors.white, size: 25),
                const SizedBox(width: 10),
              ],
            ),
          ),
          Flexible(
            child: ListView(
              padding: EdgeInsets.all(15),
              scrollDirection: Axis.horizontal,
              children: cards.map((card) => CardGame(
                disabled: !vez,
                card: card,
                onTap: () { 
                  if(vez) _onTapCard(card);
                },
              )).toList()
            ),
          ),
          Container(
            padding: EdgeInsets.all(10.0),
            color: Colors.green[800],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: tapMonte  ? _onTapDeck : null, 
                  icon: Icon(Icons.auto_awesome_motion),
                  label: Text("Pegar do Monte"),
                  style: TextButton.styleFrom(
                    minimumSize: Size(180, 40),
                    backgroundColor: Colors.blueGrey[400],
                    primary: Colors.white,
                    textStyle: TextStyle(
                      fontSize: 16
                    )
                  ),
                ),
                TextButton.icon(
                  onPressed: tapMesa ? _onTapTable : null, 
                  icon: Icon(Icons.download),
                  label: Text("Pegar da Mesa"),
                  style: TextButton.styleFrom(
                    minimumSize: Size(180, 40),
                    backgroundColor: Colors.greenAccent[700],
                    primary: Colors.white,
                    textStyle: TextStyle(
                      fontSize: 16
                    )
                  ),
                ),
                TextButton.icon(
                  onPressed: (){ Navigator.pop(context);}, 
                  icon: Icon(Icons.exit_to_app),
                  label: Text("Sair da Partida"),
                  style: TextButton.styleFrom(
                    minimumSize: Size(180, 40),
                    backgroundColor: Colors.red[400],
                    primary: Colors.white,
                    textStyle: TextStyle(
                      fontSize: 16
                    )
                  ),
                ),
              ],
            ),
          ),
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