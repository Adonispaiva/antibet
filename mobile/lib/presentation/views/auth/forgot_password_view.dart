import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  
  bool _isLoading = false;
  String? _message;

  // Função para simular o envio do link de recuperação
  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _message = null;
    });

    // Simulação de chamada de serviço para enviar e-mail
    await Future.delayed(const Duration(seconds: 2)); 

    setState(() {
      _isLoading = false;
      _message = 'Um link de recuperação foi enviado para o seu e-mail.';
    });
    
    // Após o sucesso, pode-se navegar de volta para o login
    // Ou permanecer na tela com a mensagem de sucesso
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Senha'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Icon(Icons.lock_reset, size: 80, color: Theme.of(context).primaryColor),
                const SizedBox(height: 40),

                const Text(
                  'Esqueceu sua senha?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Insira o e-mail cadastrado e enviaremos um link para você redefinir sua senha.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 30),

                // Campo E-mail
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value == null || !value.contains('@') ? 'Insira um e-mail válido.' : null,
                ),
                const SizedBox(height: 30),

                // Botão de Recuperação
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleReset,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Enviar Link', style: TextStyle(fontSize: 18)),
                ),
                
                // Exibição de Mensagem
                if (_message != null) 
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Text(
                      _message!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold),
                    ),
                  ),
                
                const SizedBox(height: 40),

                // Link de retorno
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Voltar para o Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}