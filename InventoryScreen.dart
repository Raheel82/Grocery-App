import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/cart_service.dart';
import 'CartScreen.dart';
import 'DashboardScreen.dart'; // Import to access updateSelectedIndex

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> with SingleTickerProviderStateMixin {
  String selectedCategory = 'All';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final CartService cartService = CartService(FirebaseAuth.instance.currentUser?.uid ?? '');
  int cartItemCount = 0;
  late AnimationController _cartAnimationController;
  late Animation<double> _cartScaleAnimation;

  List<String> categories = [
    'All',
    'Fruits',
    'Vegetables',
    'Dairy & Eggs',
    'Meat & Seafood',
    'Bakery & Bread',
    'Frozen Foods',
    'Canned & Packaged Goods',
    'Snacks & Sweets',
    'Beverages',
    'Grains & Pasta',
    'Spices & Condiments',
    'Personal Care',
    'Household Items',
    'Baby Care',
    'Pet Care'
  ];

  @override
  void initState() {
    super.initState();
    _cartAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _cartScaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _cartAnimationController, curve: Curves.elasticOut),
    );
    _loadCartItemCount();
  }

  Future<void> _loadCartItemCount() async {
    try {
      final cart = await cartService.getCartItems();
      if (mounted) {
        setState(() {
          cartItemCount = cart?.length ?? 0;
          _cartAnimationController.forward(from: 0);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          cartItemCount = 0;
        });
      }
      debugPrint('Error loading cart items: $e');
    }
  }

  void _showAddToCartDialog(DocumentSnapshot doc) {
    int quantity = 1;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final data = doc.data() as Map<String, dynamic>;

            return AlertDialog(
              backgroundColor: const Color(0xFF2c5364),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text(
                'Add to Cart',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product: ${data['name']}',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Price: ₹${data['price']}',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Category: ${data['category']}',
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Quantity:',
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.white, size: 20),
                        onPressed: () {
                          if (quantity > 1) {
                            setDialogState(() => quantity--);
                          }
                        },
                      ),
                      Text(
                        '$quantity',
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white, size: 20),
                        onPressed: () {
                          setDialogState(() => quantity++);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(color: Colors.tealAccent, fontSize: 14),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      await cartService.addToCart({
                        'category': data['category'],
                        'id': data['productId'],
                        'name': data['name'],
                        'price': data['price'],
                        'quantity': quantity,
                      });
                      Navigator.pop(context);
                      _loadCartItemCount();
                      if (mounted) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Added to cart!',
                                style: GoogleFonts.poppins(),
                              ),
                              backgroundColor: Colors.teal,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        });
                      }
                    } catch (e) {
                      Navigator.pop(context);
                      if (mounted) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Failed to add to cart. Please try again.',
                                style: GoogleFonts.poppins(),
                              ),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        });
                      }
                      debugPrint('Error adding to cart: $e');
                    }
                  },
                  child: Text(
                    'Add',
                    style: GoogleFonts.poppins(color: Colors.tealAccent, fontSize: 14),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0f2027),
        automaticallyImplyLeading: false,
        actions: [
          AnimatedBuilder(
            animation: _cartScaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _cartScaleAnimation.value,
                child: IconButton(
                  icon: Stack(
                    children: [
                      const Icon(Icons.shopping_cart, color: Colors.white, size: 28),
                      if (cartItemCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: CircleAvatar(
                            radius: 8,
                            backgroundColor: Colors.tealAccent,
                            child: Text(
                              '$cartItemCount',
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    ).then((_) {
                      _loadCartItemCount();
                      // Ensure DashboardScreen shows InventoryScreen when returning
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        try {
                          DashboardScreen.updateSelectedIndex(context, 0);
                        } catch (e) {
                          Navigator.pushNamed(context, '/inventory');
                        }
                      });
                    });
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFF0f2027),
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => searchQuery = value.toLowerCase());
                    },
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      hintStyle: GoogleFonts.poppins(color: Colors.white54, fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: Colors.white, size: 20),
                      filled: true,
                      fillColor: const Color(0xFF203a43),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF203a43),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    dropdownColor: const Color(0xFF203a43),
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    underline: const SizedBox(),
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedCategory = value!);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("products")
                    .orderBy("timestamp", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading products',
                        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator(color: Colors.tealAccent));
                  }

                  final filtered = snapshot.data!.docs.where((doc) {
                    try {
                      final data = doc.data() as Map<String, dynamic>;
                      final nameMatch = data['name']?.toString().toLowerCase().contains(searchQuery) ?? false;
                      final categoryMatch = selectedCategory == 'All' || data['category'] == selectedCategory;
                      return nameMatch && categoryMatch;
                    } catch (e) {
                      debugPrint('Error filtering document: $e');
                      return false;
                    }
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        'No products found',
                        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.only(bottom: 8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisExtent: 150,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      try {
                        final data = filtered[index].data() as Map<String, dynamic>;

                        return GestureDetector(
                          onTap: () => _showAddToCartDialog(filtered[index]),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF203a43), Color(0xFF2c5364)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      data['name'] ?? 'Unknown Product',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      "₹${data['price'] ?? '0'}",
                                      style: GoogleFonts.poppins(
                                        color: Colors.tealAccent,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Category: ${data['category'] ?? 'Uncategorized'}",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white70,
                                        fontSize: 11,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      "ID: ${data['productId'] ?? 'N/A'}",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white38,
                                        fontSize: 9,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      } catch (e) {
                        debugPrint('Error building item at index $index: $e');
                        return const SizedBox.shrink();
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cartAnimationController.dispose();
    super.dispose();
  }
}