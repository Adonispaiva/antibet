import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:antibet/src/core/services/native_blocker_service.dart';
import 'package:antibet/src/core/services/block_list_service.dart';

// Mocks
class MockBlockListService extends Mock implements BlockListService {
  @override
  List<String> getBlockList() => super.noSuchMethod(
        Invocation.method(#getBlockList, []),
        returnValue: ['example.com', 'test.net'], // Lista mockada
      ) as List<String>;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Define o MethodChannel a ser mockado
  const MethodChannel channel = MethodChannel('com.inovexa.antibet/native_blocker');
  late MockBlockListService mockBlockListService;
  late NativeBlockerService nativeBlockerService;
  
  // Variável para armazenar o último método invocado
  String? lastMethod;
  Map<String, dynamic>? lastArguments;

  setUp(() {
    mockBlockListService = MockBlockListService();
    nativeBlockerService = NativeBlockerService(mockBlockListService);
    
    // Configura o handler de teste para o MethodChannel
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      lastMethod = methodCall.method;
      lastArguments = methodCall.arguments as Map<String, dynamic>?;

      switch (methodCall.method) {
        case 'isPermissionGranted':
          return true; // Padrão: permissão concedida
        case 'isBlockerActive':
          return true; // Padrão: serviço ativo
        case 'updateBlockList':
          return true; // Padrão: atualização bem-sucedida
        default:
          throw PlatformException(code: 'UNIMPLEMENTED', message: 'Método não implementado no mock.');
      }
    });
  });

  tearDown(() {
    // Limpa o handler após cada teste
    channel.setMockMethodCallHandler(null);
  });

  group('NativeBlockerService - Permission Checks', () {
    test('isPermissionGranted returns true when native code confirms permission', () async {
      final isGranted = await nativeBlockerService.isPermissionGranted();
      
      expect(isGranted, isTrue);
      expect(lastMethod, 'isPermissionGranted');
    });

    test('isPermissionGranted returns false when PlatformException is caught', () async {
      // Configura o mock para lançar uma exceção
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'isPermissionGranted') {
          throw PlatformException(code: 'PERMISSION_DENIED');
        }
        return null;
      });
      
      final isGranted = await nativeBlockerService.isPermissionGranted();
      
      expect(isGranted, isFalse);
    });

    test('requestPermission invokes the correct native method', () async {
      await nativeBlockerService.requestPermission();
      
      expect(lastMethod, 'requestPermission');
      // Não se espera retorno
    });
    
    test('isBlockerActive returns true when native code confirms service is running', () async {
      final isActive = await nativeBlockerService.isBlockerActive();
      
      expect(isActive, isTrue);
      expect(lastMethod, 'isBlockerActive');
    });
  });

  group('NativeBlockerService - Update Block List', () {
    test('updateNativeBlockList calls getBlockList and sends data via MethodChannel', () async {
      final success = await nativeBlockerService.updateNativeBlockList();
      
      // 1. Verifica se o serviço de lista foi chamado
      verify(mockBlockListService.getBlockList()).called(1);
      
      // 2. Verifica a chamada do canal nativo
      expect(lastMethod, 'updateBlockList');
      
      // 3. Verifica se a lista correta foi enviada
      final List<String> sentList = lastArguments!['blockList'] as List<String>;
      expect(sentList, contains('example.com'));
      expect(sentList.length, 2);
      
      // 4. Verifica o retorno de sucesso
      expect(success, isTrue);
    });

    test('updateNativeBlockList returns false when PlatformException is caught', () async {
      // Configura o mock para lançar uma exceção no update
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'updateBlockList') {
          throw PlatformException(code: 'NATIVE_ERROR');
        }
        return null;
      });
      
      final success = await nativeBlockerService.updateNativeBlockList();
      
      expect(success, isFalse);
    });
  });
}