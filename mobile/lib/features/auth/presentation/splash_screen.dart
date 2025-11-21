import 'packagepackage:antibet/features/auth/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// [SplashScreen] é exibida durante a inicialização do app.
///
/// Sua principal responsabilidade é acionar a lógica de
/// verificação de sessão (o `loadUser()` no `UserProvider`)
/// assim que o widget é construído.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  
  @override
  void initState() {
    super.initState();
    // Assim que o widget é inicializado, chama a lógica
    // para carregar o usuário.
    // Usamos 'addPostFrameCallback' para garantir que a chamada
    // seja feita *após* o primeiro frame ser construído,
    // evitando erros de build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Usamos 'ref.read' pois estamos em um 'initState' (ou callback)
      // e só queremos acionar a ação uma vez, sem escutar
      // mudanças de estado aqui.
      ref.read(userProvider.notifier).loadUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    // A SplashScreen em si é visualmente simples,
    // apenas mostrando um indicador de carregamento.
    // O HomeScreen é quem escuta a mudança de estado
    // (de UserLoading para UserLoaded/UserLoggedOut)
    // e decide para qual tela navegar.
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}