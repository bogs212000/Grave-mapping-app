import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grapp/UI/loading.dart';

class ForgotPass extends StatefulWidget {
  const ForgotPass({Key? key}) : super(key: key);

  @override
  State<ForgotPass> createState() => _ForgotPassState();
}

class _ForgotPassState extends State<ForgotPass> {
  final TextEditingController email = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      appBar: AppBar(
          title: Text('Forgot Password'),
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
              ElevatedButton(
                onPressed: () async {
                  if (
                      email.text.isEmpty
                      ) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Missing Information'),
                          content: const Text('Please input your Email'),
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
                      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text.trim());
                      email.clear();
                      setState(() {
                        loading = false;
                      });
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Link sent'),
                            content: Text(
                                'Please check your email.'),
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
                      "Reset",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text('Please ensure that the email you provided is correct.')
            ],
          ),
        ),
      ),
    );
  }
}
