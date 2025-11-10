import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:antibet_mobileapp/core/routing/app_routes.dart';
import 'package:antibet_mobileapp/controllers/auth/register_controller.dart';
import 'package:antibet_mobileapp/core/style/app_colors.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterController(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Criar Conta'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Consumer<RegisterController>(
          builder: (context, controller, child) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: _RegisterForm(controller: controller),
            );
          },
        ),
      ),
    );
  }
}

class _RegisterForm extends StatefulWidget {
  final RegisterController controller;
  const _RegisterForm({required this.controller});

  @override
  State<_RegisterForm> createState() => __RegisterFormState();
}

class __RegisterFormState extends State<_RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.controller.register(
        _emailController.text,
        _passwordController.text,
        _nameController.text,
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome Completo'),
              validator: (v) => v!.isEmpty ? 'O nome é obrigatório' : null,
              onChanged: (_) => widget.controller.clearError(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-mail'),
              keyboardType: TextInputType.emailAddress,
              validator: (v) => v!.isEmpty || !v.contains('@') ? 'E-mail inválido' : null,
              onChanged: (_) => widget.controller.clearError(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
              validator: (v) => v!.length < 6 ? 'A senha deve ter 6+ caracteres' : null,
              onChanged: (_) => widget.controller.clearError(),
            ),
            const SizedBox(height: 24),

            if (widget.controller.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  widget.controller.errorMessage!,
                  style: const TextStyle(color: AppColors.errorColor),
                  textAlign: TextAlign.center,
                ),
              ),

            ElevatedButton(
              onPressed: widget.controller.isLoading ? null : _submit,
              child: widget.controller.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Registrar'),
            ),
            
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              },
              child: const Text('Já tem uma conta? Faça Login'),
            ),
          ],
        ),
      ),
    );
  }
}