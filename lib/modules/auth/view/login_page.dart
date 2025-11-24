import 'package:flutter/material.dart';
class LoginPage extends StatefulWidget{
    const LoginPage({super.key});


    @override
    State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>{

    final _formKey = GlobalKey<FormState>();
    String _name = "";
    String _email = "";
    String _password = "";
    
    @override
    Widget build(BuildContext context){
        return Scaffold(
            appBar: AppBar(
                title: const Center(
                    child: Text('Form User Settings', style: TextStyle(fontWeight: FontWeight.bold),),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
            ),
            body: Form(
                key: _formKey, // handler form state, validasi form, penyimpanan form
                child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            // NAME USER

                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                    decoration: InputDecoration(
                                        hintText: "Username",
                                        labelText: "Username",
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5.0),
                                            borderSide: BorderSide(color: Colors.black)
                                        )
                                    ),

                                    onChanged: (String? value){
                                        setState(() {
                                          _name = value!;
                                        });
                                    },

                                    validator: (String? value){
                                        if(value == null || value.isEmpty){
                                            return "Username tidak boleh kosong!";
                                        }

                                        if(value.length > 20){
                                            return "Username maksimum 20 karakter!";
                                        }
                                        

                                       

                                        return null;

                                    },

                                ),
                            ),


                            // Email USER

                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                    decoration: InputDecoration(
                                        hintText: "Email",
                                        labelText: "Email",
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5.0),
                                            borderSide: BorderSide(color: Colors.black)
                                        )
                                    ),

                                    onChanged: (String? value){
                                        setState(() {
                                          _email = value!;
                                        });
                                    },

                                    validator: (value){
                                        if(value == null || value.isEmpty){
                                            return "Email tidak boleh kosong!";
                                        }


                                        

                                        return null;

                                    },

                                ),
                            ),


                            // Password USER

                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                    decoration: InputDecoration(
                                        hintText: "Password",
                                        labelText: "Password",
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5.0),
                                            borderSide: BorderSide(color: Colors.black)
                                        ),
                                    ),

                                    obscureText: true,

                                    onChanged: (String? value){
                                        setState(() {
                                          _password = value!;
                                        });
                                    },

                                    validator: (value){
                                        if(value == null || value.isEmpty){
                                            return "Password tidak boleh kosong!";
                                        }


                                        

                                        return null;

                                    },

                                ),
                            ),

                            // SIMPANN

                            Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all(Colors.amber),
                                    ),
                                    onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                            return AlertDialog(
                                                title: const Text('Berita berhasil disimpan!'),
                                                content: SingleChildScrollView(
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                    Text('Username: $_name'),
                                                    Text('Email: $_email'),
                                                    Text('Password: $_password'),
                                                    ],
                                                ),
                                                ),
                                                actions: [
                                                TextButton(
                                                    child: const Text('OK'),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      _formKey.currentState!.reset();
                                                    },
                                                ),
                                                ],
                                            );
                                            },
                                        );

                                        }
                                    },
                                    child: const Text(
                                        "Simpan",
                                        style: TextStyle(color: Colors.white),
                                    ),
                                    ),
                                ),
                            ),

                            

                        ],
                    ),


                ), // membuat scrollable

            ),
        );
    }
}