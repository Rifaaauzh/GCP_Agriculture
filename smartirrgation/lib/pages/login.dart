import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'logsign.dart';
import 'dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const login());
}

class login extends StatelessWidget {
  const login({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xFFF3E5F5), // Light purple background
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Text editing controllers for email and password
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Firebase Auth instance
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void dispose() {
    // Dispose controllers when the widget is removed
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login(BuildContext context) async {
    try {
      await auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Navigate to Dashboard on successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()),
      );
    } on FirebaseAuthException catch (e) {
      // Show error dialog for FirebaseAuth errors
      _showErrorDialog(context, e.message ?? "Login failed");
    } catch (e) {
      _showErrorDialog(context, "An unexpected error occurred");
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
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
                    color: Color(0xFFB39DDB), // Light purple
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
                    color: Color(0xFFD1C4E9), // Even lighter purple
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const logsign()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7E57C2), // Purple button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    label: const Text(
                      "Back",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 130),
                  // Title
                  Center(
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(0.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  // Email Input
                  _buildInputField(
                    label: "Email",
                    hint: "hello@gmail.com",
                    icon: Icons.email,
                    controller: emailController,
                  ),
                  const SizedBox(height: 20),
                  // Password Input
                  _buildInputField(
                    label: "Password",
                    hint: "************",
                    icon: Icons.lock,
                    obscureText: true,
                    controller: passwordController,
                  ),
                  const SizedBox(height: 90),
                  // Login Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () => _login(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7E57C2), // Purple button
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
            color: Color(0xFF6A1B9A), // Dark purple for label text
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
              color: Color(0xFFB39DDB), // Light purple hint text
            ),
            prefixIcon: Icon(icon, color: const Color(0xFF7E57C2)), // Purple icon
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