import 'package:equatable/equatable.dart';

/// [Failure] é uma classe base abstrata para todos os tipos de falhas
/// (erros de lógica de negócio ou de infraestrutura) no aplicativo.
///
/// Usar 'Failures' em vez de lançar 'Exceptions' permite que a
/// camada de Domínio e UI tratem os erros de forma controlada
/// (principalmente através do 'Either' do pacote 'dartz').
abstract class Failure extends Equatable {
  final String message;
  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

/// [ApiFailure] representa um erro que ocorreu durante uma chamada
/// à API (ex: erro de rede, timeout, erro 500 no servidor).
class ApiFailure extends Failure {
  const ApiFailure({required super.message});
}

/// [AuthFailure] representa um erro específico da lógica de
/// autenticação (ex: credenciais inválidas, email já em uso).
class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

/// [CacheFailure] representa um erro que ocorreu ao tentar
/// ler ou escrever no storage local (ex: SecureStorage).
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}