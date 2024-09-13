import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'product.dart';
import 'package:hive/hive.dart';

final productBoxProvider = Provider<Box<Product>>((ref) {
  return Hive.box<Product>('productsBox');
});

final productListProvider = StateNotifierProvider<ProductListNotifier, List<Product>>((ref) {
  final box = ref.watch(productBoxProvider);
  return ProductListNotifier(box);
});

class ProductListNotifier extends StateNotifier<List<Product>> {
  final Box<Product> productBox;

  ProductListNotifier(this.productBox) : super([]) {
    loadProducts();
  }

  Future<void> loadProducts() async {

    state = productBox.values.toList();
  }

  void addProduct(Product product) {
    productBox.put(product.id, product);
    state = [...state, product];
  }

  void updateProductQuantity(Product product, int newQuantity) {
    product.updateQuantity(newQuantity);
    productBox.put(product.id, product);
    state = [...state];
  }

  List<Product> filterProductsByCategory(String category) {
    return category == 'all'
        ? state
        : state.where((product) => product.category == category).toList();
  }
}
