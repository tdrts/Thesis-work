import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Service/utils.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
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
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Statistics',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 30, bottom: 30, left: 15),
        children: [
          statisticsTile("Number of auctions in progress", getNoAuctionsInProgress()),
          const SizedBox(height: 30),
          statisticsTile("Lyric with highest price", getLyricWithHighestPrice()),
          const SizedBox(height: 30),
          statisticsTile("Lyric with highest number of unique bidders", getLyricWithHighestNoBidders()),
          const SizedBox(height: 30),
          statisticsTile("Song with highest number of lyrics bought", getSongWithHighestNoLyricsBought()),
          const SizedBox(height: 30),
          statisticsTile("Artist with highest number of lyrics bought", getArtistWithHighestNoLyricsBought()),
        ],
      ),
    );
  }

  Widget statisticsTile(String title, Future<String> function) => ListTile(
    title: Text(title,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.grey,
      ),
    ),
    subtitle: FutureBuilder<String>(
      future: function,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(snapshot.data!,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        return const CircularProgressIndicator();
      },
    ),
  );
}

