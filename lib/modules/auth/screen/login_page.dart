import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:netly_mobile/modules/auth/route/auth_route.dart';
import 'package:netly_mobile/modules/community/route/community_route.dart';
import 'package:netly_mobile/utils/path_web.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
class LoginPage extends StatefulWidget{
    const LoginPage({super.key});
    @override
    State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>{

    final TextEditingController _usernameController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
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
                                    validator: (value){
                                      if(value == null || value.isEmpty){
                                        return "Username harus diisi!";
                                      }
                                      return null;
                                    },

                                ),
                            ),


                            

                            // Password USER

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
                                    validator: (value){
                                      if(value == null || value.isEmpty){
                                        return "Password harus diisi!";
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
                                String username = _usernameController.text;
                                String password = _passwordController.text;

                                final response = await request.login(
                                  "$pathWeb/login-ajax/",
                                  jsonEncode({
                                    'username': username,
                                    'password': password,
                                  }),
                                );
                                if (request.loggedIn){

                                  request.jsonData['userData'] = response['data'];
                                  print("userData: ${request.jsonData['userData']}");
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
                                        title: const Text('Login Failed'),
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

                              child: Text("Login"),
                            ),

                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, 
                                  MaterialPageRoute(builder: AuthRoutes.routes[AuthRoutes.register]!)
                                );
                              },
                              child: Text("Don't have an Account? Register right away!",
                                style: TextStyle(color: Colors.black, fontSize: 16.0),
                              ),
                            )

                            

                            

                        ],
                    ),


                ), // membuat scrollable

            ),
        );
    }
}