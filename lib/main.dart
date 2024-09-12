import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newecommerce/home_page.dart';

import 'app_color.dart';
import 'product.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  // Register the Product adapter
  Hive.registerAdapter(ProductAdapter());
  // Open the product box with the correct type
  await Hive.openBox<Product>('productsBox');
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: AppColors.mainColor, // Change the primary color
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: AppColors.mainColor,  // For primary elements (AppBar, buttons, etc.)
          secondary: AppColors.mainColor,  // For accent color
        ),

      ),
      debugShowCheckedModeBanner: false,
      title: 'Product App',
      home: HomePage(),
    );
  }
}
