import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class OrderService {
  final String userId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Change this to your actual API URL
  // Use 10.0.2.2 instead of localhost when running on Android emulator
  //final String apiBaseUrl = 'http://10.0.2.2:5000'; // Use this for Android emulator
  final String apiBaseUrl = 'http://localhost:5000'; // Use this for web/desktop

  OrderService(this.userId);

  // Stream of orders for the current user
  Stream<QuerySnapshot> getOrders() {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('orders')
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Place an order
  Future<void> placeOrder(List<Map<String, dynamic>> items, double total) async {
    try {
      // First create the order in Firestore
      final orderRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .doc();

      final orderData = {
        'orderId': orderRef.id,
        'userId': userId,
        'items': items,
        'total': total,
        'status': 'Placed',
        'date': FieldValue.serverTimestamp(),
      };

      await orderRef.set(orderData);

      // Then record purchases in Neo4j through FastAPI for each item
      for (var item in items) {
        try {
          await recordPurchase(item);
        } catch (e) {
          print('Error recording purchase in Neo4j: $e');
          // Continue with other items even if one fails
        }
      }

      // Clear the cart after successful order
      final cartItems = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();

      // Delete each cart item
      final batch = _firestore.batch();
      for (var doc in cartItems.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print('Error placing order: $e');
      throw Exception('Error placing order: $e');
    }
  }

  // Record a purchase in Neo4j through FastAPI
  Future<void> recordPurchase(Map<String, dynamic> item) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/purchase'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'productId': item['id'],
          'quantity': item['quantity'],
          'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        }),
      ).timeout(const Duration(seconds: 10)); // Add timeout

      if (response.statusCode != 201) {
        print('API Error: ${response.body}');
        throw Exception('Failed to record purchase: ${response.statusCode}');
      }
    } catch (e) {
      print('Network error recording purchase: $e');
      // Don't throw here - we want the Firestore order to succeed even if Neo4j fails
    }
  }

  // Cancel an order
  Future<void> cancelOrder(String orderId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .doc(orderId)
          .update({'status': 'Cancelled'});
    } catch (e) {
      print('Error cancelling order: $e');
      throw Exception('Error cancelling order: $e');
    }
  }

  // Get order history
  Future<List<Map<String, dynamic>>> getOrderHistory() async {
    try {
      final orderDocs = await _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .orderBy('date', descending: true)
          .get();

      return orderDocs.docs
          .map((doc) {
        final data = doc.data();
        // Convert Timestamp to DateTime if it exists
        if (data['date'] != null && data['date'] is Timestamp) {
          final dateTime = (data['date'] as Timestamp).toDate();
          data['dateString'] = DateFormat('MMM dd, yyyy').format(dateTime);
        }
        return data;
      })
          .toList();
    } catch (e) {
      print('Error getting order history: $e');
      return [];
    }
  }
}