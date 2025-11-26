import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:netly_mobile/modules/community/route/community_route.dart';
import 'package:netly_mobile/utils/path_web.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
class RegisterPage extends StatefulWidget{
    const RegisterPage({super.key});
    @override
    State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>{

    final TextEditingController _usernameController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    final TextEditingController _confirmPasswordController = TextEditingController();
    final TextEditingController _fullNameController = TextEditingController();
    final TextEditingController _locationController = TextEditingController();
    final TextEditingController _profilePictureController = TextEditingController();
    
    final _formKey = GlobalKey<FormState>();



    @override
    Widget build(BuildContext context){

        final request = context.watch<CookieRequest>();

        return Scaffold(
            appBar: AppBar(
                title: const Center(
                    child: Text('Form User Settings', style: TextStyle(fontWeight: FontWeight.bold),),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
            ),
            body: Form( // handler form state, validasi form, penyimpanan form
                key: _formKey,
                child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            // NAME USER

                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                    controller: _usernameController,
                                    decoration: InputDecoration(
                                        hintText: "Username",
                                        labelText: "Username",
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5.0),
                                            borderSide: BorderSide(color: Colors.black)
                                        )
                                    ),

                                    validator: (value) {
                                      if(value == null || value.isEmpty){
                                        return "Username harus diisi!";
                                      }
                                      return null;
                                    },

                                ),
                            ),


                            // FullName USER

                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                    controller: _fullNameController,
                                    decoration: InputDecoration(
                                        hintText: "Fullname",
                                        labelText: "Fullname",
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5.0),
                                            borderSide: BorderSide(color: Colors.black)
                                        )
                                    ),
                                    validator: (value) {
                                      if(value == null || value.isEmpty){
                                        return "Fullname harus diisi!";
                                      }
                                      return null;
                                    },

                                ),
                            ),
                            

                            // LOCATION USER

                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                    controller: _locationController,
                                    decoration: InputDecoration(
                                        hintText: "Location",
                                        labelText: "Location",
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5.0),
                                            borderSide: BorderSide(color: Colors.black)
                                        )
                                    ),

                                ),
                            ),

                            // Profile Picture USER

                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                    controller: _profilePictureController,
                                    decoration: InputDecoration(
                                        hintText: "Profile Picture",
                                        labelText: "Profile Picture",
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5.0),
                                            borderSide: BorderSide(color: Colors.black)
                                        )
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
                                

                            ),

                            // Password 1 USER

                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                    controller: _passwordController,
                                    decoration: InputDecoration(
                                        hintText: "Password",
                                        labelText: "Password",
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5.0),
                                            borderSide: BorderSide(color: Colors.black)
                                        ),
                                    ),

                                    obscureText: true,
                                    validator: (value) {
                                      if(value == null || value.isEmpty){
                                        return "Password harus diisi!";
                                      }

                                      if (value != _confirmPasswordController.text){
                                        return "Password dan Confirm Password tidak matched!";
                                      }
                                      return null;

                                    },

                                    

                                ),
                            ),


                            // Password 2 USER

                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                    controller: _confirmPasswordController,
                                    decoration: InputDecoration(
                                        hintText: "Confirm Password",
                                        labelText: "Confirm Password",
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5.0),
                                            borderSide: BorderSide(color: Colors.black)
                                        ),
                                    ),

                                    obscureText: true,

                                    validator: (value) {
                                      if(value == null || value.isEmpty){
                                        return "Confirm Password harus diisi!";
                                      }

                                      if (value != _passwordController.text){
                                        return "Password dan Confirm Password tidak matched!";
                                      }
                                      return null;

                                    },

                                    

                                ),
                            ),

                            // Login button

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
                                      MaterialPageRoute(builder: CommunityRoutes.routes[CommunityRoutes.tes]!)
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

                            

                            

                        ],
                    ),


                ), // membuat scrollable

            ),
        );
    }
}