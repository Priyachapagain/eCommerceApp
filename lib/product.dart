import 'package:hive/hive.dart';

part 'Product.g.dart'; // This part file is needed for Hive to generate the adapter

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final String description;

  @HiveField(5)
  final String image;

  @HiveField(6)
  int quantity;

  @HiveField(7)
  bool isSelected;

  @HiveField(8) // Added a field for the rating
  final Rating? rating;

  Product({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.description,
    required this.image,
    this.quantity = 1,
    this.isSelected = false,
    this.rating,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      price: json['price'].toDouble(),
      description: json['description'],
      image: json['image'],
      rating: json['rating'] != null ? Rating.fromJson(json['rating']) : null, // Handling rating
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'price': price,
      'description': description,
      'image': image,
      'quantity': quantity,
      'isSelected': isSelected,
      'rating': rating?.toJson(), // Convert rating to JSON if it exists
    };
  }

  void updateQuantity(int newQuantity) {
    quantity = newQuantity;
  }
}

@HiveType(typeId: 1) // Separate typeId for the Rating class
class Rating {
  @HiveField(0)
  final double rate;

  @HiveField(1)
  final int count;

  Rating({
    required this.rate,
    required this.count,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      rate: json['rate'].toDouble(),
      count: json['count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rate': rate,
      'count': count,
    };
  }
}
