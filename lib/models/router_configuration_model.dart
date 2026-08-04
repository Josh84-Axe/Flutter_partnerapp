class RouterConfigurationModel {
  final String id;
  final String name;
  final String slug;
  final String? ipAddress;
  final String? password;
  final int? apiPort;
  final String? dnsName;
  final String? username;
  final String? radiusSecret;
  final int? coaPort;
  final bool? isActive;

  RouterConfigurationModel({
    required this.id,
    required this.name,
    required this.slug,
    this.ipAddress,
    this.password,
    this.apiPort,
    this.dnsName,
    this.username,
    this.radiusSecret,
    this.coaPort,
    this.isActive,
  });

  factory RouterConfigurationModel.fromJson(Map<String, dynamic> json) {
    return RouterConfigurationModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      ipAddress: json['ip_address'] ?? json['ipAddress'],
      password: json['password'],
      apiPort: json['api_port'] is int
          ? json['api_port']
          : int.tryParse(json['api_port']?.toString() ?? ''),
      dnsName: json['dns_name'] ?? json['dnsName'],
      username: json['username'],
      radiusSecret: json['secret'] ?? json['radiusSecret'],
      coaPort: json['coa_port'] is int
          ? json['coa_port']
          : int.tryParse(json['coa_port']?.toString() ?? ''),
      isActive: json['is_active'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      if (ipAddress != null) 'ip_address': ipAddress,
      if (password != null) 'password': password,
      if (apiPort != null) 'api_port': apiPort,
      if (dnsName != null) 'dns_name': dnsName,
      if (username != null) 'username': username,
      if (radiusSecret != null) 'secret': radiusSecret,
      if (coaPort != null) 'coa_port': coaPort,
      if (isActive != null) 'is_active': isActive,
    };
  }
}
