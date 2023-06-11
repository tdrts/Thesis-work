import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:versalis/Controller/blockchainService.dart';

void main() async {

  await dotenv.load(fileName: ".env");
  BlockchainService.instance;

  group('BlockchainService', () {

    test('getContract should return a valid deployed contract', () async {
      final contract = await BlockchainService.instance.getContract();

      expect(contract, isNotNull);
    });

    test('query should return the result of a contract function call', () async {
      final functionName = 'symbol';
      final args = [];

      final result = await BlockchainService.instance.query(functionName, args);

      expect(result, isNotEmpty);
    });

    test('getTokenSymbol should return the token symbol', () async {
      final result = await BlockchainService.instance.getTokenSymbol();

      expect(result, isNotEmpty);
    });

    test('getTokenCounter should return the token counter as an integer', () async {
      final result = await BlockchainService.instance.getTokenCounter();

      expect(result, isA<int>());
    });
  });
}