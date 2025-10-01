import 'package:currency_converter/models/currency_converter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:currency_converter/services/currency_service.dart';

final currencyServiceProvider = Provider<CurrencyService>(
  (ref) => CurrencyService(),
);

final currencyRatesProvider = FutureProvider.family<CurrencyConverter, String>((
  ref,
  baseCode,
) async {
  final service = ref.watch(currencyServiceProvider);
  return await service.fetchRates(baseCode);
});
