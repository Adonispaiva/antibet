/// Define o status de resultado de uma aposta registrada.
enum BetStatus {
  win,
  loss,
  pending,
  voided, // Nula ou cancelada
  unknown,
}

/// Representa o modelo de dados de uma entrada no Diário de Apostas.
///
/// Esta classe é usada para rastrear as apostas registradas pelo usuário.
class BetJournalEntryModel {
  final String id;
  final String strategyId; // ID da estratégia usada (ForeignKey)
  final BetStatus status;
  final double stake; // Valor apostado
  final double profit; // Lucro (pode ser negativo em caso de perda)
  final DateTime entryDate;
  final String notes;

  BetJournalEntryModel({
    required this.id,
    required this.strategyId,
    required this.status,
    required this.stake,
    required this.profit,
    required this.entryDate,
    this.notes = '',
  });

  /// Construtor de fábrica para criar uma instância de [BetJournalEntryModel] a partir de um Map (JSON Payload).
  factory BetJournalEntryModel.fromJson(Map<String, dynamic> json) {
    return BetJournalEntryModel(
      id: json['id'] as String,
      strategyId: json['strategyId'] as String,
      status: _parseBetStatus(json['status'] as String?),
      stake: (json['stake'] as num).toDouble(),
      profit: (json['profit'] as num).toDouble(),
      entryDate: DateTime.parse(json['entryDate'] as String),
      notes: json['notes'] as String? ?? '',
    );
  }

  /// Helper para converter string do payload para o Enum [BetStatus].
  static BetStatus _parseBetStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'win':
        return BetStatus.win;
      case 'loss':
        return BetStatus.loss;
      case 'pending':
        return BetStatus.pending;
      case 'voided':
        return BetStatus.voided;
      default:
        return BetStatus.unknown;
    }
  }

  /// Converte a instância em um Map (JSON).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'strategyId': strategyId,
      'status': status.name,
      'stake': stake,
      'profit': profit,
      'entryDate': entryDate.toIso8601String(),
      'notes': notes,
    };
  }
}