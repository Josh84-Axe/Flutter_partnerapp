class RouterConfigurationModel {
  final String id;
  final String name;
  final String slug;
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
    required this.slug,
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
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      ipAddress: json['ip_address'] ?? json['ipAddress'] ?? '',
      password: json['password'],
      apiPort: json['api_port'] ?? json['apiPort'],
      dnsName: json['dns_name'] ?? json['dnsName'],
      username: json['username'],
      radiusSecret: json['secret'] ?? json['radiusSecret'],
      coaPort: json['coa_port'] ?? json['coaPort'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'ip_address': ipAddress,
      'password': password,
      'api_port': apiPort,
      'dns_name': dnsName,
      'username': username,
      'secret': radiusSecret,
      'coa_port': coaPort,
    };
  }
}
