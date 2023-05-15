import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:versalis/Model/auctionitem.dart';
import 'package:versalis/Model/bid.dart';
import 'package:versalis/Model/transaction.dart';

import 'Service/blockchainController.dart';
import 'package:url_launcher/url_launcher.dart';

//length of the auction
const SECONDS = 10;
const INITIAL_PRICE = 5;
final blockchainController = BlockchainController.instance;

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

  AuctionItem? item;
  Timer? timer;
  int seconds = SECONDS;
  int price = INITIAL_PRICE;
  bool isAuctionActive = false;
  bool? winning;

  @override
  void initState() {

    timer = Timer.periodic(const Duration(seconds: 1) ,(timer){
      FirebaseFirestore.instance
          .collection('auctionItems')
          .where("songId", isEqualTo: widget.songId)
          .where("lyricIndex", isEqualTo: widget.lyricIndex)
          .get().then ((event) {
        if (event.docs.isNotEmpty){
          //print("auction in progress");
          isAuctionActive = true;
          var current = AuctionItem.fromJson(event.docs[0].data());

          setState(() {
            item = current;
            seconds--;
          });

          seconds = SECONDS - DateTime.now().subtract(Duration(seconds: item!.biddings.last.time.second)).second;
          price = item!.biddings.last.price;

          if (item!.biddings.last.userEmail == widget.email){
            winning = true;
          } else {
            winning = false;
          }

          // print("after setState is $seconds");
          // print(item!.biddings.last.time!);
          // print(item!.biddings.last.time.add(const Duration(seconds: SECONDS)));
          // print(DateTime.now());

          if (item!.biddings.last.time.add(const Duration(seconds: SECONDS)).isBefore(DateTime.now())){
            print("no more time for bidding");
            int winnerPrice = item!.biddings.last.price;

            addTransactionToServer(
                userEmail: item!.biddings.last.userEmail,
                songId: widget.songId,
                lyricIndex: widget.lyricIndex,
                price : winnerPrice,).then((value){
              setState(() {});
            });
            print("winer price after add trans to server $price");

            price = INITIAL_PRICE;
            print("price after reinit $price");
            isAuctionActive = false;
            timer.cancel();
          }
        } else {
          //print("passing seconds");
        }
      });
    });
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
            FutureBuilder<int>(
              future: blockchainController.gettokenCounter(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  blockchainController.tokenCounter = snapshot.data!;
                  return Text('${blockchainController.tokenCounter} minted tokens until now');
                } else {
                  return Text('\nToken number: ...');
                }
              },
            ),
            Text(
              '"${widget.lyric}"',
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 80),
            FutureBuilder<TransactionLyric?>(
              future: checkIfLyricsWasBought(widget.songId, widget.lyricIndex),
              builder: (BuildContext context, AsyncSnapshot<TransactionLyric?> snapshot) {

                if (snapshot.connectionState == ConnectionState.done) {

                  if (snapshot.hasData && snapshot.data != null) {
                    //print('lyric is bought');
                    timer?.cancel();
                    String lyricOwner = 'Owner: ${snapshot.data!.userEmail}';
                    if (snapshot.data!.userEmail == widget.email) {
                      lyricOwner = "You are the happy owner of this lyric!";
                    }
                    return Column(
                      children: [
                        Text(
                          '$lyricOwner',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 40),
                        InkWell(
                          child: Text(
                            'NFT Link: ${snapshot.data!.link}. Tap to open!',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          onTap: () async {
                            var url = snapshot.data!.link;
                            if(await canLaunchUrl(Uri.parse(url))){
                              await launchUrl(Uri.parse(url));
                            }else {
                              throw 'Could not launch $url';
                            }
                          },
                        ),
                      ],
                    );
                  } else {
                    //print('lyric is NOT bought');
                    String auctionStatus = "00:$seconds seconds remaining";
                    if (isAuctionActive == false) {
                      auctionStatus = "Press + to start the auction";
                    }

                    String winningStatus = "Auction not started";
                    if (isAuctionActive == true) {
                      if (winning! == true) {
                        winningStatus = "You are WINNING";
                      } else {
                        winningStatus = "You are LOSING";
                      }
                    }

                    return Column(
                      children: [
                        Text("Auction status: \t$winningStatus",
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(auctionStatus,
                          style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                        ),
                        const SizedBox(height: 30),
                        Text("Tap + to bid $price\$!",
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        CircleAvatar(
                          radius: 40,
                          child: IconButton(
                            icon: const Icon(Icons.add),
                            iconSize: 60,
                            onPressed: () {
                              price++;
                              addBidToServer(widget.email, widget.songId, widget.lyricIndex, price);
                            },
                          ),
                        ),
                      ],
                    );
                  }
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

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
      print("price for the first bid $price");
      final item = AuctionItem(song, index, [bid]);

      final json = item.toJson();
      print("Start auction!");
      return docUser.set(json);
    } else {
      final docUser = FirebaseFirestore.instance
          .collection('auctionItems')
          .doc(event.docs[0].id);
      var current = AuctionItem.fromJson(event.docs[0].data());
      final bid = Bid(userEmail, price, DateTime.now());

      current.biddings.add(bid);
      final json = current.toJson();
      print("New bid!");
      print("price for the new bid $price");
      return docUser.update(json);
    }
  });
}


Future<void> addTransactionToServer({required String userEmail, required String songId, required int lyricIndex,required int price}) async {

  TransactionLyric? isBought = await checkIfLyricsWasBought(songId, lyricIndex);
  if (isBought != null) {
    return Future(() => null);
  }

  final docUser = FirebaseFirestore.instance.collection('lyricsTransactions').doc();
  final transaction = TransactionLyric(docUser.id, userEmail, songId, lyricIndex, price,
      "https://testnets.opensea.io/assets/mumbai/${blockchainController.CONTRACT_ADDRESS}/${blockchainController.tokenCounter}");

  print("winning price $price");

  String url = r'ipfs://' + blockchainController.JSON_CID! + r'/' + '${songId}_${lyricIndex}.json';

  //blockchainController.mintStream(url);

  final json = transaction.toJson();
  await docUser.set(json);
}


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

