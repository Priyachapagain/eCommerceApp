import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newecommerce/firebase_options.dart';
import 'package:newecommerce/screens/splash_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'global/app_color.dart';
import 'product_pages/product.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("b859ffb1-7e6f-4724-8afd-23a987856478");
  OneSignal.Notifications.requestPermission(true);
  await Hive.initFlutter();
  Hive.registerAdapter(ProductAdapter());
  await Hive.openBox<Product>('productsBox');
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: AppColors.mainColor,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: AppColors.mainColor,
          secondary: AppColors.mainColor,
        ),

      ),
      debugShowCheckedModeBanner: false,
      title: 'Product App',
      home: SplashScreen(),
    );
  }
}
