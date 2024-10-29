import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unifood/pantry/pantryItems.dart';
import 'package:unifood/pantry/firebaseModel.dart';
import 'notifications.dart';
import 'package:unifood/DemoLocalizations.dart';
import 'package:permission_handler/permission_handler.dart';

class PantryPage extends StatefulWidget {
  const PantryPage({super.key});

  @override
  State<StatefulWidget> createState() => _PantryPageState();
}

class _PantryPageState extends State<PantryPage> {
  // Instance of notifications
  Notifications noti = Notifications();

  // Instance of Firebase model class
  PantryFirebase pantryModel = PantryFirebase();

  // List of pantry items
  List<PantryItem> pantryItems = [];

  // Item name and notification date for each item
  String newItemName = '';
  DateTime selectedDate = DateTime.now();

  String?
      currentUserEmail; // Stores current logged in user's email as unique key

  // To get current logged in user
  Future<String?> getCurrentUserEmail() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      setState(() {
        currentUserEmail = user.email; // Set the email of the current user
      });
    }
    return currentUserEmail;
  }

  // Initialization for when widget is called
  @override
  void initState() {
    super.initState();
    _checkNotificationPermission();
    getCurrentUserEmail();
    if (currentUserEmail != null) {
      loadPantryItemsForUser(currentUserEmail!);
    }
  }

  // To load items for user
  void loadPantryItemsForUser(String userId) async {
    FirebaseFirestore.instance
        .collection('pantry_items_$currentUserEmail')
        .snapshots()
        .listen(
      (QuerySnapshot snapshot) {
        List<PantryItem> loadedItems = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = data['Name'] ??
              ''; // Replace null with empty string if name is null
          final count =
              data['Count'] ?? 0; // Replace null with 0 if count is null

          // Testing output
          // print('Name: $name, Count: $count, UserId: $userId');

          return PantryItem(
            name: name,
            count: count,
            userId: userId,
          );
        }).toList();

        if (mounted) {
          setState(() {
            pantryItems =
                loadedItems; // Set list to items from firestore database
          });
        }
      },
    );
  }

  void addItemForUser(String itemName, String userId) async {
    final item = PantryItem(
        userId: userId, name: itemName, count: 1, selectedDate: selectedDate);

    await pantryModel.insertPantryItem(
        item, userId); // Call the Firebase insert method

    newItemName = '';
    loadPantryItemsForUser(
        userId); // Refresh the list for the user after adding the item
    setState(() {});
  }

  void updateItemCount(String itemName, int newCount) {
    // Find the item by its name in the pantryItems list
    PantryItem itemToUpdate = pantryItems.firstWhere(
      (item) => item.name == itemName,
      orElse: () => PantryItem(),
    );

    // Update the count if the item is found
    if (itemToUpdate.name != null) {
      setState(() {
        itemToUpdate.count = newCount;
        pantryModel.updatePantryItem(
            itemToUpdate.name!, itemToUpdate.count!, currentUserEmail!);
      });
    }
  }

  // To remove items
  void removeItem(int index, String itemId) {
    final removedItem = pantryItems[index];
    setState(() {
      pantryModel.deletePantryItem(removedItem.name!,
          currentUserEmail!); // Delete the item from the database
      pantryItems.removeAt(index);
    });

    // If item is removed, give snackbar option to undo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: Text(
          '${DemoLocalizations.of(context).item} "${removedItem.name}" ${DemoLocalizations.of(context).removed}',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        action: SnackBarAction(
          label: DemoLocalizations.of(context).undo,
          onPressed: () {
            // Add item back with count = 1 and not 0
            final item = PantryItem(
                userId: currentUserEmail,
                name: removedItem.name,
                count: 1,
                selectedDate: selectedDate);
            setState(() {
              pantryModel.insertPantryItem(removedItem,
                  currentUserEmail!); // Add the item back to the database
              pantryItems.insert(index, item);
            });
          },
        ),
      ),
    );
  }
  // Checks whether the notifications permissions are on
  void _checkNotificationPermission() async {
    var status = await Permission.notification.status;
    if (!status.isGranted) {
      // If permissions are denied
      _requestNotificationPermission();
    }
  }
  // Asks for the user for notification permissions to be turned on
  // Can either allow or deny
  void _requestNotificationPermission() async {
    var status = await Permission.notification.request();
    if (!status.isGranted) {
      _showPermissionDeniedDialog();
    }
  }
  // Shows an alert dialog if permissions have been denied
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context2) {
        return AlertDialog(
          title: Text(DemoLocalizations.of(context).permDenied),
          content: Text(DemoLocalizations.of(context).permDenExp),
          actions: <Widget>[
            TextButton(
              child: Text(DemoLocalizations.of(context).ok),
              onPressed: () {
                Navigator.of(context2).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DemoLocalizations.of(context).pantryPage),
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
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: pantryItems.length,
              itemBuilder: (context, index) {
                final item = pantryItems[index];
                TextEditingController countController =
                    TextEditingController(text: item.count.toString());
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  child: Dismissible(
                    key: Key(item.name!),
                    // Unique key for each Dismissible
                    direction: DismissDirection.endToStart,
                    // Allow swipe from right to left
                    onDismissed: (direction) {
                      setState(() {
                        removeItem(index, item.name!);
                      });
                    },
                    background: Container(
                      alignment: AlignmentDirectional.centerEnd,
                      color: Colors.red, // Background color when swiping
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    child: Card(
                      color: Colors.grey[350],
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        title: Text(
                          item.name!,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${DemoLocalizations.of(context).quantity}: ${item.count}',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 3),
                                      child: GestureDetector(
                                        onTap: () {
                                            setState(() {
                                              if (item.count! > 0) {
                                              item.count = item.count! - 1;
                                              updateItemCount(
                                                  item.name!, item.count!);
                                              }
                                              if (item.count == 0) {
                                                removeItem(index, item.name!);
                                              }
                                              countController.text =
                                                  item.count.toString();

                                            });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                spreadRadius: 5,
                                                blurRadius: 12,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: const CircleAvatar(
                                            backgroundColor: Colors.red,
                                            radius: 16,
                                            child: Icon(
                                              Icons.remove,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 55),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            item.count = item.count! + 1;
                                            updateItemCount(
                                                item.name!, item.count!);
                                            countController.text =
                                                item.count.toString();
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                spreadRadius: 5,
                                                blurRadius: 12,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: const CircleAvatar(
                                            backgroundColor: Colors.green,
                                            radius: 16,
                                            child: Icon(
                                              Icons.add,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () async {

                              final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2500),
                              );
                              TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(DateTime.now().add(Duration(minutes: 1))),
                              );
                              if (pickedDate != null && pickedTime != null) {
                                DateTime finalDateTime = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );

                                // Updates the selected date for the item
                                setState(() {
                                  item.selectedDate = finalDateTime;
                                });

                                if (finalDateTime.isBefore(DateTime.now())) {
                                  // Trigger immediate notification
                                  noti.showImmediateNotificationIncorrectTime(item.name!);
                                } else {
                                  // Schedule notification for the selected time
                                  noti.scheduleNotification(item.name!, finalDateTime, context);
                                }
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.calendar_today,
                                size: 28,
                                color: Colors.green[400],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 80)
        ],
      ),
      // To add items to pantry
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          newItemName = '';
          bool itemExists = false;
          showDialog(
            context: context,
            builder: (BuildContext context2) {
              return AlertDialog(
                title: Text(DemoLocalizations.of(context).addItem),
                content: TextField(
                  // To show a hint in the input area
                  decoration: InputDecoration(
                      labelText: DemoLocalizations.of(context).itemName),
                  onChanged: (value) {
                    itemExists = pantryItems.any((item) =>
                        item.name!.toLowerCase() == value.toLowerCase());
                    newItemName = value;
                  },
                ),
                // Allow user to back out if wanted to
                actions: <Widget>[
                  TextButton(
                    child: Text(DemoLocalizations.of(context).cancel),
                    onPressed: () {
                      Navigator.of(context2).pop();
                    },
                  ),
                  //actual text in the dialog which accepts user input
                  TextButton(
                    child: Text(DemoLocalizations.of(context).add),
                    onPressed: () {
                      if (newItemName.isNotEmpty) {
                        if (!itemExists) {
                          if (currentUserEmail != null) {
                            addItemForUser(newItemName, currentUserEmail!);
                          }
                        } else {
                          noti.showImmediateNotificationInvalid(newItemName);
                        }
                        Navigator.of(context2).pop();
                      }
                    },

                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
