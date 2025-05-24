import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../LoginScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final addressController = TextEditingController();
  final ageController = TextEditingController();
  String? gender;
  bool isEditing = false;
  bool isLoading = false;
  String error = "";
  final List<String> genders = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    addressController.dispose();
    ageController.dispose();
    super.dispose();
  }

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void toggleEdit(Map<String, dynamic>? data) {
    setState(() {
      isEditing = !isEditing;
      if (isEditing && data != null) {
        firstNameController.text = data['firstName'] ?? '';
        lastNameController.text = data['lastName'] ?? '';
        addressController.text = data['address'] ?? '';
        ageController.text = data['age']?.toString() ?? '';
        gender = data['gender'];
      }
    });
  }

  Future<void> updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    int? age = int.tryParse(ageController.text.trim());
    if (age == null || age < 0 || age > 150) {
      setState(() => error = "Please enter a valid age.");
      return;
    }

    setState(() {
      isLoading = true;
      error = "";
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'address': addressController.text.trim(),
        'age': age,
        'gender': gender,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      setState(() {
        isEditing = false;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = "Failed to update profile: $e";
        isLoading = false;
      });
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
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading profile', style: TextStyle(color: Colors.white)));
            }

            final data = snapshot.data?.data() as Map<String, dynamic>?;

            return Center(
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: isEditing
                      ? Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Text(
                          "Edit Profile",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: firstNameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration("First Name", Icons.person),
                          validator: (value) => value!.isEmpty ? 'Enter first name' : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: lastNameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration("Last Name", Icons.person),
                          validator: (value) => value!.isEmpty ? 'Enter last name' : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: addressController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration("Address", Icons.home),
                          validator: (value) => value!.isEmpty ? 'Enter address' : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: ageController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration("Age", Icons.cake),
                          validator: (value) => value!.isEmpty ? 'Enter age' : null,
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          value: gender,
                          decoration: _inputDecoration("Gender", Icons.person_outline),
                          dropdownColor: const Color(0xFF2c5364),
                          style: const TextStyle(color: Colors.white),
                          items: genders
                              .map((g) => DropdownMenuItem(
                            value: g,
                            child: Text(g),
                          ))
                              .toList(),
                          onChanged: (value) {
                            setState(() => gender = value);
                          },
                          validator: (value) => value == null ? 'Select gender' : null,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: isLoading ? null : updateProfile,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(120, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text("Save", style: TextStyle(fontSize: 16)),
                            ),
                            TextButton(
                              onPressed: () => toggleEdit(data),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                        if (error.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              error,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  )
                      : Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.cyanAccent,
                        child: Icon(Icons.person, size: 60, color: Colors.black),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Profile",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildProfileField("Name", "${data?['firstName'] ?? ''} ${data?['lastName'] ?? ''}"),
                      _buildProfileField("Email", user?.email ?? "Unknown"),
                      _buildProfileField("Address", data?['address'] ?? "Not set"),
                      _buildProfileField("Age", data?['age']?.toString() ?? "Not set"),
                      _buildProfileField("Gender", data?['gender'] ?? "Not set"),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => toggleEdit(data),
                        icon: const Icon(Icons.edit, color: Colors.black),
                        label: const Text("Edit Profile"),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () => logout(context),
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text("Logout"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.white70),
      hintText: label,
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.white10,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$label:",
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
