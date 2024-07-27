import 'package:digimon_tcg_collection_tracker/DetailedCard.dart';

class CardSet {
  late String packName;
  late List<DetailedCard> cardlist;

  CardSet(String name, List<DetailedCard> list) {
    packName = name;
    cardlist = list;
  }

  void printAllCards() {
    for (DetailedCard c in cardlist) {
      String n = c.name;
      print(n);
    }
  }

  //Map <String,Object> toMap(){}
}
