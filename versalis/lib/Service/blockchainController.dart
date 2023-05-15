import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

class BlockchainController {
  static BlockchainController _instance = BlockchainController._internal();

  String? CONTRACT_NAME ;
  String? CONTRACT_ADDRESS;
  String? JSON_CID;
  http.Client httpClient = http.Client();
  late Web3Client polygonClient;
  int tokenCounter = -1;
  String tokenSymbol = '';
  Uint8List? mintedImage;
  int mintedCircleNo = 0;

  factory BlockchainController() {
    return _instance;
  }

  static BlockchainController get instance => _instance;


  BlockchainController._internal() {
    // initialization logic
    final ALCHEMY_KEY = dotenv.env['ALCHEMY_KEY_TEST'];
    CONTRACT_NAME = dotenv.env['CONTRACT_NAME'];
    CONTRACT_ADDRESS = dotenv.env['CONTRACT_ADDRESS'];
    JSON_CID = dotenv.env["JSON_CID"];
    httpClient = http.Client();
    polygonClient = Web3Client(ALCHEMY_KEY!, httpClient);
  }

  Future<String> mintStream(String params) async {
    final WALLET_PRIVATE_KEY = dotenv.env['WALLET_PRIVATE_KEY'];

    EthPrivateKey credential = EthPrivateKey.fromHex(WALLET_PRIVATE_KEY!);
    DeployedContract contract = await getContract();
    ContractFunction function = contract.function('mint');

    var results = await Future.wait([
      polygonClient.sendTransaction(
        credential,
        Transaction.callContract(
          contract: contract,
          function: function,
          parameters: [params],
        ),
        fetchChainIdFromNetworkId: true,
        chainId: null,
      ),
    ]);
    return results[0];
  }

  Future<DeployedContract> getContract() async {
    CONTRACT_NAME = dotenv.env['CONTRACT_NAME'];
    CONTRACT_ADDRESS = dotenv.env['CONTRACT_ADDRESS'];
    String abi = await rootBundle.loadString("assets/abi.json"); //TODO update
    DeployedContract contract = DeployedContract(
      ContractAbi.fromJson(abi, CONTRACT_NAME!),
      EthereumAddress.fromHex(CONTRACT_ADDRESS!),
    );
    return contract;
  }

  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    DeployedContract contract = await getContract();
    ContractFunction function = contract.function(functionName);
    List<dynamic> result = await polygonClient.call(contract: contract, function: function, params: args);
    return result;
  }

  Future<String> getTokenSymbol() async {
    if (tokenSymbol != '') {
      return tokenSymbol;
    } else {
      List<dynamic> result = await query('symbol', []);
      return result[0].toString();
    }
  }

  Future<int> getTokenCounter() async {
    List<dynamic> result = await query('tokenCounter', []);
      return int.parse(result[0].toString());
  }
}