import 'package:versalis/Model/bid.dart';

class AuctionItem {
  String songId;
  int lyricIndex;
  List<Bid> biddings;

  AuctionItem(this.songId, this.lyricIndex, this.biddings);

  Map<String, dynamic> toJson() => {
    'songId' : songId,
    'lyricIndex' : lyricIndex,
    'biddings' : biddings.map((e) => e.toJson()).toList(),
  };

  AuctionItem.fromJson(Map<String, dynamic> json) :
        songId = json['songId'],
        lyricIndex = json['lyricIndex'],
        biddings = List.from(json['biddings']).map((i) => Bid.fromJson(i)).toList();
}