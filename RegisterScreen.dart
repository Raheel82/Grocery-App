import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../screens/DashboardScreen.dart';
import 'LoginScreen.dart';
import '../services/cart_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final addressController = TextEditingController();
  final ageController = TextEditingController();
  String? gender;
  String error = "";
  bool isLoading = false;

  final List<String> genders = ['Male', 'Female', 'Other'];

  final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");

  void registerUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirm = confirmController.text.trim();
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final address = addressController.text.trim();
    final ageText = ageController.text.trim();

    // Validation checks
    if (firstName.isEmpty || lastName.isEmpty || address.isEmpty || ageText.isEmpty || gender == null) {
      setState(() => error = "All fields are required.");
      return;
    }

    if (!emailRegex.hasMatch(email)) {
      setState(() => error = "Invalid email format.");
      return;
    }

    if (password != confirm) {
      setState(() => error = "Passwords do not match.");
      return;
    }

    int? age = int.tryParse(ageText);
    if (age == null || age < 0 || age > 150) {
      setState(() => error = "Please enter a valid age.");
      return;
    }

    setState(() {
      isLoading = true;
      error = "";
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store user in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'address': address,
        'age': age,
        'gender': gender,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Add dummy cart item
      final cartService = CartService(userCredential.user!.uid);
      await cartService.addToCart({
        'category': 'Fruit',
        'id': 1,
        'name': 'apple',
        'price': 300.0,
        'quantity': 2,
      });

      // Call FastAPI to create Neo4j user node
      final response = await http.post(
        Uri.parse('http://localhost:8000/create-user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userCredential.user!.uid,
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'address': address,
          'age': age,
          'gender': gender,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to create user node in Neo4j');
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) =>  DashboardScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = _getErrorMessage(e);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = "Registration failed: $e";
        isLoading = false;
      });
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      default:
        return 'Registration failed: ${e.message}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f2027), Color(0xFF203a43), Color(0xFF2c5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.cyanAccent)
              : SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.person_add_alt, size: 80, color: Colors.white),
                  const SizedBox(height: 10),
                  const Text(
                    "REGISTER",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(firstNameController, Icons.person, "First Name"),
                  const SizedBox(height: 20),
                  _buildTextField(lastNameController, Icons.person, "Last Name"),
                  const SizedBox(height: 20),
                  _buildTextField(emailController, Icons.email, "Email"),
                  const SizedBox(height: 20),
                  _buildTextField(addressController, Icons.home, "Address"),
                  const SizedBox(height: 20),
                  _buildTextField(ageController, Icons.cake, "Age", isNumber: true),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: gender,
                    decoration: _inputDecoration("Gender", Icons.person_outline),
                    dropdownColor: const Color(0xFF2c5364),
                    style: const TextStyle(color: Colors.white),
                    items: genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                    onChanged: (value) => setState(() => gender = value),
                    hint: const Text("Select Gender", style: TextStyle(color: Colors.white54)),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(passwordController, Icons.lock, "Password", isPassword: true),
                  const SizedBox(height: 20),
                  _buildTextField(confirmController, Icons.lock_outline, "Confirm Password", isPassword: true),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: registerUser,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("REGISTER", style: TextStyle(fontSize: 18)),
                  ),
                  if (error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(error, style: const TextStyle(color: Colors.red, fontSize: 16)),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? ", style: TextStyle(color: Colors.white)),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        ),
                        child: const Text("Login", style: TextStyle(color: Colors.cyanAccent)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.white70),
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.white10,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, IconData icon, String hintText,
      {bool isPassword = false, bool isNumber = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(hintText, icon),
    );
  }
}
