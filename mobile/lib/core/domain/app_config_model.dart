import 'package:flutter/foundation.dart';

/// Entidade de Domínio que representa as configurações globais do aplicativo.
/// Esta entidade é persistida localmente (geralmente via SharedPreferences ou Hive).
@immutable
class AppConfigModel {
  // Configurações de tema (true = Dark Mode, false = Light Mode)
  final bool isDarkMode;
  
  // Configurações de notificação (true = Ativadas)
  final bool areNotificationsEnabled; 
  
  // Configuração de idioma (código de 2 letras)
  final String languageCode; 

  const AppConfigModel({
    this.isDarkMode = false,
    this.areNotificationsEnabled = true,
    this.languageCode = 'pt', // Padrão Brasil
  });

  /// Construtor de fábrica para desserialização JSON (Storage)
  factory AppConfigModel.fromJson(Map<String, dynamic> json) {
    return AppConfigModel(
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      areNotificationsEnabled: json['areNotificationsEnabled'] as bool? ?? true,
      languageCode: json['languageCode'] as String? ?? 'pt',
    );
  }

  /// Método para serialização JSON (Envio para Storage)
  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'areNotificationsEnabled': areNotificationsEnabled,
      'languageCode': languageCode,
    };
  }

  /// Cria uma cópia da entidade, opcionalmente com novos valores (imutabilidade)
  AppConfigModel copyWith({
    bool? isDarkMode,
    bool? areNotificationsEnabled,
    String? languageCode,
  }) {
    return AppConfigModel(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      areNotificationsEnabled: areNotificationsEnabled ?? this.areNotificationsEnabled,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  // Sobrescreve hashCode e equals
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppConfigModel &&
      other.isDarkMode == isDarkMode &&
      other.areNotificationsEnabled == areNotificationsEnabled &&
      other.languageCode == languageCode;
  }

  @override
  int get hashCode {
    return isDarkMode.hashCode ^
      areNotificationsEnabled.hashCode ^
      languageCode.hashCode;
  }
}

// Definição do estado inicial (configurações padrão)
const AppConfigModel kDefaultAppConfig = AppConfigModel();