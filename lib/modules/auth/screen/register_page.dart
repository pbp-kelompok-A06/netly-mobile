import 'package:flutter/material.dart';
import 'package:netly_mobile/modules/event/route/event_route.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:netly_mobile/modules/auth/route/auth_route.dart';
import 'package:netly_mobile/utils/path_web.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _profilePictureController = TextEditingController();

  bool _passwordShown = false;
  bool _confirmPasswordShown = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: 
      Padding(
        padding: const EdgeInsets.all( 24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // GREETINGS MESSAGE
              const Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Sign up to explore more.",
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

                    // FULLNAME
                    TextFormField(
                      controller: _fullNameController,
                      decoration: InputDecoration(
                        hintText: "Fullname",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Fullname must be filled!";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // LOCATION
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        hintText: "Location",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      
                    ),

                    const SizedBox(height: 18),

                    // PROFILE PICTURE
                    TextFormField(
                      controller: _profilePictureController,
                      decoration: InputDecoration(
                        hintText: "Profile Picture",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (String? value) {
                        if(value != null && value.isNotEmpty ){
                          final uriCheck = Uri.tryParse(value);
                          if(uriCheck == null || !uriCheck.hasScheme || !uriCheck.hasAuthority){
                            return "Profile picture harus dalam link url";
                          }
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        // ICON SHOW / HIDE PASSWORD
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordShown? Icons.visibility: Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordShown = !_passwordShown;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if(value == null || value.isEmpty){
                          return "Password must be filled!";
                        }

                        if (value != _confirmPasswordController.text){
                          return "Password and Confirm Password are not matched!";
                        }
                        return null;

                      },
                    ),


                    const SizedBox(height: 16),


                    // CONFIRM PASSWORD
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_confirmPasswordShown,
                      decoration: InputDecoration(
                        hintText: "Confirm Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        // ICON SHOW / HIDE PASSWORD
                        suffixIcon: IconButton(
                          icon: Icon(
                            _confirmPasswordShown? Icons.visibility: Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _confirmPasswordShown = !_confirmPasswordShown;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if(value == null || value.isEmpty){
                          return "Confirm Password must be filled!";
                        }

                        if (value != _passwordController.text){
                          return "Password and Confirm Password are not matched!";
                        }
                        return null;

                      },
                    ),


                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: 
                        ElevatedButton(
                          onPressed: () async {

                            if (!_formKey.currentState!.validate()){
                              return ;
                            }


                            final response = await request.login(
                              "$pathWeb/register-ajax/",
                              jsonEncode({
                                'username': _usernameController.text,
                                'password1': _passwordController.text,
                                'password2': _confirmPasswordController.text,
                                'full_name': _fullNameController.text,
                                'location': _locationController.text,
                                'profile_picture': _profilePictureController.text

                                
                              }),
                            );
                            if (request.loggedIn){
                              request.jsonData['userData'] = response['data'];

                              if (context.mounted){
                                Navigator.pushReplacement(
                                  context, 
                                  MaterialPageRoute(builder: EventRoutes.routes[EventRoutes.eventPage]!)
                                );
                              }

                            }else{
                              if (context.mounted){
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Register Failed'),
                                    content: Text(response['message']),
                                    actions: [
                                      TextButton(
                                        child: const Text('OK'),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }

                          },

                          child: Text("Register"),
                      )
                    ),

                  

                    

                    const SizedBox(height: 50),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: AuthRoutes.routes[AuthRoutes.login]!,
                          ),
                        );
                      },
                      child: RichText(
                        text: const TextSpan(
                          text: "Already have an account ? ",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                          children: [
                            TextSpan(
                              text: "Login",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            )
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
