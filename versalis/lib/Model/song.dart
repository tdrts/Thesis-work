class Song{
  String id;
  String title;
  String artist;
  String artwork;
  String url;
  List<String> lyrics;
  int listenCount;

  Song(this.id, this.title, this.artist, this.artwork, this.url, this.lyrics, this.listenCount);

  Map<String, dynamic> toJson() => {
    'id' : id,
    'title' : title,
    'artist' : artist,
    'artwork' : artwork,
    'url' : url,
    'lyrics' : lyrics,
    'listenCount' : listenCount,
  };

  Song.fromJson(Map<String, dynamic> json) :
    id = json['id'],
    title = json['title'],
    artist = json['artist'],
    artwork = json['artwork'],
    url = json['url'],
    lyrics = List<String>.from(json['lyrics']).map((i) => i).toList(),
    listenCount = json['listenCount'];

  @override
  String toString() {
    return 'Song{id: $id, title: $title, artist: $artist, artwork: $artwork, url: $url, lyrics: $lyrics, listenCount: $listenCount}';
  }
}