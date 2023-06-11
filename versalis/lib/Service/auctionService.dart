import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:versalis/Service/songService.dart';

import '../Model/auctionitem.dart';
import '../Model/bid.dart';
import '../Model/song.dart';
import 'serviceLocator.dart';

class AuctionService {
  late final songService = getIt<SongService>();

  //add a new bid to the auction
  Future addBidToServer(String userEmail, String song, int index, int price, FirebaseFirestore? firebase) {
    return (firebase ?? FirebaseFirestore.instance)
        .collection('auctionItems')
        .where("songId", isEqualTo: song)
        .where("lyricIndex", isEqualTo: index)
        .get()
        .then((event) {
      if (event.docs.isEmpty) {
        final docUser = (firebase ?? FirebaseFirestore.instance).collection('auctionItems').doc();
        final bid = Bid(userEmail, price, DateTime.now());
        final item = AuctionItem(song, index, [bid]);

        final json = item.toJson();
        return docUser.set(json);
      } else {
        final docUser = (firebase ?? FirebaseFirestore.instance)
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


// get lyric with most numbers of unique bidders
  Future<String> getLyricWithHighestNoBidders(FirebaseFirestore? firebase) async {
    final collectionRef = (firebase ?? FirebaseFirestore.instance).collection('auctionItems');
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

    Song current =  await songService.getSongWithId(songId, firebase);
    return "\"${current.lyrics[lyricIndex]}\"\n${current.artist} - ${current.title}\n$maxUserEmailCount bidders";
  }


// number of auctions in progress
  Future<String> getNoAuctionsInProgress() async {
    var auctions = FirebaseFirestore.instance.collection('auctionItems');
    final snapshotAuctions = await auctions.get();

    var transactions = FirebaseFirestore.instance.collection('lyricsTransactions');
    final snapshotTrans = await transactions.get();

    return Future.value((snapshotAuctions.size - snapshotTrans.size).toString());
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
}