class DetailedCard {
  final String name;
  final String type;
  final String id;
  final int level;
  final int play_cost;
  final int evolution_cost;
  final String evolution_color;
  final int evolution_level;
  final String xros_req;
  final String color;
  final String color2;
  final String digi_type;
  final String digi_type2;
  final String form;
  final int dp;
  final String attribute;
  final String rarity;
  final String stage;
  final String artist;
  final String main_effect;
  final String source_effect;
  final String alt_effect;
  final String series;
  final String pretty_url;
  final String date_added;
  final String tcgplayer_name;
  final int tcgplayer_id;

  const DetailedCard(
      {required this.name,
      required this.type,
      required this.id,
      required this.level,
      required this.play_cost,
      required this.evolution_cost,
      required this.evolution_color,
      required this.evolution_level,
      required this.xros_req,
      required this.color,
      required this.color2,
      required this.digi_type,
      required this.digi_type2,
      required this.form,
      required this.dp,
      required this.attribute,
      required this.rarity,
      required this.stage,
      required this.artist,
      required this.main_effect,
      required this.source_effect,
      required this.alt_effect,
      required this.series,
      required this.pretty_url,
      required this.date_added,
      required this.tcgplayer_name,
      required this.tcgplayer_id});

  factory DetailedCard.fromJson(Map<String, dynamic> json) {
    //print("detail of card : $json");
    return DetailedCard(
        name: json['name'] as String,
        type: json['type'] as String,
        id: json['id'] as String,
        level: (json['level'] as int?) ?? -1,
        play_cost: (json['play_cost'] as int?) ?? -1,
        evolution_cost: (json['evolution_cost'] as int?) ?? -1,
        evolution_color: (json['evolution_color'] as String?) ?? '',
        evolution_level: (json['evolution_level'] as int?) ?? -1,
        xros_req: (json['xros_req'] as String?) ?? '',
        color: json['color'] as String,
        color2: (json['color2'] as String?) ?? '',
        digi_type: (json['digi_type'] as String?) ?? '',
        digi_type2: (json['digi_type2'] as String?) ?? '',
        form: (json['form'] as String?) ?? '',
        dp: (json['dp'] as int?) ?? -1,
        attribute: (json['attribute'] as String?) ?? '',
        rarity: json['rarity'] as String,
        stage: (json['stage'] as String?) ?? '',
        artist: (json['artist'] as String?) ?? '',
        main_effect: (json['main_effect'] as String?) ?? '',
        source_effect: (json['source_effect'] as String?) ?? '',
        alt_effect: (json['alt_effect'] as String?) ?? '',
        series: json['series'] as String,
        pretty_url: json['pretty_url'] as String,
        date_added: json['date_added'] as String,
        tcgplayer_name: (json['tcgplayer_name'] as String?) ?? '',
        tcgplayer_id: (json['tcgplayer_id'] as int?) ?? -1);
  }
}
