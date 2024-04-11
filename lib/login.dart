import 'package:special_scholar/dashboard.dart';
import 'package:special_scholar/forgot_password.dart';
import 'package:special_scholar/registration.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => LoginState();
}

class LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  Future<void> Login() async {
    if (_formKey.currentState!.validate()) {
      try {
        final FirebaseAuth auth = FirebaseAuth.instance;

        await auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const Dashboard()));
      } catch (e) {
        // Handle login failure and show an error toast.
        String errorMessage = 'Login failed';

        if (e is FirebaseAuthException) {
          errorMessage = e.code;
        }

        Fluttertoast.showToast(
          msg: errorMessage,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(
                height: 80,
              ),
              const Text(
                'Login',
                style: TextStyle(fontSize: 25.0, fontStyle: FontStyle.italic),
              ),
              const SizedBox(
                height: 30,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(hintText: 'Enter Email'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!_emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 30,
              ),
              TextFormField(
                obscureText: true,
                controller: _passwordController,
                decoration: const InputDecoration(hintText: 'Enter Password'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ForgotPassword(title: 'Forget Password')));
                },
                child: const Text('Forgot Password ',
                    style: TextStyle(fontSize: 10.0)),
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                onPressed: Login,
                child: const Text('Login'),
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Registration()));
                },
                child: const Text(
                  'Create an account',
                  style: TextStyle(fontSize: 10.0),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}