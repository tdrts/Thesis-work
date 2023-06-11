import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:versalis/Service/songService.dart';

import '../Model/song.dart';
import '../Model/transaction.dart';
import '../serviceLocator.dart';
import 'blockchainService.dart';

class TransactionService {
  late final blockchainController = BlockchainService.instance;
  late final songService = getIt<SongService>();


  //after an auction is finished, add the transaction to server
  Future<void> addTransactionToServer({required String userEmail, required String songId, required int lyricIndex,required int price, FirebaseFirestore? firebase}) async {

    TransactionLyric? isBought = await checkIfLyricsWasBought(songId, lyricIndex, firebase);
    if (isBought != null) {
      return Future(() => null);
    }

    final docUser = (firebase ?? FirebaseFirestore.instance).collection('lyricsTransactions').doc();
    final transaction = TransactionLyric(docUser.id, userEmail, songId, lyricIndex, price,
        "https://testnets.opensea.io/assets/mumbai/${blockchainController.CONTRACT_ADDRESS}/${blockchainController.tokenCounter}");

    String url = r'ipfs://' + blockchainController.JSON_CID! + r'/' + '${songId}_${lyricIndex}.json';

    //uncomment the next line when you want the NFT to be minted
    //blockchainController.mintStream(url);

    final json = transaction.toJson();
    await docUser.set(json);
  }

  //display info about transaction or display auction screen
  Future<TransactionLyric?> checkIfLyricsWasBought(String songId, int lyricIndex, FirebaseFirestore? firebase) {
    return (firebase ?? FirebaseFirestore.instance)
        .collection('lyricsTransactions')
        .where("songId", isEqualTo: songId)
        .where("lyricIndex", isEqualTo: lyricIndex)
        .get()
        .then((event) {
      if (event.docs.isEmpty) {
        return null;
      } else {
        var current = TransactionLyric.fromJson(event.docs[0].data());
        return current;
      }
    });
  }

  // get lyric with the highest price
  Future<String> getLyricWithHighestPrice(FirebaseFirestore? firebase) async {
    return (firebase ?? FirebaseFirestore.instance)
        .collection('lyricsTransactions')
        .orderBy("price",descending: true)
        .limit(1)
        .get()
        .then((event) async {
      if (event.docs.isEmpty) {
        return "error";
      } else {
        var current = TransactionLyric.fromJson(event.docs[0].data());

        Song song =  await songService.getSongWithId(current.songId,firebase);
        return "\"${song.lyrics[current.lyricIndex]}\"\n${song.artist} - ${song.title}\n\$${current.price}";
      }
    });
  }

  // get number of lyrics bought for a song
  Future<int> getNoLyricsBoughtForSong({required String songId, FirebaseFirestore? firebase}) async {
    var transactions = (firebase ?? FirebaseFirestore.instance).collection('lyricsTransactions').where("songId", isEqualTo: songId);
    final snapshotTrans = await transactions.get();

    return snapshotTrans.size;
  }

  // get song with the most lyrics bought
  Future<String> getSongWithHighestNoLyricsBought(FirebaseFirestore? firebase) async {
    final collectionRef = (firebase ?? FirebaseFirestore.instance).collection('lyricsTransactions');
    final snapshot = await collectionRef.get();

    Map<String, int> songTransactionCounts = {};

    for (var doc in snapshot.docs) {
      final transaction = TransactionLyric(
        doc.id,
        doc['userEmail'] as String,
        doc['songId'] as String,
        doc['lyricIndex'] as int,
        doc['price'] as int,
        doc['link'] as String,
      );

      final songId = transaction.songId;
      songTransactionCounts[songId] = (songTransactionCounts[songId] ?? 0) + 1;
    }

    if (songTransactionCounts.isEmpty) {
      return "No data";
    }

    String mostTransactedSongId = songTransactionCounts.keys.reduce((a, b) =>
    songTransactionCounts[a]! > songTransactionCounts[b]! ? a : b);

    Song current =  await songService.getSongWithId(mostTransactedSongId, firebase);
    return "${current.artist} - ${current.title}\n${songTransactionCounts[mostTransactedSongId]!} lyrics bought";
  }
}