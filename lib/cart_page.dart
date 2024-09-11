import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'billing_page.dart';
import 'product.dart';
import 'app_color.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Product> cartProducts = [
  ]; // Store products loaded from SharedPreferences
  Map<int, int> productQuantities = {}; // Maps product ID to quantity
  Map<int, bool> selectedProducts = {}; // Maps product ID to selection state
  bool selectAll = false; // Tracks whether all products are selected

  @override
  void initState() {
    super.initState();
    _loadCartData();
  }

  // Load cart data from SharedPreferences
  Future<void> _loadCartData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? storedCart = prefs.getStringList('cart');
    if (storedCart != null) {
      setState(() {
        cartProducts = storedCart
            .map((item) => Product.fromJson(jsonDecode(item)))
            .toList();
        for (var product in cartProducts) {
          productQuantities[product.id] = product.quantity; // Load quantities
          selectedProducts[product.id] = false; // Initialize as unselected
        }
      });
    }
  }

  // Save updated cart data to SharedPreferences
  Future<void> _saveCartData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> updatedCart = cartProducts
        .map((product) => jsonEncode(product.toJson()))
        .toList();
    await prefs.setStringList('cart', updatedCart);
  }

  double getTotalPrice() {
    double total = 0;
    cartProducts.forEach((product) {
      if (selectedProducts[product.id]!) {
        total += product.price * productQuantities[product.id]!;
      }
    });
    return total;
  }

  void toggleSelectAll(bool? value) {
    setState(() {
      selectAll = value!;
      cartProducts.forEach((product) {
        selectedProducts[product.id] =
            selectAll; // Set all products to selected state
      });
    });
  }

  void _showSignUpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Up Required'),
          content: const Text(
              'Please sign up or log in to continue with the checkout.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {

              },
              child: const Text('Sign Up'),
            ),
          ],
        );
      },
    );
  }

  // Remove a product from the cart
  void removeProduct(Product product) {
    setState(() {
      cartProducts.remove(product); // Remove product from the list
      productQuantities.remove(product.id); // Remove quantity mapping
      selectedProducts.remove(product.id); // Remove selection mapping
      _saveCartData(); // Save updated cart to SharedPreferences
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparentColor,
      appBar: AppBar(
        title: const Text(
          'My Cart',
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
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.mainColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartProducts.length,
              itemBuilder: (context, index) {
                final product = cartProducts[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Checkbox(
                        side: const BorderSide(
                          color: AppColors.mainColor,
                          width: 1.0,
                        ),
                        focusColor: AppColors.mainColor,
                        activeColor: AppColors.mainColor,
                        value: selectedProducts[product.id],
                        onChanged: (value) {
                          setState(() {
                            selectedProducts[product.id] = value!;
                          });
                        },
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.network(product.image, width: 60, height: 60),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.title,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                    '\$ ${product.price.toStringAsFixed(2)}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Decrement button
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppColors.mainColor, width: 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: IconButton(
                                icon: const Icon(
                                  Icons.remove,
                                  color: AppColors.mainColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (productQuantities[product.id]! > 1) {
                                      productQuantities[product.id] =
                                          productQuantities[product.id]! - 1;
                                      product.quantity =
                                      productQuantities[product.id]!;
                                      _saveCartData(); // Save updated quantity
                                    }
                                  });
                                },
                                padding: const EdgeInsets.all(0),
                                iconSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            productQuantities[product.id].toString(),
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 6),
                          // Increment button
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppColors.mainColor, width: 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  color: AppColors.mainColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    productQuantities[product.id] =
                                        productQuantities[product.id]! + 1;
                                    product.quantity =
                                    productQuantities[product.id]!;
                                    _saveCartData(); // Save updated quantity
                                  });
                                },
                                padding: const EdgeInsets.all(0),
                                iconSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Remove button
                          IconButton(
                            icon: const Icon(Icons.delete_outlined,
                                color: AppColors.mainColor),
                            onPressed: () {
                              removeProduct(
                                  product); // Remove product from cart
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Divider between the product list and select all/total

          // White background container below the divider
          Container(
            color: Colors.white,
            // White background color for the bottom section
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, top: 4.0, bottom: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      side: const BorderSide(
                        color: AppColors.mainColor,
                        width: 1.0,
                      ),
                      activeColor: AppColors.mainColor,
                      value: selectAll,
                      onChanged: toggleSelectAll,
                    ),
                    const Text(
                      'Select All',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total: \$${getTotalPrice().toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Create a list of selected products and their quantities
                        final selectedProductsList = cartProducts
                            .where((product) => selectedProducts[product.id] == true)
                            .toList();

                        // Create a map to track the quantity of each selected product
                        final productQuantities = {
                          for (var product in selectedProductsList)
                            product.id: product.quantity, // Assuming you have a quantity field in Product model
                        };

                        if (selectedProductsList.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select at least one product'),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BillingPage(
                                selectedProducts: selectedProductsList,
                                totalPrice: getTotalPrice(),
                                productQuantities: productQuantities, // Pass the product quantities
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Place the Order',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    )

                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}