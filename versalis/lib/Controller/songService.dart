import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:versalis/Controller/transactionService.dart';

import '../Model/song.dart';
import 'serviceLocator.dart';

class SongService {
  late final transactionService = getIt<TransactionService>();

  //display available songs in playlist
  Stream<List<Song>> readSongs(FirebaseFirestore? firebase) => (firebase ?? FirebaseFirestore.instance).collection('songs')
      .snapshots()
      .map((snapshot) =>
      snapshot.docs.map((doc) => Song.fromJson(doc.data())).toList());

  //add new songs to the playlist
  Future<void> addSongsToServer({required Song song, FirebaseFirestore? firebase}) async {
    final docUser = (firebase ?? FirebaseFirestore.instance)
        .collection('songs')
        .doc(song.id);

    final json = song.toJson();
    await docUser.set(json);
  }

  // get artist with the most lyrics bought
  Future<String> getArtistWithHighestNoLyricsBought({FirebaseFirestore? firebase}) async {
    final songsSnapshot = await (firebase ?? FirebaseFirestore.instance).collection('songs').get();
    Map<String, int> artistLyricsBought = {};

    for (var doc in songsSnapshot.docs) {
      final song = Song(
        doc.id,
        doc['title'] as String,
        doc['artist'] as String,
        doc['artwork'] as String,
        doc['url'] as String,
        List<String>.from(doc['lyrics']),
        doc['listenCount'] as int,
      );

      final int lyricsBought = await transactionService.getNoLyricsBoughtForSong(songId: doc.id, firebase: firebase);
      final artist = song.artist;

      if (artistLyricsBought.containsKey(artist)) {
        artistLyricsBought[artist] = artistLyricsBought[artist]! + lyricsBought;
      } else {
        artistLyricsBought[artist] = lyricsBought;
      }
    }

    String artistWithHighestLyricsBought = '';

    artistLyricsBought.forEach((artist, lyricsBought) {
      if (artistWithHighestLyricsBought.isEmpty || lyricsBought > artistLyricsBought[artistWithHighestLyricsBought]!) {
        artistWithHighestLyricsBought = artist;
      }
    });

    return "$artistWithHighestLyricsBought\n${artistLyricsBought[artistWithHighestLyricsBought]!} lyrics bought";
  }

  // get song from song_id
  Future<Song> getSongWithId(String id, FirebaseFirestore? firebase) {
    return (firebase ?? FirebaseFirestore.instance).collection('songs').where("id", isEqualTo: id).get().then((value) => Song.fromJson(value.docs[0].data()));
  }

  // increment listenCount
  void incrementListCount(songId, FirebaseFirestore? firebase) async {
    await (firebase ?? FirebaseFirestore.instance).collection('songs').doc(songId).update({"listenCount": FieldValue.increment(1)});
  }

  // sort songs descending by the ratio between listenCount/ lyricsBought
  Future<List<Song>> sortSongsByRatioBetweenListensAndLyricsBought(FirebaseFirestore? firebase) async {
    final songsSnapshot = await (firebase ?? FirebaseFirestore.instance).collection('songs').get();
    final songs = songsSnapshot.docs.map((doc) => Song.fromJson(doc.data())).toList();

    final sortedSongs = await Future.wait(songs.map((song) async {
      var lyricsBought = await transactionService.getNoLyricsBoughtForSong(songId: song.id, firebase: firebase);
      if (lyricsBought == 0) {
        lyricsBought = 1;
      }
      final ratio = song.listenCount / lyricsBought;
      return {'song': song, 'ratio': ratio};
    }));

    sortedSongs.sort((a, b) {
      final ratioA = a['ratio'] as double;
      final ratioB = b['ratio'] as double;

      return ratioB.compareTo(ratioA);
    });

    return sortedSongs.map((item) => item['song'] as Song).toList();
  }
}