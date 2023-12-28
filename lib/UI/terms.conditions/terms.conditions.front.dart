import 'package:flutter/material.dart';
import 'package:grapp/UI/const/const.dart';
import 'package:grapp/UI/function/fetch.dart';
import 'package:grapp/UI/onbording.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../auth/auth_wrapper.dart';

class TermsAndConditionsFront extends StatefulWidget {
  const TermsAndConditionsFront({super.key});


  @override
  State<TermsAndConditionsFront> createState() => _TermsAndConditionsFrontState();
}

class _TermsAndConditionsFrontState extends State<TermsAndConditionsFront> {
  bool value = false;

  @override
  void initState() {
    super.initState();
    fetch(); // Assuming fetch is used to initialize termsAndConditions
    checkShowHome(); // Check if showHome preference is true
  }

  void checkShowHome() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('showHome') == true) {
      // Navigate to the next page if showHome is true
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Onbording()),
      );
    }
  }

  Widget build(BuildContext context) {
    Brightness brightness = MediaQuery.of(context).platformBrightness;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Color.fromARGB(255, 5, 44, 77),
        backgroundColor: Colors.white,
        title: Text("Terms and Conditions"),
      ),
      body: Container(
          height: double.infinity,
          width: double.infinity,
          child: Stack(
            children: [
              FutureBuilder(
                future: Future.delayed(Duration(seconds: 2), () {}),
                // Simulate a delay
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // While fetching the web page, display a loading screen
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return WebView(
                      initialUrl: termsAndConditions ??
                          'https://www.freeprivacypolicy.com/live/e7a77442-c30d-4e94-a27c-4bfda170cba2',
                      // Set the URL you want to display
                      javascriptMode: JavascriptMode.unrestricted,
                      onWebResourceError: (WebResourceError webResourceError) {
                        // Handle the error here, e.g., display an error message.
                        print('Web Error: ${webResourceError.description}');
                      }, // Enable JavaScript
                    );
                  }
                },
              ),
              Container(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          left: 10, right: 10, top: 10, bottom: 5),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(
                            color: Colors.grey,
                            // Change the color as per your requirement
                            width:
                                1.0, // Change the width as per your requirement
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text('Do you agree with the Terms and Conditions?'),
                          Row(
                            children: <Widget>[
                              Checkbox(
                                value: value,
                                onChanged: (bool? newValue) {
                                  setState(() {
                                    value = newValue!;
                                  });
                                },
                              ),
                              const Text('I agree'),
                              Spacer(),
                              ElevatedButton(
                                onPressed: value
                                    ? () async {
                                  // Perform the action when the button is enabled
                                  final prefs = await SharedPreferences.getInstance();
                                  prefs.setBool('showHome', true);
                                  // ignore: use_build_context_synchronously
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => Onbording(),
                                    ),
                                  );
                                }
                                    : null, // Set onPressed to null when the button should be disabled
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
                                      "Next",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  bool _isValidEmail(String email) {
    // Regular expression for a simple email validation
    String emailRegex = r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$';
    RegExp regex = RegExp(emailRegex);
    return regex.hasMatch(email);
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Lottie.asset('assets/lottie/checkEmail.json'),
          content: Text(
              'An email containing a link to reset your password has been sent to your email address.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
