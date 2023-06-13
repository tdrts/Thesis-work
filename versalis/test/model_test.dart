import 'package:flutter_test/flutter_test.dart';
import 'package:versalis/Model/auctionitem.dart';
import 'package:versalis/Model/bid.dart';
import 'package:versalis/Model/song.dart';
import 'package:versalis/Model/transaction.dart';
import 'package:versalis/Model/user.dart';

void main() {
  group('toJson', () {
    test('should convert a Song object to a Map<String, dynamic>', () {
      final song = Song(
        '1',
        'Test Song',
        'Test Artist',
        'test_artwork.png',
        'test_url.mp3',
        ['Verse 1', 'Chorus', 'Verse 2'],
        0
      );
      expect(song.toJson(), equals({
        'id' : '1',
        'title' : 'Test Song',
        'artist' : 'Test Artist',
        'artwork' : 'test_artwork.png',
        'url' : 'test_url.mp3',
        'lyrics' : ['Verse 1', 'Chorus', 'Verse 2'],
        'listenCount' : 0,
      }));
    });

    test('should convert a User object to a Map<String, dynamic>', () {
      final user = User(
        'test@example.com',
        'Test User',
        'test_photo.png',
      );
      expect(user.toJson(), equals({
        'email' : 'test@example.com',
        'displayName' : 'Test User',
        'photoUrl' : 'test_photo.png',
      }));
    });

    test('should convert a TransactionLyric object to a Map<String, dynamic>', () {
      final purchase = TransactionLyric(
        '1',
        'test@example.com',
        'song_1',
        0,
        5,
        "a.com",
      );
      expect(purchase.toJson(), equals({
        'id' : '1',
        'userEmail' : 'test@example.com',
        'songId' : 'song_1',
        'lyricIndex' : 0,
        'price' : 5,
        'link' : "a.com",
      }));
    });

    test('should convert a Bid object to a Map<String, dynamic>', () {
      final bid = Bid('test@example.com', 9, DateTime(2023, 6, 12, 12, 0),);

      final jsonMap = bid.toJson();

      expect(jsonMap, equals({
        'userEmail': 'test@example.com',
        'price': 9,
        'time': '2023-06-12 12:00:00.000', // Replace with your expected formatted time string
      }));
    });

    test('should convert an AuctionItem object to a Map<String, dynamic>', () {
      final bid1 = Bid('test1@example.com', 9, DateTime(2023, 6, 12, 12, 0));
      final bid2 = Bid('test2@example.com', 19, DateTime(2023, 6, 13, 12, 0));
      final auctionItem = AuctionItem('song_1', 0, [bid1, bid2]);

      final jsonMap = auctionItem.toJson();

      expect(jsonMap, equals({
        'songId': 'song_1',
        'lyricIndex': 0,
        'biddings': [
          {
            'userEmail': 'test1@example.com',
            'price': 9,
            'time': '2023-06-12 12:00:00.000',
          },
          {
            'userEmail': 'test2@example.com',
            'price': 19,
            'time': '2023-06-13 12:00:00.000',
          },
        ],
      }));
    });
  });

  group('fromJson', () {
    test('should create a Song object from a Map<String, dynamic>', () {
      final songJson = {
        'id' : '1',
        'title' : 'Test Song',
        'artist' : 'Test Artist',
        'artwork' : 'test_artwork.png',
        'url' : 'test_url.mp3',
        'lyrics' : ['Verse 1', 'Chorus', 'Verse 2'],
        'listenCount' : 0,
      };
      final song = Song.fromJson(songJson);
      expect(song.id, equals('1'));
      expect(song.title, equals('Test Song'));
      expect(song.artist, equals('Test Artist'));
      expect(song.artwork, equals('test_artwork.png'));
      expect(song.url, equals('test_url.mp3'));
      expect(song.lyrics, equals(['Verse 1', 'Chorus', 'Verse 2']));
      expect(song.listenCount, equals(0));
    });
  });

  test('should create a TransactionLyric object from a Map<String, dynamic>', () {
    final transactionJson = {
      'id' : '1',
      'userEmail' : 'test@example.com',
      'songId' : 'song_1',
      'lyricIndex' : 0,
      'price' : 5,
      'link' : "a.com"
    };
    final transaction = TransactionLyric.fromJson(transactionJson);
    expect(transaction.id, equals('1'));
    expect(transaction.userEmail, equals('test@example.com'));
    expect(transaction.songId, equals('song_1'));
    expect(transaction.lyricIndex, equals(0));
    expect(transaction.price, equals(5));
    expect(transaction.link, equals("a.com"));
  });

  test('should create a Bid object from a Map<String, dynamic>', () {
    final bidJson = {
      'userEmail': 'test@example.com',
      'price': 9,
      'time': '2023-06-12 12:00:00.000',
    };

    final bid = Bid.fromJson(bidJson);

    expect(bid.userEmail, equals('test@example.com'));
    expect(bid.price, equals(9));
    expect(bid.time, equals(DateTime.parse('2023-06-12 12:00:00.000')));
  });

  test('should create an AuctionItem object from a Map<String, dynamic>', () {
    final auctionItemJson = {
      'songId': 'song_1',
      'lyricIndex': 0,
      'biddings': [
        {
          'userEmail': 'test1@example.com',
          'price': 9,
          'time': '2023-06-12 12:00:00.000',
        },
        {
          'userEmail': 'test2@example.com',
          'price': 19,
          'time': '2023-06-13 12:00:00.000',
        },
      ],
    };

    final auctionItem = AuctionItem.fromJson(auctionItemJson);

    expect(auctionItem.songId, equals('song_1'));
    expect(auctionItem.lyricIndex, equals(0));
    expect(auctionItem.biddings, isA<List<Bid>>());
    expect(auctionItem.biddings.length, equals(2));
    expect(auctionItem.biddings[0].userEmail, equals('test1@example.com'));
    expect(auctionItem.biddings[0].price, equals(9));
    expect(auctionItem.biddings[0].time, equals(DateTime.parse('2023-06-12 12:00:00.000')));
    expect(auctionItem.biddings[1].userEmail, equals('test2@example.com'));
    expect(auctionItem.biddings[1].price, equals(19));
    expect(auctionItem.biddings[1].time, equals(DateTime.parse('2023-06-13 12:00:00.000')));
  });
}
