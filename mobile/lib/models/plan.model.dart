/// Modelo de dados para um Plano (espelha a entidade 'Plan' do NestJS)
class Plan {
  final String id;
  final String name; // Ex: "Gratuito", "Autocontrole"
  final String description;
  final double price;
  final int aiDailyLimit; // Limite de interações diárias

  Plan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.aiDailyLimit,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      // Garante que o TypeORM (que pode enviar string) seja convertido para double
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      aiDailyLimit: json['aiDailyLimit'],
    );
  }

  // Plano 'fallback' caso o usuário não tenha plano (como definido no PlansService)
  static Plan fallbackFreePlan() {
    return Plan(
      id: 'fallback',
      name: 'Gratuito (Fallback)',
      description: 'Plano padrão.',
      price: 0.0,
      aiDailyLimit: 5, // (Default)
    );
  }
}