import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:antibet/src/core/notifiers/user_profile_notifier.dart';
import 'package:antibet/src/core/services/user_profile_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _birthYearMonthController = TextEditingController();
  
  // Dados do formulário
  String? _selectedGender;
  String? _selectedTimeBetting;
  int? _selectedConcernLevel;

  // Opções para Dropdowns (conforme o fluxo)
  final List<String> _genderOptions = ['Masculino', 'Feminino', 'Outro', 'Prefiro não dizer'];
  final List<String> _timeBettingOptions = ['nunca', 'pouco tempo', 'anos']; //
  final List<int> _concernLevelOptions = [1, 2, 3, 4, 5]; //

  // Função para salvar e navegar
  Future<void> _handleRegistration() async {
    if (_formKey.currentState!.validate()) {
      final notifier = context.read<UserProfileNotifier>();

      final newProfile = UserProfile(
        nickname: _nicknameController.text.trim(),
        gender: _selectedGender,
        birthYearMonth: _birthYearMonthController.text.trim(),
        timeBetting: _selectedTimeBetting,
        concernLevel: _selectedConcernLevel,
      );

      // Atualiza o perfil no Notifier/Service
      await notifier.updateProfile(newProfile);

      // Navega para a próxima etapa: Autoavaliação de Risco
      context.go('/assessment'); 
    }
  }

  // Seletor de Ano e Mês (simples)
  Future<void> _selectDate(BuildContext context) async {
    // Implementação simplificada de seleção de data para o MVP
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20), // 20 anos atrás como padrão
      firstDate: DateTime(1950),
      lastDate: now,
    );
    if (picked != null) {
      // Salva no formato YYYY-MM
      setState(() {
        _birthYearMonthController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro Inicial'),
        automaticallyImplyLeading: false, 
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Conte-nos um pouco sobre você para personalizarmos seu apoio.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 25),

              // 1. Nome ou apelido
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(labelText: 'Nome ou Apelido'),
                validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório.' : null,
              ),
              const SizedBox(height: 20),

              // 2. Sexo (para personalização da IA)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Sexo'),
                initialValue: _selectedGender,
                items: _genderOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
                validator: (value) => value == null ? 'Campo obrigatório.' : null,
              ),
              const SizedBox(height: 20),
              
              // 3. Ano e mês de nascimento (para adaptação da conversa)
              TextFormField(
                controller: _birthYearMonthController,
                decoration: const InputDecoration(
                  labelText: 'Ano e Mês de Nascimento (AAAA-MM)',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório.' : null,
              ),
              const SizedBox(height: 30),

              // 4. Há quanto tempo aposta
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Há quanto tempo aposta?'),
                initialValue: _selectedTimeBetting,
                items: _timeBettingOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.substring(0, 1).toUpperCase() + value.substring(1)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTimeBetting = newValue;
                  });
                },
                validator: (value) => value == null ? 'Campo obrigatório.' : null,
              ),
              const SizedBox(height: 20),

              // 5. Nível de preocupação com apostas (1 a 5)
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Nível de preocupação com apostas (1=Baixo, 5=Alto)'),
                initialValue: _selectedConcernLevel,
                items: _concernLevelOptions.map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value'),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedConcernLevel = newValue;
                  });
                },
                validator: (value) => value == null ? 'Campo obrigatório.' : null,
              ),
              const SizedBox(height: 40),

              // Botão: Começar minha jornada
              ElevatedButton.icon(
                onPressed: _handleRegistration,
                icon: const Icon(Icons.arrow_forward_ios),
                label: const Text('Começar minha jornada', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}