import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import '../DemoLocalizations.dart';
import 'signInPage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DemoLocalizations.of(context).userProfile),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.green, Color.fromARGB(120, 9, 97, 25)],
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft
              )
          ),
        ),
      ),
      body:
          // Built in Profile page for firebase
          ProfileScreen(
          actions: [
          // Built in sign out button for firebase
          SignedOutAction((context) async {
            // Navigate to the main sign-in screen after signing out
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (BuildContext context) => const SignInPage(),
              ),
              (route) => false, // Pop all existing routes
            );
          })
        ],
      ),
    );
  }
}
