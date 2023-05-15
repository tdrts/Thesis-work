import 'package:cloud_firestore/cloud_firestore.dart';

import '../Model/auctionitem.dart';
import '../Model/bid.dart';
import '../Model/song.dart';
import '../Model/transaction.dart';
import '../Model/user.dart';
import 'blockchainController.dart';

final blockchainController = BlockchainController.instance;

//display available songs in playlist
Stream<List<Song>> readSongs() => FirebaseFirestore.instance.collection('songs')
    .snapshots()
    .map((snapshot) =>
    snapshot.docs.map((doc) => Song.fromJson(doc.data())).toList());

//display info about transaction or display auction screen
Future<TransactionLyric?> checkIfLyricsWasBought(String songId, int lyricIndex) {
  return FirebaseFirestore.instance
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

//after an auction is finished, add the transaction to server
Future<void> addTransactionToServer({required String userEmail, required String songId, required int lyricIndex,required int price}) async {

  TransactionLyric? isBought = await checkIfLyricsWasBought(songId, lyricIndex);
  if (isBought != null) {
    return Future(() => null);
  }

  final docUser = FirebaseFirestore.instance.collection('lyricsTransactions').doc();
  final transaction = TransactionLyric(docUser.id, userEmail, songId, lyricIndex, price,
      "https://testnets.opensea.io/assets/mumbai/${blockchainController.CONTRACT_ADDRESS}/${blockchainController.tokenCounter}");

  String url = r'ipfs://' + blockchainController.JSON_CID! + r'/' + '${songId}_${lyricIndex}.json';

  //blockchainController.mintStream(url);

  final json = transaction.toJson();
  await docUser.set(json);
}

//add a new bid to the auction
Future addBidToServer(String userEmail, String song, int index, int price) {
  return FirebaseFirestore.instance
      .collection('auctionItems')
      .where("songId", isEqualTo: song)
      .where("lyricIndex", isEqualTo: index)
      .get()
      .then((event) {
    if (event.docs.isEmpty) {
      final docUser = FirebaseFirestore.instance.collection('auctionItems').doc();
      final bid = Bid(userEmail, price, DateTime.now());
      final item = AuctionItem(song, index, [bid]);

      final json = item.toJson();
      return docUser.set(json);
    } else {
      final docUser = FirebaseFirestore.instance
          .collection('auctionItems')
          .doc(event.docs[0].id);
      var current = AuctionItem.fromJson(event.docs[0].data());
      final bid = Bid(userEmail, price, DateTime.now());

      current.biddings.add(bid);
      final json = current.toJson();
      return docUser.update(json);
    }
  });
}

//add a new user logged in
Future<void> addUserToServer({required String email, required String name, required String photo}) async {
  final docUser = FirebaseFirestore.instance.collection('users').doc(email);
  final user = User(email, name, photo);

  final json = user.toJson();
  await docUser.set(json);
}

//add new songs to the playlist
Future<void> addSongsToServer() async {
  final docUser = FirebaseFirestore.instance.collection('songs').doc("song0");

  final Song song1 = Song(docUser.id,'Coffee for Your Head', 'Powfu', 'artwork": "https://samplesongs.netlify.app/album-arts/death-bed.jpg', 'https://samplesongs.netlify.app/Death%20Bed.mp3',
      ["Don't stay awake for too long, don't go to bed",
        "I'll make a cup of coffee for your head",
      ]
  );
  final json = song1.toJson();
  await docUser.set(json);
}