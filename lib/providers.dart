import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Define a FutureProvider to load products
final productListProvider = FutureProvider<List<Product>>((ref) async {
  final box = await Hive.openBox<Product>('productBox');

  if (box.isEmpty) {
    final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<Product> products = data.map((json) => Product.fromJson(json)).toList();

      for (var product in products) {
        box.put(product.id, product);
      }
      return products;
    } else {
      throw Exception('Failed to load products');
    }
  } else {
    return box.values.toList();
  }
});

// Filter provider
final filteredProductProvider = StateProvider<List<Product>>((ref) {
  final allProducts = ref.watch(productListProvider).asData?.value ?? [];
  return allProducts;
});
