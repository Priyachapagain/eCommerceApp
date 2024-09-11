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
    // Load products from Hive box when initialized
    loadProducts();
  }

  // Load products from API and save them to Hive
  Future<void> loadProducts() async {
    // Fetch from API or use some predefined data
    // For now let's simulate loading from the box
    state = productBox.values.toList();
  }

  // Add a product to the list and save it to Hive
  void addProduct(Product product) {
    productBox.put(product.id, product);
    state = [...state, product];
  }

  // Update quantity for a product
  void updateProductQuantity(Product product, int newQuantity) {
    product.updateQuantity(newQuantity);
    productBox.put(product.id, product); // Save the updated product
    state = [...state]; // Trigger UI update
  }

  // Filter products by category
  List<Product> filterProductsByCategory(String category) {
    return category == 'all'
        ? state
        : state.where((product) => product.category == category).toList();
  }
}
