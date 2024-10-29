import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unifood/groceryPage/GroceryItem.dart';
import 'package:unifood/groceryPage/GroceryItemModeler.dart';
import 'package:unifood/groceryPage/NutritionSummary.dart';
import 'package:unifood/groceryPage/submitForm.dart';
import 'package:unifood/pantry/pantryItems.dart';

import '../DemoLocalizations.dart';
import '../pantry/firebaseModel.dart';

class GroceryListPage extends StatefulWidget {
  const GroceryListPage({super.key});

  @override
  State<StatefulWidget> createState() => _GroceryListPageState();
}

class _GroceryListPageState extends State<GroceryListPage> {
  PantryFirebase pantryModel = PantryFirebase();
  final GroceryItemDatabase = GroceryItemModeler(); // Database
  // List containing all of the groceryItems
  List items = [];

  // List that is going to be displayed to the screen.
  // There is two lists because filtered_items can be updated according to the different features.
  List filtered_items = [];

  // List used for determining whether a listview needs to display
  // the text in strikethrough fashion or not.
  List<bool> toggleList = [];

  // The indexes of the items selected are to be stored here.
  // Used with the deleteSelected.
  List<int> selectedItems = [];

  //email of user
  String? userEmail;

  @override
  void initState() {
    super.initState();
    getGroceryItems();
    getCurrentUserEmail();
  }

  Future<String?> getCurrentUserEmail() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      setState(() {
        userEmail = user.email; // Set the email of the current user
      });
    }
    return userEmail;
  }

  // BUILD FUNCTION
  // 3 Icon buttons that for adding, deleting, and displaying the total nutritional summary
  // of the groceryItems.
  // It has a TextField used to update filtered_items according to the input. (matches name)
  // Listview builder builds a listview with listtiles with title(name of item), subtitle (quantity)
  // and an icon at the end that can be clicked to select that listview.
  // Also a floating button to complete the purchase and move items into the pantry.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          DemoLocalizations.of(context).groceryList,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              addGroceryItem();
            },
            icon: const Icon(Icons.add, color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              deleteSelected();
            },
            icon: const Icon(Icons.delete, color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              summary(items);
            },
            icon: const Icon(Icons.summarize, color: Colors.white),
          ),
        ],
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
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: filterList,
              decoration: InputDecoration(
                labelText: DemoLocalizations.of(context).search,
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                fillColor: Colors.white,
                filled: true,
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2.0),
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2.0),
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered_items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: toggleList[index]
                      ? Text(
                          filtered_items[index].name!,
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        )
                      : Text(filtered_items[index].name!,
                          style: const TextStyle(color: Colors.black)),
                  subtitle: Text(filtered_items[index].quantity!.toString(),
                      style: const TextStyle(color: Colors.grey)),
                  trailing: IconButton(
                    icon: toggleList[index]
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.circle_outlined,
                            color: Colors.green),
                    onPressed: () {
                      setState(() {
                        toggleIcon(index);
                        toggleSelected(index);
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showCompleteDialog(context),
        label: Text(
          DemoLocalizations.of(context).complete,
          style: const TextStyle(color: Colors.white),
        ),
        icon: const Icon(
          Icons.done_all,
          color: Colors.white,
        ),
        backgroundColor: Colors.green,

      ),
    );
  }

  // Dialog for confirming the "Completion" of task.
  Future<String?> showCompleteDialog(BuildContext context) async {
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(DemoLocalizations.of(context).emptyComplete),
          duration: const Duration(seconds: 2),
        ),
      );
    }
    else
      {
        return showDialog<String>(
          context: context,
          builder: (BuildContext context_2) => AlertDialog(
            title: Text(DemoLocalizations.of(context).finishTitle),
            content: Text(DemoLocalizations.of(context).finishDescription),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context_2, 'Cancel'),
                child: Text(DemoLocalizations.of(context).cancel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context_2, 'Yes');
                  passToPantry();
                },
                child: Text(DemoLocalizations.of(context).yes),
              ),
            ],
          ),
        );
      }
    return null;
  }

  // DATABASE FUNCTIONS
  // These functions are used to call the functions in the MODELER which connects to the DATABASE.
  // addGroceryItem() will open a new MaterialPageRoute to insert values.
  void addGroceryItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
        MaterialPageRoute(builder: (context) => SubmitForm()));
    if (newItem != null) {
      if (items.any((element) => element.name == newItem.name)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(DemoLocalizations.of(context).alreadyInGrocery),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        setState(() {
          GroceryItemDatabase.insertGroceryItem(newItem);
          getGroceryItems();
        });
      }
    }
  }

  // Get GroceryItems from database.
  void getGroceryItems() async {
    items = await GroceryItemDatabase.getAllGroceryItems();
    setState(() {
      filtered_items = items;
      toggleList = List.filled(filtered_items.length, false);
    });
  }

  // Deletes Selected items.
  Future<void> deleteSelected() async {
    if (selectedItems.isNotEmpty) {
      GroceryItemDatabase.deleteGrocery(selectedItems);
      selectedItems = [];
      setState(() {
        getGroceryItems();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(DemoLocalizations.of(context).deleteWarning),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // "Completes the Task" and sends the selected items into the Pantry database.
  // It also checks for no duplicates as requirement for Pantry database.
  Future<void> passToPantry() async {
    List pantryFromDatabase = await loadPantry(userEmail!);
    List wantToAdd = [];
    for (int id in selectedItems) {
      final GroceryItem grocery = await GroceryItemDatabase.getGroceryItem(id);
      final PantryItem pantry = PantryItem(
        userId: userEmail,
        name: grocery.name,
        count: grocery.quantity,
        selectedDate: DateTime.now(),
      );
      wantToAdd.add(pantry);
    }
    bool flag = findDuplicates(pantryFromDatabase, wantToAdd);
    if (flag) // If has duplicates, show message.
        {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(DemoLocalizations.of(context).alreadyInPantry),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      for (var pantry in wantToAdd) {
        await pantryModel.insertPantryItem2(pantry, userEmail!);
      }
      deleteSelected();
    }
  }

  // Aux function to find duplicates between 2 lists.
  bool findDuplicates(List A, List B) {
    bool hasDuplicates = false;
    for (var objA in A) {
      if (B.any((var obj2) => obj2.name == objA.name)) {
        hasDuplicates = true;
        break;
      }
    }
    return hasDuplicates;
  }

  // Function to load items from Pantry database.
  Future<List<PantryItem>> loadPantry(String userId) async {
    var completer = Completer<List<PantryItem>>();

    FirebaseFirestore.instance
        .collection('pantry_items_$userEmail')
        .get()
        .then((QuerySnapshot snapshot) {
      List<PantryItem> loadedItems = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final name = data['Name'] ?? '';
        final count = data['Count'] ?? 0;

        // print('Name: $name, Count: $count, UserId: $userId');

        return PantryItem(
          name: name,
          count: count,
          userId: userId,
        );
      }).toList();

      completer.complete(loadedItems);
    }).catchError((error) {
      completer.completeError(error);
    });

    return completer.future;
  }

  // Only used during development stage. Not intended to be used by user.
  Future<void> deleteALL() async {
    GroceryItemDatabase.deleteTable();
  }

  // FEATURES
  // summary will display the nutritional values of the items in the groceryList.
  Future<void> summary(List items) async {
    if (items.isNotEmpty) {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => NutritionSummary(items)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(DemoLocalizations.of(context).emptyList),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Function that prints into the console the values of nutritional value.
  // Not used in the actual app. Existence is for testing sake.
  // NOTE: THIS IS STILL BEING USED FOR THE MID-CHECK
  // Future<void> printSummary(List<GroceryItem> items)
  // async {
  //   var power = NutritionixCaller(items);
  //   var map = await power.totalSummary();
  //   for(var element in map.entries)
  //     {
  //       print(element);
  //     }
  // }

  // Search feature auxiliary function.
  // Updates filtered_items according to the query given. This function works with the searchbar.
  void filterList(String query) {
    setState(() {
      filtered_items = items
          .where(
              (item) => item.name!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // Button togglein auxiliary function.
  // Reverts the bool found at that index in toggleList.
  void toggleIcon(int index) {
    setState(() {
      toggleList[index] = !toggleList[index];
    });
  }

  void toggleSelected(int index) {
    if (selectedItems.contains(filtered_items[index].id)) {
      selectedItems.remove(filtered_items[index].id);
    } else {
      selectedItems.add(filtered_items[index].id);
    }
  }
}
