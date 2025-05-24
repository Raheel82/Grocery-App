import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/order_service.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final user = FirebaseAuth.instance.currentUser;
  late final OrderService orderService = OrderService(user?.uid ?? '');
  bool _isLoading = true;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final orders = await orderService.getOrderHistory();
      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load order history: $e', style: GoogleFonts.poppins()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Colors.teal,
        title: Text(
          'Order History',
          style: GoogleFonts.poppins(
            color: Theme.of(context).appBarTheme.foregroundColor ?? Colors.white,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        color: Colors.tealAccent,
        backgroundColor: Theme.of(context).cardTheme.color,
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.tealAccent))
            : _orders.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history,
                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.54),
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'No order history found',
                style: GoogleFonts.poppins(
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                  fontSize: 18,
                ),
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _orders.length,
          itemBuilder: (context, index) {
            final order = _orders[index];
            final items = (order['items'] as List<dynamic>?) ?? [];

            return Card(
              color: Theme.of(context).cardTheme.color,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: Theme.of(context).cardTheme.elevation,
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
                            'Order #${order['orderId']?.toString().substring(0, 8) ?? 'Unknown'}',
                            style: GoogleFonts.poppins(
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order['dateString'] ?? 'Unknown date',
                            style: GoogleFonts.poppins(
                              color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: order['status'] == 'Placed'
                            ? Colors.teal.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        order['status'] ?? 'Unknown',
                        style: GoogleFonts.poppins(
                          color: order['status'] == 'Placed' ? Colors.tealAccent : Colors.redAccent,
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
                          color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '₹${order['total'] ?? 0}',
                        style: GoogleFonts.poppins(
                          color: Colors.tealAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                children: [
                  Divider(color: Theme.of(context).dividerColor),
                  Text(
                    'Order Items:',
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                      fontSize: 14,
                    ),
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
                              style: GoogleFonts.poppins(
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                          Text(
                            '₹${(item['price'] ?? 0) * (item['quantity'] ?? 0)}',
                            style: GoogleFonts.poppins(
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}