import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quote_model.dart';

class QuoteService {
  static const String _baseUrl = 'https://api.api-ninjas.com/v1/quotes';

  static const String _apiKey = 'awkHw3DLXtyqX4qsxjbEMrLYbVLPiFj2QyzbhYME';

  Future<QuoteModel?> fetchRandomQuote() async {
    try {
      print("Fetching quote...");

      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {'X-Api-Key': _apiKey},
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        if (data.isNotEmpty) {
          final quote = QuoteModel.fromJson(data[0]);

          // Ignore very long quotes
          if (quote.quote.length > 140) {
            return fetchRandomQuote();
          }

          return quote;
        }
      }

      return null;
    } catch (e) {
      print("Quote Error: $e");
      return null;
    }
  }
}
