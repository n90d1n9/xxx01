String formatFnbMoney(int cents) {
  return '\$${(cents / 100).toStringAsFixed(2)}';
}
