import 'package:flutter/material.dart';
import 'product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final void Function() onTap;

  ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Hero(
                  tag: product.id,
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: Stack(
                        children: [
                          product.image.isNotEmpty
                              ? Image.network(
                            product.image,
                            fit: BoxFit.fitHeight,
                          )
                              : const Placeholder(
                            fallbackHeight: 120,
                            fallbackWidth: double.infinity,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (product.rating != null) ...[
                    Icon(Icons.star, color: Colors.amber, size: 16.0),
                    SizedBox(width: 4.0),
                    Text(
                      '${product.rating!.rate.toStringAsFixed(1)}', // Display the rating
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      '(${product.rating!.count} reviews)', // Display the count of reviews
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                product.title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('\$${product.price.toStringAsFixed(2)}', style: TextStyle(color: Colors.green, fontSize: 18),),
            ),
            SizedBox(height: 10,)
            // Add rating and count section

          ],
        ),
      ),
    );
  }
}
