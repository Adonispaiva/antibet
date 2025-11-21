import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:antibet/main_app_wrapper.dart';
import 'package:antibet/core/network/dio_provider.dart'; // Importado para inicialização (opcional)

void main() async {
  // Garante que o binding do Flutter esteja inicializado antes de qualquer chamada nativa
  WidgetsFlutterBinding.ensureInitialized();
  
  // Opcional: Aqui poderíamos inicializar o SharedPreferences, Firebase, etc.
  // No nosso caso, o AuthService lida com SharedPreferences.

  // O CustomDio é centralizado, mas não precisa de inicialização assíncrona aqui.
  // CustomDio.initialize(); 

  runApp(
    // O ProviderScope é obrigatório para que o Riverpod funcione em todo o aplicativo
    const ProviderScope(
      child: MainAppWrapper(),
    ),
  );
}