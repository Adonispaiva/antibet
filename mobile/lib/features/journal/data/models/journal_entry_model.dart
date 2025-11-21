class JournalEntryModel {
  final String id;
  final String description;
  final double amount;
  final bool isWin;
  final DateTime date;

  const JournalEntryModel({
    required this.id,
    required this.description,
    required this.amount,
    required this.isWin,
    required this.date,
  });

  /// Cria uma instância a partir de um Map (JSON).
  factory JournalEntryModel.fromJson(Map<String, dynamic> json) {
    return JournalEntryModel(
      id: json['id'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      isWin: json['isWin'] as bool,
      date: DateTime.parse(json['date'] as String),
    );
  }

  /// Converte a instância para um Map (JSON).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'isWin': isWin,
      'date': date.toIso8601String(),
    };
  }

  /// Cria uma cópia da instância com campos atualizados.
  JournalEntryModel copyWith({
    String? id,
    String? description,
    double? amount,
    bool? isWin,
    DateTime? date,
  }) {
    return JournalEntryModel(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      isWin: isWin ?? this.isWin,
      date: date ?? this.date,
    );
  }
}