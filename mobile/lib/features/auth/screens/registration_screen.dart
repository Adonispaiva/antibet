// mobile/lib/features/auth/screens/registration_screen.dart

import 'package:antibet/features/auth/notifiers/auth_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  // Controladores para o formulário
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

  /// Tenta realizar o registro de um novo usuário.
  Future<void> _attemptRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return; // Falha na validação
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'As senhas não coincidem.';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Acessa o Notifier
      final authNotifier = context.read<AuthNotifier>();
      final success = await authNotifier.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!success && mounted) {
        setState(() {
          _errorMessage = 'Falha no registro. O email pode já estar em uso.';
        });
      }
      // Se 'success' for true, o AuthWrapper (em main.dart) 
      // detectará a mudança no 'isAuthenticated' e navegará automaticamente.
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro inesperado: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Nova Conta'),
        elevation: 0,
        backgroundColor: Colors.transparent, // Permite fundo de gradiente
        foregroundColor: Colors.white, // Cor do texto/ícones
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Bem-vindo ao AntiBet',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      
                      // Campo de Nome
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'O nome é obrigatório.'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      
                      // Campo de Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => (value == null || !value.contains('@'))
                            ? 'Insira um email válido.'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      
                      // Campo de Senha
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Senha (mín. 6 caracteres)',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => (value == null || value.length < 6)
                            ? 'A senha deve ter pelo menos 6 caracteres.'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      
                      // Campo de Confirmação de Senha
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Confirmar Senha',
                          prefixIcon: Icon(Icons.lock_reset),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Confirme sua senha.'
                            : null,
                      ),
                      const SizedBox(height: 24),

                      // Mensagem de Erro
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      
                      // Botão de Registro
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _attemptRegistration,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Registrar', style: TextStyle(fontSize: 16)),
                            ),
                      
                      const SizedBox(height: 16),
                      
                      // Link para Login
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Volta para a Tela de Login
                        },
                        child: const Text('Já tem uma conta? Entrar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}