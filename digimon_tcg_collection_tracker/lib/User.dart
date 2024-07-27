import 'package:digimon_tcg_collection_tracker/CountedCard.dart';
import 'package:digimon_tcg_collection_tracker/Deck.dart';
import 'package:digimon_tcg_collection_tracker/DetailedCard.dart';

class User {
  List<CountedCard> collection = [];
  List<Deck> decks = [];

  void addCard(DetailedCard newcard) {
    for (CountedCard c in collection) {
      if (c.card.id == newcard.id) {
        c.addCard();
      }
    }
    collection.add(CountedCard(newcard, 1));
  }

  void removeCard(int index) {
    if (collection[index].quantity > 1) {
      collection[index].quantity--;
    } else if (collection[index].quantity == 1) {
      collection.removeAt(index);
    }
  }

  void addDeck(Deck deck) {
    decks.add(deck);
  }
}
