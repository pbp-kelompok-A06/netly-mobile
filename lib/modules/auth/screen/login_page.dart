import 'package:flutter/material.dart';
import 'package:netly_mobile/modules/auth/model/auth_model.dart';
import 'package:netly_mobile/modules/auth/screen/register_page.dart';
import 'package:netly_mobile/utils/colors.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:netly_mobile/utils/path_web.dart';
import 'package:netly_mobile/main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordShown = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // GREETINGS MESSAGE
              const Text(
                "Welcome!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                "Enter your details to login.",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 40),

              // FORM LOGIN
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // USERNAME
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: "Username",
                        labelText: "Username",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Username must be filled!";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // PASSWORD
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_passwordShown,
                      decoration: InputDecoration(
                        hintText: "Password",
                        labelText: "Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        // ICON SHOW / HIDE PASSWORD
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordShown
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordShown = !_passwordShown;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password must be filled!";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          try {
                            final response = await request.login(
                            "$pathWeb/login-ajax/",
                              jsonEncode({
                                'username': _usernameController.text,
                                'password': _passwordController.text,
                              }),
                            );

                            if (request.loggedIn) {
                              AuthResponse loginRes = AuthResponse.fromJson(response);
                              request.jsonData['userData'] = loginRes.data?.toJson();
                              if (context.mounted) {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Login Succeed'),
                                    content: Text("Welcome to Netly, ${request.jsonData['userData']['username']}!"),
                                    actions: [
                                      TextButton(
                                        child: const Text('OK'),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(builder: (context) => const MainPage()),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                );

                                Future.delayed(const Duration(seconds: 3), () {
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => const MainPage()),
                                    );
                                  }
                                });
                              }
                            } else {
                              if (context.mounted) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Login Failed'),
                                    content: Text(response['message']),
                                    actions: [
                                      TextButton(
                                        child: const Text('OK'),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }

                          } catch (e) {
                            if (context.mounted) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Login Error'),
                                  content: Text("Request Failed!"),
                                  actions: [
                                    TextButton(
                                      child: const Text('OK'),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                              );
                            }
                          }
                          
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: AppColors.gradientStartCommunity
                        ),
                        child: const Text("Login", style: TextStyle(color: AppColors.gradientEndCommunity),),
                      ),
                    ),

                    const SizedBox(height: 50),

                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: RichText(
                        text: const TextSpan(
                          text: "Don't have an account ? ",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                          children: [
                            TextSpan(
                              text: "Sign Up",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
