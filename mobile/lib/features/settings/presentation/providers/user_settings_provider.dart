import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:antibet/features/settings/data/models/user_settings_model.dart';
import 'package:antibet/features/settings/data/services/user_settings_service.dart';

/// Notifier que gerencia o estado das configurações do usuário (persistência).
class UserSettingsNotifier extends StateNotifier<AsyncValue<UserSettingsModel>> {
  final UserSettingsService _service;

  UserSettingsNotifier(this._service) : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  /// Carrega as configurações salvas do armazenamento local.
  void _loadSettings() {
    try {
      final settings = _service.loadSettings();
      state = AsyncValue.data(settings);
    } catch (e) {
      // Se a leitura falhar, assume as configurações iniciais
      state = AsyncValue.data(UserSettingsModel.initial());
      // Loga o erro, mas não bloqueia o app
      // print('Erro ao carregar configurações: $e');
    }
  }

  /// Atualiza uma ou mais configurações e as salva no armazenamento local.
  Future<void> updateSettings({
    bool? isDarkMode,
    bool? enableNotifications,
    String? preferredCurrency,
  }) async {
    // Garante que a atualização só ocorra se houver dados carregados
    if (state.hasValue) {
      final currentSettings = state.value!;
      
      final newSettings = currentSettings.copyWith(
        isDarkMode: isDarkMode,
        enableNotifications: enableNotifications,
        preferredCurrency: preferredCurrency,
      );

      // 1. Atualiza o estado na memória
      state = AsyncValue.data(newSettings);
      
      // 2. Salva no armazenamento local de forma assíncrona
      final success = await _service.saveSettings(newSettings);
      
      if (!success) {
        // Log de erro de salvamento
        // print('Falha ao salvar UserSettings no storage.');
        // Opcional: Reverter o estado ou notificar o usuário
      }
    }
  }
  
  /// Limpa as configurações do usuário (chamado no logout)
  Future<void> clearSettings() async {
      final success = await _service.saveSettings(UserSettingsModel.initial());
      if(success) {
         state = AsyncValue.data(UserSettingsModel.initial());
      }
  }
}

/// Provider global de configurações.
final userSettingsProvider = StateNotifierProvider<UserSettingsNotifier, AsyncValue<UserSettingsModel>>((ref) {
  final service = ref.watch(userSettingsServiceProvider);
  return UserSettingsNotifier(service);
});