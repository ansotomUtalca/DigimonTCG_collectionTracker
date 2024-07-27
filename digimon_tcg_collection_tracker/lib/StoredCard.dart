import 'package:digimon_tcg_collection_tracker/CountedCard.dart';

class StoredCard {
  //class made to store and load CountedCards from the database
  final int? id;
  final String cardId;
  final int quantity;

  const StoredCard({this.id, required this.cardId, required this.quantity});

  static StoredCard fromMap(Map<String, dynamic> map) {
    return StoredCard(
        cardId: map['cardId'] as String, quantity: ['quantity'] as int);
  }
}
