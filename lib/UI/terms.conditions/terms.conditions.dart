import 'package:flutter/material.dart';
import 'package:grapp/UI/const/const.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../auth/auth_wrapper.dart';

class TermsAndConditions extends StatefulWidget {
  const TermsAndConditions({super.key});

  @override
  State<TermsAndConditions> createState() => _TermsAndConditionsState();
}

class _TermsAndConditionsState extends State<TermsAndConditions> {
  final prefs = SharedPreferences.getInstance();
  bool value = false;

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
