// lib/models/hadith.dart
class Hadith {
  final String collection;
  final String book;
  final EnglishText english;
  final ArabicText arabic;
  final Reference reference;

  Hadith({
    required this.collection,
    required this.book,
    required this.english,
    required this.arabic,
    required this.reference,
  });

  Map<String, dynamic> toJson() => {
    'collection': collection,
    'book': book,
    'english': english.toJson(),
    'arabic': arabic.toJson(),
    'reference': reference.toJson(),
  };

  factory Hadith.fromJson(Map<String, dynamic> json) => Hadith(
    collection: json['collection'],
    book: json['book'],
    english: EnglishText.fromJson(json['english']),
    arabic: ArabicText.fromJson(json['arabic']),
    reference: Reference.fromJson(json['reference']),
  );
}

class EnglishText {
  final String hadithNarrated;
  final String hadith;
  final String fullHadith;
  final String? grade;

  EnglishText({
    required this.hadithNarrated,
    required this.hadith,
    required this.fullHadith,
    this.grade,
  });

  Map<String, dynamic> toJson() => {
    'hadithNarrated': hadithNarrated,
    'hadith': hadith,
    'fullHadith': fullHadith,
    'grade': grade,
  };

  factory EnglishText.fromJson(Map<String, dynamic> json) => EnglishText(
    hadithNarrated: json['hadithNarrated'],
    hadith: json['hadith'],
    fullHadith: json['fullHadith'],
    grade: json['grade'],
  );
}

class ArabicText {
  final String hadithNarrated;
  final String hadith;
  final String fullHadith;
  final String? grade;

  ArabicText({
    required this.hadithNarrated,
    required this.hadith,
    required this.fullHadith,
    this.grade,
  });

  Map<String, dynamic> toJson() => {
    'hadithNarrated': hadithNarrated,
    'hadith': hadith,
    'fullHadith': fullHadith,
    'grade': grade,
  };

  factory ArabicText.fromJson(Map<String, dynamic> json) => ArabicText(
    hadithNarrated: json['hadithNarrated'],
    hadith: json['hadith'],
    fullHadith: json['fullHadith'],
    grade: json['grade'],
  );
}

class Reference {
  final String hadithNumberInBook;
  final String hadithNumberInCollection;
  final String url;

  Reference({
    required this.hadithNumberInBook,
    required this.hadithNumberInCollection,
    required this.url,
  });

  Map<String, dynamic> toJson() => {
    'hadithNumberInBook': hadithNumberInBook,
    'hadithNumberInCollection': hadithNumberInCollection,
    'url': url,
  };

  factory Reference.fromJson(Map<String, dynamic> json) => Reference(
    hadithNumberInBook: json['hadithNumberInBook'],
    hadithNumberInCollection: json['hadithNumberInCollection'],
    url: json['url'],
  );
}
