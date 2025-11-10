import 'package:flutter/material.dart';

// Este provider gerencia os dados coletados no onboarding antes de registrar o usuário
class UserProvider with ChangeNotifier {
  String _name = '';
  String? _gender; // 'M', 'F', 'O'
  int? _birthYear;
  String? _gamblingDuration; // Pouco tempo, Anos, etc.
  int? _concernLevel; // 1 a 5

  String get name => _name;
  String? get gender => _gender;
  int? get birthYear => _birthYear;
  String? get gamblingDuration => _gamblingDuration;
  int? get concernLevel => _concernLevel;

  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  void setGender(String value) {
    _gender = value;
    notifyListeners();
  }

  void setBirthYear(int value) {
    _birthYear = value;
    notifyListeners();
  }

  void setGamblingDuration(String value) {
    _gamblingDuration = value;
    notifyListeners();
  }

  void setConcernLevel(int value) {
    _concernLevel = value;
    notifyListeners();
  }

  // Objeto DTO (Data Transfer Object) para ser enviado ao Backend (AuthService)
  Map<String, dynamic> toRegistrationPayload() {
    return {
      'name': _name,
      'gender': _gender,
      'birthYear': _birthYear,
      // Estes campos serão usados para configurar o primeiro prompt da IA
      'gamblingDuration': _gamblingDuration, 
      'concernLevel': _concernLevel,
      // NOTA: 'email' e 'password' serão adicionados na próxima tela (login/registro).
    };
  }

  // Limpa o estado após o registro bem-sucedido ou logout
  void clearState() {
    _name = '';
    _gender = null;
    _birthYear = null;
    _gamblingDuration = null;
    _concernLevel = null;
    notifyListeners();
  }
}