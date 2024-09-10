import 'package:flutter/material.dart';

class CategoryItem extends StatelessWidget {
  final ImageProvider image;
  final String label;
  final VoidCallback onTap; // Add onTap callback

  CategoryItem({required this.image, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Handle tap event
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white,
              child: ClipOval( // Clip the image to fit inside the circle
                child: Image(
                  image: image, // Use Image widget instead of ImageIcon
                  fit: BoxFit.cover, // Ensure the image fits well within the circle
                  width: 30, // Set the width to match the CircleAvatar size
                  height: 30, // Set the height to match the CircleAvatar size
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
