class TransactionLyric{
  String id;
  String userEmail;
  String songId;
  int lyricIndex;
  int price = 5;

  TransactionLyric(this.id, this.userEmail, this.songId, this.lyricIndex, this.price);

  @override
  String toString() {
    return 'TransactionLyric{id: $id, email: $userEmail, songId: $songId, lyricIndex: $lyricIndex, price: $price}';
  }

  Map<String, dynamic> toJson() => {
    'id' : id,
    'userEmail' : userEmail,
    'songId' : songId,
    'lyricIndex' : lyricIndex,
    'price' : price,
  };

  TransactionLyric.fromJson(Map<String, dynamic> json) :
        id = json['id'],
        userEmail = json['userEmail'],
        songId = json['songId'],
        lyricIndex = json['lyricIndex'],
        price = json['price'];
}