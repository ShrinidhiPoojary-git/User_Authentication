import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/Theme/app_pallete.dart';
import 'package:flutter_application/auth_field.dart';
import 'package:flutter_application/auth_gradient_button.dart';
import 'package:flutter_application/firebase_auth_services.dart';

class SignUpPage extends StatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const SignUpPage());
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool isSigningUp = false;

  final FirebaseAuthService _auth = FirebaseAuthService();

  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Sign Up.',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                AuthFied(
                  hintText: 'Name',
                  controller: nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                AuthFied(
                  hintText: 'Email',
                  controller: emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    } else if (!RegExp(
                            r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                        .hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                AuthFied(
                  hintText: 'Password',
                  controller: passwordController,
                  isObscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    } else if (!RegExp(
                            r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@!#$%^&*()_+={}\[\]|;:,.<>?]{6,}$')
                        .hasMatch(value)) {
                      return 'Password must be at least 6 characters long and include both letters and numbers.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                isSigningUp
                    ? const CircularProgressIndicator()
                    : AuthGradientButton(
                        buttonText: 'Sign Up',
                        onPressed:
                            _signup,
                      ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, "/login");
                  },
                  child: RichText(
                    text: TextSpan(
                      text: 'Already Have an Account? ',
                      style: Theme.of(context).textTheme.titleMedium,
                      children: [
                        TextSpan(
                          text: 'Sign In',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppPallete.gradient2,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _signup() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSigningUp = true;
    });

    String email = emailController.text;
    String password = passwordController.text;

    try {
      User? user = await _auth.signUpWithEmailAndPassword(email, password);

      setState(() {
        isSigningUp = false;
      });

      if (user != null) {
        print("User is successfully created");
        Navigator.pushNamed(context, "/login");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User creation failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        print("Some error occurred");
      }
    } catch (e) {
      setState(() {
        isSigningUp = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An exception occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
      print("An exception occurred: $e");
    }
  }
}
