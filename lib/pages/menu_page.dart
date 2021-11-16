import 'package:flutter/material.dart';
import 'package:flutter_truco/components/create_game.dart';
import 'package:flutter_truco/pages/truco/mesa_truco_page.dart';
import 'package:flutter_truco/pages/burro/mesa_dumb_game.dart';
import 'package:flutter_truco/pages/burro/player_dumb_page.dart';
import 'package:flutter_truco/pages/truco/player_truco_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({ Key? key }) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  
  void _nextToDumbMesa(){
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => MesaDumbGame()
    ));
  }
  
  void _nextToDumbPlay(){
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          content: CreatePlayer(
            onConectServer: (model){
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                builder: (ctx) => PlayerDumbPage(model: model)
              ));
            },
          ),
        );
      }
    );
  }
  
  void _nextToTrucoMesa(){
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => GameTruco()
    ));
  }
  
  void _nextToTrucoPlay(){
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          content: CreatePlayer(
            onConectServer: (model){
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                builder: (ctx) => PlayerTrucoGame(
                  model: model,
                )
              ));
            },
          ),
        );
      }
    );
  }
  
  @override
  Widget build(BuildContext context) {
    var textStyle = TextStyle(
      color: Colors.white,
      fontFamily: "Gameria",
      fontSize: 26,
    );

    return Scaffold(
      backgroundColor: Colors.green[600],
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.maxFinite,
        padding: EdgeInsets.all(30),
        child: FittedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Row(
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
                  
                  /* DefaultTextStyle(
                    style: TextStyle(
                      fontFamily: "Gameria", 
                      fontSize: 60,
                      color: Colors.yellow
                    ),
                    child: AnimatedTextKit(
                      //repeatForever: true,
                      totalRepeatCount: 2,
                      pause: Duration(milliseconds: 200),
                      animatedTexts: [
                        RotateAnimatedText("TRUCO"),
                        RotateAnimatedText("BURRO"),
                      ]
                    ),
                  ),*/
                ],
              ),
              const SizedBox(height: 15),
              Text("Selecione o Jogo", style: TextStyle(
                fontFamily: "Gameria", 
                fontSize: 22,
                color: Colors.white
              )),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/burro.png",
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(width: 20),
                  Column(
                    children: [
                      ElevatedButton(
                        autofocus: true,
                        onPressed: _nextToDumbMesa, 
                        child: Text("BURRO MESA", style: textStyle),
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(230, 70),
                          primary: Colors.red
                        ),
                      ),
                      const SizedBox(height: 7.0),
                      ElevatedButton(
                        onPressed: _nextToDumbPlay, 
                        child: Text("BURRO PLAYER", style: textStyle),
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(230, 70),
                          primary: Colors.blue
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/truco.png",
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(width: 20),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: _nextToTrucoMesa, 
                        child: Text("TRUCO MESA", style: textStyle),
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(230, 70),
                          primary: Colors.red
                        ),
                      ),
                      const SizedBox(height: 7.0),
                      ElevatedButton(
                        onPressed: _nextToTrucoPlay, 
                        child: Text("TRUCO PLAYER", style: textStyle),
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(230, 70),
                          primary: Colors.blue
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        )
      )
    );
  }
}