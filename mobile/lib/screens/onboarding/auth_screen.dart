import 'package:flutter/material.dart';
import 'package:inovexa_antibet/providers/auth_provider.dart';
import 'package:inovexa_antibet/providers/user_provider.dart';
import 'package:inovexa_antibet/utils/app_colors.dart';
import 'package:inovexa_antibet/utils/app_typography.dart';
import 'package:inovexa_antibet/widgets/app_layout.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Controla se a tela está em modo Login ou Registro
  bool _isLoginMode = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Esconde o teclado
    FocusScope.of(context).unfocus();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success = false;

    if (_isLoginMode) {
      success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    } else {
      // Modo Registro: Combina dados do UserProvider com os do formulário
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      // Validação extra para garantir que o UserProvider tem os dados
      if (userProvider.avatarName == null || userProvider.birthYear == null) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro interno: Dados do Onboarding não encontrados.')),
        );
        return;
      }

      final Map<String, dynamic> registrationData = {
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(),
        'avatarName': userProvider.avatarName,
        'gender': userProvider.gender,
        'birthYear': userProvider.birthYear,
        'mainConcern': userProvider.mainConcern,
      };

      success = await authProvider.register(registrationData);
    }

    if (!success && mounted) {
      // Se a submissão falhar, mostra o erro vindo do provider
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.authError ?? 'Ocorreu um erro.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
    // Se 'success' for true, o 'main.dart' (que estará ouvindo o AuthProvider)
    // navegará automaticamente para a tela Home.
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return AppLayout(
      title: _isLoginMode ? 'Acessar Conta' : 'Criar Conta',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isLoginMode
                    ? 'Bem-vindo de volta!'
                    : 'Estamos quase lá. Crie sua conta para começar.',
                style: AppTypography.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Campo de E-mail
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty || !value.contains('@')) {
                    return 'Por favor, insira um e-mail válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo de Senha
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.trim().length < 6) {
                    return 'A senha deve ter pelo menos 6 caracteres.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Botão de Ação (Login/Registro)
              authProvider.status == AuthStatus.loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: Text(_isLoginMode ? 'Entrar' : 'Finalizar Cadastro'),
                    ),
              
              const SizedBox(height: 16),

              // Botão para alternar o modo
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLoginMode = !_isLoginMode;
                  });
                },
                child: Text(
                  _isLoginMode
                      ? 'Não tem uma conta? Cadastre-se'
                      : 'Já tem uma conta? Faça login',
                  style: AppTypography.body.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}