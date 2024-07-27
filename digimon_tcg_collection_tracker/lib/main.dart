import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:digimon_tcg_collection_tracker/BaseCardList.dart';
import 'package:digimon_tcg_collection_tracker/CardSet.dart';
import 'package:digimon_tcg_collection_tracker/CountedCard.dart';
import 'package:digimon_tcg_collection_tracker/Deck.dart';
import 'package:digimon_tcg_collection_tracker/DetailedCard.dart';
import 'package:digimon_tcg_collection_tracker/User.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:digimon_tcg_collection_tracker/TradingCard.dart';

const String assetadd = 'lib/images/plus.svg';
Widget svgIcon =
    SvgPicture.asset(assetadd, semanticsLabel: 'Logo', height: 24, width: 24);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

List<TradingCard> cards = [];
List<CardSet> cardSets = [];
List<DetailedCard> fullInventory = [];
User usuario = User();
String selected = '';

Widget cardImage(String text, String path, context) {
  return Dialog(
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
        Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  text,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                    onPressed: Navigator.of(context).pop,
                    icon: Icon(Icons.close_rounded),
                    color: Colors.redAccent)
              ],
            )),
        Container(
            width: 220,
            height: 500,
            child: Image.network(path, fit: BoxFit.cover))
      ]));
}

void callImage(String name, String code, context) async {
  String imageURL = 'https://images.digimoncard.io/images/cards/$code.jpg';
  await showDialog(
      context: context, builder: (_) => cardImage(name, imageURL, context));
}

BoxDecoration boxDecoration(String color) {
  //consider the case for dual colors, but go mono-color for now.
  switch (color) {
    case 'Black':
      return BoxDecoration(color: Color.fromARGB(255, 79, 79, 79));
    case 'Blue':
      return BoxDecoration(color: Color.fromARGB(255, 58, 58, 212));
    case 'Colorless':
      return BoxDecoration(color: Color.fromARGB(28, 145, 145, 145));
    case 'Green':
      return BoxDecoration(color: Color.fromARGB(255, 31, 134, 33));
    case 'Purple':
      return BoxDecoration(color: Color.fromARGB(255, 116, 55, 82));
    case 'Red':
      return BoxDecoration(color: Color.fromARGB(255, 161, 57, 57));
    case 'White':
      return BoxDecoration(color: Color.fromARGB(255, 240, 240, 240));
    case 'Yellow':
      return BoxDecoration(color: Color.fromARGB(255, 232, 227, 78));
  }
  return BoxDecoration(color: Colors.white);
}

Future<List<TradingCard>> fetchCards() async {
  print('being evil');
  final response = await http.get(Uri.parse(
      'https://digimoncard.io/api-public/getAllCards.php?sort=cardnumber&series=Digimon Card Game&sortdirection=asc'));

  if (response.statusCode == 200) {
    //if the server returns 200 OK, parse the JSON
    final List<dynamic> jsonDecoded =
        jsonDecode(response.body) as List<dynamic>;
    List<TradingCard> cl = BaseCardList.fromJson(jsonDecoded).cardlist;
    return cl;
  } else {
    //throw an exception
    throw Exception('Failed to load Album');
  }
}

Future<DetailedCard> fetchCardDetail(String cardnumber) async {
  String url =
      'https://digimoncard.io/api-public/search.php?card=$cardnumber&series=Digimon Card Game';
  print(url);
  final response = await http.get(Uri.parse(
      'https://digimoncard.io/api-public/search.php?card=$cardnumber&series=Digimon Card Game'));

  if (response.statusCode == 200) {
    return DetailedCard.fromJson(
        jsonDecode(response.body)[0] as Map<String, dynamic>);
  } else {
    throw Exception('Failed to get Card details');
  }
}

Future<List<DetailedCard>> fetchFullDetailedList() async {
  final response = await http.get(Uri.parse(
      'https://digimoncard.io/api-public/search.php?sort=code&series=Digimon Card Game'));

  if (response.statusCode == 200) {
    final List<dynamic> jsonDecoded =
        jsonDecode(response.body) as List<dynamic>;
    List<DetailedCard> list = jsonDecoded
        .map((dynamic item) =>
            DetailedCard.fromJson(item as Map<String, dynamic>))
        .toList();
    for (DetailedCard c in list) {
      fullInventory.add(c);
    }
    return list;
  } else {
    throw Exception('Failed to get List');
  }
}

//obsolete method, along with the one below
List<DetailedCard> chopList(List<DetailedCard> list, int start, int end) {
  List<DetailedCard> l = [];
  for (int i = start; i < end; i++) {
    l.add(list[i]);
  }
  return l;
}

//obsolete method, would use the card codes to separate into more codes, specially for promo cards
void makeCardSets(List<DetailedCard> list) {
  cardSets.add(CardSet('ST1', chopList(list, 0, 30)));
}

Future<List<DetailedCard>> fetchCardSet(String packName, String newName) async {
  final response = await http.get(Uri.parse(
      'https://digimoncard.io/api-public/search.php?sort=code&pack=$packName&series=Digimon Card Game'));

  if (response.statusCode == 200) {
    final List<dynamic> jsonDecoded =
        jsonDecode(response.body) as List<dynamic>;
    List<DetailedCard> pack = jsonDecoded
        .map((dynamic item) =>
            DetailedCard.fromJson(item as Map<String, dynamic>))
        .toList();
    /*
    for (DetailedCard c in pack) {
      fullInventory.add(c);
    }
    */
    cardSets.add(CardSet(newName, pack));
    return pack;
  } else {
    throw Exception('Failed to get CardPack');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Collection Tracker',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 215, 106, 16)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<TradingCard>> futureCards;

  @override
  void initState() {
    super.initState();
    futureCards = fetchCards().then((value) {
      cards = value;
      return value;
    });
    fetchFullDetailedList();
    print(fullInventory.length);
  }

  void fetchBoosterPacks() async {
    fetchCardSet('BT-01: Booster New Evolution', 'BT-01');
    fetchCardSet('BT-02: Booster Ultimate Power', 'BT-02');
    fetchCardSet('BT-03: Booster Union Impact', 'BT-03');
    fetchCardSet('BT-04: Booster Great Legend', 'BT-04');
    fetchCardSet('BT-05: Booster Battle Of Omni', 'BT-05');
    await Future.delayed(const Duration(seconds: 5));
    print('next batch');
    fetchCardSet('BT-06: Booster Double Diamond', 'BT-06');
    fetchCardSet('BT-07: Booster Next Adventure', 'BT-07');
    fetchCardSet('BT-08: Booster New Awakening', 'BT-08');
    fetchCardSet('BT-09: Booster X Record', 'BT-09');
    fetchCardSet('BT-10: Booster Xros Encounter', 'BT-10');
    await Future.delayed(const Duration(seconds: 5));
    print('next batch');
    fetchCardSet('BT-11: Booster Dimensional Phase', 'BT-11');
    fetchCardSet('BT-12: Booster Across Time', 'BT-12');
    fetchCardSet('BT-13: Booster Versus Royal Knights', 'BT-13');
    fetchCardSet('BT-14: Booster Blast Ace', 'BT-14');
    fetchCardSet('BT-15: Booster Exceed Apocalypse', 'BT-15');
    await Future.delayed(const Duration(seconds: 5));
    print('next batch');
    fetchCardSet('BT-16: Booster Beginning Observer', 'BT-16');
    fetchCardSet('BT-17: Booster Secret Crisis', 'BT-17');
    fetchCardSet('BT-18: Booster Elemental Successor', 'BT-18');
    fetchCardSet('BT-19: Booster Xros Evolution', 'BT-19');
  }

  void test() {
    print(cardSets.length);
    print(fullInventory.length);
    if (cardSets.isEmpty) {
      fetchBoosterPacks();
    } else {
      print('Packs already retrieved.');
    }
  }

  void _goDeckLists() {
    setState(() {});
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => DecksList(
        title: 'Your Decks',
      ),
    ));
  }

  void _goPackList() {
    setState(() {});
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => PackList(title: 'Packs disponibles'),
    ));
  }

  void _goCollection() {
    setState(() {});
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Collection(title: 'Mi colleccion'),
    ));
  }

  void _goCardList() {}

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Column(
          children: <Widget>[
            FutureBuilder<List<TradingCard>>(
                future: futureCards,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Expanded(
                        child: ListView.builder(
                            itemCount: 20,
                            itemBuilder: (context, index) {
                              final card = snapshot.data![index];
                              return ListTile(title: Text(card.name));
                            }
                            //on tap stuff
                            ));
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  }
                  return const CircularProgressIndicator();
                }),
            ElevatedButton(onPressed: test, child: const Text(':)')),
          ],
        ),
        drawer: Drawer(
            child: Column(
          children: <Widget>[
            const SizedBox(
              height: 100,
              width: 150,
            ),
            ElevatedButton(
              onPressed: _goDeckLists,
              style: ButtonStyle(fixedSize: buttonSize, shape: buttonBorder),
              child: const Text(
                'Mazos',
                textScaler: TextScaler.linear(1.5),
              ),
            ),
            const SizedBox(width: 100, height: 20),
            ElevatedButton(
                onPressed: _goPackList,
                style: ButtonStyle(fixedSize: buttonSize, shape: buttonBorder),
                child: const Text(
                  'Packs de cartas',
                  textScaler: TextScaler.linear(1.5),
                )),
            const SizedBox(width: 100, height: 20),
            ElevatedButton(
                onPressed: _goCollection,
                style: ButtonStyle(fixedSize: buttonSize, shape: buttonBorder),
                child: const Text(
                  'Ver coleccion',
                  textScaler: TextScaler.linear(1.5),
                ))
          ],
        )));
  }

  MaterialStateProperty<Size> buttonSize =
      const MaterialStatePropertyAll(Size(400, 40));

  MaterialStateProperty<RoundedRectangleBorder> buttonBorder =
      MaterialStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)));
}

class DecksList extends StatefulWidget {
  const DecksList({super.key, required this.title});

  final String title;

  @override
  State<DecksList> createState() => DecksListState();
}

class DecksListState extends State<DecksList> {
  void _goDeckDetail(Deck deck) {
    selected = deck.name;
    setState(() {});
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => DeckDetail(
        title: deck.name,
      ),
    ));
  }

  void createDeck() {
    int deckNumber = usuario.decks.length + 1;
    usuario.addDeck(Deck('Mazo $deckNumber'));
    setState(() {});
  }

  List<Widget> showDeckList() {
    List<Widget> decklist = [];
    for (Deck d in usuario.decks) {
      decklist.add(
        ElevatedButton(
            onPressed: () => _goDeckDetail(d),
            style: ButtonStyle(fixedSize: buttonSize, shape: buttonBorder),
            child: SizedBox(child: Text(d.name), width: 400, height: 40)),
      );
    }
    return decklist;
  }

  MaterialStateProperty<Size> buttonSize =
      const MaterialStatePropertyAll(Size(400, 40));

  MaterialStateProperty<RoundedRectangleBorder> buttonBorder =
      MaterialStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)));

  @override
  Widget build(BuildContext context) {
    context = context;
    return Scaffold(
        appBar: AppBar(backgroundColor: Colors.blue),
        body: Center(
            child: Column(children: [
          Expanded(child: ListView(children: showDeckList())),
          Align(
              child: OverflowBar(
                overflowAlignment: OverflowBarAlignment.end,
                children: [
                  TextButton(onPressed: createDeck, child: Text('Agregar Mazo'))
                ],
              ),
              alignment: AlignmentDirectional.bottomCenter)
        ])));
  }
}

class DeckDetail extends StatefulWidget {
  const DeckDetail({super.key, required this.title});

  final String title;

  @override
  State<DeckDetail> createState() => DeckDetailState();
}

class DeckDetailState extends State<DeckDetail> {
  List<Widget> showDeckList() {
    List<Widget> deckCards = [];
    for (Deck d in usuario.decks) {
      if (selected == d.name) {
        for (CountedCard c in d.cards) {
          deckCards
              .add(SizedBox(width: 400, height: 40, child: Text(c.card.name)));
        }
      }
    }
    return deckCards;
  }

  @override
  Widget build(BuildContext context) {
    context = context;
    return Scaffold(
        appBar: AppBar(backgroundColor: Colors.blue),
        body: const Center(
            child: Column(
          children: [],
        )));
  }
}

class PackList extends StatefulWidget {
  PackList({super.key, required this.title});

  final String title;

  @override
  State<PackList> createState() => PackListState();
}

class PackListState extends State<PackList> {
  void _goPackDetail(String pack) {
    selected = pack;
    print(pack);
    setState(() {});
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => PackDetail(
        title: pack,
      ),
    ));
  }

  List<Widget> showPacks() {
    List<Widget> list = [];
    for (CardSet c in cardSets) {
      list.add(ElevatedButton(
          onPressed: () => _goPackDetail(c.packName), child: Text(c.packName)));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    context = context;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
        ),
        body: Center(
            child: Column(
          children: showPacks(),
        )));
  }
}

class PackDetail extends StatefulWidget {
  const PackDetail({super.key, required this.title});

  final String title;

  @override
  State<PackDetail> createState() => PackDetailState();
}

class PackDetailState extends State<PackDetail> {
  List<Widget> showPackList() {
    List<Widget> packCards = [];
    for (CardSet s in cardSets) {
      if (selected == s.packName) {
        for (DetailedCard c in s.cardlist) {
          packCards.add(
            ElevatedButton(
                onPressed: () => callImage(c.name, c.id, context),
                style: ButtonStyle(fixedSize: buttonSize, shape: buttonBorder),
                child: SizedBox(
                    child: DecoratedBox(
                        decoration: boxDecoration(c.color),
                        child: Text(
                          c.name,
                          style: TextStyle(color: Colors.black),
                        )),
                    width: 400,
                    height: 40)),
          );
        }
      }
    }
    return packCards;
  }

  MaterialStateProperty<Size> buttonSize =
      const MaterialStatePropertyAll(Size(400, 40));

  MaterialStateProperty<RoundedRectangleBorder> buttonBorder =
      MaterialStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)));

  @override
  Widget build(BuildContext context) {
    context = context;
    return Scaffold(
        appBar: AppBar(backgroundColor: Colors.blue),
        body: Center(
            child: ListView(
          children: showPackList(),
        )));
  }
}

class Collection extends StatefulWidget {
  const Collection({super.key, required this.title});

  final String title;

  @override
  State<Collection> createState() => CollectionState();
}

class CollectionState extends State<Collection> {
  void addQuantity(int index) {
    usuario.collection[index].addCard();
  }

  List<Widget> showCollectionList() {
    List<Widget> list = [];
    for (CountedCard cc in usuario.collection) {
      DetailedCard c = cc.card;
      list.add(Row(
        children: [
          SizedBox(width: 40, height: 40, child: Text(cc.quantity.toString())),
          ElevatedButton(
              onPressed: () => callImage(c.name, c.id, context),
              style: ButtonStyle(fixedSize: buttonSize, shape: buttonBorder),
              child: SizedBox(
                  child: DecoratedBox(
                      decoration: boxDecoration(c.color),
                      child: Text(
                        c.name,
                        style: TextStyle(color: Colors.black),
                      )),
                  width: 360,
                  height: 40)),
        ],
      ));
    }
    return list;
  }

  MaterialStateProperty<Size> buttonSize =
      const MaterialStatePropertyAll(Size(360, 40));

  MaterialStateProperty<RoundedRectangleBorder> buttonBorder =
      MaterialStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)));

  void _goAddCards(String selectedSet) {
    selected = selectedSet;
    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (context) => CardAddScreen(
            title: 'Agrega cartas',
          ),
        ))
        .then((value) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    context = context;
    return Scaffold(
        appBar: AppBar(backgroundColor: Colors.blue),
        body: Center(
            child: Column(children: [
          Expanded(child: ListView(children: showCollectionList())),
          Align(
              child: OverflowBar(
                overflowAlignment: OverflowBarAlignment.end,
                children: [
                  TextButton(
                      onPressed: () => _goAddCards(''),
                      child: Text('Agregar Cartas nuevas'))
                ],
              ),
              alignment: AlignmentDirectional.bottomCenter)
        ])));
  }
}

class CardAddScreen extends StatefulWidget {
  const CardAddScreen({super.key, required this.title});

  final String title;

  @override
  State<CardAddScreen> createState() => CardAddScreenState();
}

class CardAddScreenState extends State<CardAddScreen> {
  void addQuantity(DetailedCard newcard) {
    for (CountedCard c in usuario.collection) {
      if (c.card.id == newcard.id) {
        print('copy found');
        c.addCard();
        return;
      }
    }
    usuario.collection.add(CountedCard(newcard, 1));
    String id = newcard.id;
    print('$id added');
  }

  MaterialStateProperty<Size> buttonSize =
      const MaterialStatePropertyAll(Size(360, 40));

  MaterialStateProperty<RoundedRectangleBorder> buttonBorder =
      MaterialStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)));

  List<Widget> showCardList() {
    List<Widget> cards = [];
    for (CardSet s in cardSets) {
      if (selected == s.packName) {
        for (DetailedCard c in s.cardlist) {
          cards.add(Row(children: [
            ElevatedButton(
                onPressed: () => callImage(c.name, c.id, context),
                style: ButtonStyle(fixedSize: buttonSize, shape: buttonBorder),
                child: SizedBox(
                    child: DecoratedBox(
                        decoration: boxDecoration(c.color),
                        child: Text(
                          c.name,
                          style: TextStyle(color: Colors.black),
                        )),
                    width: 360,
                    height: 40)),
            IconButton(
                onPressed: () => addQuantity(c), icon: svgIcon, iconSize: 40)
          ]));
        }
        return cards;
      }
    }
    print('get other cards');
    for (DetailedCard dc in fullInventory) {
      cards.add(Row(children: [
        ElevatedButton(
            onPressed: () => callImage(dc.name, dc.id, context),
            style: ButtonStyle(fixedSize: buttonSize, shape: buttonBorder),
            child: SizedBox(
                child: DecoratedBox(
                    decoration: boxDecoration(dc.color),
                    child: Text(
                      dc.name,
                      style: TextStyle(color: Colors.black),
                    )),
                width: 360,
                height: 40)),
        IconButton(
            onPressed: () => addQuantity(dc), icon: svgIcon, iconSize: 40)
      ]));
    }
    return cards;
  }

  @override
  Widget build(BuildContext context) {
    context = context;
    return Scaffold(
        appBar: AppBar(backgroundColor: Colors.blue),
        body: Center(
            child: ListView(
          children: showCardList(),
        )));
  }
}
