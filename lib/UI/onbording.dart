import 'package:flutter/material.dart';
import 'package:grapp/UI/Homepage.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import 'content_model.dart';

class Onbording extends StatefulWidget {
  @override
  _OnbordingState createState() => _OnbordingState();
}

class _OnbordingState extends State<Onbording> {
  int currentIndex = 0;
  late PageController _controller;

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: contents.length,
              onPageChanged: (int index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (_, i) {
                return Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Lottie.asset(contents[i].image, height: 400),
                      Text(
                        contents[i].title,
                        style: GoogleFonts.sourceSansPro(
                            textStyle:
                                Theme.of(context).textTheme.headlineMedium,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,
                            color: Colors.black),
                      ),
                      Text(
                        contents[i].discription,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                            textStyle:
                                Theme.of(context).textTheme.headlineMedium,
                            fontSize: 20,
                            color: Colors.grey),
                      ),
                      Text(
                        contents[i].discription1,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                            textStyle:
                                Theme.of(context).textTheme.headlineMedium,
                            fontSize: 20,
                            color: Colors.grey),
                      ),
                      Text(
                        contents[i].discription2,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                            textStyle:
                                Theme.of(context).textTheme.headlineMedium,
                            fontSize: 20,
                            color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                contents.length,
                (index) => buildDot(index, context),
              ),
            ),
          ),
          Container(
            height: 60,
            margin: const EdgeInsets.all(40),
            width: double.infinity,
            child: FloatingActionButton(
              backgroundColor: const Color.fromARGB(255, 5, 44, 77),
              child: Text(
                  currentIndex == contents.length - 1 ? "Continue" : "Next"),
              onPressed: () async {
                if (currentIndex == contents.length - 1) {
                  final prefs = await SharedPreferences.getInstance();
                  prefs.setBool('showHome', true);
                  // ignore: use_build_context_synchronously

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const Homepage(),
                    ),
                  );
                }
                _controller.nextPage(
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.bounceIn,
                );
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          )
        ],
      ),
    );
  }

  Container buildDot(int index, BuildContext context) {
    return Container(
      height: 10,
      width: currentIndex == index ? 25 : 10,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}
