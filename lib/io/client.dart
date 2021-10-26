
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_truco/io/message.dart';

class Client {
  
  Function(Message) onData;
  Function(String) onError;
  
  bool connected = false;
  
  String host;
  int port;

  Socket? socket;

  Client({
    required this.port,
    required this.host,
    required this.onData,
    required this.onError,
  });

  Future<void> connect() async {
    try {
      socket = await Socket.connect(host, port);
      socket?.listen((Uint8List uint8){
          var data = json.decode(String.fromCharCodes(uint8));
          var message = Message.fromJson(data);
          this.onData(message);
        },
        onError: this.onError,
        onDone: disconnect,
        cancelOnError: false,
      );
      connected = true;
    } on Exception catch (exception) {
      print(exception);
      this.onError("Error ao se conectar ao Servidor!");
    }
  }

  Future<void> disconnect() async {
    if (socket != null) {
      await socket?.close();
      socket?.destroy();
      connected = false;
    }
  }

  void sendMessage(Message message) {
    socket?.write(json.encode(message.toJson()));
  }
}