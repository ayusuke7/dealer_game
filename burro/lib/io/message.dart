import 'package:flutter_truco/models/mesa.dart';

class Message {

  final String type;
  final dynamic data;
  final MesaModel? mesa;
  String? host;

  Message({ 
    required this.type, 
    required this.data,
    this.mesa,
    this.host
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    type: json["type"], 
    data: json["data"],
    mesa: json["mesa"],
    host: json["host"],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "data": data,
    "mesa": mesa,
    "host": host,
  };

}