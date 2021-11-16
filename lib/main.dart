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
      title: 'Dealer Game',
      theme: ThemeData(
        primarySwatch: Colors.green,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            overlayColor: MaterialStateProperty.all<Color>(
              Colors.black.withOpacity(0.095)
            ),
            shape: MaterialStateProperty.resolveWith<OutlinedBorder>((states) {
              if(states.contains(MaterialState.focused)){
                return RoundedRectangleBorder(
                  side: BorderSide(color: Colors.yellow, width: 4.5),
                  borderRadius: BorderRadius.circular(10),
                );
              }
              return RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)
              );
            })
          )
        )
      ),
      home: MenuPage(),
    );
  }
}


