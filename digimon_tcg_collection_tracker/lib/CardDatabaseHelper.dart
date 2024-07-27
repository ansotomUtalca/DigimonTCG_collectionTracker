import 'package:digimon_tcg_collection_tracker/CountedCard.dart';
import 'package:digimon_tcg_collection_tracker/StoredCard.dart';
import 'package:sqflite/sqflite.dart';

class CardDatabaseHelper {
  CardDatabaseHelper._privateConstructor();

  static final CardDatabaseHelper instance =
      CardDatabaseHelper._privateConstructor();
  static const _databaseName = 'collection_db';
  //static const _databaseVersion = 1;

  late Database db;

  Future<void> initDB() async {
    String path = await getDatabasesPath();
    db = await openDatabase('$path/$_databaseName',
        onCreate: (database, version) {
          database.execute('''
        CREATE TABLE card(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          cardId TEXT
          quantity INTEGER
        );
      ''');
        },
        version: 1,
        onUpgrade: (db, oldVersion, newVersion) async {
          //print('version');
          final oldData = await db.query('card');
        });
  }

  //Fcution to insert card
  Future<void> insertCard(CountedCard card) async {
    final database = await CardDatabaseHelper.instance.db;
    await database.insert(
      'card',
      card.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Function to get all Cards
  Future<List<StoredCard>> getCards() async {
    final database = await CardDatabaseHelper.instance.db;
    final List<Map<String, dynamic>> maps = await database.query('game');
    return List.generate(maps.length, (i) => StoredCard.fromMap(maps[i]));
  }

  factory CardDatabaseHelper() {
    return instance;
  }
}
