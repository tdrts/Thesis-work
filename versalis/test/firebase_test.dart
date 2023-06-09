import 'package:flutter_test/flutter_test.dart';
import 'package:versalis/Service/utils.dart';


void main() {
  group('getSongWithHighestNoLyricsBought', () {
    test("get the Song With Highest No Lyrics Bought", () {


      var res = getSongWithHighestNoLyricsBought();
      expect("Imagine Dragos - Bad Liar\n10 lyrics bought", res);

    });
  });
}