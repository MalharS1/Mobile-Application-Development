import 'package:cloud_firestore/cloud_firestore.dart';
import 'pantryItems.dart';

// Model class to handle firebase methods
class PantryFirebase {
  // To insert items into firebase cloud storage
  Future<void> insertPantryItem(PantryItem item, String userId) async {
    // This will make sure that each user has a different pantry list
    final CollectionReference pantryCollection =
        FirebaseFirestore.instance.collection('pantry_items_$userId');

    // Sets id to a time so no repetitions/duplications of ids
    final String documentId = DateTime.now().toUtc().toIso8601String();

    // Insert with name, count (one since you have 1 amount of that item now), and the user id
    await pantryCollection.doc(documentId).set({
      'Name': item.name,
      'Count': 1,
      'userid': item.userId,
    });
  }

  Future<void> insertPantryItem2(PantryItem item, String userId) async {
    // This will make sure that each user has a different pantry list
    final CollectionReference pantryCollection =
    FirebaseFirestore.instance.collection('pantry_items_$userId');

    // Sets id to a time so no repetitions/duplications of ids
    final String documentId = DateTime.now().toUtc().toIso8601String();

    // Insert with name, count (one since you have 1 amount of that item now), and the user id
    await pantryCollection.doc(documentId).set({
      'Name': item.name,
      'Count': item.count,
      'userid': item.userId,
    });
  }

  // To get all items from firebase
  Future<List<PantryItem>> getPantryItems(String userId) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('pantry_items_$userId')
        .get();

    // Converts each document into a PantryItem
    // Factory method
    return snapshot.docs
        .map((doc) => PantryItem.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // To delete item from firebase
  Future<void> deletePantryItem(String name, String userId) async {
    // Gets the reference to that collection (for each unique user)
    final pantryRef =
        FirebaseFirestore.instance.collection('pantry_items_$userId');

    // Executes a query on the selected collection
    // Finds where name in collection is equal to the name passed to the method
    final QuerySnapshot snapshot =
        await pantryRef.where('Name', isEqualTo: name).get();

    // This deletes the first instance (since name is unique (no duplicate names allowed))
    // This will only have 1 value always for each unique collection
    await snapshot.docs[0].reference.delete();
  }

  // To update count
  Future<void> updatePantryItem(
      String name, int newCount, String userId) async {
    final pantryRef =
        FirebaseFirestore.instance.collection('pantry_items_$userId');

    final QuerySnapshot snapshot =
        await pantryRef.where('Name', isEqualTo: name).get();
    final List<QueryDocumentSnapshot> docs = snapshot.docs;

    // Checks if item even exists
    if (docs.isNotEmpty) {
      final DocumentReference<Object?> docRef = docs[0].reference;

      // Update count
      await docRef.update({
        'Count': newCount,
      });
    } else {
      print('Document not found.');
    }
  }
}
