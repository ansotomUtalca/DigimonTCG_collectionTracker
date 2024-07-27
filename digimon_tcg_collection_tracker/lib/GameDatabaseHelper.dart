import 'package:digimon_tcg_collection_tracker/CountedCard.dart';
import 'package:digimon_tcg_collection_tracker/StoredCard.dart';
import 'package:sqflite/sqflite.dart';

class CardDatabaseHelper {
  CardDatabaseHelper._privateConstructor();

  static final CardDatabaseHelper instance =
      CardDatabaseHelper._privateConstructor();
  static const _databaseName = 'example_database_db';
  static const _databaseVersion = 1;

  Future<Database> get database async {
    final databasePath = await getDatabasesPath();
    //print('version check');
    return await openDatabase('$databasePath/$_databaseName',
        onCreate: (db, version) {
      db.execute('''
        CREATE TABLE card(
          id TEXT PRIMARY KEY AUTOINCREMENT,
          cardId TEXT
          quantity INTEGER
        );
      ''');
    }, onUpgrade: (db, oldVersion, newVersion) async {
      //print('version');
      final oldData = await db.query('card');
    });
  }

  //Fcution to insert card
  Future<void> insertCard(CountedCard card) async {
    final database = await CardDatabaseHelper.instance.database;
    await database.insert(
      'card',
      card.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Function to get all Cards
  Future<List<StoredCard>> getCards() async {
    final database = await CardDatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await database.query('game');
    return List.generate(maps.length, (i) => StoredCard.fromMap(maps[i]));
  }
}
