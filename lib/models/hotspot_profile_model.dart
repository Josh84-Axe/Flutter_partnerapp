class HotspotProfileModel {
  final String id;
  final String name;
  final int downloadSpeedMbps;
  final int uploadSpeedMbps;
  final String idleTimeout;

  HotspotProfileModel({
    required this.id,
    required this.name,
    required this.downloadSpeedMbps,
    required this.uploadSpeedMbps,
    required this.idleTimeout,
  });

  String get speedDescription => '$downloadSpeedMbps Mbps / $uploadSpeedMbps Mbps • Idle $idleTimeout';

  factory HotspotProfileModel.fromJson(Map<String, dynamic> json) {
    return HotspotProfileModel(
      id: json['id'],
      name: json['name'],
      downloadSpeedMbps: json['downloadSpeedMbps'],
      uploadSpeedMbps: json['uploadSpeedMbps'],
      idleTimeout: json['idleTimeout'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'downloadSpeedMbps': downloadSpeedMbps,
      'uploadSpeedMbps': uploadSpeedMbps,
      'idleTimeout': idleTimeout,
    };
  }
}
