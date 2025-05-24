import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

// Screens
import 'AddProductScreen.dart';
import 'CartScreen.dart';
import 'InventoryScreen.dart';
import 'OrderHistoryScreen.dart';
import 'OrderScreen.dart';
import 'ProfileScreen.dart';
import 'RecommendationScreen.dart';
import 'SettingsScreen.dart';
import '../LoginScreen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  // Static method to update selected index
  static void updateSelectedIndex(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<DashboardScreenState>();
    if (state != null) {
      state.setSelectedIndex(index);
    }
  }

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  final User? user = FirebaseAuth.instance.currentUser;
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _screens = [
    {'title': 'Inventory', 'screen': const InventoryScreen(), 'icon': Icons.inventory},
    {'title': 'Add Product', 'screen': const AddProductScreen(), 'icon': Icons.add_box},
    {'title': 'Cart', 'screen': const CartScreen(), 'icon': Icons.shopping_cart},
    {'title': 'Order History', 'screen': const OrderHistoryScreen(), 'icon': Icons.history},
    {'title': 'Orders', 'screen': OrderScreen(), 'icon': Icons.receipt},
    {'title': 'Profile', 'screen': const ProfileScreen(), 'icon': Icons.person},
    {'title': 'Recommendations', 'screen': const RecommendationScreen(), 'icon': Icons.recommend},
    {'title': 'Settings', 'screen': const SettingsScreen(), 'icon': Icons.settings},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  // Method to update selected index
  void setSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
      _animationController.reset();
      _animationController.forward();
    });
  }

  Widget buildDrawerItem(int index, String title, IconData icon) {
    final isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: isSelected ? Colors.cyanAccent : Colors.white70,
            size: 28,
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.cyanAccent : Colors.white,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 16,
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            setState(() {
              _selectedIndex = index;
              _animationController.reset();
              _animationController.forward();
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const LoginScreen();
    }

    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF203a43), Color(0xFF2c5364)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const UserAccountsDrawerHeader(
                      decoration: BoxDecoration(
                        color: Color(0xFF2c5364),
                      ),
                      accountName: Text('Loading...'),
                      accountEmail: Text(''),
                      currentAccountPicture: CircleAvatar(
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                    );
                  }

                  final userData = snapshot.data!.data() as Map<String, dynamic>?;
                  final firstName = userData?['firstName'] ?? 'User';
                  final lastName = userData?['lastName'] ?? '';
                  final email = userData?['email'] ?? user!.email ?? '';

                  return UserAccountsDrawerHeader(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    accountName: Text(
                      '$firstName $lastName',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    accountEmail: Text(
                      email,
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: Text(
                        firstName[0].toUpperCase(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _screens.length,
                  itemBuilder: (context, index) => buildDrawerItem(
                    index,
                    _screens[index]['title'],
                    _screens[index]['icon'],
                  ),
                ),
              ),
              const Divider(color: Colors.white30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent, size: 28),
                  title: Text(
                    "Logout",
                    style: GoogleFonts.poppins(
                      color: Colors.redAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: _logout,
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFF203a43),
        elevation: 4,
        shadowColor: Colors.black45,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: AnimatedOpacity(
          opacity: _fadeAnimation.value,
          duration: const Duration(milliseconds: 300),
          child: Text(
            _screens[_selectedIndex]['title'],
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _screens[_selectedIndex]['screen'],
      ),
      backgroundColor: const Color(0xFF0f2027),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}