
class MesaModel {

  int? vez;
  int? mao;
  int? naipe;
  int? burro;
  int? vencedor;
  int? valendo;

  int deck;
  int jogadas;
  bool running;

  MesaModel({ 
    this.deck = 0,
    this.jogadas = 0,
    this.valendo = 1,
    this.running = false,
    this.naipe,
    this.vez,
    this.mao,
    this.burro,
    this.vencedor,
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

  String get labelValor {
    return valendo == 1 
      ? "Truco" : valendo == 3 
      ? "Seis" : valendo == 6 
      ? "Nove" 
      : "Doze";
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
    valendo: json["valendo"],
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
    "valendo": valendo,
  };
}