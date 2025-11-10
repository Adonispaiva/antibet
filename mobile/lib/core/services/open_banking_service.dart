import 'package:flutter/material.dart'; // Necessário para DateTime
import 'dart:math';

// O Serviço de Open Banking simula a integração segura com a API do banco/agregador
// para coletar dados transacionais e calcular perdas reais.

// --- MODELOS DE DADOS ---

class Transaction {
  final String id;
  final DateTime date;
  final String description;
  final double amount; // Valor negativo para débito, positivo para crédito
  final bool isBettingRelated; // Classificado pela IA/Regras do Serviço

  Transaction({
    required this.id,
    required this.date,
    required this.description,
    required this.amount,
    this.isBettingRelated = false,
  });
}

// --- SERVIÇO CORE ---

class OpenBankingService {
  bool _isConnected = false;

  // Lista simulada de transações (dados de exemplo)
  final List<Transaction> _mockTransactions = [
    Transaction(id: 't1', date: DateTime.now().subtract(const Duration(days: 5)), description: 'Pix Bet365', amount: -150.00, isBettingRelated: true),
    Transaction(id: 't2', date: DateTime.now().subtract(const Duration(days: 3)), description: 'Salário Inovexa', amount: 5000.00, isBettingRelated: false),
    Transaction(id: 't3', date: DateTime.now().subtract(const Duration(days: 2)), description: 'Transferência Blaze', amount: -300.00, isBettingRelated: true),
    Transaction(id: 't4', date: DateTime.now().subtract(const Duration(days: 1)), description: 'Pagamento Netflix', amount: -49.90, isBettingRelated: false),
    Transaction(id: 't5', date: DateTime.now().subtract(const Duration(hours: 12)), description: 'Pix PIXBET', amount: -50.00, isBettingRelated: true),
  ];
  
  // --- FLUXO DE CONEXÃO ---

  /// Simula a abertura do fluxo de autenticação e a conexão com a API.
  Future<bool> connectToBank() async {
    // Em produção: Abrir WebView para autenticação OAuth 2.0 do agregador.
    await Future.delayed(const Duration(seconds: 3)); 
    _isConnected = true;
    print('Open Banking conectado com sucesso. Pronto para buscar transações.');
    return true;
  }

  /// Desconecta o serviço (revoga o token de acesso).
  Future<void> disconnectBank() async {
    // Em produção: Chamada à API para revogar o consentimento/token.
    _isConnected = false;
    print('Open Banking desconectado.');
  }

  bool get isConnected => _isConnected;

  // --- OBTENÇÃO E ANÁLISE DE DADOS ---

  /// Simula a obtenção das transações brutas do período.
  Future<List<Transaction>> fetchTransactions(DateTime startDate, DateTime endDate) async {
    if (!_isConnected) {
      return [];
    }
    // Filtra transações dentro do período
    return _mockTransactions.where((t) => t.date.isAfter(startDate) && t.date.isBefore(endDate)).toList();
  }

  /// Calcula o valor total das perdas relacionadas a apostas.
  Future<double> calculateTotalLosses(DateTime startDate, DateTime endDate) async {
    final transactions = await fetchTransactions(startDate, endDate);
    
    // Filtra transações de aposta e soma o valor (débitos são negativos)
    final totalLosses = transactions
        .where((t) => t.isBettingRelated && t.amount < 0)
        .fold(0.0, (sum, t) => sum + t.amount); 
    
    // Retorna o valor absoluto da perda
    return totalLosses.abs();
  }

  /// Calcula o "Saldo AntiBet" (Dinheiro Economizado)
  /// Este é o valor que o usuário NÃO gastou em apostas.
  Future<double> calculateAccumulatedSavings() async {
    // Simulação: Baseado na perda média histórica (R$ 500/mês)
    final months = (DateTime.now().difference(DateTime(2025, 1, 1)).inDays / 30).floor(); 
    final baseSavings = months * 500.00;
    
    // Adiciona um fator aleatório para simular a variação e evitar que o valor seja exato
    final randomFactor = Random().nextDouble() * 200.00; 

    return baseSavings + randomFactor;
  }
}