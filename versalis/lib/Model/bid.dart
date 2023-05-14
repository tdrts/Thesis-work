class Bid {
  String userEmail;
  int price;
  DateTime time;

  Bid(this.userEmail, this.price, this.time);

  Map<String, dynamic> toJson() => {
    'userEmail' : userEmail,
    'price' : price,
    'time' : time.toString(),
  };

  Bid.fromJson(Map<String, dynamic> json) :
        userEmail = json['userEmail'],
        price = json['price'],
        time = DateTime.parse(json['time']);
}