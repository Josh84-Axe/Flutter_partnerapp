class RouterConfigurationModel {
  final String id;
  final String name;
  final String ipAddress;
  final String? password;
  final int? apiPort;
  final String? dnsName;
  final String? username;
  final String? radiusSecret;
  final int? coaPort;

  RouterConfigurationModel({
    required this.id,
    required this.name,
    required this.ipAddress,
    this.password,
    this.apiPort,
    this.dnsName,
    this.username,
    this.radiusSecret,
    this.coaPort,
  });

  factory RouterConfigurationModel.fromJson(Map<String, dynamic> json) {
    return RouterConfigurationModel(
      id: json['id'],
      name: json['name'],
      ipAddress: json['ipAddress'],
      password: json['password'],
      apiPort: json['apiPort'],
      dnsName: json['dnsName'],
      username: json['username'],
      radiusSecret: json['radiusSecret'],
      coaPort: json['coaPort'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ipAddress': ipAddress,
      'password': password,
      'apiPort': apiPort,
      'dnsName': dnsName,
      'username': username,
      'radiusSecret': radiusSecret,
      'coaPort': coaPort,
    };
  }
}
