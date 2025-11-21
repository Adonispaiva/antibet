class UserSettingsModel {
  final bool isDarkMode;
  final bool enableNotifications;
  final String preferredCurrency; // Ex: 'BRL', 'USD'

  const UserSettingsModel({
    required this.isDarkMode,
    required this.enableNotifications,
    required this.preferredCurrency,
  });

  // Construtor padrão para o estado inicial
  factory UserSettingsModel.initial() {
    return const UserSettingsModel(
      isDarkMode: false, // Padrão: Light Mode
      enableNotifications: true,
      preferredCurrency: 'BRL', // Padrão: Real Brasileiro
    );
  }

  /// Cria uma instância a partir de um Map (JSON), usado pelo StorageService.
  factory UserSettingsModel.fromJson(Map<String, dynamic> json) {
    return UserSettingsModel(
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      enableNotifications: json['enableNotifications'] as bool? ?? true,
      preferredCurrency: json['preferredCurrency'] as String? ?? 'BRL',
    );
  }

  /// Converte a instância para um Map (JSON), usado pelo StorageService.
  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'enableNotifications': enableNotifications,
      'preferredCurrency': preferredCurrency,
    };
  }

  /// Cria uma cópia da instância com campos atualizados.
  UserSettingsModel copyWith({
    bool? isDarkMode,
    bool? enableNotifications,
    String? preferredCurrency,
  }) {
    return UserSettingsModel(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
    );
  }
}