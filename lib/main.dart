import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_truco/pages/menu_page.dart';
import 'package:flutter_truco/pages/mesa_dumb_game.dart';
import 'package:flutter_truco/pages/mesa_truco_page.dart';
import 'package:flutter_truco/pages/player_dumb_page.dart';

const MENU_PAGE = "menu";
const MESA_TRUCO_PAGE = "mesaTruco";
const PLAY_TRUCO_PAGE = "playTruco";
const MESA_BURRO_PAGE = "mesaBurro";
const PLAY_BURRO_PAGE = "playBurro";

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft
  ]).then((_){
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Truco',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: "menu",
      routes: {
        MENU_PAGE: (ctx) => MenuPage(),
        MESA_TRUCO_PAGE: (ctx) => GameTruco(),
        PLAY_TRUCO_PAGE: (ctx) => GameTruco(),
        MESA_BURRO_PAGE: (ctx) => DumbGame(),
        PLAY_BURRO_PAGE: (ctx) => PlayerDumbPage(),
      },
    );
  }
}


