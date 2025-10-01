import 'dart:convert';
import 'package:currency_converter/models/currency_converter.dart';
import 'package:http/http.dart' as http;

class CurrencyService {
  Future<CurrencyConverter> fetchRates(String baseCode) async {
    const apiKey = 'YOUR API KEY';
    final url = Uri.parse(
      'https://v6.exchangerate-api.com/v6/$apiKey/latest/$baseCode',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return CurrencyConverter.fromJson(jsonData);
    } else {
      throw Exception('Failed to fetch currency rates.');
    }
  }
}