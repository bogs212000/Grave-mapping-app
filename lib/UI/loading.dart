// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: const Color.fromARGB(255, 5, 44, 77),
      child: Center(
          child: Container(
              child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SpinKitWanderingCubes(
            color: Colors.white,
          )
        ],
      ))),
    ));
  }
}
