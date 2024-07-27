import 'package:digimon_tcg_collection_tracker/CountedCard.dart';

class StoredCard {
  //class made to store and load CountedCards from the database
  static String tableName = 'storedCard';
  static String createQuery =
      'CREATE TABLE card(id TEXT primary key AUTOINCREMENT,cardId TEXT, quantity INTEGER)';

  final int? id;
  final String cardId;
  final int quantity;

  const StoredCard({this.id, required this.cardId, required this.quantity});

  static StoredCard fromMap(Map<String, dynamic> map) {
    return StoredCard(
        id: map['id'],
        cardId: map['cardId'] as String,
        quantity: ['quantity'] as int);
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'cardId': cardId, 'quantity': quantity};
  }
}
