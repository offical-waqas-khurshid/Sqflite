import 'package:flutter/material.dart';
import 'package:flutter_sqflite_provider/student.dart';
import 'package:sqflite/sqflite.dart';

import 'db_provider.dart';

class StudentDBProvider extends ChangeNotifier {
  static const tableName = 'Student';
  static const keyRollNo = 'rollNo';
  static const keyName = 'name';
  static const keyFee = 'fee';
  List<Student> studentList = [];
  static const createTable =
      'CREATE TABLE $tableName($keyRollNo INTEGER PRIMARY KEY,$keyName TEXT,$keyFee REAL)';
  static const dropTable = 'DROP TABLE IF EXIST $tableName';

  Future<bool> insertStudent(Student student) async {
    Database database = await DBProvider.database;
    try {
      var rowID = await database.insert(tableName, student.toMap());
      notifyListeners();
      return rowID > 0;
    } on DatabaseException catch (e) {
      return false;
    }
  }

  Future<bool> updateStudent(Student student) async {
    Database database = await DBProvider.database;
    var rowID = await database.update(tableName, student.toMap(),
        where: '$keyRollNo =?', whereArgs: [student.rollNo]);
    notifyListeners();
    return rowID > 0;
  }

  Future<bool> deleteStudent(Student student) async {
    Database database = await DBProvider.database;
    var rowID = await database
        .delete(tableName, where: '$keyRollNo =?', whereArgs: [student.rollNo]);
    notifyListeners();
    return rowID > 0;
  }

  Future<List<Student>> fetchStudent() async {
    Database database = await DBProvider.database;
    var listMap = await database.query(
      tableName,
    );
    studentList = listMap.map((map) => Student.fromMap(map)).toList();
    notifyListeners();
    return studentList;
  }
}
