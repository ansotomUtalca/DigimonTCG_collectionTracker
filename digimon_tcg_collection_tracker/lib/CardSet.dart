import 'package:digimon_tcg_collection_tracker/DetailedCard.dart';

class CardSet {
  late String packName;
  List<DetailedCard> cardlist = [];

  CardSet(String name) {
    packName = name;
  }
}
