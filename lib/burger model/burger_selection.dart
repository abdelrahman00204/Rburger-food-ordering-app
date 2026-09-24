class BurgerSelection {
  final BurgerIngredient bun;
  final BurgerIngredient patty;
  final BurgerIngredient cheese;
  final BurgerIngredient sauce;
  final List<BurgerIngredient> toppings;

  const BurgerSelection({
    required this.bun,
    required this.patty,
    required this.cheese,
    required this.sauce,
    required this.toppings,
  });

  int get totalPrice {
    const basePrice = 0;
    final toppingsTotal = toppings.fold<int>(0, (sum, t) => sum + t.priceDelta);
    return basePrice +
        bun.priceDelta +
        patty.priceDelta +
        cheese.priceDelta +
        sauce.priceDelta +
        toppingsTotal;
  }

  bool get isDoublePatty =>
      patty.label.toLowerCase().contains('double') ||
      patty.id == 'patty_double';
  bool get hasCheese =>
      !cheese.label.toLowerCase().contains('no') &&
      !cheese.label.toLowerCase().contains('بدون') &&
      cheese.id != 'cheese_none';
  bool get hasBriocheBun => bun.label.toLowerCase().contains('brioche');
  bool get hasOnion => toppings.any(
    (t) =>
        t.label.toLowerCase().contains('onion') ||
        t.label.toLowerCase().contains('بصل'),
  );
  bool get hasMushroom => toppings.any(
    (t) =>
        t.label.toLowerCase().contains('mushroom') ||
        t.label.toLowerCase().contains('مشروم'),
  );
  bool get hasPickles => toppings.any(
    (t) =>
        t.label.toLowerCase().contains('pickle') ||
        t.label.toLowerCase().contains('مخلل'),
  );
}

class BurgerIngredient {
  final String id;
  final String label;
  final int priceDelta;

  const BurgerIngredient({
    required this.id,
    required this.label,
    this.priceDelta = 0,
  });

  String get chipLabel {
    final sign = priceDelta > 0 ? '+' : '';
    return '$label $sign$priceDelta';
  }
}
