import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import '../DemoLocalizations.dart';
import 'homePage.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Built in sign-in page builder for flutter/firebase
    // Allows for authentication of user
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            providers: [
              // Authenticators for google and custom firebase account(s)
              EmailAuthProvider(),
              GoogleProvider(
                  clientId:
                      "159632032979-lgj57bgior0tuqg5b0cph98fg5so6134.apps.googleusercontent.com"),
            ],
            headerBuilder: (context, constraints, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('assets/flutter.png'),
                ),
              );
            },
            // Text to give sign-in/sign-up information
            subtitleBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: action == AuthAction.signIn
                    // Sign in or sign up depending on current page
                    ? Text(DemoLocalizations.of(context).signin)
                    : Text(DemoLocalizations.of(context).signup)
              );
            },
            footerBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(DemoLocalizations.of(context).termsAndConditions,
                  style: const TextStyle(color: Colors.grey),
                ),
              );
            },
          );
        }
        // only after the user has logged in, it directs them to the home page of the app
        return MyHomePage(title: DemoLocalizations.of(context).uniFood);
      },
    );
  }
}
