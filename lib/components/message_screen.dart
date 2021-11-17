import 'package:flutter/material.dart';

class MessageScreen extends StatelessWidget {

  final String? avatar;
  final String? title;
  final String message;

  const MessageScreen({ 
    Key? key,
    this.avatar,
    this.title,
    required this.message
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if(avatar != null) CircleAvatar(
            radius: 50,
            child: Image.asset("$avatar", 
              fit: BoxFit.contain
            ),
          ),
          if(title != null) Text("$title", 
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 38,
              color: Colors.yellow[600],
              fontWeight: FontWeight.bold
            )
          ),
          Text(message, 
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 34,
              color: Colors.white,
              fontWeight: FontWeight.bold
            )
          )
        ],
      ),
    );
  }
}