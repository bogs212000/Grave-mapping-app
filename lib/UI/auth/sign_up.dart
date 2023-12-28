import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grapp/UI/loading.dart';

import 'auth_wrapper.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController fname = TextEditingController();
  final TextEditingController mname = TextEditingController();
  final TextEditingController lname = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController age = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController cpassword = TextEditingController();
  bool _obscureText = true;
  String role = 'client';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      appBar: AppBar(
          title: Text('Create Account'),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Color.fromARGB(255, 5, 44, 77)),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        color: Colors.white,
        height: double.infinity,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              TextFormField(
                controller: fname,
                keyboardType: TextInputType.name,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10),
                  focusColor: Colors.blue[200],
                  hintText: "First name",
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
                controller: mname,
                keyboardType: TextInputType.name,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10),
                  focusColor: Colors.blue[200],
                  hintText: "Middle name",
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
                controller: lname,
                keyboardType: TextInputType.name,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10),
                  focusColor: Colors.blue[200],
                  hintText: "Last name",
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
                controller: age,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10),
                  focusColor: Colors.blue[200],
                  hintText: "Age",
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
                      _obscureText ? Icons.visibility : Icons.visibility_off,
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
              TextFormField(
                obscureText: _obscureText,
                controller: cpassword,
                keyboardType: TextInputType.text,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10),
                  focusColor: Colors.blue[200],
                  hintText: "Confirm password",
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
              ElevatedButton(
                onPressed: () async {
                  if (fname.text.isEmpty ||
                      mname.text.isEmpty ||
                      lname.text.isEmpty ||
                      age.text.isEmpty ||
                      email.text.isEmpty ||
                      password.text.isEmpty) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Missing Information'),
                          content: const Text('Please fill in all fields.'),
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
                  } else if (cpassword.text != password.text) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Passwords Do Not Match'),
                          content: const Text(
                              'Please make sure the passwords match.'),
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
                  } else {
                    setState(() {
                      loading = true;
                    });
                    try {
                      UserCredential userCredential = await FirebaseAuth
                          .instance
                          .createUserWithEmailAndPassword(
                        email: email.text.trim(),
                        password: password.text,
                      );
                      print('Signed in: ${userCredential.user!.uid}');
                      await FirebaseFirestore.instance
                          .collection('User')
                          .doc(email.text)
                          .set({
                        'role': role,
                        "email": email.text.trim(),
                        "first_name": fname.text,
                        "middle_name": mname.text,
                        "last_name": lname.text,
                        "age": age.text,
                      });
                      email.clear();
                      fname.clear();
                      mname.clear();
                      lname.clear();
                      age.clear();
                      password.clear();
                      cpassword.clear();
                      setState(() {
                        loading = false;
                      });
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AuthWrapper(),
                        ),
                      );
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
                            content: Text(
                                '$e'),
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
                      "Sign up",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text('Please ensure that the information you provided is correct. Your information will not be shown to others.')
            ],
          ),
        ),
      ),
    );
  }
}
