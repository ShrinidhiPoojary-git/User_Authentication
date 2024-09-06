import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/Theme/app_pallete.dart';
import 'package:flutter_application/auth_gradient_button.dart';
import 'package:flutter_application/firebase_auth_services.dart';
import 'package:flutter_application/signup_page.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const LoginPage());
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  var isSigningIn = false;
  final FirebaseAuthService _auth = FirebaseAuthService();
  List<dynamic> productNamelist = [];

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Sign In.',
                style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(hintText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(hintText: 'Password',errorMaxLines: 3),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  } else if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@!#$%^&*()_+={}\[\]|;:,.<>?]{6,}$').hasMatch(value)) {
                    return 'Password must be at least 6 characters long and include both letters and numbers.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              isSigningIn
                  ? const CircularProgressIndicator()
                  : AuthGradientButton(
                      buttonText: 'Sign In',
                      onPressed:
                          _login,
                    ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    SignUpPage.route(),
                  );
                },
                child: RichText(
                  text: TextSpan(
                      text: 'Don\'t Have an Account? ',
                      style: Theme.of(context).textTheme.titleMedium,
                      children: [
                        TextSpan(
                            text: 'Sign Up',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppPallete.gradient2,
                                  fontWeight: FontWeight.bold,
                                )),
                      ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _login() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSigningIn = true;
    });

    String username = emailController.text;
    String password = passwordController.text;

    try {
      User? user = await _auth.signInWithEmailAndPassword(username, password);

      if (user != null) {
        print("User logged in successfully");
        final List<Map<String, dynamic>> productData = await apiCall();
        setState(() {
          isSigningIn = false;
        });
        Navigator.pushNamed(
          context,
          "/dashboard",
          arguments: {
            'productData': productData
          },
        );
      } else {
        setState(() {
          isSigningIn = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed with Invalid email or password.'),
            backgroundColor: Colors.red,
          ),
        );
        print("Some error occurred");
      }
    } catch (e) {
      setState(() {
        isSigningIn = false;
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

  Future<List<Map<String, dynamic>>> apiCall() async {
    const url = 'https://api.restful-api.dev/objects';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final body = response.body;
      final List<dynamic> json = jsonDecode(body);
      return json.map((item) {
        if (item is Map<String, dynamic>) {
          return item;
        } else {
          throw Exception('Invalid data format');
        }
      }).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }
}
