import 'package:get_it/get_it.dart';
import 'package:versalis/Service/blockchainService.dart';

import 'Service/auctionService.dart';
import 'Service/songService.dart';
import 'Service/transactionService.dart';
import 'Service/userService.dart';

final getIt = GetIt.asNewInstance();

void setup() {
  getIt.registerSingleton<AuctionService>(AuctionService());
  getIt.registerSingleton<SongService>(SongService());
  getIt.registerSingleton<TransactionService>(TransactionService());
  getIt.registerSingleton<UserService>(UserService());
  getIt.registerSingleton<BlockchainService>(BlockchainService());
}