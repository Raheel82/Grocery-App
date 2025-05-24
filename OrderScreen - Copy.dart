import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/order_service.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final user = FirebaseAuth.instance.currentUser;
  late final OrderService orderService = OrderService(user?.uid ?? '');
  bool _isCancelling = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f2027),
      appBar: AppBar(
        backgroundColor: const Color(0xFF203a43),
        title: Text('Your Orders', style: GoogleFonts.poppins(color: Colors.white)),
      ),
      body: StreamBuilder(
        stream: orderService.getOrders(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading orders: ${snapshot.error}',
                style: GoogleFonts.poppins(color: Colors.white70),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Colors.tealAccent));
          }

          final orders = snapshot.data!.docs;
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined, color: Colors.white54, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'No orders found',
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 18),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final data = orders[index].data() as Map<String, dynamic>;
              final items = (data['items'] as List<dynamic>?) ?? [];
              final timestamp = data['date'] as Timestamp?;
              final orderDate = timestamp != null
                  ? timestamp.toDate().toString().split('.')[0]
                  : 'Processing';

              return Card(
                color: const Color(0xFF203a43),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  childrenPadding: const EdgeInsets.all(16),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  title: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #${data['orderId']?.toString().substring(0, 8) ?? 'Unknown'}',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              orderDate,
                              style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: data['status'] == 'Placed'
                              ? Colors.teal.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          data['status'] ?? 'Unknown',
                          style: GoogleFonts.poppins(
                            color: data['status'] == 'Placed' ? Colors.tealAccent : Colors.redAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${items.length} item${items.length == 1 ? '' : 's'}',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '₹${data['total'] ?? 0}',
                          style: GoogleFonts.poppins(
                            color: Colors.tealAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: data['status'] == 'Placed'
                      ? TextButton(
                    onPressed: _isCancelling
                        ? null
                        : () async {
                      setState(() {
                        _isCancelling = true;
                      });

                      try {
                        await orderService.cancelOrder(data['orderId']);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Order cancelled', style: GoogleFonts.poppins()),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to cancel order: $e', style: GoogleFonts.poppins()),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isCancelling = false;
                          });
                        }
                      }
                    },
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(color: Colors.redAccent),
                    ),
                  )
                      : null,
                  children: [
                    const Divider(color: Colors.white24),
                    Text(
                      'Order Items:',
                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    ...items.map<Widget>((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item['name'] ?? 'Unknown Product'} (x${item['quantity'] ?? 0})',
                                style: GoogleFonts.poppins(color: Colors.white),
                              ),
                            ),
                            Text(
                              '₹${(item['price'] ?? 0) * (item['quantity'] ?? 0)}',
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}