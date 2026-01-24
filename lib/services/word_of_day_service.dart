import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class WordOfDay {
  final String word;
  final String definition;
  final String link;

  WordOfDay({
    required this.word,
    required this.definition,
    required this.link,
  });
}

class WordOfDayService {
  static const String _rssUrl = 'https://wordsmith.org/awad/rss1.xml';

  static Future<WordOfDay?> getWordOfDay() async {
    try {
      final response = await http.get(Uri.parse(_rssUrl));
      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(response.body);
        final items = document.findAllElements('item');
        
        if (items.isNotEmpty) {
          final item = items.first;
          final title = item.findElements('title').first.text;
          final description = item.findElements('description').first.text;
          final link = item.findElements('link').first.text;
          
          return WordOfDay(
            word: title.trim(),
            definition: description.trim(),
            link: link.trim(),
          );
        }
      }
    } catch (e) {
      // Handle error silently
    }
    return null;
  }
}

