class CurrencyConverter {
  const CurrencyConverter({required this.conversionRates});

  final Map<String, double> conversionRates;
  

  factory CurrencyConverter.fromJson(Map<String, dynamic> json) {
    return CurrencyConverter(
      conversionRates: (json['conversion_rates'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
    );
  }
}