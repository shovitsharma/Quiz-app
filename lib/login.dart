import 'package:flutter/material.dart';
import 'package:quiz_app/auth/auth_service.dart';
import 'package:quiz_app/signup.dart';
import 'package:quiz_app/welcome_page.dart';

// Note: Make sure the 'QuizPageTemplate' widget is accessible from this file.
// If it's in another file, you will need to import it.

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  
  @override
  Widget build(BuildContext context) {
    // Reusing the same template for a consistent background
    return QuizPageTemplate(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Login',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 40),
          _buildTextField(label: 'Email', hint: 'Enter your email', controller: _emailController,),
          const SizedBox(height: 20),
          _buildTextField(label: 'Password', hint: 'Enter password', controller: _passwordController),
          const SizedBox(height: 40),
          _buildLoginButton(context),
          const SizedBox(height: 20),
          _buildSignUpPrompt(context),
        ],
      ),
    );
  }

  /// A reusable widget for creating a labeled text field.
  Widget _buildTextField({
  required String label,
  required String hint,
  bool isObscure = false,
  required TextEditingController controller,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: controller, // <-- add controller here
        obscureText: isObscure,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.black, width: 2.0),
          ),
        ),
      ),
    ],
  );
}

  /// Builds the main "Login" button.
  Widget _buildLoginButton(BuildContext context) {
  return ElevatedButton(
    onPressed: () async {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enter both email and password")),
        );
        return;
      }

      final result = await AuthService.login(email, password);

      // ✅ Check for token instead of 'success'
      if (result['token'] != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WelcomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? "Login failed")),
        );
      }
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 54),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      elevation: 5,
    ),
    child: const Text(
      'Login',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );
}

  /// Builds the text prompt for users who don't have an account.
  Widget _buildSignUpPrompt(BuildContext context) {
    return GestureDetector(
      onTap: () {
         Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const SignUpPage()),
      );
      },
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[600],
          ),
          children: const [
            TextSpan(text: "Don't have an account? "),
            TextSpan(
              text: 'Sign Up',
              style: TextStyle(
                color: Colors.black, // Changed to black to match image
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// --- This is the TEMPLATE WIDGET from the previous step ---
// You would typically have this in its own file and import it.

class QuizPageTemplate extends StatelessWidget {
  final Widget child;
  const QuizPageTemplate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackgroundCircles(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundCircles() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          left: -150,
          child: _BlendedCircle(color: Colors.yellow.shade600, size: 300),
        ),
        Positioned(
          top: -80,
          left: -100,
          right: 2,
          child: _BlendedCircle(color: Colors.red.shade400, size: 200),
        ),
        Positioned(
          bottom: -100,
          right: -150,
          child: _BlendedCircle(color: Colors.green.shade400, size: 300),
        ),
        Positioned(
          bottom: -80,
          right: -100,
          left: 2,
          child: _BlendedCircle(color: Colors.blue.shade300, size: 200),
        ),
      ],
    );
  }
}

class _BlendedCircle extends StatelessWidget {
  final Color color;
  final double size;
  const _BlendedCircle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withAlpha(230),
        shape: BoxShape.circle,
        backgroundBlendMode: BlendMode.multiply,
      ),
    );
  }
}
