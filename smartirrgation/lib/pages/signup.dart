import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'logsign.dart';
import 'login.dart';

void main() {
  runApp(const registerpage());
}

class registerpage extends StatelessWidget {
  const registerpage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xFFEDE7F6), // Light purple background
      ),
      home: const RegisterPage(),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _register(BuildContext context) async {
    if (passwordController.text != confirmPasswordController.text) {
      _showErrorDialog("Passwords do not match");
      return;
    }

    try {
      await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully Registered! Please log in.'),
          duration: Duration(seconds: 3),
        ),
      );

      // Navigate to login page after successful registration
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const login()),
        );
      });
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = "This email is already in use.";
          break;
        case 'invalid-email':
          errorMessage = "Invalid email address.";
          break;
        case 'weak-password':
          errorMessage = "Password should be at least 6 characters.";
          break;
        default:
          errorMessage = "An unexpected error occurred. Please try again.";
      }
      _showErrorDialog(errorMessage);
    } catch (e) {
      _showErrorDialog("An unexpected error occurred.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Decorative Circles
          Positioned(
            top: -screenHeight * 0.2,
            right: -screenWidth * 0.1,
            child: Opacity(
              opacity: 0.2,
              child: Container(
                width: screenWidth * 0.9,
                height: screenWidth * 0.9,
                decoration: const BoxDecoration(
                  color: Color(0xFFB39DDB), // Light purple shade
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            top: -screenHeight * 0.1,
            right: -screenWidth * 0.3,
            child: Opacity(
              opacity: 0.2,
              child: Container(
                width: screenWidth * 0.7,
                height: screenWidth * 0.7,
                decoration: const BoxDecoration(
                  color: Color(0xFFD1C4E9), // Lighter purple shade
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          // Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 45),
                // Back Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const logsign()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      backgroundColor: const Color(0xFF7E57C2), // Purple button
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    label: const Text(
                      "Back",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 75),
                // Title
                const Center(
                  child: Text(
                    'Register Now!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Form Fields
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      _buildInputField(
                        label: "Name",
                        hint: "Enter your full name",
                        icon: Icons.person,
                        controller: nameController,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: "Email",
                        hint: "hello@gmail.com",
                        icon: Icons.email,
                        controller: emailController,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: "Password",
                        hint: "************",
                        icon: Icons.lock,
                        obscureText: true,
                        controller: passwordController,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: "Confirm Password",
                        hint: "************",
                        icon: Icons.lock,
                        obscureText: true,
                        controller: confirmPasswordController,
                      ),
                      const SizedBox(height: 60),
                      // Create Account Button
                      ElevatedButton(
                        onPressed: () {
                          _register(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7E57C2), // Purple button
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 100,
                            vertical: 16,
                          ),
                        ),
                        child: const Text(
                          'Create an Account',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF5E35B1), // Dark purple for label text
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 14,
              color: Color(0xFFB39DDB), // Lighter purple for hint text
            ),
            prefixIcon: Icon(icon, color: const Color(0xFF7E57C2)), // Icon in purple
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF7E57C2), // Purple border
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF7E57C2), // Purple border
              ),
            ),
          ),
        ),
      ],
    );
  }
}