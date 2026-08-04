class LanguageModel {
  final String code;
  final String name;
  final String nativeName;
  final bool isSelected;

  LanguageModel({
    required this.code,
    required this.name,
    required this.nativeName,
    this.isSelected = false,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      code: json['code'],
      name: json['name'],
      nativeName: json['nativeName'],
      isSelected: json['isSelected'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'nativeName': nativeName,
      'isSelected': isSelected,
    };
  }

  LanguageModel copyWith({
    String? code,
    String? name,
    String? nativeName,
    bool? isSelected,
  }) {
    return LanguageModel(
      code: code ?? this.code,
      name: name ?? this.name,
      nativeName: nativeName ?? this.nativeName,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  static List<LanguageModel> get availableLanguages => [
        LanguageModel(code: 'en', name: 'English', nativeName: 'English', isSelected: true),
        LanguageModel(code: 'fr', name: 'French', nativeName: 'Français'),
      ];
}
