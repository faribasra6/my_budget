class Currency {
  final String code;
  final String symbol;
  final String name;

  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
  });
}

class CurrencyService {
  static const List<Currency> _currencies = [
    Currency(code: 'AED', symbol: 'د.إ', name: 'UAE Dirham'),
    Currency(code: 'USD', symbol: '\$', name: 'US Dollar'),
    Currency(code: 'EUR', symbol: '€', name: 'Euro'),
    Currency(code: 'GBP', symbol: '£', name: 'British Pound'),
    Currency(code: 'SAR', symbol: 'ر.س', name: 'Saudi Riyal'),
    Currency(code: 'QAR', symbol: 'ر.ق', name: 'Qatari Riyal'),
    Currency(code: 'PKR', symbol: '₨', name: 'Pakistani Rupee'),
    Currency(code: 'INR', symbol: '₹', name: 'Indian Rupee'),
  ];

  static Currency _selectedCurrency = _currencies[0]; // Default to AED

  static List<Currency> get allCurrencies => _currencies;
  static Currency get selectedCurrency => _selectedCurrency;

  static void setCurrency(Currency currency) {
    _selectedCurrency = currency;
  }

  static String formatAmount(double amount) {
    return '${_selectedCurrency.symbol} ${amount.toStringAsFixed(2)}';
  }

  static String get currencySymbol => _selectedCurrency.symbol;
  static String get currencyCode => _selectedCurrency.code;
}