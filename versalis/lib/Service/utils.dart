import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Model/auctionitem.dart';
import '../Model/bid.dart';
import '../Model/song.dart';
import '../Model/transaction.dart';
import '../Model/user.dart';
import 'blockchainController.dart';

final blockchainController = BlockchainController.instance;


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

  //uncomment the next line when you want the NFT to be minted
  //blockchainController.mintStream(url);

  final json = transaction.toJson();
  await docUser.set(json);
}

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

//used to open the OpenSea NFT link
Future<void> launchUrlFromText(link) async {
  var url = link;
  if(await canLaunchUrl(Uri.parse(url))){
  await launchUrl(Uri.parse(url));
  } else {
  throw 'Could not launch $url';
  }
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

//FUNCTIONS FOR STATISTICS
// lyric with the highest price

Future<String> getLyricWithHighestPrice() async {
  return FirebaseFirestore.instance
      .collection('lyricsTransactions')
      .orderBy("price",descending: true)
      .limit(1)
      .get()
      .then((event) async {
    if (event.docs.isEmpty) {
      return "error";
    } else {
      var current = TransactionLyric.fromJson(event.docs[0].data());

      Song song =  await getSongWithId(current.songId);
      return "${song.lyrics[current.lyricIndex]} from ${song.title} by ${song.artist} with ${current.price}\$";
    }
  });
}

// Future<Map<String, dynamic>> getLyricWithHighestPrice() async {
//   var transaction = await getTransactionLyricWithHighestPrice();
//
//   return FirebaseFirestore.instance
//       .collection('songs')
//       .where("id", isEqualTo: transaction!.songId)
//       .get()
//       .then((event) {
//     if (event.docs.isEmpty) {
//       return {};
//     } else {
//       var current = Song.fromJson(event.docs[0].data());
//       return {'lyric': current.lyrics[transaction.lyricIndex], 'songTitle': current.title, 'artist' : current.artist,'price' : transaction.price};
//     }
//   });
// }

// Future<String> getLyricWithHighestPriceAsString() async {
//   var result = await getLyricWithHighestPrice();
//   return result['lyric'] + " from " + result['songTitle'] + " by " + result['artist'] + ' with ${result['price']} \$';
// }


//lyric with most numbers of unique bidders
Future<String> findLyricWithHighestNoBidders() async {
  final collectionRef = FirebaseFirestore.instance.collection('auctionItems');
  final snapshot = await collectionRef.get();

  int maxUserEmailCount = 0;
  String songId = '';
  int lyricIndex = -1;

  for (var doc in snapshot.docs) {
    final biddingsData = doc['biddings'] as List<dynamic>;

    List<Bid> biddings = biddingsData.map((bidData) {
      return Bid(
        bidData['userEmail'] as String,
        bidData['price'] as int,
        DateTime.parse(bidData['time']),
      );
    }).toList();

    Set<String> emails = {};

    for (var bid in biddings) {
      emails.add(bid.userEmail);
    }
    
    if (emails.length >= maxUserEmailCount) {
      songId = doc['songId'] as String;
      lyricIndex = doc['lyricIndex'] as int;
      maxUserEmailCount = emails.length;
    }
  }

  Song current =  await getSongWithId(songId);
  return "${current.lyrics[lyricIndex]} from ${current.title} by ${current.artist} with $maxUserEmailCount bidders";
}

// Future<Map<String, dynamic>> getLyricWithHighestNoBidders() async {
//   var json = await findLyricDataWithHighestNoBidders();
//   String songId = json['songId'];
//   int lyricIndex = json['lyricIndex'];
//   int noBidders = json['userEmailCount'];
//
//   return FirebaseFirestore.instance
//       .collection('songs')
//       .where("id", isEqualTo: songId)
//       .get()
//       .then((event) {
//     if (event.docs.isEmpty) {
//       return {};
//     } else {
//       var current = Song.fromJson(event.docs[0].data());
//       return {'lyric': current.lyrics[lyricIndex], 'songTitle': current.title, 'artist' : current.artist, 'noBidders' : noBidders};
//     }
//   });
// }
//
// Future<String> getLyricWithHighestNoBiddersAsString() async {
//   var result = await getLyricWithHighestNoBidders();
//   return result['lyric'] + " from " + result['songTitle'] + " by " + result['artist'] + ' with ${result['noBidders']} bidders';
// }


// song with most lyrics bought
Future<String> getMostTransactedSong() async {
  final collectionRef = FirebaseFirestore.instance.collection('lyricsTransactions');
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

  Song current =  await getSongWithId(mostTransactedSongId);
  return "${current.title} by ${current.artist} with ${songTransactionCounts[mostTransactedSongId]!} lyrics bought";
}

// Future<Map<String, dynamic>> getMostTransactedSongData() async {
//   var json = await getMostTransactedSongId();
//   String songId = json['songId'];
//   int count = json['count'];
//
//   return FirebaseFirestore.instance
//       .collection('songs')
//       .where("id", isEqualTo: songId)
//       .get()
//       .then((event) {
//     if (event.docs.isEmpty) {
//       return {};
//     } else {
//       var current = Song.fromJson(event.docs[0].data());
//       return {'songTitle': current.title, 'artist' : current.artist, 'count' : count};
//     }
//   });
// }

// Future<String> getMostTransactedSongDataAsString() async {
//   var result = await getMostTransactedSongData();
//   return result['songTitle'] + " by " + result['artist'] + ' with ${result['count']} lyrics bought';
// }


// number of auctions in progress
Future<int> getNoAuctionsInProgress() async {
  var auctions = FirebaseFirestore.instance.collection('auctionItems');
  final snapshotAuctions = await auctions.get();

  var transactions = FirebaseFirestore.instance.collection('lyricsTransactions');
  final snapshotTrans = await transactions.get();

  return snapshotAuctions.size - snapshotTrans.size;
}

// find songs in the auction process
Future<int> findIfAuctionInProgress(String songId) async {
  var auctions = FirebaseFirestore.instance.collection('auctionItems').where("songId", isEqualTo: songId);
  final snapshotAuctions = await auctions.get();

  var transactions = FirebaseFirestore.instance.collection('lyricsTransactions').where("songId", isEqualTo: songId);
  final snapshotTrans = await transactions.get();

  return snapshotAuctions.size - snapshotTrans.size;
}

// find lyrics in the auction process
Future<int> findIfLyricInProgress(String songId, int index) async {
  var auctions = FirebaseFirestore.instance.collection('auctionItems').where("songId", isEqualTo: songId).where("lyricIndex", isEqualTo: index);
  final snapshotAuctions = await auctions.get();

  var transactions = FirebaseFirestore.instance.collection('lyricsTransactions').where("songId", isEqualTo: songId).where("lyricIndex", isEqualTo: index);
  final snapshotTrans = await transactions.get();

  return snapshotAuctions.size - snapshotTrans.size;
}

// get song from song_id
Future<Song> getSongWithId(String id) {
  return FirebaseFirestore.instance.collection('songs').where("id", isEqualTo: id).get().then((value) => Song.fromJson(value.docs[0].data()));
}