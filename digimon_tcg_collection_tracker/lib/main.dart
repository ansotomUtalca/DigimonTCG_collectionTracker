import 'dart:convert';

import 'package:digimon_tcg_collection_tracker/BaseCardList.dart';
import 'package:digimon_tcg_collection_tracker/CardSet.dart';
import 'package:digimon_tcg_collection_tracker/DetailedCard.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:digimon_tcg_collection_tracker/TradingCard.dart';

void main() {
  runApp(const MyApp());
}

List<TradingCard> cards = [];
List<CardSet> cardSets = [];

Future<List<TradingCard>> fetchCards() async {
  print('being evil');
  final response = await http.get(Uri.parse(
      'https://digimoncard.io/api-public/getAllCards.php?sort=name&series=Digimon Card Game&sortdirection=asc'));

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

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
  }

  Widget test() {
    if (cards.isNotEmpty) {
      Future<DetailedCard> card = fetchCardDetail(cards[5].cardnumber);
      return FutureBuilder(
          future: card,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data!.main_effect);
            } else {
              return const Text('error al obtener carta');
            }
          });
    }
    return const Text(':)');
  }

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

      //const Text(
      //  'You have pushed the button this many times:',
      //),
      //Text(
      //  '$_counter',
      //  style: Theme.of(context).textTheme.headlineMedium,
      //),
    );
  }
}
