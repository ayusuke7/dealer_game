
class MesaModel {

  int? vez;
  int? mao;
  int? naipe;
  int? burro;
  int? vencedor;

  int deck;
  int jogadas;
  bool running;

  MesaModel({ 
    this.deck = 0,
    this.jogadas = 0,
    this.running = false,
    this.naipe,
    this.vez,
    this.mao,
    this.burro,
    this.vencedor,
  });

  String? get naipeAsset {
    
    if(naipe == 0){
      return "diamond.png";
    }else 
    if(naipe == 1){
      return "spades.png";
    }else 
    if(naipe == 2){
      return "heart.png";
    }else 
    if(naipe == 3){
      return "club.png";
    }

    return null;
  }

  factory MesaModel.fromJson(Map<String, dynamic> json) => MesaModel(
    vez: json["vez"],
    mao: json["mao"],
    deck: json["deck"],
    naipe: json["naipe"],
    burro: json["burro"],
    running: json["running"],
    jogadas: json["jogadas"],
    vencedor: json["vencedor"],
  );

  Map<String, dynamic> toJson() => {
    "vez": vez,
    "mao": mao,
    "deck": deck,
    "naipe": naipe,
    "burro": burro,
    "running": running,
    "jogadas": jogadas,
    "vencedor": vencedor,
  };
}