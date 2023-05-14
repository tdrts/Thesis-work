import 'dart:async';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:versalis/Model/auctionitem.dart';
import 'package:versalis/Model/bid.dart';
import 'package:versalis/Model/transaction.dart';

import 'Service/blockchainController.dart';

class LyricScreen extends StatefulWidget {
  const LyricScreen({
    Key? key,
    required this.lyric,
    required this.email,
    required this.songId,
    required this.lyricIndex,
  }) : super(key: key);

  final String lyric;
  final String email;
  final String songId;
  final int lyricIndex;

  @override
  State<LyricScreen> createState() => _LyricScreenState();
}

class _LyricScreenState extends State<LyricScreen> {
  final blockchainController = BlockchainController.instance;
  AuctionItem? item;
  Timer? timer;
  int seconds = 30;
  bool? isBiddingActive;
  // verificat daca nu e null verificat daca timpul a trecut

  @override
  void initState() {
    timer = Timer.periodic(const Duration(seconds: 1) ,(timer){
      FirebaseFirestore.instance
          .collection('auctionItems')
          .where("songId", isEqualTo: widget.songId)
          .where("lyricIndex", isEqualTo: widget.lyricIndex)
          .get().then ((event) {
        if (event.docs.isNotEmpty){
          print("se continua licitatia!");
          isBiddingActive = true;
          var current = AuctionItem.fromJson(event.docs[0].data());

          setState(() {
            item = current;
            seconds--;
          });

          seconds = 30 - DateTime.now().subtract(Duration(seconds: item!.biddings.last.time.second)).second;
          print("after setState is $seconds");
          print(item!.biddings.last.time!);
          print(item!.biddings.last.time.add(const Duration(seconds: 30)));
          print(DateTime.now());
          if (item!.biddings.last.time.add(const Duration(seconds: 30)).isBefore(DateTime.now())){

            print("s-a terminat tranzactia");
            FirebaseFirestore.instance
                .collection('lyricsTransactions')
                .where("songId", isEqualTo: widget.songId)
                .where("lyricIndex", isEqualTo: widget.lyricIndex)
                .get().then ((event) {
                    if (event.docs.isEmpty){
                      addTransactionToServer(
                          userEmail: item!.biddings.last.userEmail,
                          songId: widget.songId,
                          lyricIndex: widget.lyricIndex);
                      print("s-a adaugat la fb");
                      setState(() {});
                    }
            });

            isBiddingActive = false;
            timer.cancel();
          }
        } else {
          print("trece timpul trece");
        }
      });
      if (isBiddingActive == false){
        setState(() {});
        print("set state pt active bidding false");
      }
    });
    if (isBiddingActive == false){
      setState(() {});
      print("set state pt active bidding false dupa timer");
    }
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(blockchainController.CONTRACT_ADDRESS!),
            FutureBuilder<String>(
              future: blockchainController.getTokenSymbol(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text('\nToken symbol: ${snapshot.data!}');
                } else {
                  return Text('\nToken symbol: wait...');
                }
              },
            ),
            FutureBuilder<int>(
              future: blockchainController.gettokenCounter(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  blockchainController.tokenCounter = snapshot.data!;
                  return Text('\nNumber of tokens: ${blockchainController.tokenCounter}');
                } else {
                  return Text('\nNumber of tokens: wait...');
                }
              },
            ),
            Text(
              'Lyric: ${widget.lyric}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            FutureBuilder<String?>(
              future: checkIfLyricsWasBought(widget.songId, widget.lyricIndex),
              builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {

                if (snapshot.connectionState == ConnectionState.done) {

                  if (snapshot.hasData && snapshot.data != null) {
                    //print('lyric already bought');
                    timer?.cancel();
                    return Column(
                      children: [
                        Text(
                          'Email: ${snapshot.data!}',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        const Text("already bought!"),
                      ],
                    );
                  } else {
                    //print('lyric is NOT bought');
                    return Column(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          child: IconButton(
                            icon: const Icon(Icons.account_balance_wallet),
                            iconSize: 40,
                            onPressed: () {
                              addBidToServer(widget.email, widget.songId, widget.lyricIndex, 55);
                              // addTransactionToServer(
                              //     userEmail: widget.email,
                              //     songId: widget.songId,
                              //     lyricIndex: widget.lyricIndex);
                              // setState(() {});
                            },
                          ),
                        ),
                        Text("$seconds"),
                      ],
                    );
                  }
                } else {
                  //print('loading');
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future addBidToServer(String userEmail, String song, int index, int price ) {

    return FirebaseFirestore.instance
        .collection('auctionItems')
        .where("songId", isEqualTo: song)
        .where("lyricIndex", isEqualTo: index)
        .get().then ((event) {
          if (event.docs.isEmpty){
            final docUser = FirebaseFirestore.instance.collection('auctionItems').doc();
            final bid = Bid(userEmail, price, DateTime.now());
            final item = AuctionItem(song, index, [bid]);

            final json = item.toJson();
            print("s-a inceput licitatia!");
            return docUser.set(json);
          } else {
            final docUser = FirebaseFirestore.instance.collection('auctionItems').doc(event.docs[0].id);
            var current = AuctionItem.fromJson(event.docs[0].data());
            final bid = Bid(userEmail, price, DateTime.now());

            current.biddings.add(bid);
            final json = current.toJson();
            print("s-a adaugat un nou bid!");
            return docUser.update(json);
          }
    });
  }

  Future<void> addTransactionToServer({required String userEmail, required String songId, required int lyricIndex, int price = 10}) async {
    final docUser = FirebaseFirestore.instance.collection('lyricsTransactions').doc();
    final transaction = TransactionLyric(docUser.id, userEmail, songId, lyricIndex, price);

    String url = r'ipfs://' + blockchainController.JSON_CID! + r'/' + '${songId}_${lyricIndex}.json';
    //blockchainController.mintStream(url);

    final json = transaction.toJson();
    await docUser.set(json);
  }
}




Stream<List<TransactionLyric>> readTransactions() =>
    FirebaseFirestore.instance
        .collection('lyricsTransactions')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs
            .map((doc) => TransactionLyric.fromJson(doc.data()))
            .toList());

Future<String?> checkIfLyricsWasBought(String songId, int lyricIndex) async {
  Stream<List<TransactionLyric>> transactions = readTransactions();
  Completer<String> completer = Completer();

  await for (List<TransactionLyric> transactionLyrics in transactions) {
    for (var transactionLyric in transactionLyrics) {
      if ((transactionLyric.songId == songId) &&
          (transactionLyric.lyricIndex == lyricIndex)) {
        completer.complete(transactionLyric.userEmail);
        return completer.future;
      }
    }
    return null;
  }
}
