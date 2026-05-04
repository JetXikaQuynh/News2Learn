import 'dart:convert';
import 'package:http/http.dart' as http;

class DictionaryService {
  Future<Map<String, dynamic>?> fetchWord(String word) async {
    try {
      final res = await http.get(
        Uri.parse("https://api.dictionaryapi.dev/api/v2/entries/en/$word"),
      );

      if (res.statusCode != 200) return null;

      final data = jsonDecode(res.body);
      final dictData = data[0];

      // Lấy danh sách nghĩa theo loại từ (Noun, Verb...)
      List<Map<String, String>> structuredMeanings = [];

      for (var m in dictData["meanings"]) {
        String pos = m["partOfSpeech"] ?? "word";
        String defEn = m["definitions"][0]["definition"] ?? "";

        // Dịch nghĩa của loại từ đó
        String defVi = await translateToVietnamese(defEn);

        structuredMeanings.add({"pos": pos, "meaning": defVi});
      }

      final phonetic = dictData["phonetic"] ?? "";
      String? audio;
      final phonetics = dictData["phonetics"];
      if (phonetics != null) {
        for (var p in phonetics) {
          if (p["audio"] != null && p["audio"] != "") {
            audio = p["audio"];
            break;
          }
        }
      }

      return {
        "meanings": structuredMeanings, // Trả về list nghĩa
        "phonetic": phonetic,
        "audio": audio,
      };
    } catch (e) {
      print("DICT ERROR: $e");
      return null;
    }
  }

  Future<String> translateToVietnamese(String text) async {
    try {
      final res = await http.get(
        Uri.parse(
          "https://api.mymemory.translated.net/get?q=$text&langpair=en|vi",
        ),
      );

      if (res.statusCode != 200) return "";

      final data = jsonDecode(res.body);

      return data["responseData"]["translatedText"] ?? "";
    } catch (e) {
      return "";
    }
  }
}
