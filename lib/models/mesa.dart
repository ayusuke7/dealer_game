
class MesaModel {

  int? vez;
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
    this.burro,
    this.vencedor
  });

  String? get asset {
    
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
    deck: json["deck"],
    naipe: json["naipe"],
    burro: json["burro"],
    running: json["running"],
    jogadas: json["jogadas"],
    vencedor: json["vencedor"],
  );

  Map<String, dynamic> toJson() => {
    "vez": vez,
    "deck": deck,
    "naipe": naipe,
    "burro": burro,
    "running": running,
    "jogadas": jogadas,
    "vencedor": vencedor,
  };
}