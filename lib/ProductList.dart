import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Product.dart';
import 'ProductCard.dart';
import 'ProductDetails.dart';
import 'app_color.dart';
import 'categoryitem.dart';
import 'package:shimmer/shimmer.dart';  // Import shimmer package

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<Product>> _products;
  String _selectedCategory = 'all'; // Default to 'all'
  TextEditingController _searchController = TextEditingController();
  List<Product> _allProducts = []; // Store all fetched products here
  List<Product> _filteredProducts = []; // Store filtered products here based on search
  bool _isLoading = true; // Track the loading state

  int _currentIndex = 0; // Track the selected index for bottom navigation

  @override
  void initState() {
    super.initState();
    _onCategoryTap('all'); // Fetch all products by default
  }

  // Fetch Products from API
  Future<List<Product>> fetchProducts({String? category}) async {
    final url = category == 'all'
        ? 'https://fakestoreapi.com/products'
        : 'https://fakestoreapi.com/products/category/$category';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<Product> products =
      data.map((json) => Product.fromJson(json)).toList();

      // Save all products and filtered products initially
      setState(() {
        _allProducts = products;
        _filteredProducts = products;
        _isLoading = false; // Data has been loaded
      });
      return products;
    } else {
      throw Exception('Failed to load products');
    }
  }

  // Filter products by search query
  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        // If search query is empty, show all products
        _filteredProducts = _allProducts;
      } else {
        // Filter the products based on the title
        _filteredProducts = _allProducts
            .where((product) =>
            product.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _onCategoryTap(String? category) {
    setState(() {
      _selectedCategory = category ?? 'all';
      _isLoading = true; // Set loading state when fetching new data
      _products = fetchProducts(category: _selectedCategory);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      // Handle navigation to different screens based on the selected index
    });
  }

  // Build shimmer placeholder
  Widget _buildShimmerProductGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              color: Colors.white,
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
            ),
          );
        },
        childCount: 6, // Display 6 placeholders
      ),
    );
  }

  // Build the real product grid
  Widget _buildProductGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final product = _filteredProducts[index];
          return ProductCard(
            product: product,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(product: product),
                ),
              );
            },
          );
        },
        childCount: _filteredProducts.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparentColor,
      appBar: AppBar(
        title: const Text(
          'Products',
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
        titleTextStyle: const TextStyle(
          fontSize: 18, // Adjust the font size of the title text
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomScrollView(
          slivers: [
            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: TextFormField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Find what you need...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColors.mainColor, // Set the focus color to mainColor
                        width: 0.5, // You can adjust the width if necessary
                      ),
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.mainColor, // Change the icon color if needed
                    ),
                  ),
                  cursorColor: AppColors.mainColor, // Set the cursor color to mainColor
                  onChanged: (value) {
                    _filterProducts(value); // Apply search filter on text change
                  },
                ),
              ),
            ),

            // Categories Section
            SliverToBoxAdapter(
              child: SizedBox(
                height: 100, // Increased height for the horizontal list
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      CategoryItem(
                        image: const AssetImage('assets/Images/product.png'),
                        label: "All",
                        onTap: () => _onCategoryTap('all'), // Default category
                      ),
                      const SizedBox(width: 10),
                      CategoryItem(
                        image: const AssetImage('assets/Images/mens.png'),
                        label: "men's clothing",
                        onTap: () => _onCategoryTap("men's clothing"),
                      ),
                      const SizedBox(width: 10),
                      CategoryItem(
                        image: const AssetImage('assets/Images/jwellery.png'),
                        label: "jewelery",
                        onTap: () => _onCategoryTap("jewelery"),
                      ),
                      const SizedBox(width: 10),
                      CategoryItem(
                        image: const AssetImage('assets/Images/electronics.png'),
                        label: "electronics",
                        onTap: () => _onCategoryTap("electronics"),
                      ),
                      const SizedBox(width: 10),
                      CategoryItem(
                        image: const AssetImage('assets/Images/woman.png'),
                        label: "women's clothing",
                        onTap: () => _onCategoryTap("women's clothing"),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Show shimmer when loading, else show the product grid
            _isLoading ? _buildShimmerProductGrid() : _buildProductGrid(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.mainColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_outlined),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
