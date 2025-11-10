import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_typography.dart';
import '../../widgets/app_layout.dart';
// import 'auth_screen.dart'; // Próxima tela: Login/Autenticação

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return AppLayout(
      title: '1/3 - Seu Perfil',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: FormBuilder(
          key: _formKey,
          initialValue: {
            'gambling_duration': 'Pouco tempo',
            'concern_level': 3.0,
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Precisamos de alguns dados para personalizar seu AntiBet Coach. Seus dados são confidenciais.',
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // 1. Nome/Apelido
              FormBuilderTextField(
                name: 'name',
                decoration: const InputDecoration(labelText: 'Seu Nome ou Apelido'),
                validator: FormBuilderValidators.required(errorText: 'Nome é obrigatório'),
                onChanged: userProvider.setName,
              ),
              const SizedBox(height: 16),

              // 2. Ano de Nascimento
              FormBuilderTextField(
                name: 'birthYear',
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Ano de Nascimento (Ex: 1995)'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'O ano é obrigatório'),
                  FormBuilderValidators.numeric(errorText: 'Deve ser um número'),
                  FormBuilderValidators.max(DateTime.now().year, errorText: 'Ano inválido'),
                ]),
                onChanged: (val) {
                  if (val != null) {
                    userProvider.setBirthYear(int.tryParse(val) ?? 0);
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // 3. Sexo/Gênero
              FormBuilderDropdown<String>(
                name: 'gender',
                decoration: const InputDecoration(labelText: 'Sexo/Gênero'),
                validator: FormBuilderValidators.required(errorText: 'Gênero é obrigatório'),
                items: ['Masculino', 'Feminino', 'Outro', 'Prefiro não informar']
                    .map((gender) => DropdownMenuItem(
                          value: gender.substring(0, 1).toUpperCase(),
                          child: Text(gender),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    userProvider.setGender(val);
                  }
                },
              ),
              const SizedBox(height: 24),

              // 4. Há quanto tempo aposta
              FormBuilderDropdown<String>(
                name: 'gambling_duration',
                decoration: const InputDecoration(labelText: 'Há quanto tempo você aposta (Regularmente)?'),
                items: ['Pouco tempo (até 6 meses)', 'Meses (6 meses a 1 ano)', 'Anos (Mais de 1 ano)', 'Nunca ou Raramente']
                    .map((duration) => DropdownMenuItem(
                          value: duration,
                          child: Text(duration),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    userProvider.setGamblingDuration(val);
                  }
                },
              ),
              const SizedBox(height: 24),

              // 5. Nível de Preocupação
              Text(
                'Nível de preocupação com suas apostas (1=Nenhuma, 5=Máxima): ${userProvider.concernLevel ?? 3}',
                style: AppTypography.bodyMedium,
              ),
              FormBuilderSlider(
                name: 'concern_level',
                min: 1.0,
                max: 5.0,
                initialValue: 3.0,
                divisions: 4,
                activeColor: AppColors.warningOrange,
                inactiveColor: AppColors.textSecondary.withOpacity(0.3),
                displayValues: true,
                onChanged: (val) {
                  if (val != null) {
                    userProvider.setConcernLevel(val.round());
                  }
                },
              ),
              
              const SizedBox(height: 48),

              // Botão: Próxima Etapa
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.positiveGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (_formKey.currentState?.saveAndValidate() ?? false) {
                    // Dados foram salvos no UserProvider. 
                    // Próxima etapa: Tela de Autenticação/Registro Completo.
                    // Navigator.of(context).pushReplacement(
                    //   MaterialPageRoute(
                    //     builder: (context) => const AuthScreen(),
                    //   ),
                    // );
                    
                    // Substituindo pelo placeholder até a criação da AuthScreen
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Dados coletados com sucesso. Próxima tela: Autenticação/Login', style: AppTypography.labelMedium.copyWith(color: Colors.white)))
                    );
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const Center(child: Text("Tela de Autenticação/Login (Próxima Sessão)", style: TextStyle(color: Colors.black))),
                      ),
                    );
                  }
                },
                child: Text(
                  'Começar minha jornada',
                  style: AppTypography.labelLarge.copyWith(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}