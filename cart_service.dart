import 'package:cloud_firestore/cloud_firestore.dart';

class CartService {
  final String userId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CartService(this.userId);

  // Add item to cart
  Future<void> addToCart(Map<String, dynamic> item) async {
    try {
      final cartRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(item['id'].toString());

      await cartRef.set({
        ...item,
        'addedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error adding to cart: $e');
      throw e; // Re-throw to allow handling in UI
    }
  }

  // Get cart items
  Future<List<Map<String, dynamic>>> getCart() async {
    try {
      final cartSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();

      return cartSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error getting cart: $e');
      return []; // Return empty list instead of null on error
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(String itemId) async {
    try {
      final cartRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(itemId);  // Using the product id as the document id

      await cartRef.delete();
    } catch (e) {
      print('Error removing from cart: $e');
      throw e; // Re-throw to allow handling in UI
    }
  }

  // This method was empty and causing your null error
  // Now it properly calls the getCart() method
  Future<List<Map<String, dynamic>>> getCartItems() async {
    return await getCart();
  }
}