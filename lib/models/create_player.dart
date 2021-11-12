class CreatePlayerModel {

  String? avatar;
  String name;
  String host;

  CreatePlayerModel({
    required this.host,
    required this.name,
    this.avatar,
  });

}