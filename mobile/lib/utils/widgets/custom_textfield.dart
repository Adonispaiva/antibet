import 'packagepackage:flutter/material.dart';

/// [CustomTextField] é um wrapper reutilizável do [TextFormField]
/// com um estilo padronizado para o app AntiBet.
class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.icon,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String labelText;
  final IconData? icon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: icon != null
            ? Icon(
                icon,
                color: theme.colorScheme.primary,
              )
            : null,
        
        // Estilo da borda padrão
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        
        // Estilo da borda em foco
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.0),
        ),
        
        // Estilo da borda em erro
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 1.0),
        ),
        
        // Estilo da borda em foco com erro
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2.0),
        ),
        
        filled: true,
        fillColor: theme.colorScheme.surface,
      ),
    );
  }
}