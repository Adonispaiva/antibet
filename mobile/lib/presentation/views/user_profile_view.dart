import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Necessário para formatação de data/hora

// Importações dos notifiers e modelos
import '../../notifiers/user_profile_notifier.dart';
import '../../core/domain/user_profile_model.dart';

class UserProfileView extends StatefulWidget {
  const UserProfileView({super.key});

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  DateTime? _selectedDate;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Inicia a busca pelo perfil assim que a View for construída
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProfileNotifier>().fetchProfile();
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  /// Popula os controllers com os dados do perfil
  void _populateControllers(UserProfileModel profile) {
    _fullNameController.text = profile.fullName;
    _phoneController.text = profile.phoneNumber ?? '';
    if (profile.dateOfBirth != null) {
      _selectedDate = profile.dateOfBirth;
      _dobController.text = DateFormat('dd/MM/yyyy').format(profile.dateOfBirth!);
    } else {
      _selectedDate = null;
      _dobController.text = '';
    }
  }

  /// Manipula o salvamento das alterações do perfil
  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final notifier = context.read<UserProfileNotifier>();

      try {
        await notifier.updateProfile(
          fullName: _fullNameController.text,
          phoneNumber: _phoneController.text.isNotEmpty ? _phoneController.text : null,
          dateOfBirth: _selectedDate,
        );
        setState(() {
          _isEditing = false; // Sai do modo de edição em caso de sucesso
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
      } catch (e) {
        // O erro já foi definido no Notifier; apenas exibe a mensagem de erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(notifier.errorMessage ?? 'Erro ao salvar perfil.')),
        );
      }
    }
  }
  
  /// Selecionador de Data de Nascimento
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().subtract(const Duration(days: 365 * 18)), // 18 anos atrás
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        actions: <Widget>[
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _handleSave,
            ),
        ],
      ),
      // O Consumer (ou Selector) reage às mudanças no Notifier
      body: Consumer<UserProfileNotifier>(
        builder: (context, notifier, child) {
          if (notifier.state == ProfileState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (notifier.state == ProfileState.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Erro: ${notifier.errorMessage}', style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: notifier.fetchProfile, // Tenta recarregar
                      child: const Text('Tentar Novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          final profile = notifier.userProfile;
          if (profile == null) {
             // Se não houver perfil e não estiver em erro/loading (ex: erro no backend/token)
             return const Center(child: Text('Nenhum dado de perfil disponível.'));
          }

          // Garante que os controllers sejam populados APENAS quando o perfil for carregado
          // e o modo de edição for iniciado, ou se os dados tiverem mudado.
          if (_fullNameController.text.isEmpty || !_isEditing) {
             _populateControllers(profile);
          }


          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Campo Nome Completo
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(labelText: 'Nome Completo'),
                    enabled: _isEditing,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'O nome completo é obrigatório';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  // Campo Telefone
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Telefone'),
                    keyboardType: TextInputType.phone,
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 15),
                  // Campo Data de Nascimento
                  TextFormField(
                    controller: _dobController,
                    decoration: const InputDecoration(
                      labelText: 'Data de Nascimento',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true, // A data deve ser selecionada pelo picker
                    enabled: _isEditing,
                    onTap: _isEditing ? () => _selectDate(context) : null,
                  ),
                  const SizedBox(height: 30),
                  
                  if (_isEditing)
                    Center(
                      child: ElevatedButton(
                        onPressed: _handleSave,
                        child: const Text('Salvar Alterações'),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}