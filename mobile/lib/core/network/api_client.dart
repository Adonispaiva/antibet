// mobile/lib/core/network/api_client.dart

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import '../config/app_config.dart';

/// Classe central para fazer requisições HTTP para a API do Backend.
/// Segue o Padrão Repository/Data Layer.
class ApiClient {
  final String _baseUrl = AppConfig.baseUrl;

  // Headers padroes
  Map<String, String> _getHeaders(String? authToken) {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (authToken != null && authToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    return headers;
  }

  /// Faz uma requisicao GET (Leitura)
  Future<dynamic> get(String url, {String? authToken}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$url'),
        headers: _getHeaders(authToken),
      ).timeout(Duration(seconds: AppConfig.apiTimeoutSeconds));

      return _processResponse(response);
    } on SocketException {
      throw Exception('Falha de Conexao: Verifique sua internet ou VPN.');
    } on TimeoutException {
      throw Exception('Tempo limite da conexao esgotado.');
    }
  }

  /// Faz uma requisicao POST (Criacao)
  Future<dynamic> post(String url, dynamic body, {String? authToken}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/$url'),
        headers: _getHeaders(authToken),
        body: json.encode(body),
      ).timeout(Duration(seconds: AppConfig.apiTimeoutSeconds));

      return _processResponse(response);
    } on SocketException {
      throw Exception('Falha de Conexao.');
    }
  }

  /// Faz uma requisicao PATCH (Atualizacao Parcial)
  Future<dynamic> patch(String url, dynamic body, {String? authToken}) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/$url'),
        headers: _getHeaders(authToken),
        body: json.encode(body),
      ).timeout(Duration(seconds: AppConfig.apiTimeoutSeconds));

      return _processResponse(response);
    } on SocketException {
      throw Exception('Falha de Conexao.');
    }
  }

  /// Faz uma requisicao DELETE (Remocao)
  Future<dynamic> delete(String url, {String? authToken}) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$url'),
        headers: _getHeaders(authToken),
      ).timeout(Duration(seconds: AppConfig.apiTimeoutSeconds));

      return _processResponse(response);
    } on SocketException {
      throw Exception('Falha de Conexao.');
    }
  }


  /// Processa e trata a resposta HTTP do Backend (NestJS)
  dynamic _processResponse(http.Response response) {
    final dynamic responseBody = json.decode(response.body);
    
    switch (response.statusCode) {
      case 200: // OK
      case 201: // CREATED
        return responseBody;

      case 400: // Bad Request (Erros de Validacao do DTO)
        // O NestJS retorna um array de mensagens de erro em data.message
        throw Exception(responseBody['message'] ?? 'Erro de validacao.');

      case 401: // Unauthorized (Token invalido/expirado)
        throw Exception('Sessao expirada. Por favor, faca login novamente.');
        
      case 404: // Not Found
        throw Exception(responseBody['message'] ?? 'Recurso nao encontrado.');

      case 409: // Conflict (ex: Email ja em uso no Registro)
        throw Exception(responseBody['message'] ?? 'Conflito de dados.');

      case 500: // Server Error
      default:
        throw Exception(
            'Erro interno do servidor: ${responseBody['message'] ?? response.statusCode}');
    }
  }
}