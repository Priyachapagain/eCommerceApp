import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:newecommerce/global/preferences_manager.dart';
import 'dart:convert';
import '../auth/signup_screen.dart';
import '../product_pages/product.dart';
import '../global/app_color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BillingPage extends StatefulWidget {
  final List<Product> selectedProducts;
  final double totalPrice;
  final Map<int, int> productQuantities;

  const BillingPage({
    super.key,
    required this.selectedProducts,
    required this.totalPrice,
    required this.productQuantities,
  });

  @override
  _BillingPageState createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> {
  Map<String, dynamic>? paymentIntentData;
  bool isSignedIn = false;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

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
        body: json
            .encode({'amount': (widget.totalPrice).toInt()}), // Amount in cents
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

      await Stripe.instance.presentPaymentSheet();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment successful!')),
      );

      // Store product in Firebase after payment
      await storeProductInFirebase();

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
    for (var product in widget.selectedProducts) {
      final quantity = widget.productQuantities[product.id] ?? 1;
      await FirebaseFirestore.instance.collection('orders').add({
        'userId': userId, // Add userId to the order
        'productId': product.id,
        'title': product.title,
        'price': product.price,
        'quantity': quantity,
        'image': product.image,
        'totalPrice': widget.totalPrice,
        'status': 'completed',
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
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
              style:
                  TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
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
                  builder: (context) => const SignupScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Sign Up',
                style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void showConfirmationDialog() {
    double totalAmount = widget.totalPrice;
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
              style:
                  TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to pay \$${totalAmount.toStringAsFixed(2)}?',
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

  @override
  Widget build(BuildContext context) {
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
              'Selected Products:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: widget.selectedProducts.length,
                itemBuilder: (context, index) {
                  final product = widget.selectedProducts[index];
                  final quantity = widget.productQuantities[product.id] ?? 1;
                  bool isCompleted = paymentIntentData == null;

                  return Padding(
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
                              spreadRadius: 2)
                        ],
                      ),
                      child: ListTile(
                        leading:
                            Image.network(product.image, width: 60, height: 60),
                        title: Text(product.title),
                        subtitle: Text(
                          'Price: \$${product.price.toStringAsFixed(2)} x$quantity',
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Total: \$${widget.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.green,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    isSignedIn ? showConfirmationDialog() : showSignUpDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Payment through Stripe',
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
