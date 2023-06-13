import 'dart:math';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:versalis/Model/auctionitem.dart';
import 'package:versalis/Model/song.dart';
import 'package:versalis/Model/transaction.dart';
import 'package:versalis/Controller/auctionService.dart';
import 'package:versalis/Controller/blockchainService.dart';
import 'package:versalis/Controller/songService.dart';
import 'package:versalis/Controller/transactionService.dart';
import 'package:versalis/Controller/userService.dart';
import 'package:versalis/Controller/serviceLocator.dart';


void main() async {
  await dotenv.load(fileName: ".env");
  BlockchainService.instance;
  setup();
  final userService = getIt<UserService>();
  final songService = getIt<SongService>();
  final transactionService = getIt<TransactionService>();
  final auctionService = getIt<AuctionService>();

  group('addUserToServer', () {
    test('should add user to Firestore', () async {
      final firestore = FakeFirebaseFirestore();
      final email = 'a@m.com';
      final name = 'Ana Maria';
      final photo = 'photo.jpg';

      await userService.addUserToServer(
        email: email,
        name: name,
        photo: photo,
        firebase: firestore,
      );

      final docUser = firestore.collection('users').doc(email);
      final snapshot = await docUser.get();
      final data = snapshot.data();

      expect(data, isNotNull);
      expect(data?['email'], equals(email));
      expect(data?['displayName'], equals(name));
      expect(data?['photoUrl'], equals(photo));
    });
  });

  group('readSongs', () {
    test('should add and read songs from Firestore', () async {
      final firestore = FakeFirebaseFirestore();

      Song songData1 = Song(
        'song1',
        'Song 1',
        'Artist 1',
        'song1.jpg',
        'https://example.com/song1.mp3',
        ['Lyric 1', 'Lyric 2'],
         0,
      );
      Song songData2 = Song(
        'song2',
        'Song 2',
        'Artist 2',
        'song2.jpg',
        'https://example.com/song2.mp3',
        ['Lyric 3', 'Lyric 4'],
        0,
      );

      songService.addSongsToServer(song: songData1, firebase: firestore);
      songService.addSongsToServer(song: songData2, firebase: firestore);

      final songsStream = songService.readSongs(firestore);
      final songsList = await songsStream.first;

      expect(songsList, isNotNull);
      expect(songsList.length, equals(2));

      final song1 = songsList.firstWhere((song) => song.id == songData1.id);
      expect(song1.title, equals('Song 1'));
      expect(song1.artist, equals('Artist 1'));
      expect(song1.artwork, equals('song1.jpg'));
      expect(song1.url, equals('https://example.com/song1.mp3'));
      expect(song1.lyrics, equals(['Lyric 1', 'Lyric 2']));
      expect(song1.listenCount, equals(0));

      final song2 = songsList.firstWhere((song) => song.id == songData2.id);
      expect(song2.title, equals('Song 2'));
      expect(song2.artist, equals('Artist 2'));
      expect(song2.artwork, equals('song2.jpg'));
      expect(song2.url, equals('https://example.com/song2.mp3'));
      expect(song2.lyrics, equals(['Lyric 3', 'Lyric 4']));
      expect(song2.listenCount, equals(0));
    });
  });

  group('getSongWithId', () {
    final firestore = FakeFirebaseFirestore();

    Song songData1 = Song(
      'song1',
      'Song 1',
      'Artist 1',
      'song1.jpg',
      'https://example.com/song1.mp3',
      ['Lyric 1', 'Lyric 2'],
      0,
    );

    songService.addSongsToServer(song: songData1, firebase: firestore);

    test('should return the correct song with a valid ID', () async {
      final songId = 'song1';
      final song = await songService.getSongWithId(songId, firestore);

      expect(song.id, songId);
      expect(song.title, 'Song 1');
      expect(song.artist, 'Artist 1');
      expect(song.artwork, 'song1.jpg');
      expect(song.url, 'https://example.com/song1.mp3');
      expect(song.listenCount, 0);
    });

    test('should throw an error when the song ID is not found', () async {
      final songId = 'invalid_id';
      expect(() => songService.getSongWithId(songId, firestore), throwsA(isA<RangeError>()));
    });
  });

  group('incrementListCount', () {
    test('should return the listen count incremented by 1', () async {
      final firestore = FakeFirebaseFirestore();

      Song songData1 = Song(
        'song1',
        'Song 1',
        'Artist 1',
        'song1.jpg',
        'https://example.com/song1.mp3',
        ['Lyric 1', 'Lyric 2'],
        0,
      );

      songService.addSongsToServer(song: songData1, firebase: firestore);
      songService.incrementListCount('song1', firestore);
      final song = await songService.getSongWithId('song1', firestore);

      expect(song.listenCount, 1);
    });
  });

  group('sortSongsByRatioBetweenListensAndLyricsBought', () {
    test('should return songs sorted by ratio', () async {
      final firestore = FakeFirebaseFirestore();
      Song songData1 = Song(
        'song1',
        'Song 1',
        'Artist 1',
        'song1.jpg',
        'https://example.com/song1.mp3',
        ['Lyric 1', 'Lyric 2'],
        3,
      );
      Song songData2 = Song(
        'song2',
        'Song 2',
        'Artist 2',
        'song2.jpg',
        'https://example.com/song2.mp3',
        ['Lyric 3', 'Lyric 4'],
        2,
      );

      songService.addSongsToServer(song: songData1, firebase: firestore);
      songService.addSongsToServer(song: songData2, firebase: firestore);
      final result = await songService.sortSongsByRatioBetweenListensAndLyricsBought(firestore);

      expect(result.length, equals(2));
      expect(result[0].id, equals('song1'));
      expect(result[1].id, equals('song2'));

      firestore.collection('lyricsTransactions').add({
        'id': '1',
        'userEmail': 'user1',
        'songId': 'song1',
        'lyricIndex': 1,
        'price': 10,
        'link': 'link1',
      });
      firestore.collection('lyricsTransactions').add({
        'id': '2',
        'userEmail': 'user2',
        'songId': 'song1',
        'lyricIndex': 1,
        'price': 20,
        'link': 'link2',
      });

      final result2 = await songService.sortSongsByRatioBetweenListensAndLyricsBought(firestore);

      expect(result2.length, equals(2));
      expect(result2[0].id, equals('song2'));
      expect(result2[1].id, equals('song1'));
    });
  });

  group('getArtistWithHighestNoLyricsBought', () {
    test('should return a formatted string', () async {
      final firestore = FakeFirebaseFirestore();

      Song songData1 = Song(
        'song1',
        'Song 1',
        'Artist 1',
        'song1.jpg',
        'https://example.com/song1.mp3',
        ['Lyric 1', 'Lyric 2'],
        0,
      );

      Song songData2 = Song(
        'song2',
        'Song 2',
        'Artist 2',
        'song2.jpg',
        'https://example.com/song2.mp3',
        ['Lyric 3', 'Lyric 4'],
        0,
      );

      songService.addSongsToServer(song: songData1, firebase: firestore);
      songService.addSongsToServer(song: songData2, firebase: firestore);

      final res = await transactionService.addTransactionToServer(userEmail: 'a@a.com', songId: 'song1', lyricIndex: 1, price: 5, firebase: firestore);
      final res2 = await transactionService.addTransactionToServer(userEmail: 'a@a.com', songId: 'song2', lyricIndex: 0, price: 8, firebase: firestore);
      final res3 = await transactionService.addTransactionToServer(userEmail: 'a@a.com', songId: 'song2', lyricIndex: 1, price: 7, firebase: firestore);

      final no1 = await songService.getArtistWithHighestNoLyricsBought(firebase: firestore);
      expect(no1, equals("Artist 2\n2 lyrics bought"));
    });
  });

  group('checkIfLyricsWasBought', () {
    test('should return transaction lyric if found', () async {
      final firestore = FakeFirebaseFirestore();
      final lyricsTransactionsCollection = firestore.collection('lyricsTransactions');

      final transactionLyricData = {
        'id' : 't1',
        'userEmail' : 'a@a.com',
        'songId' : 'song1',
        'lyricIndex' : 1,
        'price' : 5,
        'link' : 'a.com',
      };

      await lyricsTransactionsCollection.add(transactionLyricData);
      final res = await transactionService.checkIfLyricsWasBought('song1', 1, firestore);

      expect(res, isNotNull);
    });

    test('should return null if transaction lyric not found', () async {
      final firestore = FakeFirebaseFirestore();
      final res = await transactionService.checkIfLyricsWasBought('song1', 1, firestore);

      expect(res, isNull);
    });
  });

  group('addTransactionToServer', () {
    test('should check if transaction is added', () async {
      final firestore = FakeFirebaseFirestore();

      final res = await transactionService.addTransactionToServer(userEmail: 'a@a.com', songId: 'song1', lyricIndex: 1, price: 5, firebase: firestore);

      final transactionsSnapshot = await firestore.collection('lyricsTransactions').get();
      expect(transactionsSnapshot.docs.length, equals(1));

      final transactionDoc = transactionsSnapshot.docs.first;
      final transaction = TransactionLyric.fromJson(transactionDoc.data());
      expect(transaction.userEmail, equals('a@a.com'));
      expect(transaction.songId, equals('song1'));
      expect(transaction.lyricIndex, equals(1));
      expect(transaction.price, equals(5));
    });

    test('should only add one transaction', () async {
      final firestore = FakeFirebaseFirestore();

      final res = await transactionService.addTransactionToServer(userEmail: 'a@a.com', songId: 'song1', lyricIndex: 1, price: 5, firebase: firestore);
      final res2 = await transactionService.addTransactionToServer(userEmail: 'a@a.com', songId: 'song1', lyricIndex: 1, price: 5, firebase: firestore);

      final transactionsSnapshot = await firestore.collection('lyricsTransactions').get();
      expect(transactionsSnapshot.docs.length, equals(1));
    });
  });

  group('getNoLyricsBoughtForSong', () {
    test('should return number of lyric bought', () async {
      final firestore = FakeFirebaseFirestore();

      final res = await transactionService.addTransactionToServer(userEmail: 'a@a.com', songId: 'song1', lyricIndex: 1, price: 5, firebase: firestore);
      final res2 = await transactionService.addTransactionToServer(userEmail: 'a@a.com', songId: 'song1', lyricIndex: 2, price: 5, firebase: firestore);
      final res3 = await transactionService.addTransactionToServer(userEmail: 'a@a.com', songId: 'song2', lyricIndex: 2, price: 5, firebase: firestore);

      final no1 = await transactionService.getNoLyricsBoughtForSong(songId: 'song1', firebase: firestore);
      expect(no1, equals(2));

      final no2 = await transactionService.getNoLyricsBoughtForSong(songId: 'song2', firebase: firestore);
      expect(no2, equals(1));

      final no3 = await transactionService.getNoLyricsBoughtForSong(songId: 'song3', firebase: firestore);
      expect(no3, equals(0));
    });
  });

  group('getSongWithHighestNoLyricsBought', () {
    test('should return a formatted string', () async {
      final firestore = FakeFirebaseFirestore();

      Song songData1 = Song(
        'song1',
        'Song 1',
        'Artist 1',
        'song1.jpg',
        'https://example.com/song1.mp3',
        ['Lyric 1', 'Lyric 2'],
        0,
      );

      Song songData2 = Song(
        'song2',
        'Song 2',
        'Artist 2',
        'song2.jpg',
        'https://example.com/song2.mp3',
        ['Lyric 3', 'Lyric 4'],
        0,
      );

      songService.addSongsToServer(song: songData1, firebase: firestore);
      songService.addSongsToServer(song: songData2, firebase: firestore);

      final res = await transactionService.addTransactionToServer(userEmail: 'a@a.com', songId: 'song1', lyricIndex: 1, price: 5, firebase: firestore);
      final res2 = await transactionService.addTransactionToServer(userEmail: 'a@a.com', songId: 'song2', lyricIndex: 0, price: 5, firebase: firestore);
      final res3 = await transactionService.addTransactionToServer(userEmail: 'a@a.com', songId: 'song2', lyricIndex: 1, price: 5, firebase: firestore);

      final no1 = await transactionService.getSongWithHighestNoLyricsBought(firestore);
      expect(no1, equals("Artist 2 - Song 2\n2 lyrics bought"));
    });
  });

  group('getLyricWithHighestPrice', () {
    test('should return a formatted string', () async {
      final firestore = FakeFirebaseFirestore();

      Song songData1 = Song(
        'song1',
        'Song 1',
        'Artist 1',
        'song1.jpg',
        'https://example.com/song1.mp3',
        ['Lyric 1', 'Lyric 2'],
        0,
      );

      Song songData2 = Song(
        'song2',
        'Song 2',
        'Artist 2',
        'song2.jpg',
        'https://example.com/song2.mp3',
        ['Lyric 3', 'Lyric 4'],
        0,
      );

      songService.addSongsToServer(song: songData1, firebase: firestore);
      songService.addSongsToServer(song: songData2, firebase: firestore);

      final res = await transactionService.addTransactionToServer(userEmail: 'a@a.com', songId: 'song1', lyricIndex: 1, price: 5, firebase: firestore);
      final res2 = await transactionService.addTransactionToServer(userEmail: 'a@a.com', songId: 'song2', lyricIndex: 0, price: 8, firebase: firestore);
      final res3 = await transactionService.addTransactionToServer(userEmail: 'a@a.com', songId: 'song2', lyricIndex: 1, price: 7, firebase: firestore);

      final no1 = await transactionService.getLyricWithHighestPrice(firestore);
      expect(no1, equals("\"Lyric 3\"\nArtist 2 - Song 2\n\$8"));
    });
  });

  group('addBidToServer', () {
    test('should add bid to auction item in Firestore', () async {
      final firestore = FakeFirebaseFirestore();

      final userEmail = 'test@example.com';
      final song = 'song1';
      final index = 1;
      final price = 10;

      final auctionItemsCollection = firestore.collection('auctionItems').add({
        'songId': song,
        'lyricIndex': index,
        'biddings': [
          {
            'userEmail': 'other@example.com',
            'price': 5,
            'time': DateTime.now().toString(),
          },
        ],
      });

      await auctionService.addBidToServer(
        userEmail,
        song,
        index,
        price,
        firestore,
      );

      final auctionItemSnapshot = await firestore
          .collection('auctionItems')
          .where('songId', isEqualTo: song)
          .where('lyricIndex', isEqualTo: index)
          .get();
      expect(auctionItemSnapshot.docs.length, equals(1));

      final auctionItemDoc = auctionItemSnapshot.docs.first;
      final auctionItem = AuctionItem.fromJson(auctionItemDoc.data());
      expect(auctionItem.biddings.length, equals(2));
      expect(auctionItem.biddings.last.userEmail, equals(userEmail));
      expect(auctionItem.biddings.last.price, equals(price));
      expect(auctionItem.lyricIndex, equals(index));
      expect(auctionItem.songId, equals(song));
    });

    test('should create new auction item and add bid if no existing item found', () async {
      final firestore = FakeFirebaseFirestore();

      final userEmail = 'test@example.com';
      final song = 'song1';
      final index = 1;
      final price = 10;

      await auctionService.addBidToServer(
        userEmail,
        song,
        index,
        price,
        firestore,
      );

      final auctionItemSnapshot = await firestore
          .collection('auctionItems')
          .where('songId', isEqualTo: song)
          .where('lyricIndex', isEqualTo: index)
          .get();
      expect(auctionItemSnapshot.docs.length, equals(1));

      final auctionItemDoc = auctionItemSnapshot.docs.first;
      final auctionItem = AuctionItem.fromJson(auctionItemDoc.data());
      expect(auctionItem.biddings.length, equals(1));
      expect(auctionItem.biddings.first.userEmail, equals(userEmail));
      expect(auctionItem.biddings.first.price, equals(price));
      expect(auctionItem.lyricIndex, equals(index));
      expect(auctionItem.songId, equals(song));
    });
  });


  group('getLyricWithHighestNoBidders', (){
    test('should return formatted string with the lyric having the most no of bidders', () async {
      final firestore = FakeFirebaseFirestore();

      Song songData1 = Song(
        'song1',
        'Song 1',
        'Artist 1',
        'song1.jpg',
        'https://example.com/song1.mp3',
        ['Lyric 1', 'Lyric 2'],
        0,
      );

      Song songData2 = Song(
        'song2',
        'Song 2',
        'Artist 2',
        'song2.jpg',
        'https://example.com/song2.mp3',
        ['Lyric 3', 'Lyric 4'],
        0,
      );

      songService.addSongsToServer(song: songData1, firebase: firestore);
      songService.addSongsToServer(song: songData2, firebase: firestore);


      final userEmail = 'test@example.com';
      final song = 'song1';
      final index = 1;

      final userEmail2 = 'test2@example.com';
      final song2 = 'song2';

      await auctionService.addBidToServer(
        userEmail,
        song,
        index,
        5,
        firestore,
      );

      await auctionService.addBidToServer(
        userEmail,
        song2,
        index,
        5,
        firestore,
      );

      await auctionService.addBidToServer(
        userEmail2,
        song,
        index,
        6,
        firestore,
      );

      final no1 = await auctionService.getLyricWithHighestNoBidders(firestore);
      expect(no1, equals("\"Lyric 2\"\nArtist 1 - Song 1\n2 bidders"));

    });
  });

  group('findIfLyricInProgress', () {
    test('should return 0 if lyric is not in auction and other int if auction in progress', () async {
      late FakeFirebaseFirestore firebase;

      firebase = FakeFirebaseFirestore();

      firebase.collection('auctionItems').add({
        'songId': 'song1',
        'lyricIndex': 1,
        'biddings': [],
      });
      firebase.collection('auctionItems').add({
        'songId': 'song1',
        'lyricIndex': 2,
        'biddings': [],
      });
      firebase.collection('auctionItems').add({
        'songId': 'song2',
        'lyricIndex': 1,
        'biddings': [],
      });

      firebase.collection('lyricsTransactions').add({
        'id': '1',
        'userEmail': 'user1',
        'songId': 'song1',
        'lyricIndex': 1,
        'price': 10,
        'link': 'link1',
      });
      firebase.collection('lyricsTransactions').add({
        'id': '2',
        'userEmail': 'user2',
        'songId': 'song1',
        'lyricIndex': 1,
        'price': 20,
        'link': 'link2',
      });
      firebase.collection('lyricsTransactions').add({
        'id': '3',
        'userEmail': 'user2',
        'songId': 'song2',
        'lyricIndex': 1,
        'price': 20,
        'link': 'link2',
      });

      final result = await auctionService.findIfLyricInProgress('song1', 1, firebase);
      expect(result, equals(-1));

      final result2 = await auctionService.findIfLyricInProgress('song2', 1, firebase);
      expect(result2, equals(0));
    });
  });

  group('findIfSongInProgress', () {
    test('should return 0 if song is not in auction and other int if auction in progress', () async {
      late FakeFirebaseFirestore firebase;

      firebase = FakeFirebaseFirestore();

      firebase.collection('auctionItems').add({
        'songId': 'song1',
        'lyricIndex': 1,
        'biddings': [],
      });
      firebase.collection('auctionItems').add({
        'songId': 'song1',
        'lyricIndex': 2,
        'biddings': [],
      });
      firebase.collection('auctionItems').add({
        'songId': 'song2',
        'lyricIndex': 1,
        'biddings': [],
      });

      firebase.collection('lyricsTransactions').add({
        'id': '1',
        'userEmail': 'user1',
        'songId': 'song1',
        'lyricIndex': 1,
        'price': 10,
        'link': 'link1',
      });
      firebase.collection('lyricsTransactions').add({
        'id': '2',
        'userEmail': 'user2',
        'songId': 'song1',
        'lyricIndex': 1,
        'price': 20,
        'link': 'link2',
      });


      final result = await auctionService.findIfAuctionInProgress('song1', firebase);
      expect(result, equals(0));

      final result2 = await auctionService.findIfAuctionInProgress('song2', firebase);
      expect(result2, equals(1));
    });
  });

  group('getNoAuctionsInProgress', () {
    test('should return the correct difference between the number of auctions and number of lyric transactions', () async {
      late FakeFirebaseFirestore firebase;

      firebase = FakeFirebaseFirestore();

      firebase.collection('auctionItems').add({
        'songId': 'song1',
        'lyricIndex': 1,
        'biddings': [],
      });
      firebase.collection('auctionItems').add({
        'songId': 'song1',
        'lyricIndex': 2,
        'biddings': [],
      });
      firebase.collection('auctionItems').add({
        'songId': 'song2',
        'lyricIndex': 1,
        'biddings': [],
      });

      firebase.collection('lyricsTransactions').add({
        'id': '1',
        'userEmail': 'user1',
        'songId': 'song1',
        'lyricIndex': 1,
        'price': 10,
        'link': 'link1',
      });
      firebase.collection('lyricsTransactions').add({
        'id': '2',
        'userEmail': 'user2',
        'songId': 'song1',
        'lyricIndex': 1,
        'price': 20,
        'link': 'link2',
      });


      final result = await auctionService.getNoAuctionsInProgress(firebase);
      expect(result, equals('1'));
    });
  });
}

