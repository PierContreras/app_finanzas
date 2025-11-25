extension CurrencyExtension on double {
  String toCurrency() {
    return '\$${toStringAsFixed(2)}';
  }
}

extension IntCurrencyExtension on int {
  String toCurrency() {
    return '\$${toString()}';
  }
}

extension DateTimeExtension on DateTime {
  String toFormattedDate() {
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
  }

  String toMonthYear() {
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${months[month - 1]} $year';
  }
}