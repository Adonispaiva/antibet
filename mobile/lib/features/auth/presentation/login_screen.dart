import 'packagepackage:antibet/features/auth/presentation/register_screen.dart';
import 'packagepackage:antibet/features/auth/providers/user_provider.dart';
import 'packagepackage:antibet/utils/widgets/custom_button.dart';
import 'packagepackage:antibet/utils/widgets/custom_textfield.dart';
import 'packagepackage:flutter/material.dart';
import 'packagepackage:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    // 1. Valida o formulário
    if (_formKey.currentState?.validate() ?? false) {
      // 2. Chama o provider para tentar o login
      ref.read(userProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
    }
  }

  void _navigateToRegister() {
    // Navega para a tela de registro
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 3. Escuta o estado para side-effects (como SnackBar)
    ref.listen<UserState>(userProvider, (previous, next) {
      next.whenOrNull(
        error: (message) {
          // Em caso de erro, exibe um SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        },
      );
    });

    // 4. Assiste ao estado para mudanças de UI (loading)
    final userState = ref.watch(userProvider);
    final isLoading = userState is UserLoading;

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
                // TODO: Adicionar Logo/Título
                Text(
                  'AntiBet',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 48),

                // Campo de Email
                CustomTextField(
                  key: const ValueKey('loginEmailField'),
                  controller: _emailController,
                  labelText: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty || !value.contains('@')) {
                      return 'Por favor, insira um email válido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo de Senha
                CustomTextField(
                  key: const ValueKey('loginPasswordField'),
                  controller: _passwordController,
                  labelText: 'Senha',
                  icon: Icons.lock_outline,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 6) {
                      return 'A senha deve ter pelo menos 6 caracteres.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Botão de Login
                CustomButton(
                  key: const ValueKey('loginButton'),
                  text: 'Entrar',
                  isLoading: isLoading,
                  onPressed: _submitLogin,
                ),
                const SizedBox(height: 24),

                // Botão para criar conta
                TextButton(
                  onPressed: isLoading ? null : _navigateToRegister,
                  child: Text(
                    'Não tem uma conta? Crie uma',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}