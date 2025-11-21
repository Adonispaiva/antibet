import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

// O arquivo de configuração será gerado pelo 'build_runner'
// após a execução do comando flutter pub run build_runner build --delete-conflicting-outputs
import 'injection_container.config.dart';

final GetIt getIt = GetIt.instance;

/// Configura a injeção de dependência do projeto.
/// 
/// O decorator [InjectableInit] instrui o build_runner a gerar o código de 
/// registro de todas as classes anotadas com @injectable.
@InjectableInit(
  initializerName: 'init', // Define o nome da função gerada (ex: getIt.init)
  preferRelativeImports: true, // Preferir importações relativas
  asExtension: true, // Usar a função init como extensão de GetIt
)
Future<void> configureDependencies({
  required String environment,
}) async {
  // Chamada à função gerada
  await getIt.init(environment: environment);
}

// Nota para o Adonis: Após a inserção deste arquivo, você deve executar:
// flutter pub run build_runner build --delete-conflicting-outputs
// para gerar o arquivo injection_container.config.dart.