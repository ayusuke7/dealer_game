import 'package:flutter/material.dart';
import 'package:flutter_truco/components/dpad_controler.dart';
import 'package:flutter_truco/pages/mesa_dumb_game.dart';
import 'package:flutter_truco/pages/mesa_truco_page.dart';
import 'package:flutter_truco/pages/player_dumb_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({ Key? key }) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {

  int _node = 1;

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
    return Scaffold(
      body: Container(
        color: Colors.green[600],
        padding: EdgeInsets.symmetric(
          horizontal: 50,
          vertical: 10
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 450,
                margin: EdgeInsets.only(bottom: 40),
                child: Row(
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
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: _nextToDumbMesa,
                    enableFeedback: true,
                    child: FocusContainer(
                      autofocus: true,
                      onClick: _nextToDumbMesa,
                      onFocus: (focus){
                        setState(() => _node = 1);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Image.asset(_node == 1 
                            ? "assets/images/burro.png" 
                            : "assets/images/burro-gray.png",
                            width: 150,
                            height: 150,
                          ),
                          const SizedBox(height: 10.0),
                          Text("BURRO MESA", style: TextStyle(
                            fontFamily: "Gameria",
                            color: Colors.white,
                            fontSize: 20,
                          ))
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 50),
                  InkWell(
                    onTap: _nextToDumbPlay,
                    enableFeedback: true,
                    child: FocusContainer(
                      autofocus: true,
                      onClick: _nextToDumbPlay,
                      onFocus: (focus){
                        setState(() => _node = 2);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Image.asset(_node == 2 
                            ? "assets/images/burro.png" 
                            : "assets/images/burro-gray.png",
                            width: 150,
                            height: 150,
                          ),
                          const SizedBox(height: 10.0),
                          Text("BURRO PLAYER", style: TextStyle(
                            fontFamily: "Gameria",
                            color: Colors.white,
                            fontSize: 20,
                          ))
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 50),
                  InkWell(
                    onTap: _nextToTrucoMesa,
                    child: FocusContainer(
                      onClick: _nextToTrucoMesa,
                      onFocus: (focus){
                        setState(() => _node = 3);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Image.asset(_node == 3 
                            ? "assets/images/truco.png" 
                            : "assets/images/truco-gray.png",
                            width: 150,
                            height: 150,
                          ),
                          const SizedBox(height: 10.0),
                          Text("TRUCO MESA", style: TextStyle(
                            color: Colors.white,
                            fontFamily: "Gameria",
                            fontSize: 20,
                          ))
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 50),
                  InkWell(
                    onTap: _nextToTrucoPlay,
                    child: FocusContainer(
                      onClick: _nextToTrucoPlay,
                      onFocus: (focus){
                        setState(() => _node = 4);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Image.asset(_node == 4 
                            ? "assets/images/truco.png" 
                            : "assets/images/truco-gray.png",
                            width: 150,
                            height: 150,
                          ),
                          const SizedBox(height: 10.0),
                          Text("TRUCO PLAYER", style: TextStyle(
                            color: Colors.white,
                            fontFamily: "Gameria",
                            fontSize: 20,
                          ))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      )
    );
  }
}