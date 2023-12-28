import 'package:flutter/material.dart';
import 'package:grapp/UI/auth/forgot.pass.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'UI/auth/auth_wrapper.dart';
import 'UI/auth/sign_up.dart';
import 'UI/onbording.dart';
import 'UI/terms.conditions/terms.conditions.dart';
import 'UI/terms.conditions/terms.conditions.front.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final showHome = prefs.getBool('showHome') ?? false;
  await Firebase.initializeApp();
  runApp(MyApp(showHome: showHome));
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  final bool showHome;
  const MyApp({Key? key, required this.showHome}) : super(key: key);

  // This widget is the root of your application.
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Grave Mapping',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/signup': (context) => SignUpPage(),
        '/forgotpass': (context) => ForgotPass(),
        '/terms_and_conditions': (context) => TermsAndConditions(),
      },
      home: showHome ? AuthWrapper() : TermsAndConditionsFront(),
    );
  }
}
