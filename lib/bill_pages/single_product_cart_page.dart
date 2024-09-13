import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../global/preferences_manager.dart';
import '../auth/signup_screen.dart';
import '../product_pages/product.dart';
import '../global/app_color.dart';

class SingleBillingPage extends StatefulWidget {
  final Product product;
  final double totalPrice;

  const SingleBillingPage({
    super.key,
    required this.product,
    required this.totalPrice,
  });

  @override
  _BillingPageState createState() => _BillingPageState();
}

class _BillingPageState extends State<SingleBillingPage> {
  Map<String, dynamic>? paymentIntentData;
  bool isSignedIn = false;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    Stripe.publishableKey =
    "your_publishable_key";
    _checkSignInStatus();
  }

  Future<void> _checkSignInStatus() async {
    bool status = await PreferencesManager.getSignedInStatus();
    setState(() {
      isSignedIn = status;
    });
  }

  Future<void> createPaymentIntent() async {
    try {
      final url = Uri.parse('http://192.168.1.5:3001/create-payment-intent');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': (widget.totalPrice * quantity).toInt(),
        }),
      );

      if (response.statusCode == 200) {
        paymentIntentData = jsonDecode(response.body);
      } else {
        throw Exception('Failed to create PaymentIntent');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> processStripePayment() async {
    try {
      await createPaymentIntent();

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData!['clientSecret'],
          style: ThemeMode.light,
          merchantDisplayName: 'Your Merchant Name',
        ),
      );

      await storeProductInFirebase();

      await Stripe.instance.presentPaymentSheet();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment successful!')),
      );
      setState(() {
        paymentIntentData = null;
      });
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e')),
      );
    }
  }

  Future<void> storeProductInFirebase() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    await FirebaseFirestore.instance.collection('orders').add({
      'userId': userId,
      'productId': widget.product.id,
      'title': widget.product.title,
      'price': widget.product.price,
      'quantity': quantity,
      'image': widget.product.image,
      'totalPrice': widget.totalPrice * quantity,
      'status': 'completed',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void showSignUpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text(
              'Sign Up Required',
              style: TextStyle(
                  color: Colors.black87, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Please sign up to proceed with the payment.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SignupScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Sign Up', style: TextStyle(color: Colors.white),),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.green),
            SizedBox(width: 8),
            Text(
              'Confirm Payment',
              style: TextStyle(
                  color: Colors.black87, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to pay \$${(widget.totalPrice * quantity).toStringAsFixed(2)}?',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              processStripePayment();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Yes, Pay Now',
                style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _updateQuantity(int delta) {
    setState(() {
      quantity = (quantity + delta).clamp(1, 99);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double updatedTotalPrice = widget.totalPrice * quantity;

    return Scaffold(
      backgroundColor: AppColors.transparentColor,
      appBar: AppBar(
        title: const Text(
          'Billing Information',
          style: TextStyle(
            color: AppColors.mainColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 50,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.mainColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selected Product:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 8,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: ListTile(
                  leading: Image.network(
                    widget.product.image,
                    width: 60,
                    height: 60,
                  ),
                  title: Text(widget.product.title),
                  subtitle: Text(
                    'Price: \$${widget.product.price.toStringAsFixed(2)}',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Total: \$${updatedTotalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.green, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                IconButton(
                  icon: const Icon(Icons.remove, color: AppColors.mainColor),
                  onPressed: () => _updateQuantity(-1),
                ),
                Text(
                  '$quantity',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: AppColors.mainColor),
                  onPressed: () => _updateQuantity(1),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                ElevatedButton(
                  onPressed: () {
                    if (isSignedIn) {
                      showConfirmationDialog();
                    } else {
                      showSignUpDialog();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Proceed to Pay',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
