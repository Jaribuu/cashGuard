import 'package:intl/intl.dart';

class CurrencyFormatter {
  // Private constructor to prevent instantiation
  CurrencyFormatter._();

  // Default currency is USD
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  // Format number to currency (e.g., $1,234.56)
  static String format(double amount) {
    return _currencyFormatter.format(amount);
  }

  // Format number to currency without symbol (e.g., 1,234.56)
  static String formatWithoutSymbol(double amount) {
    return _currencyFormatter.format(amount).replaceAll(_currencyFormatter.currencySymbol, '').trim();
  }

  // Parse currency string to double
  static double parse(String amount) {
    // Remove currency symbol and commas
    String sanitized = amount.replaceAll(_currencyFormatter.currencySymbol, '')
        .replaceAll(',', '')
        .trim();
    return double.tryParse(sanitized) ?? 0.0;
  }

  // Format number as percentage
  static String formatAsPercentage(double value) {
    return NumberFormat.percentPattern().format(value / 100);
  }

  // Format for compact display of large numbers
  static String formatCompact(double value) {
    return NumberFormat.compact().format(value);
  }
}