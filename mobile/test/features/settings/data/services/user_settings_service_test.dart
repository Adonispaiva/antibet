import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:antibet/core/local_storage/storage_service.dart';
import 'package:antibet/features/settings/data/models/user_settings_model.dart';
import 'package:antibet/features/settings/data/services/user_settings_service.dart';

// Mocks
class MockStorageService extends Mock implements StorageService {}

void main() {
  late MockStorageService mockStorageService;
  late UserSettingsService settingsService;

  const String settingsKey = 'user_settings';
  
  // Modelo de teste
  const tSettings = UserSettingsModel(
    isDarkMode: true,
    enableNotifications: false,
    preferredCurrency: 'USD',
  );

  final tJsonString = json.encode(tSettings.toJson());

  setUp(() {
    mockStorageService = MockStorageService();
    settingsService = UserSettingsService(mockStorageService);
    
    registerFallbackValue(settingsKey);
    registerFallbackValue(tJsonString);
  });

  group('UserSettingsService Load Settings', () {
    test('should return stored settings when data is present and valid', () {
      // Arrange
      when(() => mockStorageService.getString(settingsKey)).thenReturn(tJsonString);

      // Act
      final result = settingsService.loadSettings();

      // Assert
      expect(result.isDarkMode, true);
      expect(result.preferredCurrency, 'USD');
      verify(() => mockStorageService.getString(settingsKey)).called(1);
    });

    test('should return default settings (initial) when no data is found', () {
      // Arrange
      when(() => mockStorageService.getString(settingsKey)).thenReturn(null);

      // Act
      final result = settingsService.loadSettings();

      // Assert
      expect(result.isDarkMode, false);
      expect(result.preferredCurrency, 'BRL');
      expect(result.enableNotifications, true);
    });

    test('should return default settings (initial) when stored data is invalid JSON', () {
      // Arrange
      when(() => mockStorageService.getString(settingsKey)).thenReturn('{"isDarkMode": invalid}');

      // Act
      final result = settingsService.loadSettings();

      // Assert: Deve cair no catch e retornar o padrão
      expect(result.isDarkMode, false);
      expect(result.preferredCurrency, 'BRL');
    });
  });

  group('UserSettingsService Save Settings', () {
    test('should call setString with correct JSON string on success', () async {
      // Arrange
      when(() => mockStorageService.setString(settingsKey, tJsonString)).thenAnswer((_) async => true);

      // Act
      final result = await settingsService.saveSettings(tSettings);

      // Assert
      expect(result, true);
      verify(() => mockStorageService.setString(settingsKey, tJsonString)).called(1);
    });

    test('should return false if setString fails', () async {
      // Arrange
      when(() => mockStorageService.setString(settingsKey, any())).thenAnswer((_) async => false);

      // Act
      final result = await settingsService.saveSettings(tSettings);

      // Assert
      expect(result, false);
    });
  });
}