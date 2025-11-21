import 'package:flutter_test/flutter_test.dart';
import 'package:antibet/features/settings/data/models/user_settings_model.dart';

void main() {
  group('UserSettingsModel', () {
    const tModel = UserSettingsModel(
      isDarkMode: true,
      enableNotifications: false,
      preferredCurrency: 'USD',
    );

    final tJson = {
      'isDarkMode': true,
      'enableNotifications': false,
      'preferredCurrency': 'USD',
    };

    test('initial factory constructor should return default values', () {
      // Act
      final initialModel = UserSettingsModel.initial();

      // Assert
      expect(initialModel.isDarkMode, false);
      expect(initialModel.enableNotifications, true);
      expect(initialModel.preferredCurrency, 'BRL');
    });

    test('should return a valid model from JSON', () {
      // Act
      final result = UserSettingsModel.fromJson(tJson);

      // Assert
      expect(result.isDarkMode, tModel.isDarkMode);
      expect(result.enableNotifications, tModel.enableNotifications);
      expect(result.preferredCurrency, tModel.preferredCurrency);
    });

    test('should handle null/missing fields gracefully during fromJson', () {
      // Arrange
      final incompleteJson = {
        'isDarkMode': null,
        'preferredCurrency': 'EUR',
      };

      // Act
      final result = UserSettingsModel.fromJson(incompleteJson);

      // Assert: Deve cair nos valores default definidos no fromJson
      expect(result.isDarkMode, false);
      expect(result.enableNotifications, true);
      expect(result.preferredCurrency, 'EUR');
    });

    test('should return a JSON map containing the proper data', () {
      // Act
      final result = tModel.toJson();

      // Assert
      expect(result, tJson);
    });

    test('copyWith should return a valid model with updated values', () {
      // Act
      final result = tModel.copyWith(isDarkMode: false, preferredCurrency: 'EUR');

      // Assert
      expect(result.isDarkMode, false); // Atualizado
      expect(result.enableNotifications, tModel.enableNotifications); // Mantido
      expect(result.preferredCurrency, 'EUR'); // Atualizado
    });
  });
}