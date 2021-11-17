import 'package:flutter/material.dart';
import 'package:flutter_truco/components/create_game.dart';
import 'package:flutter_truco/models/create_player.dart';
import 'package:flutter_truco/pages/burro/player_dumb_page.dart';
import 'package:flutter_truco/pages/truco/mesa_truco_page.dart';
import 'package:flutter_truco/pages/burro/mesa_dumb_game.dart';
import 'package:flutter_truco/pages/truco/player_truco_page.dart';
import 'package:flutter_truco/utils/storage.dart';
import 'package:flutter_switch/flutter_switch.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({ Key? key }) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  
  CreatePlayerModel? player;
  bool modePlayer = true;

  void _onTapBurro(){
    if(!modePlayer){
      Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => MesaDumbGame()
      ));
    }else 
    if(player == null){
      _createPlayer();
    }else{
      Navigator.push(context, MaterialPageRoute(
        builder: (ctx) => PlayerDumbPage(model: player)
      ));
    }
  }

  void _onTapTruco(){
    if(!modePlayer){
      Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => GameTruco()
      ));
    }else 
    if(player == null){
      _createPlayer();
    }else{
      Navigator.push(context, MaterialPageRoute(
        builder: (ctx) => PlayerTrucoGame(model: player)
      ));
    }
  }

  void _createPlayer(){
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: Text("Player", 
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: "Gameria",
              letterSpacing: 5.0,
              color: Colors.white,
              fontSize: 28,
            )
          ),
          backgroundColor: Colors.transparent,
          content: CreatePlayer(
            model: player,
            onTapSave: (model){
              Navigator.of(context).pop();
              setState(() { player = model; });
              Storage.saveModelPlayer(model);
            },
          ),
        );
      }
    );
  }
  
  @override
  void initState() {
    super.initState();


    Storage.getModelPlayer().then((value) {      
      if(value != null){
        print(value.toJson());
        setState(() {
          player = value;
        });
      }
    });

  }
  
  @override
  Widget build(BuildContext context) {
    var textStyle = TextStyle(
      color: Colors.white,
      fontFamily: "Gameria",
      fontSize: 22,
    );

    return Scaffold(
      backgroundColor: Colors.green[600],
      appBar: AppBar(
        toolbarHeight: 100.0,
        backgroundColor: Colors.green[800],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Dealer ", style: TextStyle(
              fontFamily: "Gameria", 
              fontSize: 60,
              color: Colors.white
            )),
            Text("Game", style: TextStyle(
              fontFamily: "Gameria", 
              fontSize: 60,
              color: Colors.yellow
            )),
          ],
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("MESA", style: textStyle.merge(
                  TextStyle(fontSize: 26)
                )),
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: FlutterSwitch(
                    width: 120.0,
                    height: 50.0,
                    padding: 8.0,
                    toggleSize: 45.0,
                    value: modePlayer,
                    borderRadius: 30.0,
                    valueFontSize: 20.0,
                    activeColor: Colors.blue,
                    inactiveColor: Colors.red,
                    activeIcon: Icon(Icons.face),
                    inactiveIcon: Icon(Icons.how_to_vote),
                    onToggle: (val) {
                      setState(() {
                        modePlayer = val;
                      });
                    },
                  ),
                ),
                Text("PLAYER", style: textStyle.merge(
                  TextStyle(fontSize: 26)
                )),
              ],
            ),
            const SizedBox(height: 50.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  autofocus: true,
                  onPressed: _onTapBurro, 
                  child: Column(
                    children: [
                      Image.asset("assets/images/burro.png",
                        width: 150,
                        height: 150,
                      ),
                      const SizedBox(height: 15),
                      Text("JOGO DO BURRO", style: textStyle),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.transparent,
                    padding: EdgeInsets.all(15.0)
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _onTapTruco, 
                  child: Column(
                    children: [
                      Image.asset("assets/images/truco.png",
                        width: 150,
                        height: 150,
                      ),
                      const SizedBox(height: 15),
                      Text("JOGO DO TRUCO", style: textStyle),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.transparent,
                    padding: EdgeInsets.all(15.0)
                  ),
                ),
                const SizedBox(width: 20),
                if(modePlayer) ElevatedButton(
                  onPressed: _createPlayer, 
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      player != null ? Image.asset("${player?.avatar}", 
                        width: 130, 
                        height: 130
                      ) : Icon(Icons.face, size: 100.0),
                      const SizedBox(height: 10),
                      Text(player?.name ?? "Player", style: textStyle, softWrap: false,),
                      Text(player?.host ?? "", style: TextStyle(
                        fontSize: 18
                      )),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.transparent,
                    padding: EdgeInsets.all(15.0),
                    fixedSize: Size(170, 220)
                  ),
                ),
              ],
            ),
          ],
        )
      ),
    );
  }
}