# Currency Converter (Flutter)

A simple and modern currency converter built with Flutter and Riverpod. It fetches live exchange rates from the ExchangeRate-API (v6) and converts between selected currencies on demand.

## Features

- Material 3 look and feel with light/dark themes
- Clean, minimal UI with large amount input
- Side-by-side currency selectors with a swap action
- Result shows only after tapping Convert (no auto-convert)
- Keyboard-safe and scroll-friendly layout (no bottom overflows)
- State management via Riverpod

## Quick start

Prerequisites:
- Flutter (stable channel) with Dart SDK >= 3.9.2

Install dependencies and run:

```powershell
flutter pub get
flutter run
```

Pick a device/emulator when prompted, or specify one:

```powershell
flutter run -d windows   # Windows desktop
flutter run -d chrome    # Web
flutter run -d emulator  # Android/iOS emulator
```

## Configuration

This app uses ExchangeRate-API (v6). The API key is currently provided in `lib/services/currency_service.dart`:

- File: `lib/services/currency_service.dart`
- Constant: `const apiKey = '...'`

Replace the placeholder with your own key or wire it up from a safer source.

Notes about secrets:
- Avoid committing real API keys into source control.
- For simple demos, leaving a key in code may be acceptable, but for production consider:
	- `flutter_dotenv` to load from a `.env` file (not checked in)
	- Platform-side configuration (Android/iOS secrets) and passing them via MethodChannels

Default currencies can be changed in `lib/screens/converter.dart`:
- `fromCurrency = 'USD'`
- `toCurrency = 'TRY'`

## Project structure

```
lib/
	main.dart                     # App entry; Material 3 theming
	models/
		currency_converter.dart     # Model for conversion rates
	providers/
		converter_provider.dart     # Riverpod FutureProvider for rates
	services/
		currency_service.dart       # HTTP client to ExchangeRate-API
	screens/
		converter.dart              # Main screen: input, selectors, result, convert
	widgets/
		currency_selector.dart      # Reusable currency selector tile
		swap_circle.dart            # Swap button widget
		code_badge.dart             # Small initial badge used in selector
```

## How it works

- Enter an amount and pick From/To currencies.
- Tap Convert to fetch the latest rates for the selected base currency (From) and calculate the converted result.
- The screen uses a scrollable layout with keyboard-aware padding to prevent layout overflow when the keyboard is open.

Data flow:
- UI triggers `_convertCurrency()` in `converter.dart`.
- It reads `currencyRatesProvider(baseCode)` from Riverpod.
- Provider calls `CurrencyService.fetchRates(baseCode)` to get JSON from ExchangeRate-API.
- Response is parsed into `CurrencyConverter`, then the specific `toCurrency` rate is used for calculation.

## Testing

Run all tests (if any):

```powershell
flutter test
```

## Troubleshooting

- API failures: Ensure your API key is valid and request quota is not exceeded.
- Web CORS: Public APIs may restrict origins. If you hit CORS issues on the web, run on mobile/desktop or use a proxy during development.
- Android/iOS network: Ensure your emulator/device has internet access. On real devices, also check OS-level connection policies.

## License

This project is provided as-is for learning and demonstration purposes. Replace or add a license as needed for your use case.
