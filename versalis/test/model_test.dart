import 'package:flutter_test/flutter_test.dart';
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
      );
      expect(song.toJson(), equals({
        'id' : '1',
        'title' : 'Test Song',
        'artist' : 'Test Artist',
        'artwork' : 'test_artwork.png',
        'url' : 'test_url.mp3',
        'lyrics' : ['Verse 1', 'Chorus', 'Verse 2'],
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

    test('should convert a Purchase object to a Map<String, dynamic>', () {
      final purchase = TransactionLyric(
        '1',
        'test@example.com',
        'song_1',
        0,
        5,
      );
      expect(purchase.toJson(), equals({
        'id' : '1',
        'userEmail' : 'test@example.com',
        'songId' : 'song_1',
        'lyricIndex' : 0,
        'price' : 5,
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
      };
      final song = Song.fromJson(songJson);
      expect(song.id, equals('1'));
      expect(song.title, equals('Test Song'));
      expect(song.artist, equals('Test Artist'));
      expect(song.artwork, equals('test_artwork.png'));
      expect(song.url, equals('test_url.mp3'));
      expect(song.lyrics, equals(['Verse 1', 'Chorus', 'Verse 2']));
    });
  });

  test('should create a TransactionLyric object from a Map<String, dynamic>', () {
    final transactionJson = {
      'id' : '1',
      'userEmail' : 'test@example.com',
      'songId' : 'song_1',
      'lyricIndex' : 0,
      'price' : 5,
    };
    final transaction = TransactionLyric.fromJson(transactionJson);
    expect(transaction.id, equals('1'));
    expect(transaction.userEmail, equals('test@example.com'));
    expect(transaction.songId, equals('song_1'));
    expect(transaction.lyricIndex, equals(0));
    expect(transaction.price, equals(5));
  });
}
