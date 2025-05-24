import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import 'DashboardScreen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  late final cartService = CartService(user?.uid ?? '');
  late final orderService = OrderService(user?.uid ?? '');
  bool _isPlacingOrder = false;
  ScaffoldMessengerState? _scaffoldMessenger;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f2027),
      appBar: AppBar(
        backgroundColor: const Color(0xFF203a43),
        title: Text('Your Cart', style: GoogleFonts.poppins(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('cart')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading cart: ${snapshot.error}',
                style: GoogleFonts.poppins(color: Colors.white70),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Colors.tealAccent));
          }

          final cartItems = snapshot.data!.docs;

          if (cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, color: Colors.white54, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent[700],
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        try {
                          DashboardScreen.updateSelectedIndex(context, 0);
                        } catch (e) {
                          Navigator.pushNamed(context, '/inventory');
                        }
                      });
                    },
                    child: Text('Continue Shopping', style: GoogleFonts.poppins()),
                  ),
                ],
              ),
            );
          }

          double total = 0;
          for (var doc in cartItems) {
            final data = doc.data() as Map<String, dynamic>;
            total += ((data['price'] as num?) ?? 0) * ((data['quantity'] as num?) ?? 0);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final data = cartItems[index].data() as Map<String, dynamic>;
                    return Card(
                      color: const Color(0xFF203a43),
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(
                          data['name'] ?? 'Unknown Product',
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Category: ${data['category'] ?? 'Unknown'}',
                              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${data['price'] ?? 0} x ${data['quantity'] ?? 0}',
                              style: GoogleFonts.poppins(color: Colors.tealAccent, fontSize: 14),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '₹${((data['price'] as num?) ?? 0) * ((data['quantity'] as num?) ?? 0)}',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent, size: 22),
                              onPressed: () async {
                                try {
                                  await cartService.removeFromCart(data['id'].toString());
                                  if (mounted) {
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      _scaffoldMessenger?.showSnackBar(
                                        SnackBar(
                                          content: Text('Item removed', style: GoogleFonts.poppins()),
                                          backgroundColor: Colors.redAccent,
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    });
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      _scaffoldMessenger?.showSnackBar(
                                        SnackBar(
                                          content: Text('Failed to remove item', style: GoogleFonts.poppins()),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    });
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF203a43),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
                          ),
                          Text(
                            '₹${total.toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.tealAccent[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _isPlacingOrder
                              ? null
                              : () async {
                            if (user == null) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _scaffoldMessenger?.showSnackBar(
                                  SnackBar(
                                    content: Text('Please log in to place an order', style: GoogleFonts.poppins()),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              });
                              return;
                            }

                            if (cartItems.isEmpty) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _scaffoldMessenger?.showSnackBar(
                                  SnackBar(
                                    content: Text('Cart is empty', style: GoogleFonts.poppins()),
                                  ),
                                );
                              });
                              return;
                            }

                            setState(() {
                              _isPlacingOrder = true;
                            });

                            try {
                              await orderService.placeOrder(
                                cartItems.map((e) => e.data() as Map<String, dynamic>).toList(),
                                total,
                              );

                              if (mounted) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _scaffoldMessenger?.showSnackBar(
                                    SnackBar(
                                      content: Text('Order placed successfully!', style: GoogleFonts.poppins()),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  Navigator.pop(context);
                                });
                              }
                            } catch (e) {
                              if (mounted) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _scaffoldMessenger?.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        e.toString().contains('TimeoutException')
                                            ? 'Network error: Could not connect to server. Please try again.'
                                            : 'Failed to place order: $e',
                                        style: GoogleFonts.poppins(),
                                      ),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                });
                              }
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isPlacingOrder = false;
                                });
                              }
                            }
                          },
                          icon: _isPlacingOrder
                              ? Container(
                            width: 24,
                            height: 24,
                            padding: const EdgeInsets.all(2),
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Icon(Icons.shopping_bag_outlined),
                          label: Text(
                            _isPlacingOrder ? 'Processing...' : 'Place Order',
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}