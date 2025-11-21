import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:antibet/core/utils/snackbar_utils.dart';
import 'package:antibet/features/auth/data/services/auth_service.dart';
import 'package:antibet/features/auth/presentation/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Usamos o estado do Provider para o loading/error, mas mantemos o estado local para o formulário.
  bool get _isLoading => ref.watch(authProvider).isLoading;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    ref.read(authProvider.notifier).setLoading();

    try {
      final authService = ref.read(authServiceProvider);
      
      // Chamada ao serviço de autenticação
      final token = await authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // Atualiza o estado global de autenticação, persistindo o token
      await ref.read(authProvider.notifier).setToken(token);

      if (mounted) {
        SnackBarUtils.showSuccess(context, 'Login realizado com sucesso!');
        // A lógica de redirect no app_router deve levar para /journal.
        // Se já estiver na tela de login, o 'go' apenas garante a navegação segura.
        context.go('/journal');
      }
    } catch (e) {
      // Atualiza o provider com o erro
      ref.read(authProvider.notifier).setError(e.toString());
      
      if (mounted) {
        final message = e.toString().replaceAll('Exception: ', '');
        SnackBarUtils.showError(context, message);
      }
    } 
    // O finally não é mais necessário aqui, pois o setError ou setToken limpam o loading do provider.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: Color(0xFF263238), // Primary Color
                ),
                const SizedBox(height: 32),
                const Text(
                  'Bem-vindo ao AntiBet',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  key: const Key('email_field'),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu e-mail.';
                    }
                    if (!value.contains('@')) {
                      return 'Insira um e-mail válido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('password_field'),
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira sua senha.';
                    }
                    if (value.length < 6) {
                      return 'A senha deve ter pelo menos 6 caracteres.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  key: const Key('login_button'),
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('ENTRAR'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _isLoading ? null : () {
                    context.go('/register');
                  },
                  child: const Text('Não tem uma conta? Registre-se'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}