import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:grapp/UI/auth/sign_up.dart';
import 'package:grapp/UI/function/fetch.dart';
import 'package:grapp/UI/loading.dart';

import '../homepage.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool _obscureText = true;
  bool loading = false;

  void initState() {
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            body: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              color: Colors.white,
              height: double.infinity,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/cemetery.png',
                    scale: 2,
                    color: Color.fromARGB(255, 5, 44, 77),
                  ),
                  const Text(
                    'Grave Mapping',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color.fromARGB(255, 5, 44, 77),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10),
                      focusColor: Colors.blue[200],
                      hintText: "Email",
                      filled: true,
                      fillColor: Colors.blue[50],
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.white)),
                      labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(20.0)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    obscureText: _obscureText,
                    controller: password,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10),
                      focusColor: Colors.blue[200],
                      hintText: "Password",
                      filled: true,
                      fillColor: Colors.blue[50],
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.white)),
                      labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(20.0)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Color.fromARGB(255, 5, 44, 77),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        loading = true;
                      });
                      try {
                        UserCredential userCredential = await FirebaseAuth
                            .instance
                            .signInWithEmailAndPassword(
                          email: email.text.trim(),
                          password: password.text,
                        );
                        print('Signed in: ${userCredential.user!.uid}');
                        email.clear();
                        password.clear();
                        setState(() {
                          loading = false;
                        });
                      } on FirebaseAuthException catch (e) {
                        print('FirebaseAuthException: $e');
                        // Handle FirebaseAuthException here
                        setState(() {
                          loading = false;
                        });
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Error'),
                              content: Text('$e'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      } catch (e) {
                        print('Error: $e');
                        // Handle other exceptions here
                        setState(() {
                          loading = false;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 5, 44, 77),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Sign In",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/forgotpass');
                          },
                          child: Text(
                            'Forgot password?',
                            style: TextStyle(color: Colors.blue),
                          )),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: Text(
                            'Create Account',
                            style: TextStyle(color: Colors.blue),
                          )),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                                context, '/terms_and_conditions');
                          },
                          child: Text(
                            'Terms and Conditions',
                            style: TextStyle(color: Colors.blue),
                          )),
                    ],
                  )
                ],
              ),
            ),
          );
  }
}
