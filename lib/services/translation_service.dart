import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  Future<String> translateToVi(String text) async {
    try {
      final encoded = Uri.encodeComponent(text);
      final url = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=vi&dt=t&q=$encoded',
      );
      final resp = await http.get(url);
      if (resp.statusCode != 200) return '';

      final body = resp.body;
      final data = json.decode(body) as dynamic;
      if (data is List && data.isNotEmpty && data[0] is List) {
        final parts = data[0] as List;
        final buffer = StringBuffer();
        for (final p in parts) {
          if (p is List && p.isNotEmpty && p[0] is String) {
            buffer.write(p[0] as String);
          }
        }
        return buffer.toString();
      }
      return '';
    } catch (e) {
      return '';
    }
  }
}
