import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_truco/models/create_player.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CreatePlayer extends StatefulWidget {

  final CreatePlayerModel? model;
  final Function(CreatePlayerModel model) onTapSave;

  const CreatePlayer({ 
    Key? key,
    this.model,
    required this.onTapSave,
  }) : super(key: key);

  @override
  State<CreatePlayer> createState() => _CreatePlayerState();
}

class _CreatePlayerState extends State<CreatePlayer> {
  
  TextEditingController _name = TextEditingController();
  TextEditingController _host = TextEditingController();
  
  List<String> _assets = [];
  String? _avatar;

  void _listAssets() async {
    var assetsFile = await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    
    final Map<String, dynamic> manifestMap = json.decode(assetsFile);
    
    var images = manifestMap.keys.where((String key){
      return key.contains('avatar');
    }).toList();

    if(images.isNotEmpty){
      var tmp = widget.model?.avatar;

      setState(() {
        _assets = images;
        _avatar = tmp ?? images.first;
      });
    }

  }

  void _onConnect(){
      if(
        _avatar != null && 
        _host.text.trim().isNotEmpty && 
        _name.text.trim().isNotEmpty
      ){
          
          var model = CreatePlayerModel(
            avatar: _avatar,
            host: _host.text.trim(),
            name: _name.text.trim()
          );
          
          widget.onTapSave(model);        
      } else {
        Fluttertoast.showToast(
          msg: "Preencha os campos!",
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _listAssets();

    if(widget.model != null){
      _name.text = widget.model!.name;
      _host.text = widget.model!.host;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _host.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(_avatar);
    var size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: size.width * 0.4,
            padding: EdgeInsets.all(5.0),
            child: SingleChildScrollView(
              child: Wrap(
                alignment: WrapAlignment.center,
                children: _assets.map((img) => GestureDetector(
                  onTap: (){
                    setState(() => _avatar = img);
                  },
                  child: CircleAvatar(
                    child: Image.asset(img),
                    radius: 40,
                    backgroundColor: _avatar == img 
                      ? Colors.yellow 
                      : Colors.transparent,
                  ),
                )).toList(),
              ),
            ),
          ),
          Container(
            width: size.width * 0.3,
            padding: EdgeInsets.all(5.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    focusColor: Colors.white,
                    filled: true,
                    hintText: "Nome do Jogador"
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _host,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    focusColor: Colors.white,
                    filled: true,
                    hintText: "IP do Servidor"
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _onConnect,
                  icon: Icon(Icons.save),
                  label: Text("Salvar"),
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(size.width / 3, 50),
                    primary: Colors.blue,
                    textStyle: TextStyle(fontSize: 16),
                  )
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}