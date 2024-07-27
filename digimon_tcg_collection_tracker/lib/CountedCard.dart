import 'package:digimon_tcg_collection_tracker/DetailedCard.dart';

class CountedCard {
  late DetailedCard card;
  int quantity = 0;

  CountedCard(DetailedCard _card, int _quantity) {
    card = _card;
    quantity = _quantity;
  }

  void addCard() {
    quantity = quantity + 1;
  }

  void removeCard() {
    quantity = quantity - 1;
  }

  bool checkEmpty() {
    if (quantity == 0) {
      return true;
    }
    return false;
  }

  Map<String, Object> toMap() {
    return {
      'cardId': card.id,
      'quantity': quantity,
    };
  }
}
