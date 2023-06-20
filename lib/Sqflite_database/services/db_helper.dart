
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart' as sql;
class SqlHelper{
  static Future<void> createTables(sql.Database database) async{
    await database.execute('''   
     CREATE TABLE item(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    title TEXT,
    description TEXT,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP)
      ''');
  }
  static Future<sql.Database>db()async{
    return sql.openDatabase('database_path',version: 1,
    onCreate: (sql.Database database , int version) async{
      await createTables(database);
    }
    );
  }
  static Future<int> createItem(String title , String description)async{
    final db = await SqlHelper.db();
    final data = {'title':title , 'description':description};
    final id = await db.insert('item', data , conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }
  static Future<List<Map<String,dynamic>>> getItems() async{
    final db = await SqlHelper.db();
    return db.query('item' , orderBy: 'id');
  }
  static Future<List<Map<String,dynamic>>> getItem(int id)async{
    final db = await SqlHelper.db();
    return db.query('item',where: 'id=?' , whereArgs: [id],limit: 1);
  }
  static Future<int> updateItem(int id , String title , String description)async{
    final db = await SqlHelper.db();
    final data = {
      'title':title,
      'description':description,
      'createdAt':DateTime.now().toString()
    };
    final result = await db.update('item', data , where: 'id = ?',whereArgs: [id]);
    return result;
  }
  static Future<void> deleteItem(int id) async{
    final db = await SqlHelper.db();
    try{
      await db.delete('item',where: 'id = ?',whereArgs: [id]);
    }catch(err){
      debugPrint("Something went wrong : ${err}");
    }
  }
}