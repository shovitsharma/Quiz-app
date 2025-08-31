import 'package:flutter/material.dart';
import 'package:quiz_app/auth/auth_service.dart'; // Make sure this path is correct
import 'package:quiz_app/signup.dart';
import 'package:quiz_app/ui_question_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // --- STATE AND CONTROLLERS ---
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- LOGIC ---

  /// Handles the entire login process, including validation, API call, and error handling.
  Future<void> _handleLogin() async {
    // 1. Validate the form fields
    if (!_formKey.currentState!.validate()) {
      return; // If validation fails, do nothing.
    }

    setState(() => _isLoading = true);

    try {
      // 2. Call the AuthService using the singleton instance
      await AuthService.instance.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // 3. Navigate to the welcome page on success
      if (mounted) {
        Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const QuizCreationPage()),
      );
      }
    } on AuthException catch (e) {
      // 4. Show a user-friendly error dialog on failure
      if (mounted) {
        _showErrorDialog(e.message);
      }
    } finally {
      // 5. Always turn off the loading indicator
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Shows a simple alert dialog for displaying errors.
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Login Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // --- UI BUILD ---

  @override
  Widget build(BuildContext context) {
    return QuizPageTemplate(
      child: Form( // Wrap the column with a Form widget
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Login',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.black),
            ),
            const SizedBox(height: 40),
            _buildEmailField(),
            const SizedBox(height: 20),
            _buildPasswordField(),
            const SizedBox(height: 40),
            _buildLoginButton(),
            const SizedBox(height: 20),
            _buildSignUpPrompt(context),
          ],
        ),
      ),
    );
  }

  // --- UI HELPER WIDGETS (with validation) ---

  Widget _buildEmailField() {
    return _buildTextFormField(
      label: 'Email',
      hint: 'Enter your email',
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        // Simple regex for email validation
        if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return _buildTextFormField(
      label: 'Password',
      hint: 'Enter password',
      controller: _passwordController,
      isObscure: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
    );
  }

  /// A reusable widget for creating a labeled TextFormField.
  Widget _buildTextFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isObscure = false,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700]),
        ),
        const SizedBox(height: 8),
        TextFormField( // Changed from TextField to TextFormField
          controller: controller,
          obscureText: isObscure,
          keyboardType: keyboardType,
          validator: validator,
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
              borderSide: const BorderSide(color: Colors.black, width: 2.0),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2.0),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the main "Login" button with loading state.
  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleLogin, // Disable button when loading
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 5,
      ),
      child: _isLoading
          ? const CircularProgressIndicator( // Show loading indicator
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
          : const Text(
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
          style: TextStyle(fontSize: 15, color: Colors.grey[600]),
          children: const [
            TextSpan(text: "Don't have an account? "),
            TextSpan(
              text: 'Sign Up',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}


// --- TEMPLATE WIDGET (Keep this in its own file and import it) ---
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
    // ... (This part remains unchanged)
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