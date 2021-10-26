import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:network_info_plus/network_info_plus.dart';

import '/io/message.dart';

class Server {
  final network = NetworkInfo();

  Function(Message) onData;
  Function(String) onError;

  ServerSocket? server;
  bool running = false;
  List<Socket> sockets = [];

  Server({
    required this.onData,
    required this.onError,
  });

  Future<void> start() async {
    try {
      var host = await network.getWifiIP();
      
      server = await ServerSocket.bind(host, 4444);
      
      server?.listen((Socket socket){
        socket.listen((Uint8List uint8){
          var data = String.fromCharCodes(uint8);
          var message = Message.fromJson(json.decode(data));
          this.onData(message);
          
          if(message.type == "connect"){
            sockets.add(socket);
            print("client connect ${message.data}");
          }else 
          if(message.type == "disconect"){
            sockets.remove(socket);
            print("client disconect ${message.data}");
          }

        });
      });
      this.running = true;
      print('Server listening on $host:4444');
    } on Exception catch (ex) {
      print(ex);
      this.running = false;
      this.onError("Error ao iniciar o Servidor!!");
    }
  }

  Future<void> stop() async {
    await this.server?.close();
    print("stop server ${server?.address.host}");
    this.server = null;
    this.running = false;
  }

  void sendTo(String host, Message message){
    for (Socket socket in sockets) {
      if(socket.address.host == host){
        print('send message to $host');
        socket.write(json.encode(message.toJson()));
        break;
      }
    }
  }
  
  void sendIndex(int index, Message message){
    if(index < sockets.length){
      print('send message to ${sockets[index].address.host}');
      sockets[index].write(json.encode(message.toJson()));
    }
  }

  void broadcast(Message message) {
    print('send broadcasting');
    var encode = json.encode(message.toJson());
    for (Socket socket in sockets) {
      socket.write(encode);
    }
  }

}