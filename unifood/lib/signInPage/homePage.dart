import 'package:flutter/material.dart';
import 'package:unifood/DemoLocalizations.dart';
import 'package:unifood/signInPage/profilePage.dart';
import '../FoodMap/foodMapPage.dart';
import '../groceryPage/GroceryListPage.dart';
import '../pantry/pantryPage.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// Home page with all pages in the bottom navigation bar
class _MyHomePageState extends State<MyHomePage> {
  int currentPageIndex = 0;

  // list of pages
  final List<Widget> pages = [
    const FoodMapPage(),
    const GroceryListPage(),
    const PantryPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentPageIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index)
        {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: <Widget>[
          NavigationDestination(icon: const Icon(Icons.map), label: DemoLocalizations.of(context).map),
          NavigationDestination(icon: const Icon(Icons.local_grocery_store), label: DemoLocalizations.of(context).grocery),
          NavigationDestination(icon: const Icon(Icons.kitchen), label: DemoLocalizations.of(context).pantry),
          NavigationDestination(icon: const Icon(Icons.account_circle), label: DemoLocalizations.of(context).userProfile)
        ],
        indicatorColor: Colors.green,
      ),
    );
  }
}
