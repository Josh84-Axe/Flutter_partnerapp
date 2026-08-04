class ProfileModel {
  final String id;
  final String name;
  final String speedPlan;
  final int downloadSpeed;
  final int uploadSpeed;
  final int idleTimeout;
  final String routerId;

  ProfileModel({
    required this.id,
    required this.name,
    required this.speedPlan,
    required this.downloadSpeed,
    required this.uploadSpeed,
    required this.idleTimeout,
    required this.routerId,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      name: json['name'],
      speedPlan: json['speedPlan'],
      downloadSpeed: json['downloadSpeed'],
      uploadSpeed: json['uploadSpeed'],
      idleTimeout: json['idleTimeout'],
      routerId: json['routerId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'speedPlan': speedPlan,
      'downloadSpeed': downloadSpeed,
      'uploadSpeed': uploadSpeed,
      'idleTimeout': idleTimeout,
      'routerId': routerId,
    };
  }

  ProfileModel copyWith({
    String? id,
    String? name,
    String? speedPlan,
    int? downloadSpeed,
    int? uploadSpeed,
    int? idleTimeout,
    String? routerId,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      speedPlan: speedPlan ?? this.speedPlan,
      downloadSpeed: downloadSpeed ?? this.downloadSpeed,
      uploadSpeed: uploadSpeed ?? this.uploadSpeed,
      idleTimeout: idleTimeout ?? this.idleTimeout,
      routerId: routerId ?? this.routerId,
    );
  }
}
