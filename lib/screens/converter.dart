import 'package:currency_converter/providers/converter_provider.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:currency_converter/widgets/currency_selector.dart';
import 'package:currency_converter/widgets/swap_circle.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConverterScreen extends ConsumerStatefulWidget {
  const ConverterScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ConverterScreenState();
}

class _ConverterScreenState extends ConsumerState<ConverterScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _textToController = TextEditingController();
  final TextEditingController _textFromController = TextEditingController();

  String fromCurrency = 'USD';
  String toCurrency = 'TRY';
  bool _showResult = false;
  Timer? _debounce;
  bool _isConverting = false;

  @override
  void dispose() {
    _textToController.dispose();
    _textFromController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _convertCurrency() async {
    if (!formKey.currentState!.validate()) return;
    final textFrom = _textFromController.text;
    final amount = double.tryParse(textFrom.replaceAll(',', '.'));
    if (amount == null) return;

    setState(() => _isConverting = true);
    try {
      final rates = await ref.read(currencyRatesProvider(fromCurrency).future);
      final rate = rates.conversionRates[toCurrency];
      if (rate == null) return;
      final convertedResult = amount * rate;
      setState(() {
        _textToController.text = convertedResult.toStringAsFixed(2);
        _showResult = true;
      });
    } finally {
      if (mounted) setState(() => _isConverting = false);
    }
  }

  void _onAmountChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 150), () {
      setState(() {
        _showResult = false;
        _textToController.clear();
      });
    });
  }

  Future<void> _pickCurrency({
    required bool isFrom,
    required List<String> items,
  }) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        String query = '';
        List<String> filtered = List.from(items);
        return StatefulBuilder(
          builder: (context, setModalState) {
            void applyFilter(String q) {
              setModalState(() {
                query = q.toUpperCase();
                filtered = items
                    .where((e) => e.toUpperCase().contains(query))
                    .toList();
              });
            }

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.85,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (_, controller) => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search currency (e.g., USD)',
                      ),
                      onChanged: applyFilter,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: controller,
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final code = filtered[i];
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.secondaryContainer,
                            child: Text(
                              code.substring(0, 2),
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceTint,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          title: Text(
                            code,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          onTap: () => Navigator.of(context).pop(code),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (selected != null) {
      HapticFeedback.selectionClick();
      setState(() {
        if (isFrom) {
          fromCurrency = selected;
        } else {
          toCurrency = selected;
        }
        _showResult = false;
        _textToController.clear();
      });
    }
  }

  void _swapCurrencies() {
    HapticFeedback.lightImpact();
    setState(() {
      final tmp = fromCurrency;
      fromCurrency = toCurrency;
      toCurrency = tmp;
      _showResult = false;
      _textToController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncRates = ref.watch(currencyRatesProvider(fromCurrency));
    final scheme = Theme.of(context).colorScheme;
    final rate = ref
        .read(currencyRatesProvider(fromCurrency))
        .value
        ?.conversionRates[toCurrency];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Currency Converter')),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text('Amount', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _textFromController,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _convertCurrency(),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(
                    fontSize: 33,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    prefixIcon: Icon(Icons.calculate_outlined),
                  ),
                  onChanged: _onAmountChanged,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Amount is required';
                    }
                    final parsed = double.tryParse(value.replaceAll(',', '.'));
                    if (parsed == null) return 'Enter a valid number';
                    if (parsed < 0) return 'Must be greater than zero';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                asyncRates.when(
                  data: (rates) {
                    final items = rates.conversionRates.keys.toList()..sort();
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        const double swapW = 44;
                        const double spacing = 12;
                        final double available =
                            constraints.maxWidth - swapW - spacing * 2;
                        final double itemW = (available / 2).clamp(
                          120.0,
                          220.0,
                        );
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: itemW,
                              child: CurrencySelector(
                                label: 'From',
                                code: fromCurrency,
                                onTap: () =>
                                    _pickCurrency(isFrom: true, items: items),
                              ),
                            ),
                            const SizedBox(width: spacing),
                            SwapCircle(onTap: _swapCurrencies),
                            const SizedBox(width: spacing),
                            SizedBox(
                              width: itemW,
                              child: CurrencySelector(
                                label: 'To',
                                code: toCurrency,
                                onTap: () =>
                                    _pickCurrency(isFrom: false, items: items),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (e, st) => Text('Failed to fetch rates: $e'),
                ),
                const SizedBox(height: 50),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isConverting ? null : _convertCurrency,
                    icon: _isConverting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.currency_exchange),
                    label: Text(_isConverting ? 'Converting...' : 'Convert'),
                  ),
                ),
                SizedBox(height: 40),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Result',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _showResult
                                ? Text(
                                    '${_textToController.text} $toCurrency',
                                    key: const ValueKey('big-result'),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  )
                                : Text(
                                    '—',
                                    key: const ValueKey('no-result'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: scheme.outline,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 6),
                          if (rate != null)
                            Text(
                              '1 $fromCurrency = ${rate.toStringAsFixed(4)} $toCurrency',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: scheme.outline),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}