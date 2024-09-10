import 'package:flutter/material.dart';
import 'Product.dart';

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
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Hero(
                  tag: product.id,
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                product.title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('\$${product.price.toStringAsFixed(2)}'),
            ),
          ],
        ),
      ),
    );
  }
}
