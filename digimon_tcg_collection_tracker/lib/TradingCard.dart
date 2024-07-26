class TradingCard {
  final String name;
  final String cardnumber;

  const TradingCard({required this.name, required this.cardnumber});

  factory TradingCard.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {'name': String name, 'cardnumber': String cardnumber} =>
        TradingCard(name: name, cardnumber: cardnumber),
      _ => throw const FormatException('Failed to load card'),
    };
  }
}
