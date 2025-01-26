import 'package:flutter/material.dart';
import 'login.dart';
import 'signup.dart';

void main() {
  runApp(const logsign());
}

class logsign extends StatelessWidget {
  const logsign({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white, // White background
      ),
      home: const LoginSignUp(),
    );
  }
}

class LoginSignUp extends StatelessWidget {
  const LoginSignUp({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 50), // Space above the logo
          // Logo and Title Section
          Column(
            children: [
              Image.asset(
                'assets/images/farm_logo.png', // Keep the same image
                width: screenWidth * 0.6, // Adjusted logo size
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20), // Space between image and text
              const Text(
                'Your Best Irrigation System',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF4A154B), // Same purple text color
                  fontSize: 18, // Text size remains the same
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          // Bottom Section with Buttons
          Container(
            width: screenWidth,
            height: screenHeight * 0.4, // Adjusted height
            decoration: const BoxDecoration(
              color: Color(0xFF6A1B9A), // Same purple color
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(30), // Rounded top corners
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Login Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const login()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBA68C8), // Same button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      minimumSize: Size(screenWidth * 0.6, 50), // Adjusted button size
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20), // Space between buttons
                  // Sign Up Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const registerpage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBA68C8), // Same button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      minimumSize: Size(screenWidth * 0.6, 50), // Adjusted button size
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}