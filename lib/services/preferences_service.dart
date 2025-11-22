import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _currencyKey = 'salary_currency';
  static const String _defaultCurrency = 'NGN'; // Nigerian Naira

  // Get the selected currency
  static Future<String> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currencyKey) ?? _defaultCurrency;
  }

  // Set the selected currency
  static Future<void> setCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currency);
  }

  // Get currency symbol
  static String getCurrencySymbol(String currency) {
    switch (currency) {
      case 'NGN':
        return '₦';
      case 'USD':
        return '\$';
      case 'GBP':
        return '£';
      case 'EUR':
        return '€';
      default:
        return '\$';
    }
  }

  // Get currency name
  static String getCurrencyName(String currency) {
    switch (currency) {
      case 'NGN':
        return 'Nigerian Naira';
      case 'USD':
        return 'US Dollar';
      case 'GBP':
        return 'British Pound';
      case 'EUR':
        return 'Euro';
      default:
        return 'US Dollar';
    }
  }

  // Available currencies
  static List<String> getAvailableCurrencies() {
    return ['NGN', 'USD', 'GBP', 'EUR'];
  }
}

