import 'package:digimon_tcg_collection_tracker/TradingCard.dart';

class BaseCardList {
  late List<TradingCard> cardlist;

  BaseCardList({required this.cardlist});

  factory BaseCardList.fromJson(List<dynamic> json) {
    List<TradingCard> cards = [];
    cards = json
        .map((dynamic item) =>
            TradingCard.fromJson(item as Map<String, dynamic>))
        .toList();

    return BaseCardList(cardlist: cards);
  }

  String getCardName(int index) {
    return cardlist[index].name;
  }

  String getCardNumber(int index) {
    return cardlist[index].cardnumber;
  }
}
