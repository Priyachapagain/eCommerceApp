import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newecommerce/home_page.dart';
import 'app_color.dart';
import 'product.dart';
import 'product_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Register the Product adapter
  Hive.registerAdapter(ProductAdapter());

  // Open the product box with the correct type
  await Hive.openBox<Product>('productsBox');

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Product App',

      home: HomePage(),
    );
  }
}
