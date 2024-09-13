import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bill_pages/billing_page.dart';
import '../product_pages/product.dart';
import '../global/app_color.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Product> cartProducts = [];
  Map<int, int> productQuantities = {};
  Map<int, bool> selectedProducts = {};
  bool selectAll = false;

  @override
  void initState() {
    super.initState();
    _loadCartData();
  }

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
        selectedProducts[product.id] = selectAll;
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
              onPressed: () {},
              child: const Text('Sign Up'),
            ),
          ],
        );
      },
    );
  }

  void removeProduct(Product product) {
    setState(() {
      cartProducts.remove(product);
      productQuantities.remove(product.id);
      selectedProducts.remove(product.id);
      _saveCartData();
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
                                Text('\$ ${product.price.toStringAsFixed(2)}'),
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
                              removeProduct(product); // Remove product from cart
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
          Container(
            color: Colors.white,
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
                        final selectedProductsList = cartProducts
                            .where((product) =>
                        selectedProducts[product.id] == true)
                            .toList();

                        final productQuantities = {
                          for (var product in selectedProductsList)
                            product.id: product.quantity,
                        };

                        if (selectedProductsList.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                              Text('Please select at least one product'),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BillingPage(
                                productQuantities: productQuantities,
                                selectedProducts: selectedProductsList,
                                totalPrice: getTotalPrice(),
                              ),
                            ),
                          ).then((_) {
                            setState(() {
                              cartProducts.removeWhere((product) =>
                              selectedProducts[product.id] == true);
                              selectedProducts.removeWhere(
                                      (id, selected) => selected == true);
                              productQuantities.removeWhere((id, quantity) =>
                                  selectedProducts.containsKey(id));
                              _saveCartData();
                            });
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainColor,
                      ),
                      child: const Text(
                        'Place the Order',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
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
