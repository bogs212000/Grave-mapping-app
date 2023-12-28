// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grapp/UI/auth/sign_in.dart';
import 'package:grapp/UI/homepage.dart';
import 'package:lottie/lottie.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? email = FirebaseAuth.instance.currentUser?.email;
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('User')
          .doc('$email')
          .snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> userData) {
        if (!userData.hasData) {
          return Center(
            child: Lottie.asset('assets/lottie/4901-location-finding.json', width: 100, height: 100),
          );
        } else if (userData.connectionState == ConnectionState.waiting) {
          return Center(
            child: Lottie.asset('assets/lottie/4901-location-finding.json', width: 100, height: 100),
          );
        } else if (userData.hasError) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                "Something went wrong!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 231, 25, 25),
                ),
              ),
            ],
          );
        } else if (userData.hasData) {
          return Builder(
            builder: (
              context,
            ) {
              if (userData.data!['role'] == 'client') {
                return Homepage();
              } else {
                return SignInPage();
              }
            },
          );
        } else {
          return SignInPage();
        }
      },
    );
  }
}
