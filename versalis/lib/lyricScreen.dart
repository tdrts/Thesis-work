import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:versalis/Model/transaction.dart';

class LyricScreen extends StatefulWidget {
  const LyricScreen({Key? key, required this.lyric, required this.email, required this.songId, required this.lyricIndex}) : super(key: key);

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
              Text (
                'Lyric: ${widget.lyric}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text (
                'Email: ${widget.email}',
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
              CircleAvatar(
                radius: 35,
                child: IconButton(
                  icon: const Icon(
                    Icons.account_balance_wallet
                  ),
                  iconSize: 50,
                  onPressed: () {
                      addTransactionToServer(userEmail: widget.email, songId: widget.songId, lyricIndex: widget.lyricIndex);
                      print('${widget.email} bought ${widget.lyric} which is on position ${widget.lyricIndex} from song with id ${widget.songId}');
                    },
                ),
              ),
              ],
        ),
      ),
    );
  }

  Future<void> addTransactionToServer({required String userEmail, required String songId, required int lyricIndex, int price = 5}) async {
    final docUser = FirebaseFirestore.instance.collection('lyricsTransactions').doc();
    final transaction = TransactionLyric(docUser.id, userEmail, songId, lyricIndex, price);

    final json = transaction.toJson();
    await docUser.set(json);
  }
}
