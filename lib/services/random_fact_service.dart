import 'dart:convert';
import 'package:http/http.dart' as http;

class RandomFact {
  final String text;
  final String source;
  final String? sourceUrl;

  RandomFact({
    required this.text,
    required this.source,
    this.sourceUrl,
  });
}

class RandomFactService {
  static const String _apiUrl = 'https://uselessfacts.jsph.pl/api/v2/facts/random';

  static Future<RandomFact?> getRandomFact() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RandomFact(
          text: data['text'] as String? ?? '',
          source: data['source'] as String? ?? '',
          sourceUrl: data['source_url'] as String?,
        );
      }
    } catch (e) {
      // Handle error silently
    }
    return null;
  }
}

