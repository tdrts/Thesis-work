import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:versalis/Model/transaction.dart';

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
                    return CircleAvatar(
                      radius: 35,
                      child: IconButton(
                        icon: const Icon(Icons.account_balance_wallet),
                        iconSize: 50,
                        onPressed: () {
                          addTransactionToServer(
                              userEmail: widget.email,
                              songId: widget.songId,
                              lyricIndex: widget.lyricIndex);
                          setState(() {});
                        },
                      ),
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
}


Future<void> addTransactionToServer({required String userEmail,
  required String songId,
  required int lyricIndex,
  int price = 5}) async {
  final docUser =
  FirebaseFirestore.instance.collection('lyricsTransactions').doc();
  final transaction =
  TransactionLyric(docUser.id, userEmail, songId, lyricIndex, price);

  final json = transaction.toJson();
  await docUser.set(json);
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
