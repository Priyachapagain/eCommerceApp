import 'package:flutter/material.dart';
import 'package:newecommerce/app_color.dart';
import 'Product.dart';
import 'cart_page.dart';

List<Product> cart = [];
class ProductDetailScreen extends StatelessWidget {
  final Product product;

  ProductDetailScreen({required this.product});

  void addToCart(Product product) {
    bool productExists = false;

    // Check if the product is already in the cart
    for (var cartProduct in cart) {
      if (cartProduct.id == product.id) {
        productExists = true;
        cartProduct.quantity += 1; // Increment quantity if product exists
        break;
      }
    }

    // If the product doesn't exist in the cart, add it with quantity 1
    if (!productExists) {
      product.quantity = 1; // Set initial quantity to 1
      cart.add(product);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          product.title,
          style: const TextStyle(
            color: AppColors.mainColor,
            fontSize: 20, // Adjust font size for the title
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white, // Customize background color if needed
        elevation: 0, // Remove shadow if desired
        toolbarHeight: 50, // Set a smaller height for the AppBar
        titleTextStyle: const TextStyle(
          fontSize: 18, // Adjust the font size of the title text
          fontWeight: FontWeight.bold,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.mainColor,),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(

        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: product.id,
                child: Center(
                  child: Image.network(
                    product.image,
                    height: 400,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Text(
                product.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 40, color: Colors.green),
              ),
              const SizedBox(height: 14),
              const Text("Description",style: const TextStyle(fontSize: 25,
                  )),
              const SizedBox(height: 6),
              Text(product.description, style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blueGrey),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.mainColor, width: 2), // Border color and width
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
                child: TextButton(
                  onPressed: () {
                    // Add to cart functionality
                    addToCart(product);

                    // Show a confirmation message (SnackBar)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${product.title} added to the cart!',
                          style: TextStyle(color: Colors.white), // Set text color if needed
                        ),
                        backgroundColor: AppColors.greenColor, // Set the background color
                      ),
                    );

                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.mainColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined),
                      SizedBox(width: 3,),
                      Text('Add to Cart'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.mainColor, width: 2), // Border color and width
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to Checkout screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CartPage(products: cart)),
                    );
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
