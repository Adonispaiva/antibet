import 'package:antibet/features/auth/providers/user_provider.dart';
import 'packagepackage:antibet/utils/widgets/custom_button.dart';
import 'packagepackage:antibet/utils/widgets/custom_textfield.dart';
import 'packagepackage:flutter/material.dart';
import 'packagepackage:flutter_riverpod/flutter_riverpod.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitRegister() {
    // 1. Valida o formulário
    if (_formKey.currentState?.validate() ?? false) {
      // 2. Chama o provider para tentar o registro
      ref.read(userProvider.notifier).register(
            email: _emailController.text.trim(),
            name: _nameController.text.trim(),
            password: _passwordController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 3. Escuta o estado para side-effects (SnackBar e Navegação)
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
        loaded: (user) {
          // Em caso de sucesso (UserLoaded),
          // limpa a stack de navegação e volta para a tela anterior
          // (que agora será o HomeScreen -> JournalScreen)
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      );
    });

    // 4. Assiste ao estado para mudanças de UI (loading)
    final userState = ref.watch(userProvider);
    final isLoading = userState is UserLoading;

    return Scaffold(
      appBar: AppBar(
        // Adiciona um AppBar para permitir ao usuário voltar
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Criar Conta',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 48),

                // Campo de Nome
                CustomTextField(
                  key: const ValueKey('registerNameField'),
                  controller: _nameController,
                  labelText: 'Nome',
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu nome.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo de Email
                CustomTextField(
                  key: const ValueKey('registerEmailField'),
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
                  key: const ValueKey('registerPasswordField'),
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
                const SizedBox(height: 16),

                // Campo de Confirmação de Senha
                CustomTextField(
                  controller: _confirmPasswordController,
                  labelText: 'Confirme a Senha',
                  icon: Icons.lock_outline,
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'As senhas não conferem.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Botão de Cadastro
                CustomButton(
                  key: const ValueKey('registerButton'),
                  text: 'Cadastrar',
                  isLoading: isLoading,
                  onPressed: _submitRegister,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}