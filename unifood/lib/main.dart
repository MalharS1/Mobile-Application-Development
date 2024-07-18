import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'signInPage/signInPage.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'firebaseServices/firebase_options.dart';

void main() async{
  // Initializing notifications and firebase
  tz.initializeTimeZones();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Root of the application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Main Page',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Assigns sign in page as home page because the user has to sign-in to explore the app
      home: const SignInPage(),
    );
  }
}