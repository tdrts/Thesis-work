import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:versalis/Model/auctionitem.dart';
import 'package:versalis/Model/transaction.dart';
import 'package:versalis/Service/auctionService.dart';
import 'package:versalis/View/audioplayerScreen.dart';

import '../Model/song.dart';
import '../Service/blockchainService.dart';

import '../Service/transactionService.dart';
import '../Service/serviceLocator.dart';

//length of the auction
const SECONDS = 30;

//length bid price
const INITIAL_PRICE = 5;

class LyricScreen extends StatefulWidget {
  LyricScreen({
    Key? key,
    required this.lyric,
    required this.email,
    required this.song,
    required this.lyricIndex,
  }) : super(key: key);

  final String lyric;
  final String email;
  final Song song;
  final int lyricIndex;

  @override
  State<LyricScreen> createState() => _LyricScreenState();
}

class _LyricScreenState extends State<LyricScreen> {

  final auctionService = getIt<AuctionService>();
  final blockchainController = BlockchainService.instance;
  final transactionService = getIt<TransactionService>();
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
          .where("songId", isEqualTo: widget.song.id)
          .where("lyricIndex", isEqualTo: widget.lyricIndex)
          .get().then ((event) {
        if (event.docs.isNotEmpty){
          isAuctionActive = true;

          setState(() {
            if (item != AuctionItem.fromJson(event.docs[0].data())){
              item = AuctionItem.fromJson(event.docs[0].data());
            }
            seconds--;
          });

          updateSecondsAndPrice();
          winning = checkForWinningStatus();
          checkIfAuctionIsFinished();
        }
      });
    });
    super.initState();
  }

  void updateSecondsAndPrice() {
    seconds = SECONDS - DateTime.now().subtract(Duration(seconds: item!.biddings.last.time.second)).second;
    price = item!.biddings.last.price;
  }

  bool checkForWinningStatus() => item!.biddings.last.userEmail == widget.email;

  void checkIfAuctionIsFinished() {
    if (item!.biddings.last.time.add(const Duration(seconds: SECONDS)).isBefore(DateTime.now())){
      int winnerPrice = item!.biddings.last.price;

      transactionService.addTransactionToServer(userEmail: item!.biddings.last.userEmail, songId: widget.song.id, lyricIndex: widget.lyricIndex, price : winnerPrice,)
          .then((value){
        setState(() {});
      });

      price = INITIAL_PRICE;
      isAuctionActive = false;
      timer?.cancel();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.green,
                Colors.teal,
              ],
            ),
          ),
        ),
        leading: BackButton(
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Audioplayer(song: widget.song, email: widget.email)));
          },
        ),
        title: const Text(
          'Lyric Screen',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              tokenNumberText(),
              Text(
                '"${widget.lyric}"',
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 80),
              checkIfLyricBought(),
            ],
          ),
        ),
      ),
    );
  }

  FutureBuilder<TransactionLyric?> checkIfLyricBought() {
    return FutureBuilder<TransactionLyric?>(
      future: transactionService.checkIfLyricsWasBought(widget.song.id, widget.lyricIndex, null),
      builder:
          (BuildContext context, AsyncSnapshot<TransactionLyric?> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data != null) {
            timer?.cancel();
            return Column(
              children: [
                ownerText(snapshot.data!.userEmail),
                const SizedBox(height: 40),
                NFTLinkText(snapshot.data!.link),
              ],
            );
          } else {
            return Column(
              children: [
                auctionStatusText(),
                const SizedBox(height: 30),
                remainingTimeText(),
                const SizedBox(height: 30),
                bidPriceText(),
                const SizedBox(height: 20),
                bidButton(),
              ],
            );
          }
        } else {
          return Column(
            children: [
              auctionStatusText(),
              const SizedBox(height: 30),
              remainingTimeText(),
              const SizedBox(height: 30),
              bidPriceText(),
              const SizedBox(height: 20),
              bidButton(),
            ],
          );
        }
      },
    );
  }

  Widget bidButton() => CircleAvatar(
    radius: 40,
    child: IconButton(
      icon: const Icon(Icons.add),
      iconSize: 60,
      onPressed: () {
        price++;
        auctionService.addBidToServer(widget.email, widget.song.id, widget.lyricIndex, price, null);
      },
    ),
  );

  Widget bidPriceText() => Text("Tap + to bid \$$price!",
    style: const TextStyle(
      fontSize: 20,
      color: Colors.black,
    ),
    textAlign: TextAlign.center,
  );

  Widget remainingTimeText() {
    String remainingTime = "00:$seconds seconds remaining";
    if (isAuctionActive == false) {
      remainingTime = "Press + to start the auction";
    }

    return Text(remainingTime,
      style: const TextStyle(
        fontSize: 20,
        color: Colors.black,
        backgroundColor: Color.fromRGBO(245, 51, 61, 0.5),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget auctionStatusText() {
    String winningStatus = "Auction not started";
    if (isAuctionActive == true) {
      if (winning! == true) {
        winningStatus = "You are WINNING";
      } else {
        winningStatus = "You are LOSING";
      }
    }
    return Text("Auction status: \t$winningStatus",
      style: const TextStyle(
        fontSize: 20,
        color: Colors.black,
        backgroundColor: Color.fromRGBO(245, 224, 166, 0.7),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget NFTLinkText(link) => InkWell(
    child: const Text(
      'Tap to see NFT in OpenSea!',
      style: TextStyle(
        fontSize: 18,
        color: Colors.black,
        backgroundColor: Color.fromRGBO(166, 228, 245, 0.5),
      ),
      textAlign: TextAlign.center,
    ),
    onTap: () async {
      launchUrlFromText(link);
    },
  );

  Widget ownerText(email) {
    String lyricOwner = 'Owner: $email';
    if (email == widget.email) {
      lyricOwner = "You are the happy owner of this lyric!";
    }

    return Text(
      lyricOwner,
      style: const TextStyle(
        fontSize: 18,
        color: Colors.black,
        backgroundColor: Color.fromRGBO(76, 175, 80, 0.5),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget tokenNumberText() => FutureBuilder<int>(
    future: blockchainController.getTokenCounter(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        blockchainController.tokenCounter = snapshot.data!;
        return Text('${blockchainController.tokenCounter} minted tokens until now');
      } else {
        return const Text('\nToken number: ...');
      }
    },
  );
}

Future<void> launchUrlFromText(link) async {
  var url = link;
  if(await canLaunchUrl(Uri.parse(url))){
    await launchUrl(Uri.parse(url));
  } else {
    throw 'Could not launch $url';
  }
}







