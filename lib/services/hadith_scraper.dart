// lib/services/hadith_scraper.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html_unescape/html_unescape.dart';
import 'package:hadith_cheker/models/hadith.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HadithScraper {
  final HtmlUnescape _unescape = HtmlUnescape();
  static const String _baseUrl = 'https://sunnah.com';
  static const String _cacheKeyPrefix = 'hadith_cache_';

  Future<List<Hadith>> searchHadith(String query) async {
    final url = '$_baseUrl/search?q=$query';
    final cacheKey = '$_cacheKeyPrefix${query.hashCode}';

    // Check cache first
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(cacheKey);
    if (cachedData != null) {
      final List<dynamic> jsonList = jsonDecode(cachedData);
      return jsonList.map((json) => Hadith.fromJson(json)).toList();
    }

    // Fetch from web
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to load page: ${response.statusCode}');
    }

    final html = _unescape.convert(response.body);
    final document = parse(html);
    final allHadith = document.querySelector('.AllHadith');
    if (allHadith == null) return [];

    final hadithElements = document.querySelectorAll('.boh');
    final results = hadithElements.map((info) {
      final collection = info.querySelectorAll('.nounderline')[0].text.trim();
      final book = info.querySelectorAll('.nounderline')[1].text.trim();

      final englishNarrated =
          info.querySelector('.english_hadith_narrated')?.text.trim() ?? '';
      final englishHadith =
          info.querySelector('.english_hadith_full .text_details')?.text.trim() ?? '';
      final englishFullHadith =
          info.querySelector('.english_hadith_full')?.text.trim() ?? '';
      final englishGrade =
          info.querySelector('.english_hadith_full .grade')?.text.trim();

      final arabicNarrated =
          info.querySelector('.arabic_hadith_narrated')?.text.trim() ?? '';
      final arabicHadith =
          info.querySelector('.arabic_hadith_full .text_details')?.text.trim() ?? '';
      final arabicFullHadith =
          info.querySelector('.arabic_hadith_full')?.text.trim() ?? '';
      final arabicGrade =
          info.querySelector('.arabic_hadith_full .grade')?.text.trim();

      final reference = info.querySelector('.hadith_reference');
      final refText = reference?.text.trim().split('\n') ?? [];
      final hadithNumberInBook = refText.isNotEmpty ? refText[0].trim() : 'Unknown';
      final hadithNumberInCollection =
          refText.length > 1 ? refText[1].trim() : 'Unknown';
      final collectionId = collection.toLowerCase().replaceAll(' ', '');
      final bookId = book.toLowerCase().replaceAll(' ', '');
      final refUrl = '$_baseUrl/$collectionId/$bookId/$hadithNumberInBook';

      return Hadith(
        collection: collection,
        book: book,
        english: EnglishText(
          hadithNarrated: englishNarrated,
          hadith: englishHadith,
          fullHadith: englishFullHadith,
          grade: englishGrade,
        ),
        arabic: ArabicText(
          hadithNarrated: arabicNarrated,
          hadith: arabicHadith,
          fullHadith: arabicFullHadith,
          grade: arabicGrade,
        ),
        reference: Reference(
          hadithNumberInBook: hadithNumberInBook,
          hadithNumberInCollection: hadithNumberInCollection,
          url: refUrl,
        ),
      );
    }).toList();

    // Cache results
    await prefs.setString(
        cacheKey, jsonEncode(results.map((h) => h.toJson()).toList()));
    return results;
  }
}