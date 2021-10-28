import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_truco/components/card_game.dart';
import 'package:flutter_truco/io/client.dart';
import 'package:flutter_truco/io/message.dart';
import 'package:flutter_truco/models/card.dart';
import 'package:flutter_truco/models/mesa.dart';
import 'package:flutter_truco/models/player.dart';
import 'package:fluttertoast/fluttertoast.dart';


class PlayerDumbPage extends StatefulWidget {

  const PlayerDumbPage({  Key? key }) : super(key: key);

  @override
  _PlayerDumbPageState createState() => _PlayerDumbPageState();
}

class _PlayerDumbPageState extends State<PlayerDumbPage> {

  TextEditingController _name = TextEditingController();
  TextEditingController _host = TextEditingController();

  MesaModel _mesa = MesaModel();

  List<String> _assets = [];
  
  Client? _client;
  Player? _player;
  String? _avatar;

  bool _running = false;

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
 
  void _conectServer() async {

    if(
      _avatar != null &&
      _host.text.isNotEmpty && 
      _name.text.isNotEmpty
    ){
      
      _client = Client(
        host: _host.text, 
        port: 4444,
        onData: _onDataReceive, 
        onError: (error) {
          Fluttertoast.showToast(
            msg: error,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER
          );
        }
      );

      await _client?.connect();

      if(_client!.connected){
        var play = Player(
          number: _client.hashCode,
          name: _name.text,
          asset: _avatar, 
        );
        var message = Message(
          type: "connect", 
          data: play.toJson()
        );
        _client?.sendMessage(message);
        setState(() { _player = play; });
      }

    } else {
      Fluttertoast.showToast(
          msg: "Preencha os campos!",
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }

  }
  
  void _disconectServer() async {
    if(_client != null){
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

  void _listAssets() async {
    var assetsFile = await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    
    final Map<String, dynamic> manifestMap = json.decode(assetsFile);
    
    var images = manifestMap.keys.where((String key){
      return key.contains('avatar');
    }).toList();

    if(images.isNotEmpty){
      setState(() {
        _assets = images;
        _avatar = images.first;
      });
    }

  }
  
  @override
  void initState() {
    super.initState();
    _listAssets();
  }

  @override
  void dispose() {
   _disconectServer();
   _name.dispose();
   _host.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var conn = _client != null && _client!.connected;
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.green[600],
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: conn
        ? _buildCardsPlayer(size)
        : _buildCreatePlayer(size)
      ),
    );
  }

  Widget _buildCreatePlayer(Size size){
     return Container(
      padding: EdgeInsets.all(20),
      height: size.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: size.width * 0.6,
            padding: EdgeInsets.all(5.0),
            child: SingleChildScrollView(
              child: Wrap(
                alignment: WrapAlignment.center,
                children: _assets.map((img) => GestureDetector(
                  onTap: (){
                    setState(() => _avatar = img);
                  },
                  child: CircleAvatar(
                    child: Image.asset(img),
                    radius: 40,
                    backgroundColor: _avatar == img 
                      ? Colors.yellow 
                      : Colors.transparent,
                  ),
                )).toList(),
              ),
            ),
          ),
          Container(
            width: size.width * 0.3,
            padding: EdgeInsets.all(5.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Player", style: TextStyle(
                    fontFamily: "Gameria",
                    letterSpacing: 5.0,
                    color: Colors.white,
                    fontSize: 28,
                  )),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _name,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      focusColor: Colors.white,
                      filled: true,
                      hintText: "Nome do Jogador"
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _host,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      focusColor: Colors.white,
                      filled: true,
                      hintText: "IP do Servidor"
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _conectServer, 
                    icon: Icon(Icons.bolt),
                    label: Text("Conectar"),
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(size.width / 3, 50),
                      primary: Colors.blue,
                      textStyle: TextStyle(fontSize: 16),
                    )
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardsPlayer(Size size){
    var cards = _player?.cards ?? [];
    var vez = _mesa.vez == _player?.number;

    if(_running && cards.isEmpty){
      return _buildMessage("!! Parabéns !!\nVocê não é BURRO !");
    }else 
    if(_running && _mesa.burro == _player?.number){
      return _buildMessage("!! Parabéns !!\nVocê conseguiu ser \no mais BURRO da sua turma.");
    }

    return Column(
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
                    child: Image.asset("${_player?.asset}", 
                      fit: BoxFit.contain
                    ),
                  ),
                  title: Text("${_player?.name}",style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                  )),
                ),
              ),
              Text("Cartas: ${_player?.cards.length}",style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold
              )),
              const SizedBox(width: 40),
              Text("Jogada: ",style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold
              )),
              _mesa.asset != null
                ? Image.asset("assets/images/${_mesa.asset}", width: 30)
                : Icon(Icons.help_outline, color: Colors.white, size: 30)
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
              width: 120,
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
                onPressed: _mesa.deck > 0 && vez ? _onTapDeck : null, 
                icon: Icon(Icons.auto_awesome_motion),
                label: Text("Pegar do Monte"),
                style: TextButton.styleFrom(
                  minimumSize: Size(180, 30),
                  backgroundColor: Colors.blueGrey[400],
                  primary: Colors.white,
                  textStyle: TextStyle(
                    fontSize: 16
                  )
                ),
              ),
              TextButton.icon(
                onPressed: _mesa.deck == 0 && !vez ? _onTapTable : null, 
                icon: Icon(Icons.download),
                label: Text("Pegar da Mesa"),
                style: TextButton.styleFrom(
                  minimumSize: Size(180, 30),
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
                  minimumSize: Size(180, 30),
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

  Widget _buildMessage(String message){
    return Container(
      width: double.maxFinite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            child: Image.asset("${_player?.asset}", 
              fit: BoxFit.contain
            ),
          ),
          Text(message, 
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 36,
              color: Colors.white,
              fontWeight: FontWeight.bold
            )
          )
        ],
      ),
    );
  }
}