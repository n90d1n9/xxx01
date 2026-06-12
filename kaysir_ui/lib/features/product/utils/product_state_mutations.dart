import '../models/product.dart';

List<Product> upsertProductInList(
  Iterable<Product>? products,
  Product product,
) {
  final currentProducts = products ?? const <Product>[];
  var replaced = false;
  final next = <Product>[];

  for (final currentProduct in currentProducts) {
    if (currentProduct.id == product.id) {
      next.add(product);
      replaced = true;
    } else {
      next.add(currentProduct);
    }
  }

  if (!replaced) next.add(product);

  return List.unmodifiable(next);
}

List<Product> replaceProductInList(
  Iterable<Product>? products,
  Product product,
) => upsertProductInList(products, product);

List<Product> removeProductFromList(Iterable<Product>? products, String id) {
  return List.unmodifiable(
    (products ?? const <Product>[]).where((product) => product.id != id),
  );
}
