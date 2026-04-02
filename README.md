# Currency Converter

A simple Flutter currency converter app that converts amounts between different currencies using live exchange rates.

## Features

- Convert amounts between different currencies
- Fetch live exchange rates from an API
- Select source and target currencies easily
- Swap currencies with a single action
- Clean and modern Material 3 interface
- Built with Flutter and Dart

## Screens Used in the Project

- `main.dart` → app entry point and app theme setup
- `converter.dart` → main converter screen and conversion logic
- `currency_selector.dart` → reusable currency selector widget
- `swap_circle.dart` → swap button widget
- `code_badge.dart` → small badge widget for currency codes
- `currency_converter.dart` → model for currency conversion rates
- `converter_provider.dart` → Riverpod provider for fetching rates
- `currency_service.dart` → handles API requests for exchange rates

## How It Works

The app starts with the main converter screen.  
When the user enters an amount and selects the source and target currencies, the app fetches the latest exchange rates and calculates the converted result when the Convert button is pressed.

## Technologies

- Flutter
- Dart
- flutter_riverpod
- HTTP / API integration
- Material 3

## Getting Started

To run this project locally:

```bash
git clone https://github.com/iremcimen/Currecy-Converter.git
cd Currecy-Converter
flutter pub get
flutter run
