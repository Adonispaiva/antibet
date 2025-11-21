import 'package:antibet/features/journal/models/journal_entry_model.dart'; // NOVO: Importa a entrada
import 'package:equatable/equatable.dart';

/// [JournalModel] representa o diário de um usuário para um dia específico.
class JournalModel extends Equatable {
  const JournalModel({
    required this.id,
    required this.userId,
    required this.date, // Formato YYYY-MM-DD
    required this.totalBets,
    required this.totalWins,
    required this.totalLost,
    required this.profit,
    required this.entries,
  });

  final String id;
  final String userId;
  final String date;
  final int totalBets;
  final int totalWins;
  final int totalLost;
  final double profit;
  final List<JournalEntryModel> entries; // Lista de apostas individuais

  @override
  List<Object?> get props => [
        id,
        userId,
        date,
        totalBets,
        totalWins,
        totalLost,
        profit,
        entries,
      ];

  /// Construtor de fábrica para criar um [JournalModel] a partir de um JSON (Map).
  factory JournalModel.fromJson(Map<String, dynamic> json) {
    // Implementa a decodificação de 'entries'
    final entriesList = (json['entries'] as List)
        .map((entryJson) => JournalEntryModel.fromJson(entryJson as Map<String, dynamic>))
        .toList();

    return JournalModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: json['date'] as String,
      totalBets: json['totalBets'] as int,
      totalWins: json['totalWins'] as int,
      totalLost: json['totalLost'] as int,
      profit: (json['profit'] as num).toDouble(),
      entries: entriesList,
    );
  }

  /// Método para converter o [JournalModel] em um JSON (Map).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date,
      'totalBets': totalBets,
      'totalWins': totalWins,
      'totalLost': totalLost,
      'profit': profit,
      'entries': entries.map((e) => e.toJson()).toList(),
    };
  }

  /// Construtor helper para criar um modelo de diário vazio.
  factory JournalModel.empty(String date, {required String userId}) {
    return JournalModel(
      id: '', // Sem ID, pois não existe no banco
      userId: userId,
      date: date,
      totalBets: 0,
      totalWins: 0,
      totalLost: 0,
      profit: 0.0,
      entries: const [],
    );
  }
}