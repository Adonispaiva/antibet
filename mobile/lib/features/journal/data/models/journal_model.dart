import 'package:antibet/features/journal/data/models/journal_entry_model.dart';

class JournalModel {
  final List<JournalEntryModel> entries;
  final double totalInvested;
  final int totalWins;
  final int totalLosses;

  const JournalModel({
    required this.entries,
    required this.totalInvested,
    required this.totalWins,
    required this.totalLosses,
  });

  factory JournalModel.fromJson(Map<String, dynamic> json) {
    return JournalModel(
      entries: (json['entries'] as List<dynamic>?)
              ?.map((e) => JournalEntryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalInvested: (json['totalInvested'] as num?)?.toDouble() ?? 0.0,
      totalWins: json['totalWins'] as int? ?? 0,
      totalLosses: json['totalLosses'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entries': entries.map((e) => e.toJson()).toList(),
      'totalInvested': totalInvested,
      'totalWins': totalWins,
      'totalLosses': totalLosses,
    };
  }
}