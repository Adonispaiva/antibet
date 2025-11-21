import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:antibet/core/local_storage/storage_service.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPrefs;
  late StorageService storageService;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    storageService = StorageService(mockPrefs);
  });

  group('StorageService Unit Test', () {
    const tKey = 'auth_token';
    const tValue = 'jwt_token_123';

    test('getString should return stored value', () {
      // Arrange
      when(() => mockPrefs.getString(tKey)).thenReturn(tValue);

      // Act
      final result = storageService.getString(tKey);

      // Assert
      expect(result, tValue);
      verify(() => mockPrefs.getString(tKey)).called(1);
    });

    test('setString should save value successfully', () async {
      // Arrange
      when(() => mockPrefs.setString(tKey, tValue)).thenAnswer((_) async => true);

      // Act
      final result = await storageService.setString(tKey, tValue);

      // Assert
      expect(result, true);
      verify(() => mockPrefs.setString(tKey, tValue)).called(1);
    });

    test('getBool should return stored boolean value', () {
      // Arrange
      when(() => mockPrefs.getBool('is_dark_mode')).thenReturn(true);

      // Act
      final result = storageService.getBool('is_dark_mode');

      // Assert
      expect(result, true);
    });

    test('setBool should save boolean value successfully', () async {
      // Arrange
      when(() => mockPrefs.setBool('is_dark_mode', false)).thenAnswer((_) async => true);

      // Act
      final result = await storageService.setBool('is_dark_mode', false);

      // Assert
      expect(result, true);
      verify(() => mockPrefs.setBool('is_dark_mode', false)).called(1);
    });

    test('remove should delete key successfully', () async {
      // Arrange
      when(() => mockPrefs.remove(tKey)).thenAnswer((_) async => true);

      // Act
      final result = await storageService.remove(tKey);

      // Assert
      expect(result, true);
      verify(() => mockPrefs.remove(tKey)).called(1);
    });

    test('clear should remove all data', () async {
      // Arrange
      when(() => mockPrefs.clear()).thenAnswer((_) async => true);

      // Act
      final result = await storageService.clear();

      // Assert
      expect(result, true);
      verify(() => mockPrefs.clear()).called(1);
    });
  });
}