import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'GroceryItem.dart';

// CODE FOR THE DATABASE AUXILIARY CLASS.
// Essentially, this class communicates with the database created with SQFLITE.


class GroceryItemModeler
{
  final table = 'groceryitems';
  void insertGroceryItem(GroceryItem groceryItem) async
  {
    final db = await DBUtils.init();
    await db.insert(
      'groceryitems',
      groceryItem.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List> getAllGroceryItems() async
  {
    final db = await DBUtils.init();
    final List items = await db.query('groceryitems');
    List result = [];
    if(items.isNotEmpty) {
      for (int i = 0; i < items.length; i++) {
        result.add(GroceryItem.fromMap(items[i]));
      }
    }
    return result;
  }

  Future getGroceryItem(int id) async
  {
    final db = await DBUtils.init();
    final List result = await db.query(
      'groceryitems',
      where: 'id = ?',
      whereArgs: [id],
    );
    if(result.isNotEmpty)
      {
        return (GroceryItem.fromMap(result.first));
      }
    else
      {
        debugPrint("QUERY FROM GETGROCERYITEM IS NULL");
      }

  }

  Future<int> updateGrocery(GroceryItem groceryItem) async
  {
    final db = await DBUtils.init();
    return db.update(
      'groceryitems',
      groceryItem.toMap(),
      where: 'id = ?',
      whereArgs: [groceryItem.id]
    );
  }

  // Future<int> deleteGrocery(int id) async
  // {
  //   final db = await DBUtils.init();
  //   return db.delete(
  //     'groceryitems',
  //     where: 'id = ?',
  //     whereArgs: [id]
  //   );
  // }

  Future<void> deleteGrocery(List ids) async
  {
    final db = await DBUtils.init();
    for(int id in ids)
      {
        db.delete(
          'groceryitems',
          where: 'id = ?',
          whereArgs: [id]
        );
      }
  }

  Future<int> deleteTable() async
  {
    final db = await DBUtils.init();
    return db.delete('groceryitems');
  }

}

class DBUtils{
  static Future init() async
  {
    var database = openDatabase(
      path.join(await getDatabasesPath(), 'groceryitem3_database.db'),
      onCreate: (db, version)
        {
          db.execute(
            'CREATE TABLE groceryitems(id INTEGER PRIMARY KEY, name TEXT, quantity INTEGER)' // MAKE NOT NULL the text and quantity
          );
        },
      version: 1,
    );
    // print('Created DB $database');
    return database;
  }
}