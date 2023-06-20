// import 'dart:io';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:sqflite/sqflite.dart';
//
// class DatabaseHelper{
//   static const dbName = 'myDatabase.db';
//   static const dbversion = 1;
//   static const dbTable = 'myTable';
//   static const columnId = 'id';
//   static const columnName = 'nmae';
//   static final DatabaseHelper instance = DatabaseHelper();
//   static Database? _database;
//   Future<Database?> get database async{
//     _database  = await initDb();
//       return _database;
//
//   }
//   initDb()async{
//     Directory directory = await getApplicationDocumentsDirectory();
//     String path = join(directory.path , dbName);
//     return await openDatabase(path,version: dbversion,onCreate: onCreate);
//   }
//   Future onCreate(Database db , int version) async{
//     db.execute(
//     '''
//     CREATE TABLE $dbTable (
//     $columnId INTEGER PRIMARY KEY
//     $columnName TEXT NOT NULL
//     ) '''
//     );
//
//   }
//   inserRecord(Map<String,dynamic>row) async{
//     Database? db = await instance.database;
//     return db?.insert(dbTable, row);
//   }
//   Future<List<Map<String,dynamic>>?> queryRecord()async{
//     Database? db = await instance.database;
//     return await db?.query(dbTable);
//   }
//   Future<int?> updateRecord(Map<String,dynamic>row)async{
// Database? db = await instance.database;
// int id = row[columnId];
// return await db?.update(dbTable, row , where: '$columnId=?',whereArgs: [id]);
//   }
//   Future<int?>deleteRecord(int id)async{
//     Database? db = await instance.database;
//     return await db?.delete(dbTable,where: '$columnId=?',whereArgs: [id]);
//   }
// }
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