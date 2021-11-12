import 'package:flutter/material.dart';
import 'package:flutter_truco/io/client.dart';
import 'package:flutter_truco/models/mesa.dart';
import 'package:flutter_truco/models/player.dart';

class PlayerTrucoGame extends StatefulWidget {
  const PlayerTrucoGame({ Key? key }) : super(key: key);

  @override
  _PlayerTrucoGameState createState() => _PlayerTrucoGameState();
}

class _PlayerTrucoGameState extends State<PlayerTrucoGame> {
  
  MesaModel mesa = MesaModel();
  
  Client? client;
  Player? player;

  bool running = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
    );
  }
}