

import 'package:flutter_sqflite_provider/student_dbprovider.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  static Database? _database;
  static Future<Database> get database async {
    var path = await getDatabasesPath();
    await deleteDatabase(path);
    return _database ??= await openDatabase(
      '${path}elms.db',
      onCreate: (db, version) async {
        await db.execute(StudentDBProvider.createTable);
      },
      version: 1,
    );
    
  }
}
