import 'package:flutter/material.dart';
import 'package:quiz_app/auth/auth_service.dart'; // Ensure this path is correct
import 'package:quiz_app/login.dart';

// Assuming QuizPageTemplate is in another file, like login.dart or its own file.
// If it's in login.dart, you might need to import that.
import 'package:quiz_app/login.dart' show QuizPageTemplate;


class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // --- STATE AND CONTROLLERS ---
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- LOGIC ---

  /// Handles the entire signup process.
  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService.instance.signup(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // On success, show a confirmation and guide the user to the login page.
      if (mounted) {
        _showSuccessDialog();
      }
    } on AuthException catch (e) {
      if (mounted) {
        _showErrorDialog(e.message);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- UI FEEDBACK DIALOGS ---

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Signup Failed'),
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must interact with the dialog
      builder: (_) => AlertDialog(
        title: const Text('Signup Successful'),
        content: const Text('Your account has been created. Please log in to continue.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false, // Clear the navigation stack
              );
            },
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }

  // --- UI BUILD ---

  @override
  Widget build(BuildContext context) {
    return QuizPageTemplate(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Sign up', textAlign: TextAlign.center, style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900)),
            const SizedBox(height: 40),
            _buildUsernameField(),
            const SizedBox(height: 20),
            _buildEmailField(),
            const SizedBox(height: 20),
            _buildPasswordField(),
            const SizedBox(height: 40),
            _buildSignUpButton(),
            const SizedBox(height: 20),
            _buildLoginPrompt(context),
          ],
        ),
      ),
    );
  }

  // --- UI HELPER WIDGETS ---

  Widget _buildUsernameField() {
    return _buildTextFormField(
      label: 'Username',
      hint: 'Enter your username',
      controller: _usernameController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a username';
        }
        return null;
      },
    );
  }

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
          return 'Please enter a password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _buildTextFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isObscure = false,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    // This is the same robust TextFormField builder from the login page
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700])),
        const SizedBox(height: 8),
        TextFormField(
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

  Widget _buildSignUpButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleSignUp,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: _isLoading
          ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
          : const Text('Sign Up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to LoginPage, replacing the current page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      },
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(fontSize: 15, color: Colors.grey[600]),
          children: const [
            TextSpan(text: 'Already have an account? '),
            TextSpan(text: 'Login', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}