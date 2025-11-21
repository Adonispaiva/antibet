import 'package:json_annotation/json_annotation.dart';

part 'journal_entry_model.g.dart';

@JsonSerializable()
class JournalEntryModel {
  final String id;
  final double amount;
  final String description;
  final DateTime date;
  final String type; // 'bet', 'deposit', 'withdraw'

  JournalEntryModel({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    this.type = 'bet',
  });

  factory JournalEntryModel.fromJson(Map<String, dynamic> json) => _$JournalEntryModelFromJson(json);

  Map<String, dynamic> toJson() => _$JournalEntryModelToJson(this);

  // Método copyWith para facilitar a atualização imutável do estado
  JournalEntryModel copyWith({
    String? id,
    double? amount,
    String? description,
    DateTime? date,
    String? type,
  }) {
    return JournalEntryModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      type: type ?? this.type,
    );
  }
}