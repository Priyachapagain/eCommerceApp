import 'package:flutter/material.dart';
import 'Product.dart';
import 'app_color.dart';

class CartPage extends StatefulWidget {
  final List<Product> products;

  CartPage({required this.products});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Map<int, int> productQuantities = {}; // Maps product ID to quantity
  Map<int, bool> selectedProducts = {}; // Maps product ID to selection state
  bool selectAll = false; // Tracks whether all products are selected

  @override
  void initState() {
    super.initState();
    for (var product in widget.products) {
      productQuantities[product.id] = 1; // Initialize each product's quantity as 1
      selectedProducts[product.id] = false; // Initialize each product as unselected
    }
  }

  double getTotalPrice() {
    double total = 0;
    widget.products.forEach((product) {
      if (selectedProducts[product.id]!) {
        total += product.price * productQuantities[product.id]!;
      }
    });
    return total;
  }

  void toggleSelectAll(bool? value) {
    setState(() {
      selectAll = value!;
      widget.products.forEach((product) {
        selectedProducts[product.id] = selectAll; // Set all products to the same selection state
      });
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
            fontSize: 20, // Adjust font size for the title
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white, // Customize background color if needed
        elevation: 0, // Remove shadow if desired
        toolbarHeight: 50, // Set a smaller height for the AppBar
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.mainColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Select All Checkbox
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Checkbox(
                  activeColor: AppColors.mainColor,
                  value: selectAll,
                  onChanged: toggleSelectAll, // Toggle select all products
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
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: widget.products.length,
                itemBuilder: (context, index) {
                  final product = widget.products[index];
                  return Card(
                    color: Colors.white,
                    child: ListTile(
                      leading: Checkbox(
                        activeColor: AppColors.mainColor, // Set checkbox color
                        value: selectedProducts[product.id],
                        onChanged: (value) {
                          setState(() {
                            selectedProducts[product.id] = value!;
                          });
                        },
                      ),
                      title: Row(
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppColors.mainColor,
                                  width: 1), // Border color and width
                              borderRadius: BorderRadius.circular(8), // Rounded corners
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
                                    }
                                  });
                                },
                                padding: const EdgeInsets.all(0), // Remove extra padding
                                iconSize: 15,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            productQuantities[product.id].toString(),
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppColors.mainColor,
                                  width: 1), // Border color and width
                              borderRadius: BorderRadius.circular(8), // Rounded corners
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
                                  });
                                },
                                padding: const EdgeInsets.all(0), // Remove extra padding
                                iconSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.mainColor, width: 0.8), // Border color and width
                borderRadius: BorderRadius.circular(10), // Rounded corners
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\$ ${getTotalPrice().toStringAsFixed(2)}', // Fixed decimals for consistency
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Implement checkout functionality here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Text(
                        'Checkout',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
