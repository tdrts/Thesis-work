import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Service/utils.dart';

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
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: Text('Number of auctions in progress'),
            subtitle: FutureBuilder<int>(
              future: getNoAuctionsInProgress(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text("${snapshot.data!}");
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                return CircularProgressIndicator();
              },
            ),
          ),
          ListTile(
            title: Text('Lyric with Most Bidders'),
            subtitle: FutureBuilder<String>(
              future: findLyricWithHighestNoBidders(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(snapshot.data!);
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                return const CircularProgressIndicator();
              },
            ),
          ),
          ListTile(
            title: Text('Lyric with Highest Price'),
            subtitle: FutureBuilder<String>(
              future: getLyricWithHighestPrice(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(snapshot.data!);
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                return const CircularProgressIndicator();
              },
            ),
          ),
          ListTile(
            title: Text('Song with Most Lyrics Bought'),
            subtitle: FutureBuilder<String>(
              future: getMostTransactedSong(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(snapshot.data!);
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                return CircularProgressIndicator();
              },
            ),
          ),
        ],
      ),
    );
  }
}

