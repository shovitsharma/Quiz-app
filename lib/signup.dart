import 'package:flutter/material.dart';
import 'package:quiz_app/auth/auth_service.dart';
import 'package:quiz_app/login.dart';
import 'package:quiz_app/welcome_page.dart' hide QuizPageTemplate;

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return QuizPageTemplate(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Sign up', textAlign: TextAlign.center, style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900)),
          const SizedBox(height: 40),
          _buildTextField(label: 'Username', hint: 'Enter your username', controller: _usernameController),
          const SizedBox(height: 20),
          _buildTextField(label: 'Email', hint: 'Enter your email', controller: _emailController),
          const SizedBox(height: 20),
          _buildTextField(label: 'Password', hint: 'Enter password', isObscure: true, controller: _passwordController),
          const SizedBox(height: 40),
          _buildSignUpButton(context),
          const SizedBox(height: 20),
          _buildLoginPrompt(context),
        ],
      ),
    );
  }

  Widget _buildTextField({required String label, required String hint, bool isObscure = false, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700])),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
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
              borderSide: const BorderSide(color: Colors.black, width: 2.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final username = _usernameController.text.trim();
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();

        if(username.isEmpty || email.isEmpty || password.isEmpty){
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
          return;
        }

        final result = await AuthService.signup(username, email, password);

        if(result['success'] == true){
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const WelcomePage()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'])));
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: const Text('Sign Up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginPage())),
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
