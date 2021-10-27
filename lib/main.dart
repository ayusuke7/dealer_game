import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_truco/pages/menu_page.dart';

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
      home: MenuPage(),
    );
  }
}


