import 'package:flutter/material.dart';

@immutable
class BetJournalEntryModel {
  final String id;
  final DateTime date;
  final String strategyId; // ID da estratégia utilizada (para análise)
  final String description;
  final double stake; // Valor apostado
  final String result; // 'Win', 'Loss', 'Push'
  final double payout; // Retorno total (incluindo o stake)

  const BetJournalEntryModel({
    required this.id,
    required this.date,
    required this.strategyId,
    required this.description,
    required this.stake,
    required this.result,
    required this.payout,
  });

  // Método auxiliar para calcular o lucro/prejuízo líquido
  double get netProfitLoss => payout - stake;

  // Método auxiliar para criar o modelo a partir de JSON (para desserialização do storage)
  factory BetJournalEntryModel.fromJson(Map<String, dynamic> json) {
    return BetJournalEntryModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      strategyId: json['strategyId'] as String,
      description: json['description'] as String,
      // Garante que os números sejam lidos como double
      stake: (json['stake'] as num).toDouble(), 
      result: json['result'] as String,
      payout: (json['payout'] as num).toDouble(),
    );
  }

  // Método auxiliar para converter o modelo para JSON (para serialização no storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'strategyId': strategyId,
      'description': description,
      'stake': stake,
      'result': result,
      'payout': payout,
    };
  }
  
  // Opcional: Implementar equals e hashCode para testes e comparação, mas omitido aqui por simplicidade.
}