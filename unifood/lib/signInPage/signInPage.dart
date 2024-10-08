import 'package:flutter/material.dart';
import 'authenticator.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:unifood/DemoLocalizations.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      onGenerateTitle: (context) => DemoLocalizations.of(context).title,
      localizationsDelegates: const [
        DemoLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: DemoLocalizations.languages().map((String language) => Locale(language)).toList(),
      // Authenticating the user
      home: const AuthGate(),
    );
  }
}
