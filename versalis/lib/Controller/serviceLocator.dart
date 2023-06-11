import 'package:get_it/get_it.dart';
import 'package:versalis/Controller/blockchainService.dart';

import 'auctionService.dart';
import 'songService.dart';
import 'transactionService.dart';
import 'userService.dart';

final getIt = GetIt.asNewInstance();

void setup() {
  getIt.registerSingleton<AuctionService>(AuctionService());
  getIt.registerSingleton<SongService>(SongService());
  getIt.registerSingleton<TransactionService>(TransactionService());
  getIt.registerSingleton<UserService>(UserService());
  getIt.registerSingleton<BlockchainService>(BlockchainService());
}