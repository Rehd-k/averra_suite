extension FinancialFormat on String {
  String mathFunc(Match match) => '${match[1]},';

  String formatToFinancial({bool isMoneySymbol = false}) {
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');

    final formatNumber = replaceAllMapped(reg, mathFunc);
    if (isMoneySymbol) {
      return '\u20A6 $formatNumber';
    }
    return formatNumber;
  }
}

String capitalizeFirstLetter(String input) {
  if (input.isEmpty) {
    return input;
  }
  return input[0].toUpperCase() + input.substring(1);
}
