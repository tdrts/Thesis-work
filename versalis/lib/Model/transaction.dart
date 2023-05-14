class TransactionLyric{
  String id;
  String userEmail;
  String songId;
  int lyricIndex;
  int price = 5;
  String link;

  TransactionLyric(this.id, this.userEmail, this.songId, this.lyricIndex, this.price, this.link);


  @override
  String toString() {
    return 'TransactionLyric{id: $id, userEmail: $userEmail, songId: $songId, lyricIndex: $lyricIndex, price: $price, link: $link}';
  }

  Map<String, dynamic> toJson() => {
    'id' : id,
    'userEmail' : userEmail,
    'songId' : songId,
    'lyricIndex' : lyricIndex,
    'price' : price,
    'link' : link,
  };

  TransactionLyric.fromJson(Map<String, dynamic> json) :
        id = json['id'],
        userEmail = json['userEmail'],
        songId = json['songId'],
        lyricIndex = json['lyricIndex'],
        price = json['price'],
        link = json['link'];
}