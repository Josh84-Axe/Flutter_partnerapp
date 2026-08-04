class ConfigurationModel {
  final String id;
  final String name;
  final String type;
  final Map<String, dynamic> settings;

  ConfigurationModel({
    required this.id,
    required this.name,
    required this.type,
    required this.settings,
  });

  factory ConfigurationModel.fromJson(Map<String, dynamic> json) {
    return ConfigurationModel(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      settings: json['settings'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'settings': settings,
    };
  }
}
