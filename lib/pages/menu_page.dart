import 'package:flutter/material.dart';
import 'package:flutter_truco/pages/mesa_dumb_game.dart';
import 'package:flutter_truco/pages/mesa_truco_page.dart';
import 'package:flutter_truco/pages/player_dumb_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({ Key? key }) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {

  void _nextToDumbMesa(){
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => DumbGame()
    ));
  }
  
  void _nextToDumbPlay(){
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => PlayerDumbPage()
    ));
  }
  
  void _nextToTrucoMesa(){
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => GameTruco()
    ));
  }
  
  void _nextToTrucoPlay(){
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => GameTruco()
    ));
  }
  
  @override
  Widget build(BuildContext context) {
    var textStyle = TextStyle(
      color: Colors.white,
      fontFamily: "Gameria",
      fontSize: 26,
    );


    return Scaffold(
      body: Container(
        width: double.maxFinite,
        color: Colors.green[600],
        padding: EdgeInsets.all(30),
        child: FittedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Flutter ", style: TextStyle(
                    fontFamily: "Gameria", 
                    fontSize: 60,
                    color: Colors.white
                  )),
                  Text("Dealer", style: TextStyle(
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
              Container(
                margin: EdgeInsets.only(
                  top: 40, 
                  bottom: 20
                ),
                child: Row(
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
              ),
              Container(
                margin: EdgeInsets.only(top: 20),
                child: Row(
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
              )
            ],
          ),
        )
      )
    );
  }
}