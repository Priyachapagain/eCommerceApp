class Product {
  final int id;
  final String title;
  final String category;
  final double price;
  final String description;
  final String image;
  int quantity; // Manage quantity
  bool isSelected; // Add this field to track selection

  Product({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.description,
    required this.image,
    this.quantity = 1, // Default quantity is 1
    this.isSelected = false, // Default selected state is false
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      price: json['price'].toDouble(),
      description: json['description'],
      image: json['image'],
    );
  }

  // Method to update the quantity
  void updateQuantity(int newQuantity) {
    quantity = newQuantity;
  }
}
