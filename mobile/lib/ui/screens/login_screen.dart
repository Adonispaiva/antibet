import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:antibet/core/notifiers/auth_notifier.dart';
import 'package:antibet/core/notifiers/app_config_notifier.dart';
import 'package:antibet/ui/widgets/custom_text_field.dart'; // Importação do widget reutilizável

/// Tela responsável por receber as credenciais do usuário e acionar o processo de autenticação.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Lógica de login que chama o AuthNotifier.
  void _performLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      // Futuramente, exibirá um Snackbar com erro
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    
    // Chama o método login simulado no Notifier
    await authNotifier.login(_emailController.text, _passwordController.text);
    
    // Nota: O roteamento para a Dashboard é feito automaticamente pelo AuthCheckerScreen
    // no app_routes.dart, pois o estado de autenticação mudará.

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usa o AppConfigNotifier para permitir que o tema seja alternado
    final appConfig = Provider.of<AppConfigNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AntiBet Login'),
        actions: [
          // Botão para alternar o tema (para fins de teste inicial)
          IconButton(
            icon: Icon(appConfig.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: appConfig.toggleTheme,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Logo ou Título Principal
              const Text(
                'Bem-vindo ao AntiBet',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // Campo de E-mail (Refatorado)
              CustomTextField(
                controller: _emailController,
                labelText: 'E-mail',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              // Campo de Senha (Refatorado)
              CustomTextField(
                controller: _passwordController,
                labelText: 'Senha',
                icon: Icons.lock,
                isPassword: true,
              ),
C              const SizedBox(height: 30),

              // Botão de Login
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _performLogin,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Entrar',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Placeholder para outras ações
              TextButton(
                onPressed: () {
                  // Ação de recuperação de senha (a ser implementada)
                },
                child: const Text('Esqueceu a senha?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}