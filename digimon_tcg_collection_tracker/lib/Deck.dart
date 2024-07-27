import 'package:digimon_tcg_collection_tracker/CountedCard.dart';
import 'package:digimon_tcg_collection_tracker/DetailedCard.dart';

class Deck {
  late String name;
  int cardAmount = 0;
  List<CountedCard> cards = [];
  List<DetailedCard> eggCards = [];

  Deck(String _name) {
    name = _name;
  }

  void addCard(DetailedCard newcard) {
    if (newcard.type == 'Digi-Egg' && checkEggLimit()) {
      eggCards.add(newcard);
    } else if (cardAmount < 50) {
      for (CountedCard c in cards) {
        if (c.card.id == newcard.id) {
          if (c.quantity < 4) c.addCard();
          return;
        }
      }
      cards.add(CountedCard(newcard, 1));
    }
  }

  void removeEgg() {}

  void removeCard() {}

  void editName(String text) {
    name = text;
  }

  //return true if there's space for more eggs
  bool checkEggLimit() {
    if (eggCards.length > 4) {
      return false;
    }
    return true;
  }
}
